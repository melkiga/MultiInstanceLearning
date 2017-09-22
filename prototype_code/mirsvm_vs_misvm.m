clear; clc; close all;

C = 1000;
param = 1.5;
seed = 1;
dim = 2;
rng(seed);
bnump = 2;
bnumn = 4;
numb = bnump + bnumn;
num = [30 35 15 15 15 15]';
shiftx = [4 6 3 4.7 5.1 7];
shifty = [4 4 4.5 5 2.5 5];
vari = [0.4 0.4 0.4 0.3 0.3 0.4];	

%%%%%%%% Load Data %%%%%%%%

X = []; Y = []; B = []; Bsizes = [];
for x = 1:bnump
    X = [X; shiftx(x)+randn(num(x),1)*vari(x) shifty(x)+randn(num(x),1)*vari(x)];
    Y = [Y; ones(num(x),1)];
    B = [B; x*ones(num(x),1)];
    Bsizes = [Bsizes; num(x)*ones(num(x),1)];
end
for x = 1:bnumn
    n = bnump+x;
    X = [X; shiftx(n)+randn(num(n),1)*vari(n) shifty(n)+randn(num(n),1)*vari(n)];
    Y = [Y; -ones(num(n),1)];
    B = [B; (n)*ones(num(n),1)];
    Bsizes = [Bsizes; num(n)*ones(num(n),1)];
end

%plot2D(X,Y,1);

%% MIRSVM is here
options = optimoptions('quadprog','Algorithm','interior-point-convex','Display','off');

[alphay,bias,S] = DualTrain(X,Y,B,C,param,options,Bsizes);
XS = X(S,:);
[TP,TN,FP,FN] = DualTest(X,XS,Y,B,alphay,bias,param);
acc = (TP+TN)/numb;
MIRSVM_acc = acc

plot2D(X,Y,1);
%hold on;
minnum = min(min(X))-1;
maxnum = max(max(X))+1;
x1 = linspace(minnum,maxnum,99);
x2 = linspace(minnum,maxnum,100);
X0 = centri(x1,x2);
Gp = grbf_fast(X0,X(S,:),param);
O = Gp*alphay + bias;
O = reshape(O,length(x1),length(x2));
[~,h] = contour(x1,x2,(O'),[0 0],'k','DisplayName','decision boundary');
set(h,'linewidth',1.5);
h = plot(X(S,1),X(S,2),'kx','DisplayName','support vectors','linewidth',2);
set(h,'linewidth',1.5);
[~,h] = contour(x1,x2,(O'),[1 1],'b--','DisplayName','positive margin');
set(h,'linewidth',1.5);
[~,h] = contour(x1,x2,(O'),[-1 -1],'r--','DisplayName','negative margin');
set(h,'linewidth',1.5);
axis([minnum maxnum minnum+0.5 maxnum-1]);
set(gca,'TickLabelInterpreter', 'tex');
title('MIRSVM Decision Boundary','Interpreter','latex');
set(gca,'fontsize',11);
vars = [1.1 1.1];
for b=1:bnump
    indB = find(B == b);
    minx = min(X(indB,:)); maxx = max(X(indB,:));
    meanB = mean([minx; maxx]);
    circle(meanB(1),meanB(2),vars(b),0.01,1,[0.1 0.1 0.9]);
end
vars = [1.1 0.8 0.8 1.2];
for b=1:bnumn
    indB = find(B == (b+2));
    minx = min(X(indB,:)); maxx = max(X(indB,:));
    meanB = mean([minx; maxx]);
    circle(meanB(1),meanB(2),vars(b),0.01,1,[0.9 0.1 0.1]);
end
legend({'instance in positive bag','instance in negative bag','decision boundary','support vectors','positive margin','negative margin'});


%% MISVM is here
[alphay,bias,S,indSV] = MISVM(X,Y,B,C,param,options,Bsizes);
Xn = [X(S,:); X(Y==-1,:)];

for I = 1:numb
    o_temp = grbf_fast(X(B == I,:),Xn,param)*alphay + bias;
    o_temp(abs(o_temp) <= 1e-7) = NaN;
    output(I,1) = sign(max(o_temp));
end
[~,in] = unique(B);
acc = sum(Y(in) == output)/numb;
MISVM_acc = acc

plot2D(X,Y,2);
%hold on;
minnum = min(min(X))-1;
maxnum = max(max(X))+1;
x1 = linspace(minnum,maxnum,99);
x2 = linspace(minnum,maxnum,100);
X0 = centri(x1,x2);
Gp = grbf_fast(X0,Xn,param);
O = Gp*alphay + bias;
O = reshape(O,length(x1),length(x2));
[~,h] = contour(x1,x2,(O'),[0 0],'k','DisplayName','decision boundary');
set(h,'linewidth',1.5);
h = plot(Xn(indSV,1),Xn(indSV,2),'kx','DisplayName','support vectors','linewidth',2);
set(h,'linewidth',1.5);
[~,h] = contour(x1,x2,(O'),[1 1],'b--','DisplayName','positive margin');
set(h,'linewidth',1.5);
[~,h] = contour(x1,x2,(O'),[-1 -1],'r--','DisplayName','negative margin');
set(h,'linewidth',1.5);
axis([minnum maxnum minnum+0.5 maxnum-1]);
set(gca,'TickLabelInterpreter', 'tex');
title('MISVM Decision Boundary','Interpreter','latex');
set(gca,'fontsize',11);
vars = [1.1 1.1];
for b=1:bnump
    indB = find(B == b);
    minx = min(X(indB,:)); maxx = max(X(indB,:));
    meanB = mean([minx; maxx]);
    circle(meanB(1),meanB(2),vars(b),0.01,1,[0.1 0.1 0.9]);
end
vars = [1.1 0.8 0.8 1.2];
for b=1:bnumn
    indB = find(B == (b+2));
    minx = min(X(indB,:)); maxx = max(X(indB,:));
    meanB = mean([minx; maxx]);
    circle(meanB(1),meanB(2),vars(b),0.01,1,[0.9 0.1 0.1]);
end
legend({'instance in positive bag','instance in negative bag','decision boundary','support vectors','positive margin','negative margin'});

