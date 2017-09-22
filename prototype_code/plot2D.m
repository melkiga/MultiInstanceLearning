function [] = plot2D(X,Y,f)
%% Plots 2D data with 2 classes in figure f
figure(f);
hold on;
grid on;

indp = (Y==1);
indn = (Y==-1);
plot(X(indp,1),X(indp,2),'bo','DisplayName','instance in positive bag');
plot(X(indn,1),X(indn,2),'ro','DisplayName','instance in negative bag');

xlabel('$x_1$','Interpreter','latex');
ylabel('$x_2$','Interpreter','latex');
set(gca,'fontsize',11);
set(gca,'TickLabelInterpreter', 'latex');

%hold off;
end