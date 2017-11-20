function y=bpf(x,f1,f2,fs)
% �̂�hilbert��BPF�𗼕������Ă������A�����BPF�݂̂�������B
% x�F�t�B���^���������2�����s��B
% f1�FBPF�̍Œ�l�B�܂�n�C�p�X�̎��g���B
% f2�FBPF�̍ō��l�B�܂胍�[�p�X�̎��g���B
% fs�F�T���v�����O���g��
if f1>=f2
    disp('����f1<f2�œ��͂��Ă�')
    fd=f1;
    f1=f2;
    f2=fd;
end

% ���ω������F���f�̂܂ܕ��ϒl�i���f���j�����ʂƂ��č�������
xm=mean(x);
xd=bsxfun(@minus,x,xm);

% �K�v�ȃp�����[�^�̍쐬
n=size(xd,1);        % ���ԕ����̃|�C���g��32*600
h=zeros(n,1);       % hilbert�p�̍s��̂��߂̏c�x�N�g��

% BPF��������
lp=round(f2*n/fs+1);        % ���[�p�X��f2�ȉ���ʂ�
hp=round(f1*n/fs+1);        % �n�C�p�X��f1�ȏ��ʂ�

% BPF+hilbert�̕ϊ��s��̂��ƂƂȂ��x�N�g�������
% �����Ƃ������ɂ���Ȃ�=�ȉ���K���ɁF�n�j���O���Ȃ�hanning(lp-hp+1)
% h(hp:lp)=ones(lp-hp+1,1);   % ���E�Ώ̂�BPF�̂����O�������ʂ��̂�hilbert
h(hp:lp)=hanning(lp-hp+1);   
h(n-lp+1:n-hp+1)=hanning(lp-hp+1);   

% �ł����t�B���^��������B�Ō�ɂ͕��ω������̕���Y�ꂸ�ɁB
fx=fft(xd,n,1);
yd=ifft(fx.*h(:,ones(1,size(x,2))));     % h�͗�x�N�g���Ȃ̂ōs��ɂ���
y=bsxfun(@plus,yd,xm);
end



% �ȉ��͋𒼂�hilbert��BPF�����������́B
% BPF�݂̂��K�v�ɂȂ������Ȃǂ͎g����͂��B
% --------------------------------
% function y=hbpf(x,fl,fh,fs)
% % hilbert��BPF���܂Ƃ߂Ă�����B�������e����x�N�g���Ƃ���B
% % BPF�͈̔͂�fl��fh��
% if fl<=fh
%     disp('����f1>f2�œ��͂��Ă�')
%     fd=fl;
%     fl=fh;
%     fh=fd;
% end
% % �K�v�ȃp�����[�^�̍쐬
% n=size(x,1);        % ���ԕ����̃|�C���g��
% h=zeros(n,1);       % hilbert�p�̍s��̂��߂̏c�x�N�g��
% lp=ones(n,1);       % ���[�p�X�t�B���^�p�̏c�x�N�g��
% hp=zeros(n,1);      % �n�C�p�X�t�B���^�p�̏c�x�N�g��
% vs=ones(1,size(x,2));       % �f�[�^�̗�
% 
% % BPF������
% lp1=round(fl*n/fs+1);
% lp2=n+2-lp1;
% lp(lp1+1:lp2-1)=zeros(lp2-lp1-1,1);
% hp1=round(fh*n/fs+1);
% hp2=n+2-hp1;
% hp(hp1:hp2)=ones(hp2-hp1+1,1);
% 
% % hilbert�����
% if 2*fix(n/2) == n
%     h([1,n/2+1])=1;
%     h(2:n/2) = 2;
% else
%     h(1) = 1;
%     h(2:(n+1)/2) = 2;
% end
% 
% % �ł����t�B���^��������
% fx=fft(x,n,1);
% y=ifft(fx.*hp(:,vs).*lp(:,vs).*h(:,vs));
% end