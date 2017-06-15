function [acc,iter,precision,recall,kappa,AUC,sums,numb_bags] = mirsvm_script(path,name,C,param,rnd,p)
% [acc,iter,precision,recall,kappa,AUC] = mirsvm_script('Google Drive/data/midata/libsvm/','musk1',1000,4.6,1,1)

rng('default'); rng(rnd); 
options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');

[Y,X] = libsvmread([path name]); X = full(X);  Y(Y==2) = -1;
B = X(:,2); Bsizes = X(:,1); X = X(:,3:end); X = scale(X,2); X(isnan(X)) = 0;
[unique_bag_ids,~] = unique(B);
numb_bags = length(unique_bag_ids);
% train
[alphay,bias,S,iter,sums] = DualTrain(X,Y,B,C,param,options,Bsizes);
XS = X(S,:);
% test
[TP,TN,FP,FN] = DualTest(X,XS,Y,B,alphay,bias,param);
num_data = (TP + TN + FP + FN);

acc = (TP+TN)/num_data;
precision = TP/(TP+FP);
recall = TP/(TP+FN);
EA = (TP+FN)*(TP+FP) + (FP + TN)*(FN + TN);
kappa = (num_data*(TP+TN) - EA)/(num_data^2 - EA);
AUC = (1 + recall - (FP/(FP+TN)))/2;

if p == 1
    fig = figure; plot(sums); hold on; title(name,'Interpreter','latex'); 
    grid minor; xlabel('Iterations','Interpreter','latex'); ylabel('Equal Representatives','Interpreter','latex');
    plot(numb_bags.*ones(length(sums),1),'r'); axis([1 length(sums) 1 numb_bags+1]);
    set(gca,'fontsize',11);
    set(gca,'TickLabelInterpreter', 'latex');
    print(fig,name,'-dpng');
end


%disp('[acc,iter,precision,recall,kappa,AUC] = mirsvm_script(path,name,C,param,rnd,p)');
end
