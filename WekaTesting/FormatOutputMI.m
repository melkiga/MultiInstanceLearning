% Create Excel File
clear; clc; close all;

% Get algorithm names
path = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/output/';
alg_names = dir(path); alg_names([1:4 6 13:14]) = [];
names = getList(path,'.');

metrics = {'Precision','Recall'};

% Create Excel File
fold = 0;
excelFile = [path 'ResultsPR.xlsx'];
sheet = 1;
startRange = 2;
xlRange = ['B' num2str(startRange)];

%[status,~] = xlswrite(excelFile,{'Algorithm','DataSet','NumData','Accuracy','Precision','Recall','Kappa','AUC'},sheet,'A1');
[status,~] = xlswrite(excelFile,{'Algorithm','DataSet','Time'},sheet,'A1');

for n = 1:length(names)
    folder = names{n};
    files = getList([path folder '\*.txt'],'');
    disp(['Reading ' folder]);
    for f = 1:length(files)
        line{1} = folder;
        [resFile, ~] = fopen([path folder '\' files{f}],'r');
        resText = fscanf(resFile,'%s');
        fclose(resFile);
        line{2} = files{f};
        disp(['Reading ' files{f}]);
        
        TP = regexp(resText,'TP=(\d+[.\d+]+)','tokens'); TP = str2double(TP{1});
        FP = regexp(resText,'FP=(\d+[.\d+]+)','tokens'); FP = str2double(FP{1});
        TN = regexp(resText,'TN=(\d+[.\d+]+)','tokens'); TN = str2double(TN{1});
        FN = regexp(resText,'FN=(\d+[.\d+]+)','tokens'); FN = str2double(FN{1});
        traintime = regexp(resText,'TrainTime=(\d+[.\d+]+)','tokens'); traintime = str2double(traintime{1});
        testtime = regexp(resText,'TestTime=(\d+[.\d+]+)','tokens'); testtime = str2double(testtime{1});
        time = (traintime + testtime)/2;
        
        num = (TP+FP+TN+FN);
        accuracy = (TP+TN)/num;
        precision = TP/(TP+FP);
        recall = TP/(TP+FN);
        EA = (TP+FN)*(TP+FP) + (FP + TN)*(FN + TN);
        kappa = (num*(TP+TN) - EA)/(num^2 - EA);
        AUC = (1+(TP/(TP+FN)) - (FP/(FP+TN)))/2;
        
        precision(isnan(precision)) = 1;
        recall(isnan(recall)) = 1;
        
        %results = [num accuracy precision recall kappa AUC];
        results = time;
        
        for m = 1:length(metrics)
            line{2+m} = results(m);
        end
        [status,message] = xlswrite(excelFile,line,sheet,xlRange);
        if(status == 0)
            disp(message);
            return;
        end
        startRange = startRange + 1;
        xlRange = ['A' num2str(startRange)];
        line = {};
    end
    

end