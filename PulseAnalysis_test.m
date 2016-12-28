% PulseAnalysis_test.m
% 
% Matlab script to run an example of the pulse detector and plot the pulse
% counting results along with the velocity and acceleration traces. No
% input parameters are needed.
%
% This script uses the irisFetch matlab function. The latest version is
% available here:
% http://ds.iris.edu/ds/nodes/dmc/software/downloads/irisfetch.m/
% The IRIS WS jar file is also required, it is available here:
% http://ds.iris.edu/ds/nodes/dmc/software/downloads/IRIS-WS/ 
% make sure the java jar is in the path
% The version used here is IRIS-WS-2.0.11.jar
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

clear
javaaddpath('include\IRIS-WS-2.0.11.jar');
path(path,'include')

% Fetch a channel of data from IRIS, with responses included.
mytrace=irisFetch.Traces('IU','KIP','60','LH2','2016-03-03 08:00:00','2016-03-03 15:00:00','includePZ')

% Send data to pulse counting function
[ pulse_res]=PulseAnalysis_Fn(mytrace);

% Create filtered acceleration trace (for plotting only)
[Blp,Alp]=butter(4,[(1/20)]./(mytrace(1).sampleRate),'low');
traceAccf = filter(Blp,Alp,detrend(double(RemoveResp(mytrace(1),2,.001))));

% create velocity traces by applying sensitivity but not removing response 
% (this is for plotting only)
traceVelsc = detrend(mytrace(1).data./mytrace(1).sensitivity);
traceVelscf = filter(Blp,Alp,detrend(double(mytrace(1).data./mytrace(1).sensitivity)));

sampletimes=linspace(mytrace(1).startTime,mytrace(1).endTime,mytrace(1).sampleCount);

% plot up velocity and acceleration traces with pulses detected.
figure(1); clf
subplot(3,1,1)
plot(sampletimes,traceVelsc,'k')
ylabel(mytrace(1).sensitivityUnits,'fontsize',14)
datetick
axis('tight'); ax=axis; set(gca,'ylim',[ax(3:4).*1.25]);
legend(sprintf('%s-%s',mytrace(1).location,mytrace(1).channel))
title(sprintf('%s %s-%s UTC, unfiltered',mytrace(1).station,datestr(mytrace(1).startTime,'yyyy-mm-dd HH:MM:SS'),datestr(mytrace(1).endTime,'HH:MM:SS')),'fontsize',14)
set(gca,'fontsize',12)

subplot(3,1,2)
plot(sampletimes,traceVelscf,'k')
ylabel(mytrace(1).sensitivityUnits,'fontsize',14)
datetick
axis('tight'); ax=axis; set(gca,'ylim',[ax(3:4).*1.25]);
legend(sprintf('%s-%s',mytrace(1).location,mytrace(1).channel))
title(sprintf('%s %s-%s UTC, 20s lowpass filtered',mytrace(1).station,datestr(mytrace(1).startTime,'yyyy-mm-dd HH:MM:SS'),datestr(mytrace(1).endTime,'HH:MM:SS')),'fontsize',14)
set(gca,'fontsize',12)

hold on
if ~isempty(pulse_res),
for n = 1:length(pulse_res(:,1)),
    plot([pulse_res(n,1) pulse_res(n,1)],ax(3:4),'r')
end
end

subplot(3,1,3)
hpulse(1)=plot(sampletimes,traceAccf,'k');
ylabel('m/s/s','fontsize',14)
datetick
axis('tight'); ax=axis; set(gca,'ylim',[ax(3:4).*1.25]);
title(sprintf('%s %s-%s UTC, sensor response removed',mytrace(1).station,datestr(mytrace(1).startTime,'yyyy-mm-dd HH:MM:SS'),datestr(mytrace(1).endTime,'HH:MM:SS')),'fontsize',14)
set(gca,'fontsize',12)

hold on
if ~isempty(pulse_res),
for n = 1:length(pulse_res(:,1)),
    hpulse(2)=plot([pulse_res(n,1) pulse_res(n,1)],ax(3:4),'r');
end
legend(hpulse,sprintf('%s-%s',mytrace(1).location,mytrace(1).channel),'pulse detection')
else
    legend(hpulse,sprintf('%s-%s',mytrace(1).location,mytrace(1).channel))
end
