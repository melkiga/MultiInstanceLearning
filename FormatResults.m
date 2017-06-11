% Create Excel File
clear; clc; close all;

% Get algorithm names
path = 'C:\Users\melkiga\Google Drive\Research\Cano\MultiInstanceClassification\WekaTesting\output\';
names = getList(path,'.');
excelFile = [path 'Results.xlsx'];

%metrics = {'Accuracy','Precision','Recall','Kappa','AUC'};
metrics = {'Accuracy'};
algorithms = {'MIRSVM','MIBoost','MIOptimalBall','MIDD','MIWrapper','MISMO','MISVM','SimpleMI','TLC','Bagging','Stacking'};
line1 = {'Dataset','MIRSVM','MIBoost','MIOptimalBall','MIDD','MIWrapper','MISMO','MISVM','SimpleMI','TLC','Bagging','Stacking'};
columns = {'B','C','D','E','F','G','H','I','J','K','L'};
ImportTime
data = DataSet(1:15);
clearvars DataSet;

for m = 1:length(metrics)
    sheet = metrics{m};
    xlswrite(excelFile,line1,sheet,'A1');
    xlswrite(excelFile,data,sheet,'A2:A16');
    
    for a=2:length(algorithms)
        ind = strmatch(algorithms{a},Algorithm);
        ind2 = strmatch(algorithms{a},algorithms);
        m_vals = round(Time(ind,m),4);
        range = strjoin([columns(ind2) '2:' columns(ind2) '16'],'');
        xlswrite(excelFile,m_vals,sheet,range);
    end
end


