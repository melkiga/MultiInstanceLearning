%clear; clc;
warning off;
name = 'function/';
path = './data/midata/CVSets/';
n = 1;
C = 1;
param = 1;
rnum = 1;
%ii = [21:40];

Xtrain = cell(10,1); Xtest = cell(10,1);
Ytrain = cell(10,1); Ytest = cell(10,1);
Btrain = cell(10,1); Btest = cell(10,1);
Bsizes = cell(10,1);

for i = 0:9
    index = i + 1;
    [Ytrain{index},Xtrain{index}] = libsvmread([path name 'train_' num2str(i)]);
    Xtrain{index} = full(Xtrain{index});
    Ytrain{index}(Ytrain{index}==2) = -1;
    [~, dim] = size(Xtrain{index});
    Bsizes{index} = Xtrain{index}(:,1);
    Btrain{index} = Xtrain{index}(:,2);
    Xtrain{index} = Xtrain{index}(:,3:dim);
    Xtrain{index}(isnan(Xtrain{index})) = 0;
    indred = abs(sum(Xtrain{index})) < 1e-5;
    Xtrain{index}(:,indred) = [];

    [Ytest{index},Xtest{index}] = libsvmread([path name 'test_' num2str(i)]);
    Xtest{index} = full(Xtest{index});
    Ytest{index}(Ytest{index}==2) = -1;
    [numb_data, dim] = size(Xtest{index});
    Btest{index} = Xtest{index}(:,2);
    Xtest{index} = Xtest{index}(:,3:dim);
    [~,dim] = size(Xtest{index}); 
    Xtest{index}(isnan(Xtest{index})) = 0;
    Xtest{index}(:,indred) = [];
    disp(['Data ' num2str(i) ' has finished..']);
end
disp('Finished reading data...');

%% 
% n = 4;
% C = 1000;
% param = 4;
% rnum = 2;
% ii = [21:24];

if n == 1
    t0 = cputime;
    [acc, iter, precision, recall, kappa, AUC, Time] = tst(Xtrain,Ytrain,Btrain,Bsizes,Xtest,Ytest,Btest,C,param,rnum);
    t = cputime - t0;
    disp(['Finished after ' num2str(t) ' seconds.']);
else
    acc = zeros(n,1);
    iter = zeros(n,1);
    precision = zeros(n,1);
    recall = zeros(n,1);
    kappa = zeros(n,1);
    AUC = zeros(n,1);
    for i = 1:n
        t0 = cputime;
        [acc(i),iter(i), precision(i), recall(i), kappa(i), AUC(i)] = tst(Xtrain,Ytrain,Btrain,Bsizes,Xtest,Ytest,Btest,C,param,ii(i));
        t = cputime - t0;
        disp(['Iteration ' num2str(i) ' complete after ' num2str(t) ' seconds.']);
    end
end

%load gong.mat, sound(y), clearvars y;

[maxacc,indacc] = max(acc);
maxacc
iter = iter(indacc)
precision = precision(indacc)
recall = recall(indacc)
kappa = kappa(indacc)
AUC = AUC(indacc)
Time  = mean(Time)