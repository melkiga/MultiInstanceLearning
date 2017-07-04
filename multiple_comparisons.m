clear; clc; close all;

if ispc
    disp('TODO: add paths for windows machine.');
    disp('Terminating script.'); return;
else
    path_in = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/stats/';
    path_out = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/stats/';
end

metrics = {'Accuracy','Precision','Recall','Kappa','AUC','Time'};
%metrics = {'accuracy'};
num_metrics = length(metrics);
alpha = 0.1;
% initialize using Accuracy.csv
T = readtable([path_in metrics{1} '_pVal.csv']);
% get algorithm names
algorithms = {'MIRSVM vs.'};
algorithms(2:size(T(:,1),1)+1) = table2cell(T(:,1));
num_algorithms = length(algorithms);
% get dataset names + latex table row names
methods = {'Nemenyi $p$-value', 'Holm $p$-value', 'Shaffer $p$-value'};

for m = 1:num_metrics
    % get data
    T = readtable([path_in metrics{m} '_pVal.csv']);
    data = T{:,2:end}'; 
    disp(['Analyzing ' metrics{m}]);
    % create latex table
    matrix2latex_metrics(data, [path_out [metrics{m} '_pV.tex']], 'rowLabels', methods, 'columnLabels', algorithms, 'alignment', 'c', 'format', '%1.4f', 'rank', 'no');
end