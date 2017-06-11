clear; clc; close all;

filename = 'Results.xlsx';
path_in = 'C:\Users\melkiga\Google Drive\Research\Cano\MultiInstanceClassification\WekaTesting\output\';
path_out = 'C:\Users\melkiga\Google Drive\MatlabHelpers\stats_tables\';
file_path = [path_in filename];
metrics = {'accuracy','precision','recall','kappa','auc','Time'};
num_metrics = length(metrics);
alpha = 0.1;

% Get algorithm and datasets names and lengths
[~, ~, prints] = xlsread(file_path,2,'A1:L1');
prints(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),prints)) = {NaN};
algorithms = prints(2:end);
num_algorithms = length(algorithms);

[~, ~, datasets] = xlsread(file_path,2,'A2:A16');
datasets(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),datasets)) = {NaN};
datasets = datasets';
num_datasets = length(datasets);
latex_data_rows = datasets; latex_data_rows{end+1} = 'Average'; latex_data_rows{end+1} = 'Rank';

% Allocate memory
ranks = zeros(num_metrics,num_algorithms);

for m = 1:length(metrics)
    metric = metrics{m};
    disp(metric);
    
    [~, ~, data] = xlsread(file_path,metric,'B2:L16');
    data(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),data)) = {NaN};
    data = cell2mat(data);
    
    [avg_ranks,chi_statistics] = avg_rank(-data);
    ranks(m,:) = avg_ranks;
    %max_rank = round(max(avg_ranks))+1;
    %[stats,headers] = wilcoxon(data,alpha);
    
    %data(end+1,:) = mean(data);
    %data(end+1,:) = avg_ranks;
    
    %matrix2latex_metrics(data, [path_out [metric '.tex']], 'rowLabels', latex_data_rows, 'columnLabels', algorithms, 'alignment', 'c', 'format', '%-1.1f', 'rank', 'yes');
    % create results table latex
    %matrix2latex(stats, [path_out [metric '_wx.tex']], 'rowLabels', algorithms, 'columnLabels', headers, 'alignment', 'c', 'format', '%-1.4f');
    
    % create Bonferroni-Dunn CD figure
    %bonferroni_dunn_tikz([path_out [metric '_Fig.tex']],avg_ranks,1,num_algorithms,algorithms,max_rank);
    
end