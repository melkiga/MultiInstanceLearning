cclear;
path = '../Google Drive/data/midata/libsvm';
datasets = dir(path);
datasets([1:2 3 7 10:12 16],:) = [];
C = 1; Sigma = 0.1; 

figure;
j = 1;
for data = datasets'
    name = data.name;
    [~,~,~,~,~,~,sums,numb_bags] = mirsvm_script([path '/'],name,C,Sigma,1,0);
    
    fig = subplot(3,3,j); plot(sums,'LineWidth',1.2); hold on; title(name,'Interpreter','latex'); 
    grid minor; xlabel('Iterations','Interpreter','latex'); ylabel('Equal Representatives','Interpreter','latex');
    plot(numb_bags.*ones(length(sums),1),'r--','LineWidth',1); axis([1 length(sums) 1 numb_bags+2]);
    set(gca,'fontsize',11);
    set(gca,'TickLabelInterpreter', 'latex');
    j = j + 1;
end

%print(gcf,'Research/MultiInstanceLearning/convergence/subplot','-dpng');