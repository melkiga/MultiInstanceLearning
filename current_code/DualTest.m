function [TP,TN,FP,FN] = DualTest(X,XS,Y,B,alphay,bias,param)

[unique_bag_ids,id] = unique(B);
Yb = Y(id);
numb_bags = length(unique_bag_ids);
output = zeros(numb_bags,1);

for I = 1:numb_bags
    o_temp = GaussianKernel(X(B == unique_bag_ids(I),:),XS,param)*alphay + bias;
    o_temp(abs(o_temp) <= 1e-7) = NaN;
    output(I,1) = sign(max(o_temp));
end

indP = (Yb == 1);
indN = (Yb == -1);

TP = sum(Yb(indP) == output(indP));
TN = sum(Yb(indN) == output(indN));
FP = sum(Yb(indN) ~= output(indN));
FN = sum(Yb(indP) ~= output(indP));

end