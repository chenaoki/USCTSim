function y=bpf(x,f1,f2,fs)
% 昔はhilbertとBPFを両方かけていたが、今回はBPFのみをかける。
% x：フィルタ処理される2次元行列。
% f1：BPFの最低値。つまりハイパスの周波数。
% f2：BPFの最高値。つまりローパスの周波数。
% fs：サンプリング周波数
if f1>=f2
    disp('次はf1<f2で入力してね')
    fd=f1;
    f1=f2;
    f2=fd;
end

% 平均化処理：複素のまま平均値（複素数）を下駄として差し引く
xm=mean(x);
xd=bsxfun(@minus,x,xm);

% 必要なパラメータの作成
n=size(xd,1);        % 時間方向のポイント数32*600
h=zeros(n,1);       % hilbert用の行列のための縦ベクトル

% BPF側をつくる
lp=round(f2*n/fs+1);        % ローパスはf2以下を通す
hp=round(f1*n/fs+1);        % ハイパスはf1以上を通す

% BPF+hilbertの変換行列のもととなる列ベクトルを作る
% ちゃんとした窓にするなら=以下を適当に：ハニング窓ならhanning(lp-hp+1)
% h(hp:lp)=ones(lp-hp+1,1);   % 左右対称のBPFのうち前半だけ通すのがhilbert
h(hp:lp)=hanning(lp-hp+1);   
h(n-lp+1:n-hp+1)=hanning(lp-hp+1);   

% できたフィルタをかける。最後には平均化処理の分を忘れずに。
fx=fft(xd,n,1);
yd=ifft(fx.*h(:,ones(1,size(x,2))));     % hは列ベクトルなので行列にする
y=bsxfun(@plus,yd,xm);
end



% 以下は愚直にhilbertとBPFをかけたもの。
% BPFのみが必要になった時などは使えるはず。
% --------------------------------
% function y=hbpf(x,fl,fh,fs)
% % hilbertとBPFをまとめてかける。ただし各列をベクトルとする。
% % BPFの範囲はflとfhで
% if fl<=fh
%     disp('次はf1>f2で入力してね')
%     fd=fl;
%     fl=fh;
%     fh=fd;
% end
% % 必要なパラメータの作成
% n=size(x,1);        % 時間方向のポイント数
% h=zeros(n,1);       % hilbert用の行列のための縦ベクトル
% lp=ones(n,1);       % ローパスフィルタ用の縦ベクトル
% hp=zeros(n,1);      % ハイパスフィルタ用の縦ベクトル
% vs=ones(1,size(x,2));       % データの列数
% 
% % BPFをつくる
% lp1=round(fl*n/fs+1);
% lp2=n+2-lp1;
% lp(lp1+1:lp2-1)=zeros(lp2-lp1-1,1);
% hp1=round(fh*n/fs+1);
% hp2=n+2-hp1;
% hp(hp1:hp2)=ones(hp2-hp1+1,1);
% 
% % hilbertを作る
% if 2*fix(n/2) == n
%     h([1,n/2+1])=1;
%     h(2:n/2) = 2;
% else
%     h(1) = 1;
%     h(2:(n+1)/2) = 2;
% end
% 
% % できたフィルタをかける
% fx=fft(x,n,1);
% y=ifft(fx.*hp(:,vs).*lp(:,vs).*h(:,vs));
% end