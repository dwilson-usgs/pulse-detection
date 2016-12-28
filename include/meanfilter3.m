function [ pfilt, pfilt2, pfilt3, pstd1, pstd2, pstd3] = meanfilter3(p,num,dir)

% meanfilter3
%
%   function to preform a n point mean filter on a vector
% this version returns the mean of the lower third, middle third, and upper
% third of the data.
%   [ pfilt,pfilt2, pfilt3, pstd1, pstd2, pstd3 ] = meanfilter(p,n,dir)  where n is odd
%   dir can be 
%       'C' - centered (this is the default)
%       'F' - returned value is for n points FORWARD in time
%       'B' - returned value is for n points BACKWARD in time

if nargin < 3,
    dir='C';
end

nn = length(p);
num = ceil(num/2)*2 -1;
if num<3; num=3; end;
pfilt = zeros(length(p),1);
pfilt2=pfilt; pfilt3=pfilt;
pstd1=pfilt; pstd2=pfilt; pstd3=pfilt;
pstd = zeros(length(p),1);
nnn=floor(num/2);

if strcmp(dir,'C'),
  % calculate the edges
  for n = 1:nnn,
      p2=sort(p(1:n+nnn));
      lnp=length(p2);
	  pfilt(n)=mean(p2(1:floor(lnp/3)));
      pfilt2(n)=mean(p2(floor(lnp/3):floor(lnp/1.5)));
      pfilt3(n)=mean(p2(lnp-floor(lnp/3):lnp));
      p2=sort(p(nn-(n-1)-nnn:nn));
      lnp=length(p2);
	  pfilt(nn-(n-1))=mean(p2(1:floor(lnp/3)));
      pfilt2(nn-(n-1))=mean(p2(floor(lnp/3):floor(lnp/1.5)));
      pfilt3(nn-(n-1))=mean(p2(lnp-floor(lnp/3):lnp));
      pstd1(nn-(n-1))=std(p2(1:floor(lnp/3)));
      pstd2(nn-(n-1))=std(p2(floor(lnp/3):floor(lnp/1.5)));
      pstd3(nn-(n-1))=std(p2(lnp-floor(lnp/3):lnp));   
  end
  % now fill in the rest
  for n = nnn+1:nn-nnn,
      p2=sort(p(n-nnn:n+nnn));
      lnp=length(p2);
	  pfilt(n)=mean(p2(1:floor(lnp/3)));
      pfilt2(n)=mean(p2(floor(lnp/3):floor(lnp/1.5)));
      pfilt3(n)=mean(p2(lnp-floor(lnp/3):lnp));
      pstd1(n)=std(p2(1:floor(lnp/3)));
      pstd2(n)=std(p2(floor(lnp/3):floor(lnp/1.5)));
      pstd3(n)=std(p2(lnp-floor(lnp/3):lnp));
    
  end
end
if strcmp(dir,'F'),
  % calculate the edges
  for n = 1:num,
	 % pfilt(n)=mean(p(1:n+nnn));
  %        pfilt(nn-(n-1))=mean(p(nn-(n-1):nn));
         pfilt(nn-(n-1))=mean(p(nn-num:nn));
                  pstd(nn-(n-1))=std(p(nn-num:nn));
  end
  % now fill in the rest
  for n = 1:nn-num,
    pfilt(n) = mean(p(n:n+num));
       pstd(n) = std(p(n:n+num));
  end
end
if strcmp(dir,'B'),
  % calculate the edges
  for n = 1:num,
	%  pfilt(n)=mean(p(1:n));
    pfilt(n)=mean(p(1:num));
        pstd(n)=std(p(1:num));
      %    pfilt(nn-(n-1))=mean(p(nn-(n-1)-nnn:nn));
  end
  % now fill in the rest
  for n = num+1:nn,
    pfilt(n) = mean(p(n-num:n));
       pstd(n) = std(p(n-num:n));
  end
end
return;
