%かつ丼と親子丼をDCNN特徴による線形SVM分類
load('list_fn2.mat');
IM = [];
cv = 5;
idx2 = [1:125];
accuracy=[];
data_pos = [];
data_neg = [];

net = alexnet;

%画像の合体
for i=1:250
    img = imread(name{i});
    reimg = imresize(img,net.Layers(1).InputSize(1:2));
    IM = cat(4,IM,reimg);
end

%DCNN特徴を抽出
dcnnf = activations(net,IM,'fc7');
dcnnf = squeeze(dcnnf);
dcnnf = dcnnf';

for i=1:125
    data_pos = [data_pos;dcnnf(i,:)];
end
for i=126:250
    data_neg = [data_neg;dcnnf(i,:)];
end

%5-fold cross validation
for i=1:cv
    train_pos = data_pos(find(mod(idx2,cv)~=(i-1)),:);
    eval_pos = data_pos(find(mod(idx2,cv)==(i-1)),:);
    train_neg = data_neg(find(mod(idx2,cv)~=(i-1)),:);
    eval_neg = data_neg(find(mod(idx2,cv)==(i-1)),:);

    train = [train_pos;train_neg];
    eval = [eval_pos;eval_neg];

    train_label = [ones(size(train_pos,1),1); ones(size(train_neg,1),1)*(-1)];
    eval_label = [ones(size(eval_pos,1),1); ones(size(eval_neg,1),1)*(-1)];
    
    %線形SVMを用いた分類
    model = fitcsvm(train,train_label,'KernelFunction','linear');
    [predicted_label,scores] = predict(model,eval);
    ac = numel(find(eval_label==predicted_label))/numel(eval_label);
    accuracy=[accuracy,ac];
end

fprintf('accuracy:%.3f\n',mean(accuracy));