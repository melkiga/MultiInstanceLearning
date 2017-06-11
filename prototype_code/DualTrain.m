function [alphay,bias,S,iter] = DualTrain(X,Y,B,C,param,options,Bsizes)

[unique_bag_ids,~] = unique(B);
numb_bags = length(unique_bag_ids);
%%%%%%%% Initialize %%%%%%%%
S = zeros(numb_bags,1);
S_old = ones(numb_bags,1);
p=0;
offset = 0;
for I = 1:numb_bags
    temp = X(B == unique_bag_ids(I),:);
    ind = randi(length(temp(:,1)),1,1);
    S(I,:) = ind+offset;
    offset = offset + length(temp(:,1));
end

Xn = X(S,:);
Yn = Y(S);
Bn = B(S);
%%%%%%%% Compute QP Solution %%%%%%%%
iter = 0;
while(max(sum(ismember(S_old,S))) ~= numb_bags && iter < 3)
%while(sum(S == S_old) ~= numb_bags)
    iter = iter + 1;
    S_old = [S_old S];
    %S_old = S;
    H = (Yn*Yn').*grbf_fast(Xn,Xn,param);
    f = -1*ones(numb_bags,1);
    Aeq = Yn';
    beq = 0;
    LB = zeros(numb_bags,1);
    UB = ones(numb_bags,1)*C; 
    
    alpha = quadprog(H,f,[],[],Aeq,beq,LB,UB,[],options);
    indSV = find(1e-7 <= abs(alpha) & abs(alpha) <= (C+1e-7));
    alphay(:,iter) = Yn.*alpha;
    bias(iter) = (1/length(indSV))*sum(Yn(indSV) - grbf_fast(Xn(indSV,:),Xn(indSV,:),param)*alphay(indSV,iter));
    
    if p==1
        plot2D(X,Y,iter);
        hold on;
        minnum = min(min(X))-1;
        maxnum = max(max(X))+1;
        x1 = linspace(minnum,maxnum,99);
        x2 = linspace(minnum,maxnum,100);
        X0 = centri(x1,x2);
        Gp = grbf_fast(X0,X(S,:),param);
        O = Gp*alphay(:,iter) + bias(iter);
        O = reshape(O,length(x1),length(x2));
        contour(x1,x2,(O'),[0 0],'k','ShowText','on');
        plot(X(S,1),X(S,2),'mx');
        contour(x1,x2,(O'),[1 1],'b:');
        contour(x1,x2,(O'),[-1 -1],'r:');
        axis([minnum maxnum minnum maxnum]);
    end
    
    offset = 0;
    for I = 1:numb_bags
        o = grbf_fast(X(B == Bn(I),:),Xn,param)*alphay(:,iter) + bias(iter);
        o(abs(o) <= 1e-5) = NaN;
        [~,ind] = max(o);
        S(I,1) = ind+offset;
        offset = offset + Bsizes(S(I,1));
    end
    
    Xn = X(S,:);
    Yn = Y(S);
    Bn = B(S);
end

%index = find(sum(ismember(S_old,S)) == numb_bags);
%S = S_old(:,iter);
%ind = find(sum(ismember(S_old,S)) == numb_bags);
ind = iter;
S = S_old(:,ind(end));
alphay = alphay(:,ind(end)-1);
bias = bias(ind(end)-1);

end