clear; clc; close all;
C = 1000;
param = 2;
seed = 1;
rng(seed);
options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');
%%%%%%%% Load Data %%%%%%%%
%bag3data; l = 1;
%loaddataoverlap; l = 1;
%loadrandommidata; l = 0;
%data_nonlin; l = 1;
%[numb_data,dim] = size(X);
% l = 0;
% [Y,X] = libsvmread('C:\Code\MIQP\data\nonlin');
% X = full(X);
% Y(Y==2) = -1;
% [numb_data,dim] = size(X);
% B = X(:,2);
% Bsizes = X(:,1);
% X = X(:,3:dim);
% [~,dim] = size(X);

[Y,X] = libsvmread('./Research/Cano/MultiInstanceClassification/musk1svm');
X = full(X);
Y(Y==2) = -1;
[numb_data,dim] = size(X);
B = X(:,2);
Bsizes = X(:,1);
X = X(:,3:dim);
[~,dim] = size(X);

%%%%%%%% Preprocess %%%%%%%%
%args = shuffle(numb_data,seed,X,Y,B);
%X = args{1}; Y = args{2}; B = args{3};
%X = scale(X,2); 

if dim == 2 && l == 0; plot2D(X,Y,1); end

unique_bag_ids = unique(B);
numb_bags = length(unique_bag_ids);
%%%%%%%% Initialize %%%%%%%%
S = zeros(numb_bags,1);
S_old = [];
Ybt = zeros(numb_bags,1);
output = zeros(numb_bags,1);

for I = 1:numb_bags
    temp = X(B == unique_bag_ids(I),:);
    Ybt(I,1) = max(Y(B == unique_bag_ids(I),1));
    ind = randi(length(temp(:,1)),1,1);
    [~,t] = ismember(temp(ind,:),X,'rows');
    S(I,:) = t;
end

Xn = X(S,:);
Yn = Y(S);
Bn = B(S);
G = grbf_fast(X,X,param);
%%%%%%%% Compute QP Solution %%%%%%%%
iter = 0;
while(sum(ismember(S_old,S)) ~= numb_bags)
    iter = iter + 1;
    S_old = [S_old S];
    Gn = G(S,S);
    H = (Yn*Yn').*Gn;
    if(cond(H) > 1e2), H = H + eye(numb_bags)*1e-7; end
    f = -1*ones(numb_bags,1);
    Aeq = Yn';
    beq = 0;
    LB = zeros(numb_bags,1);
    UB = ones(numb_bags,1)*C; 
    
    alpha = quadprog(H,f,[],[],Aeq,beq,LB,UB,[],options);
    indSV = find(1e-7 <= abs(alpha) & abs(alpha) <= (C+1e-7));
    alphay = Yn(indSV).*alpha(indSV);
    bias = (1/length(indSV))*sum(Yn(indSV) - G(S(indSV),S(indSV))*alphay);
       
    if dim == 2
        figure(iter)
        plot2D(X,Y,iter);
        hold on;
        minnum = min(min(Xn))-2;
        maxnum = max(max(Xn))+2;
        x1 = linspace(minnum,maxnum,99);
        x2 = linspace(minnum,maxnum,100);
        X0 = centri(x1,x2);
        Gp = grbf_fast(X0,Xn(indSV,:),param);
        O = Gp*alphay + bias;
        O = reshape(O,length(x1),length(x2));
        contour(x1,x2,(O'),[0 0],'k','ShowText','on')
        contour(x1,x2,(O'),[1 1],'b--')
        contour(x1,x2,(O'),[-1 -1],'r--')
        plot(Xn(indSV,1),Xn(indSV,2),'mx');
        axis([minnum maxnum minnum maxnum]);
    end

    for I = 1:numb_bags
        cur_bag = Bn(I);
        Xb = X(B == cur_bag,:);
        Gb = G(B == cur_bag,S(indSV));
        o = Gb*alphay + bias;
        o(abs(o) <= 1e-5) = NaN;
        [~,ind] = max(o);
        [~,t] = ismember(Xb(ind,:),X,'rows');
        Snew(I,1) = t;
    end
    S = Snew;
    Xn = X(S,:);
    Yn = Y(S);
    Bn = B(S);
end



for I = 1:numb_bags
    cur_bag = Bn(I);
    Xb = X(B == cur_bag,:);
    Gb = G(B == cur_bag,S(indSV));
    o_temp = Gb*alphay + bias;
    o_temp(abs(o_temp) <= 1e-5) = NaN;
    output(I,1) = sign(max(o_temp));
end

acc = (sum(Ybt == output)/numb_bags)*100;

clearvars options Gb G t temp Yb o kerSV minnum maxnum q uSV std shift index index_neg b_ind_p b_p_labels b_n_labels b_ind_n b_ind_n o_temp seed unique_bag_ids z xplot x2plot m Xb variance Aineq bineq H o val ind I curbag f Aeq beq LB UB numb_uSV nnew cur_bag args Xn Yn x S_old;
