cclear;
path = 'C:\Users\melkiga\Google Drive\data\midata\libsvm';
datasets = dir(path);
datasets([1:2 3 7 16],:) = [];
C = [0.1 1 10 100 1000];
Sigma = [0.05 0.1 0.5 1 2.5 5 7 10 15];
acc = zeros(length(C),length(Sigma));

fid = fopen('best_vars.txt','w+');
fprintf(fid,'Dataset, C, Sigma, Iter, Accuracy, Precision, Recall, Kappa, AUC\n');
j = 1;
for data = datasets'
    for c = 1:length(C)
        for s = 1:length(Sigma)
            [acc(c,s)] = mirsvm_script([path '\'],data.name,C(c),Sigma(s),1,0);
        end
    end
    [max_val,indBestC,indBestSigma] = best_svm_params(acc);
    BestC(j) = C(indBestC); BestS(j) = Sigma(indBestSigma);
    [acc,iter,precision,recall,kappa,AUC] = mirsvm_script([path '\'],data.name,C(indBestC),Sigma(indBestSigma),1,1);
    fprintf(fid,'%s, %.4f, %.4f, %d, %.4f, %.4f, %.4f, %.4f, %.4f\n'...
           ,data.name,C(indBestC),Sigma(indBestSigma),iter,acc,precision,recall,kappa,AUC);
    j = j + 1;
end
fclose(fid);

%%
fid = fopen('best_rand_vars.txt','w+');
fprintf(fid,'Dataset, C, Sigma, Iter, Accuracy, Precision, Recall, Kappa, AUC, RND\n');
BestC = [1 0.1 0.1 0.1 1 0.1 1 100 0.1 0.1 1 0.1];
BestS = [0.5 0.5 0.5 5 1 0.1 0.5 0.05 10 1 0.1 0.1];
j = 1;
for data = datasets'
    for i = 1:10
        [acc,iter,precision,recall,kappa,AUC] = mirsvm_script([path '\'],data.name,BestC(j),BestS(j),i,0);
        fprintf(fid,'%s, %.4f, %.4f, %d, %.4f, %.4f, %.4f, %.4f, %.4f, %d\n'...
           ,data.name,C(indBestC),Sigma(indBestSigma),iter,acc,precision,recall,kappa,AUC);
    end
    j = j + 1;
end
fclose(fid);