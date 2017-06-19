cclear;
path = '../../../../Google Drive/data/midata/libsvm';
datasets = dir(path);
datasets([1:2 3 7 10:12 16],:) = [];
C = 1;
Sigma = 0.1;

figure(1); figure(2);
j = 1;
for data = datasets'
    name = data.name;
    [~,~,~,~,~,~,sums,numb_bags,tracc] = mirsvm_script([path '/'],data.name,C,Sigma,1,0);
    % sums
    figure(1); subplot(3,3,j); hold on; grid minor;
    plot(sums,'LineWidth',2.2); plot(numb_bags.*ones(length(sums),1),'r--','LineWidth',1.8);
    xlabel('Iterations','Interpreter','latex','fontsize',13); 
    ylabel('Equal Representatives','Interpreter','latex','fontsize',13);
    title(name,'Interpreter','latex','fontsize',16); axis([1 length(sums) 1 numb_bags+2]);
    set(gca,'TickLabelInterpreter', 'latex');
    % accs
    figure(2); subplot(3,3,j); hold on; grid minor;
    plot(tracc,'LineWidth',2.2);
    xlabel('Iterations','Interpreter','latex','fontsize',13); 
    ylabel('Training Accuracy','Interpreter','latex','fontsize',13);
    title(name,'Interpreter','latex','fontsize',16); axis([1 length(name) 1 100]);
    set(gca,'TickLabelInterpreter', 'latex');
    j = j + 1;
end
