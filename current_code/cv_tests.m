function [acc, iter, precision, recall, kappa, AUC] = cv_tests(Xtrain,Ytrain,Btrain,Bsizes,Xtest,Ytest,Btest,C,param,randomnum)
rng(randomnum);
options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
iter = zeros(10,1);
TP = zeros(10,1);
TN = zeros(10,1);
FP = zeros(10,1);
FN = zeros(10,1);

for i = 0:9
    index = i + 1;
    [alphay,bias,S,iter(index)] = DualTrain(Xtrain{index},Ytrain{index},Btrain{index},C,param,options,Bsizes{index});

    XS = Xtrain{index}(S,:);
    %%%%%%%% MISVM Testing %%%%%%%%
    [TP(index),TN(index),FP(index),FN(index)] = DualTest(Xtest{index},XS,Ytest{index},Btest{index},alphay,bias,param);
    disp(['Iteration ' num2str(i) ' complete.']);
end

TP = sum(TP);
TN = sum(TN);
FP = sum(FP);
FN = sum(FN);
numb_data = (TP + TN + FP + FN);
%%%%%%%% Results %%%%%%%%%%%%%%
acc = (TP+TN)/numb_data;
precision = TP/(TP+FP);
recall = TP/(TP+FN);
EA = (TP+FN)*(TP+FP) + (FP + TN)*(FN + TN);
kappa = (numb_data*(TP+TN) - EA)/(numb_data^2 - EA);
AUC = (1 + recall - (FP/(FP+TN)))/2;

precision(isnan(precision)) = 0;
recall(isnan(recall)) = 0;
kappa(isnan(kappa)) = 0;
AUC(isnan(AUC)) = 0;

acc = mean(acc);
iter = mean(iter);
precision = mean(precision);
recall = mean(recall);
kappa = mean(kappa);
AUC = mean(AUC);

end