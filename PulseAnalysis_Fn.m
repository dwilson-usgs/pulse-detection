function [ pulse_results] = PulseAnalysis_Fn(mytrace)

% function [ pulse_results] = PulseAnalysis_Fn(mytrace)
% 
% analyzes seismic data in mytrace (an IRIS WS object)
% and finds step acceleration pulses
% pulse_results has two columns, time and pulse amplitude in m/s/s
%
%**Disclaimer:**
%
%This software is preliminary or provisional and is subject to revision. It is 
%being provided to meet the need for timely best science. The software has not 
%received final approval by the U.S. Geological Survey (USGS). No warranty, 
%expressed or implied, is made by the USGS or the U.S. Government as to the 
%functionality of the software and related material nor shall the fact of release 
%constitute any such warranty. The software is provided on the condition that 
%neither the USGS nor the U.S. Government shall be held liable for any damages 
%resulting from the authorized or unauthorized use of the software.

if length(mytrace.data)<2*3600*mytrace(1).sampleRate,
    disp('Please use a minimum of 2hrs of data. This version of PulseAnalysis is tuned for looking at acceleration steps on BB and VBB instruments')
    pulse_results=[];
    return;
end

[Blp,Alp]=butter(4,[(1/40)]./(mytrace(1).sampleRate),'low');
one_count=1/(mytrace.sensitivity);
sampletimes=linspace(mytrace(1).startTime,mytrace(1).endTime,mytrace(1).sampleCount);

% Remove instrument response and convert to acceleration.
traceAccf = filtfilt(Blp,Alp,detrend(double(RemoveResp(mytrace(1),2,.001))));

lc=length(traceAccf);

% set up 15 minute long step function
stepfun=[zeros(round(430*mytrace.sampleRate),1); (1:(round(40*mytrace.sampleRate)))'./(round(40*mytrace.sampleRate) ); ones(round(430*mytrace.sampleRate),1)];

% Compute the windowed cross correlation function.
[xcC, xcA]=Wxcorr(traceAccf,stepfun);

% Remove hour long trend from filtered data.
traceAccf2 = traceAccf-meanfilter(traceAccf,3600*mytrace(1).sampleRate);

% Diff the trend removed data and calculate 15 minute and 60 seconds
% averages. This is for the sharpness constraint.
traceAccdiff=[0; diff(traceAccf2)];
[traceAccCdiff20, Cstddiff20] = meanfilter(abs(traceAccdiff),900*mytrace.sampleRate,'C');
[traceAccCdiff, Cstddiff] = meanfilter(traceAccdiff,60*mytrace.sampleRate,'C');


% set window lengths and compute envelope functions.
w1=round(240*mytrace.sampleRate);
w2=round(140*mytrace.sampleRate);
[traceAccC1, traceAccC2, traceAccC3] = meanfilter3(traceAccf2,w1,'C');
% now compute envelope function differences to see if the upper, middle,
% and lower 33rd percentiles all have the same sign.
recfunC1=zeros(size(traceAccC1));
recfunC2=recfunC1;
recfunC3=recfunC1;
recfunC1(w2:lc-w2)=traceAccC1(w2*2:lc)-traceAccC1(1:lc-(w2*2-1));
recfunC2(w2:lc-w2)=traceAccC2(w2*2:lc)-traceAccC2(1:lc-(w2*2-1));
recfunC3(w2:lc-w2)=traceAccC3(w2*2:lc)-traceAccC3(1:lc-(w2*2-1));

% Compute the constraint functions, Sfun, Sfun2, and Sfun3

% First, all envelopes must all be the same sign
Sfun = abs(recfunC1+recfunC2+recfunC3)./(abs(recfunC1)+abs(recfunC2)+abs(recfunC3));
[Y,I]=find(Sfun<1);
Sfun(Y)=0;

% Second, xcorr must be greater than .7
[Y,I]=find(abs(xcC)<.7);
Sfun2=ones(size(Sfun));
Sfun2(Y)=0;

% Third, sharpness constraint
% the acceleration changes within a 60 second window must be >4 times the
% changes in the surrounding 15 minute window.
[Y,I]=find(abs(((traceAccCdiff20*900-abs(traceAccCdiff)*60)/840)./traceAccCdiff)>.25);
Sfun3=ones(size(Sfun));
Sfun3(Y)=0;

signfun3=Sfun.*Sfun2.*Sfun3;

% find local maxima where all conditions are met.
[ Imax, maxval ] = localmax(abs(signfun3.*xcC));

pulse_results=[];
if ~isempty(Imax),
    % at each local max, check to see if the amplitude is above cutoff.
    I=find(abs(xcA(Imax)).*signfun3(Imax)>=10*one_count);
    if ~isempty(I),
      pulseI=Imax(I);
      pulseXA=xcA(pulseI);
      pulseT=sampletimes(pulseI);
      pulse_results = [ pulseT' pulseXA ];
    end
end

return;





   