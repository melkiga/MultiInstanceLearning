warning off;
name = 'elephant/';
path = '/Users/gabriellamelki/Google Drive/data/midata/CVSets/';
num = 10; C = 1000; param = 4.5; randomnum = 6;

TP = zeros(num,1); TN = zeros(num,1); FP = zeros(num,1); FN = zeros(num,1);
Time = zeros(num,1);

options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
rng(randomnum);

for i = 0:9
    index = i + 1;
    [Ytrain, Xtrain] = libsvmread([path name 'train_' num2str(i)]);
    Xtrain = full(Xtrain);
    Ytrain(Ytrain==2) = -1;
    [~, dim] = size(Xtrain);
    Bsizes = Xtrain(:,1);
    Btrain = Xtrain(:,2);
    Xtrain = Xtrain(:,3:dim);
    Xtrain(isnan(Xtrain)) = 0;

    [Ytest,Xtest] = libsvmread([path name 'test_' num2str(i)]);
    Xtest = full(Xtest);
    Ytest(Ytest==2) = -1;
    [~, dim] = size(Xtest);
    Btest = Xtest(:,2);
    Xtest = Xtest(:,3:dim);
    [~,dim] = size(Xtest); 
    Xtest(isnan(Xtest)) = 0;
    disp(['Reading data ' num2str(i) ' has finished..']);
    
    % Training
    t0 = cputime;
    [alphay,bias,S] = DualTrain(Xtrain,Ytrain,Btrain,C,param,options,Bsizes);
    t = cputime - t0;
    XS = Xtrain(S,:);
    % Testing
    tt0 = cputime;
    [TP(index),TN(index),FP(index),FN(index)] = DualTest(Xtest,XS,Ytest,Btest,alphay,bias,param);
    tt = cputime - tt0;
    Time(index) = t + tt;
end

% Results

TP = sum(TP);
TN = sum(TN);
FP = sum(FP);
FN = sum(FN);
numb_data = (TP + TN + FP + FN);

acc = (TP+TN)/numb_data
precision = TP/(TP+FP);
recall = TP/(TP+FN);
EA = (TP+FN)*(TP+FP) + (FP + TN)*(FN + TN);
kappa = (numb_data*(TP+TN) - EA)/(numb_data^2 - EA);
AUC = (1 + recall - (FP/(FP+TN)))/2;
Time = mean(Time)
