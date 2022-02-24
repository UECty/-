%ラーメンとチャーハンをBoFベクトルから非線形SVM分類
load('codebook_fn1.mat');
load('list_fn1.mat');

cv = 5;
idx2 = [1:125];
accuracy=[];
data_pos = [];
data_neg = [];

bof2=zeros(250,500);

%BoFベクトルの生成
for j=1:250
    I=rgb2gray(imread(name{j}));
    p=detectSURFFeatures(I);
    [f,p2]=extractFeatures(I,p);
    for i=1:size(p2,1)
        r = f(i,:);
        r1=repmat(r,500,1);
        a1 = sqrt(sum((codebook-r1).^2,2));
        [s,idx]=sort(a1);
        bof2(j,idx(1)) = bof2(j,idx(1))+1;
    end
end

for i=1:125
    data_pos = [data_pos;bof2(i,:)];
end
for i=126:250
    data_neg = [data_neg;bof2(i,:)];
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
    
    %非線形SVMでの分類
    model = fitcsvm(train,train_label,'KernelFunction','rbf','KernelScale','auto');
    [predicted_label,scores] = predict(model,eval);
    ac = numel(find(eval_label==predicted_label))/numel(eval_label);
    accuracy=[accuracy,ac];
end

fprintf('accuracy:%.3f\n',mean(accuracy));