%かつ丼と親子丼の画像からコードブックを生成
n=0;list=[];name={};
Features=[];
data_pos=[];data_neg=[];
LIST = {'katsudon','oyakodon'};
DIRO = 'imgdir/';

%全画像のSURF特徴を抽出する。
for i=1:length(LIST)
    DIR = strcat(DIRO,LIST(i),'/');
    W = dir(DIR{:});

    for j=1:size(W)
        if(strfind(W(j).name,'.jpg'))
            fn = strcat(DIR{:},W(j).name);
            n=n+1;
            name={name{:} fn};

            I=rgb2gray(imread(fn));
            p=detectSURFFeatures(I);
            [f,p2]=extractFeatures(I,p);
            Features=[Features;f];
        end
    end
end

%コードブックの生成
[idx,codebook]=kmeans(Features,500);

save('codebook_fn2.mat','codebook');
save('list_fn2.mat','name');