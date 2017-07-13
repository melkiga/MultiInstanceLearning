clear; clc; close all;

if ispc
    disp('TODO: add paths for windows machine.');
    disp('Terminating script.'); return;
else
    path_in = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/output/';
    path_out = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/stats/';
end

metrics = {'Accuracy','Precision','Recall','Kappa','AUC','Time'};
%metrics = {'Time'};
num_metrics = length(metrics);
alpha = 0.1;
% initialize using Accuracy.csv
T = readtable([path_in metrics{1} '.csv']);
% get algorithm names
algorithms = T.Properties.VariableNames;
num_algorithms = length(algorithms)-1;
% get dataset names + latex table row names
datasets = table2cell(T(:,1));
num_datasets = length(datasets);
latex_data_rows = datasets; latex_data_rows{end+1} = 'Average'; latex_data_rows{end+1} = 'Rank'; 
ranks = zeros(num_metrics,num_algorithms);

for m = 1:num_metrics
    % get data
    T = readtable([path_in metrics{m} '.csv']);
    data = T{:,2:end};
    disp(['Analyzing ' metrics{m}]);
    
    if strmatch('Time',metrics{m})
        data2 = data;
        rank_val = 'time';
        format = '%-1.1f';
    else
        data2 = -data;
        rank_val = 'yes';
        format = '%-1.4f';
    end
    
    [avg_ranks,chi_statistics] = avg_rank(data2);
    ranks(m,:) = avg_ranks;
    max_rank = round(max(avg_ranks))+1;
    %[stats,headers] = wilcoxon(data,alpha);
    
    % add average + ranks to data
    data(end+1,:) = mean(data);
    data(end+1,:) = avg_ranks;
    
    % create latex table
    matrix2latex_metrics(data, [path_out [metrics{m} '.tex']], 'rowLabels', latex_data_rows, 'columnLabels', algorithms, 'alignment', 'c', 'format', format, 'rank', rank_val);
    % create bonferroni-dunn figure
    bonferroni_dunn_tikz([path_out [metrics{m} '_Fig.tex']],avg_ranks,1,num_algorithms,algorithms,max_rank);
end

% create latex table
disp('Analyzing Meta-Ranks');
[avg_ranks,~] = avg_rank(ranks);
ranks(end+1,:) = mean(ranks);
ranks(end+1,:) = avg_ranks;
max_rank = round(max(avg_ranks))+1;
rank_val = 'time';
format = '%-1.4f';
metrics{end+1} = 'Average'; metrics{end+1} = 'Rank'; 

matrix2latex_metrics(ranks, [path_out 'metaranks.tex'], 'rowLabels', metrics, 'columnLabels', algorithms, 'alignment', 'c', 'format', format, 'rank', rank_val);
bonferroni_dunn_tikz([path_out 'metaranks_Fig.tex'],avg_ranks,1,num_algorithms,algorithms,max_rank);