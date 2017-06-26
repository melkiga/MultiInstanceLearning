clear; clc; close all;

if ispc
    disp('TODO: add paths for windows machine.');
    disp('Terminating script.'); return;
else
    path_in = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/output/';
    path_out = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/stats/';
end

metrics = {'Accuracy','Precision','Recall','Kappa','AUC','Time'};
num_metrics = length(metrics);
alpha = 0.1;
% initialize using Accuracy.csv
T = readtable([path_in metrics{1} '.csv']);
% get algorithm names
algorithms = T.Properties.VariableNames(2:end);
num_algorithms = length(algorithms);
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
    [avg_ranks,chi_statistics] = avg_rank(-data);
    ranks(m,:) = avg_ranks;
    max_rank = round(max(avg_ranks))+1;
    %[stats,headers] = wilcoxon(data,alpha);
    
    % add average + ranks to data
    data(end+1,:) = mean(data);
    data(end+1,:) = avg_ranks;
    
    % create latex table
    matrix2latex_metrics(data, [path_out [metrics{m} '.tex']], 'rowLabels', latex_data_rows, 'columnLabels', algorithms, 'alignment', 'c', 'format', '%-1.4f', 'rank', 'yes');
    % create bonferroni-dunn figure
    bonferroni_dunn_tikz([path_out [metrics{m} '_Fig.tex']],avg_ranks,1,num_algorithms,algorithms,max_rank);
end
