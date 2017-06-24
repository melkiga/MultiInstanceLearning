% Create Excel File
cclear;
% get dataset names
path_data = '/Users/gabriellamelki/Google Drive/data/midata/libsvm/';
Datasets = dir([path_data '*']);
Datasets(1:2,:) = []; Datasets = {Datasets.name}';
path = '/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/output/';
%names = {'miGraph'};
names = {'MIRSVM','MIBoost','MIOptimalBall','MIDD','MIWrapper','MISMO','MISVM','SimpleMI','TLC','Bagging','Stacking','miGraph'};
% metrics
metrics = {'Accuracy','Precision','Recall','Kappa','AUC','Time'};
ind = [11,2,15,6,7,14,13,9,10,8,12,3,4,1,5];
% initialize table
T = table;
T.Datasets = Datasets(ind);
for m = 1:length(metrics)   % for each metric, build a table
    sheet = m;
    for n = 1:length(names) % for each algorithm
        folder = names{n};
        
        if strcmp(folder,'MIRSVM')
            results = xlsread('./output/Results.xlsx',metrics{m},'B2:B16');
        else
            files = dir([path folder '/*.txt']); files = {files.name}';
            disp(['Reading ' folder]);
            for f = 1:length(files) % for each dataset result
                [resFile, ~] = fopen([path folder '/' files{f}],'r');
                resText = fscanf(resFile,'%s');
                fclose(resFile);

                TP = regexp(resText,'TP=(\d+[.\d+]+)','tokens'); TP = str2double(TP{1});
                FP = regexp(resText,'FP=(\d+[.\d+]+)','tokens'); FP = str2double(FP{1});
                TN = regexp(resText,'TN=(\d+[.\d+]+)','tokens'); TN = str2double(TN{1});
                FN = regexp(resText,'FN=(\d+[.\d+]+)','tokens'); FN = str2double(FN{1});
                traintime = regexp(resText,'TrainTime=(\d+[.\d+]+)','tokens'); traintime = str2double(traintime{1});
                testtime = regexp(resText,'TestTime=(\d+[.\d+]+)','tokens'); testtime = str2double(testtime{1});
                time = (traintime + testtime)/2;

                num = (TP+FP+TN+FN);
                switch metrics{m}
                    case 'Accuracy'
                        accuracy = (TP+TN)/num;
                        results(f,1) = accuracy;
                    case 'Precision'
                        precision = TP/(TP+FP);
                        if TP + FP == 0
                            precision = 1;
                        end
                        results(f,1) = precision;
                    case 'Recall'
                        recall = TP/(TP+FN);
                        if TP + FN == 0
                            recall = 1;
                        end
                        results(f,1) = recall;
                    case 'Kappa'
                        EA = (TP+FN)*(TP+FP) + (FP + TN)*(FN + TN);
                        kappa = (num*(TP+TN) - EA)/(num^2 - EA);
                        results(f,1) = kappa;
                    case 'AUC'
                        AUC = (1+(TP/(TP+FN)) - (FP/(FP+TN)))/2;
                        results(f,1) = AUC;
                    case 'Time'
                        results(f,1) = time;
                end
            end
            results = results(ind);
        end         
        eval(sprintf('T.%s=results;',folder));
    end
    writetable(T,[path metrics{m} '.csv']);
    %excel = table2array(T(1:end,2:end));
    %xlswrite([path 'Results_new.xlsx'],metrics{m},'B2:L16');
    clearvars T; T = table; T.Datasets = Datasets(ind);
end
