function [alphay,bias,S,indSV] = MISVM(X,Y,B,C,param,options,Bsizes)

[unique_pos_bags,~] = unique(B(Y==1));
numb_pos_bags = length(unique_pos_bags);
%%%%%%%% Initialize %%%%%%%%
S_old = zeros(numb_pos_bags,1);
S = ones(numb_pos_bags,1);

for I = 1:numb_pos_bags
    Xp(I,:) = mean(X(B == unique_pos_bags(I),:));
end

Xn = [Xp; X(Y==-1,:)];
Yn = [ones(numb_pos_bags,1); Y(Y==-1)];
len_neg = length(Y(Y==-1));
nbag = numb_pos_bags + len_neg;

while(sum(S == S_old) ~= numb_pos_bags)
    S_old = S;
    H = (Yn*Yn').*grbf_fast(Xn,Xn,param);
    f = -1*ones(nbag,1);
    Aeq = Yn';
    beq = 0;
    LB = zeros(nbag,1);
    UB = ones(nbag,1)*C; 
    
    alpha = quadprog(H,f,[],[],Aeq,beq,LB,UB,[],options);
    indSV = find(1e-7 <= abs(alpha) & abs(alpha) <= (C+1e-7));
    alphay = Yn.*alpha;
    bias = (1/length(indSV))*sum(Yn(indSV) - grbf_fast(Xn(indSV,:),Xn(indSV,:),param)*alphay(indSV,1));
    %w = Xn'*alphay;
    
    offset = 0;
    for I = 1:numb_pos_bags
        o = grbf_fast(X(B == unique_pos_bags(I),:),Xn,param)*alphay + bias;
        [~,ind] = max(o);
        S(I,1) = ind+offset;
        offset = offset + Bsizes(S(I,1));
    end
    
    Xn = [X(S,:); X(Y==-1,:)];
    Yn = [ones(numb_pos_bags,1); Y(Y==-1)];
end

end