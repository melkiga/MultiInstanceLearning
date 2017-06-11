clear; clc; close all;

C = 10;
param = 0.2;
seed = 1;
k = 2;
rng(seed);
options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
%%%%%%%% Load Data %%%%%%%%
%bag3data; l = 1;
%loaddataoverlap; l = 1;
%loadrandommidata; l = 0;
% data_nonlin; l = 1;
% [numb_data,dim] = size(X);

[Y,X] = libsvmread('C:\Code\MIRSVM\data\suraminsvm');
%[Y,X] = libsvmread('C:\Code\MIQP\data\nonlin'); l = 1;
X = full(X);
Y(Y==2) = -1;
[numb_data, dim] = size(X);
B = X(:,2);
Bsizes = X(:,1);
X = X(:,3:dim);
[~,dim] = size(X);

%%%%%%%% Preprocess %%%%%%%%
%args = shuffle(numb_data,seed,X,Y,B);
%X = args{1}; Y = args{2}; B = args{3};
X = scale(X,0); 
X(isnan(X)) = 0;

if dim == 2 && l == 0; plot2D(X,Y,1); end

unique_bag_ids = unique(B);
numb_bags = length(unique_bag_ids);

for bl = 1:numb_bags
    bagLabels(bl,1) = Y(min(find(B == unique_bag_ids(bl))));
end

[cv] = crossvalind('Kfold',bagLabels,k);

acc = zeros(k,1);
accCV = zeros(length(C), length(param));

for c = 1:length(C)
    c0 = C(c);
    for p = 1:length(param)
        p0 = param(p);
        for i = 1:k
            if k == 1
                tr = ismember(B,unique_bag_ids);
                tst = ismember(B,unique_bag_ids);
            else
                teIdx = (cv == i); trIdx = ~teIdx;
                tr = ismember(B,unique_bag_ids(trIdx));
                tst = ismember(B,unique_bag_ids(teIdx));
            end

            Xtr = X(tr,:); Ytr = Y(tr); Btr = B(tr); 
            Xtst = X(tst,:); Ytst = Y(tst); Btst = B(tst);
            
            %%%%%%%% MISVM Training %%%%%%%%
            [alphay,bias,S,iter] = DualTrain(Xtr,Ytr,Btr,c0,p0,options);
            XS = Xtr(S,:);
            %%%%%%%% MISVM Testing %%%%%%%%
            [acc(i)] = DualTest(Xtst,XS,Ytst,Btst,alphay,bias,p0);
        end
        accCV(c,p) = mean(acc); 
    end 
end

clearvars args Btr Btst c c0 cv dim i options p p0 shift std teIds tr trIdx tst variance XS Xtr Xtst Ytr Ytst;















