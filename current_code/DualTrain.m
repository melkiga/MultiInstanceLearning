function [alphay,bias,S,iter,sums,tracc] = DualTrain(X,Y,B,C,param,options,Bsizes)

[unique_bag_ids,~] = unique(B);
numb_bags = length(unique_bag_ids);
%%%%%%%% Initialize %%%%%%%%
S = []; S_old = zeros(numb_bags,1); ytrain = zeros(numb_bags,1);

offset = 0;
for I = 1:numb_bags
    temp = X(B == unique_bag_ids(I),:);
    len = length(temp(:,1));
    ind = randi(len,1,1);
    S(I,:) = ind+offset;
    offset = offset + len;
end

Xn = X(S,:); Yn = Y(S); Bn = B(S);
%%%%%%%% Compute QP Solution %%%%%%%%
iter = 1; scurrent = 1; max_iter = numb_bags;
while(iter <= max_iter)%(scurrent ~= numb_bags && iter < numb_bags)
    S_old = [S_old S];
    H = (Yn*Yn').*GaussianKernel(Xn,Xn,param);
    f = -1*ones(numb_bags,1);
    Aeq = Yn';
    beq = 0;
    LB = zeros(numb_bags,1);
    UB = ones(numb_bags,1)*C; 
    
    alpha = quadprog(H,f,[],[],Aeq,beq,LB,UB,[],options);
    indSV = find(1e-7 <= abs(alpha) & abs(alpha) <= (C+1e-7));
    alphay = Yn.*alpha;
    bias = (1/length(indSV))*sum(Yn(indSV) - grbf_fast(Xn(indSV,:),Xn(indSV,:),param)*alphay(indSV));
    
    offset = 0;
    for I = 1:numb_bags
        o = GaussianKernel(X(B == Bn(I),:),Xn,param)*alphay + bias;        
        o(abs(o) <= 1e-5) = NaN;
        [ytrain(I),ind] = max(o);
        ytrain(I) = sign(ytrain(I));
        S(I,1) = ind+offset;
        offset = offset + Bsizes(S(I,1));
    end
    Xn = X(S,:); Yn = Y(S); Bn = B(S);
    sums(iter) = sum(S_old(:,iter) == S);
    tracc(iter) = 100*(sum(ytrain == Yn))/numb_bags;
    scurrent = sums(iter);
    iter = iter + 1;
end
%figure, plot(sums); hold on; title('Sums'); grid on;
%S = S_old(:,ind_max);
%alphay = alphay(:,ind_max);
%bias = bias(ind_max);

end