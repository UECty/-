%ラーメンとチャーハンを最近傍分類
n=0;list=[];
data_pos=[];data_neg=[];
LIST = {'ramen','chahan'};
DIRO = 'imgdir/';

%全画像のカラーヒストグラムの生成、またポジティブ画像とネガティブ画像にわける
for i=1:length(LIST)
    DIR = strcat(DIRO,LIST(i),'/');
    W = dir(DIR{:});

    for j=1:size(W)
        if(strfind(W(j).name,'.jpg'))
            fn = strcat(DIR{:},W(j).name);
            n=n+1;

            X = imread(fn); 
            RED = X(:,:,1); GREEN = X(:,:,2); BLUE = X(:,:,3);
            X64 = floor(double(RED)/64)*4*4 + floor(double(GREEN)/64)*4 + floor(double(BLUE)/64);

            hist = zeros(1,64);
            [w,h] = size(X64);

            for x=1:w
                for y=1:h
                    t = X64(x,y)+1;
                    hist(1,t)=hist(1,t)+1;
                end
            end

            if(i==1)
                data_pos=[data_pos;hist];
            end

            if(i==2)
                data_neg=[data_neg;hist];
            end
        end
    end
end

cv = 5;
accuracy=[];
%5-fold cros validation
for i=1:cv
    train_pos = data_pos(find(mod([1:125],cv)~=(i-1)),:);
    eval_pos = data_pos(find(mod([1:125],cv)==(i-1)),:);
    train_neg = data_neg(find(mod([1:125],cv)~=(i-1)),:);
    eval_neg = data_neg(find(mod([1:125],cv)==(i-1)),:);

    train = [train_pos;train_neg];
    eval = [eval_pos;eval_neg];
    
    ans = 0;

    %学習画像のカラーヒストグラムのなかで最も近い画像の被写体が同じか
    for j=1:50
        r=eval(j,:);
        r1=repmat(r,200,1);
        a1 = sqrt(sum((train-r1).^2,2));
        [s,idx]=sort(a1);
        if j <= 25 && idx(1) <= 100
            ans = ans + 1;
        end
    
        if j > 25 && idx(1) > 100
            ans = ans + 1;
        end
    end

    accuracy=[accuracy,ans/50];
end

fprintf('accuracy:%.3f\n',mean(accuracy));


