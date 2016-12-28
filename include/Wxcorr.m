function [ pfilt, scal, xerr] = Wxcorr(p,q)

% Wxcorr
%
%   function to preform a moving window cross correlation
%   [ wcorr, scal ] = Wxcorr(LongSeries,ShortSeries) 
%   
%     wcorr is the cross correlation value (0 to 1)
%     scal is the scale factor relative to the short series
%     xerr is the std dev of the fit

nn=length(p);
lq=length(q);
num=ceil(lq/2);
pfilt = zeros(nn,1);
scal=pfilt;
xerr=scal;
q1=q;
q=detrend(q);
q=q./sqrt(sum(q.*q));
wl=.001*max(abs(p));

  for n = num+1:nn-num-1,
      p2=p((n-num):(n-num+lq-1));
      p2=detrend(p2);
      p3 = p2./(sqrt(sum(p2.*p2))+wl);
	  pfilt(n)=sum(p3.*q);
      scal(n)=sum(p2.*q)/sum(q1.*q);
      xerr(n)=std(p2-scal(n).*q);
  end
 
return;
