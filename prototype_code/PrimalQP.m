clear; clc; close all;

C = 1000;
param = 1;
N = 0.1;
seed = 1;
rng(seed);
%%%%%%%% Load Data %%%%%%%%
%loaddataoverlap
%loadrandommidata
[X,Y,B] = MuskData('musk1');
[numb_data,dim] = size(X);

%%%%%%%% Preprocess %%%%%%%%
args = shuffle(numb_data,seed,X,Y,B);
X = args{1}; Y = args{2}; B = args{3};
X = scale(X,2); 

if dim == 2
   plot2D(X,Y,1);
end

b_ind_p = find(Y == 1);
b_p_labels = unique(B(b_ind_p));
numb_p_bags = length(b_p_labels);

b_ind_n = find(Y == -1);
b_n_labels = unique(B(b_ind_n));
numb_n_bags = length(b_n_labels);

numb_bags = numb_p_bags + numb_n_bags;
unique_bag_ids = unique(B);

%%%%%%%% Initialize %%%%%%%%
% S = zeros(numb_p_bags,1);
% S_old = zeros(numb_p_bags,1);

% %also try setting N to the number of +ive bags, to make it balanced
model = svmtrain(Y(b_ind_n),X(b_ind_n,:),['-s 2 -t 1 -g ' num2str(param) ' -n ' num2str(N) ' -q ' num2str(0) ' -v' num2str(1)]);
[~,t] = ismember(full(model.SVs),X,'rows');
index_neg = t(:,1);

model2 = svmtrain(Y(b_ind_p),X(b_ind_p,:),['-s 2 -t 1 -g ' num2str(param) ' -n ' num2str(N) ' -q ' num2str(0) ' -v' num2str(1)]);
[~,t] = ismember(full(model2.SVs),X,'rows');
S = t(:,1);
endlength = length(S);
S_old = zeros(endlength,1);

% for I = 1:numb_p_bags
%     temp = X(B == b_p_labels(I),:);
%     ind = randi(length(temp(:,1)),1,1);
%     [~,t] = ismember(temp(ind,:),X,'rows');
%     S(I,:) = t;
% end
clearvars I t x cur_bag;

%%%%%%%% Compute QP Solution %%%%%%%%
iter = 1;
while(sum(S_old == S) ~= endlength)
    S_old = S;
    index = [index_neg; S];
    nnew = length(index);
    args = shuffle(nnew,seed,index);
    index = args{1};
    Xn = X(index,:);
    Yn = Y(index);
    
    H = diag([ones(1,dim), zeros(1, nnew+1)]);
    f = [zeros(1, dim), C * ones(1, nnew), 0]';
    Aineq = [-diag(Yn)*Xn, -eye(nnew), -Yn];
    bineq = -ones(nnew, 1);
    LB = [-inf(1,dim), zeros(1,nnew), -inf];

    z = quadprog(H,f,Aineq,bineq,[],[],LB);
    w = z(1:dim,1);
    bias = z(end,1);
    ksi = z(dim+1:end-1,1);
    
    if dim == 2
        figure(1);
        hold on;
        minnum = min(min(Xn));
        maxnum = max(max(Xn));
        xplot = [minnum-1 maxnum+1];
        m = -1*(w(1,:)/w(2,:));
        x2plot = m.*xplot + (-bias/w(2,:));
        plot(xplot,x2plot,'k');
    end
    
    for I = 1:numb_p_bags
        cur_bag = b_p_labels(I);
        Xb = X(B == cur_bag,:);
        o = Xb*w + bias;
        [~,ind] = max(o);
        [~,t] = ismember(Xb(ind,:),X,'rows');
        S(I,1) = t;
    end
    iter = iter + 1;
end
clearvars o;
for I = 1:numb_bags
    cur_bag = unique_bag_ids(I);
    Xb = X(B == cur_bag,:);
    o(I,1) = sign(max(Xb*w + bias));
    bag_labels(I,1) = max(Y(B == cur_bag));
end

acc = (sum(bag_labels == o)/length(bag_labels))*100;

clearvars t temp S ksi index index_neg b_ind_p b_p_labels b_n_labels b_ind_n b_ind_n o o_temp seed unique_bag_ids z xplot x2plot m Xb variance Aineq bineq H o val ind I curbag f Aeq beq LB UB numb_uSV nnew cur_bag args Xn Yn x S_old;
% for I = 1:numb_p_bags
%     cur_bag = b_p_labels(I);
%     x(I,:) = sum(X(B == cur_bag,:))/sum(B == cur_bag);
%     S(I,1) = 1;
% end
%index_neg = b_ind_n;
%model = svmtrain(Y,X,['-s 0 -t ' num2str(t) ' -g ' num2str(param) ' -c ' num2str(C) ' -q ' num2str(q) ' -v' num2str(k)]);
%[predicted_label, accuracy, ~] = svmpredict(Y, X, model, ['-q ' num2str(q)]);