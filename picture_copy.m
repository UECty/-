%URLから画像を保存する
list = textread('soba2.txt','%s') %読み込むtxtファイル
OUTDIR='imgdir/soba_i' %保存するフォルダ
for i=1:400 %写真数に応じて数値を変更する
    fname=strcat(OUTDIR,'/',num2str(i,'%04d'),'.jpg')
    websave(fname,list{i})
end