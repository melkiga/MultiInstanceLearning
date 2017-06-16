cclear;
path = '../../../Google Drive/data/midata/libsvm/';
cols = {'Dimensionality','Positive Bags','Negative Bags' ...
    ,'Total Bags','Instances','Average Bag Size'};
datasets = dir([path '*']);
datasets(1:2,:) = [];

i = 1;
for data = datasets'
    name = data.name;
    % get data
    [Y,X] = libsvmread([path name]); 
    X = full(X); Y(Y==2) = -1; B = X(:,2); 
    Bsizes = X(:,1); X = X(:,3:end);
    [num_data, dim] = size(X);
    [uniqueBid,indU] = unique(B); 
    num_bags = length(uniqueBid);
    % get unique labels and sizes
    YuB = Y(indU); numPos = sum(YuB == 1); numNeg = sum(YuB == -1);
    BsizeU = Bsizes(indU); % get unique bag sizes
    
    % save info
    attributes(i) = dim;
    pos_bags(i) = numPos; neg_bags(i) = numNeg;
    bags(i) = num_bags; instances(i) = num_data;
    avgBagSize(i) = sum(BsizeU)/num_bags;
    name(1) = upper(name(1));
    rows{i} = name;
    i = i + 1;
end
clearvars X Y B Bsizes num_data dim indU uniqueBid num_bags YuB numPos numNeg BsizeU i name;
% sort based on bag size
[bags,indSort] = sort(bags,'ascend');
attributes = attributes(indSort); pos_bags = pos_bags(indSort);
neg_bags = neg_bags(indSort); instances = instances(indSort);
avgBagSize = avgBagSize(indSort);
rows = rows(indSort);
data = [attributes' pos_bags' neg_bags' bags' instances' avgBagSize'];

matrix2latex(data, 'datasets.tex', ...
    'rowLabels', rows, 'columnLabels', cols, 'alignment', 'c', ...
    'format', '%-4.2f', 'size', 'small');