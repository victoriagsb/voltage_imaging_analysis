function [avg, amp_avg, SNR_avg, FWHM_avg, RT_avg, decay_avg, decay8020_avg]=analysis_1actionpotential(intprofile, stim1,apnumber)
s=size(intprofile,1);
nsweeps=size(intprofile,2);
time0=0:0.312:0.01*(length(intprofile(:,1))-1);
timei = 0:0.01:0.01*(length(intprofile(:,1))-1);
[~, istim1] = min(abs(timei-time0(stim1)));
%average trace
avg=zeros(1,s);
for j=1:s
avg (j) = mean(intprofile(j,:));
end
%amplitude
%select time point of stim using brush tool
apnumber
hfig=figure('Name','Select time point of the action potential to be analysed');
p2=plot(avg,'b');
hbrush=brush;
set(hbrush,'Enable','on');
hstart = uicontrol('Position',[250 10 80 20],'String','Ok',...
              'Callback','uiresume(gcbf)');
uiwait(gcf); 
brushed_locs = get(p2, 'BrushData');
close(hfig);
ap_loc=find(brushed_locs==1);
[dF_avg, peakpos_avg]=min(avg(ap_loc:(ap_loc+500)));
F_avg=mean(avg((istim1-1500):istim1));
peakpos_avg=peakpos_avg+ap_loc-1;
amp_avg=(dF_avg-F_avg)/F_avg;
%Calculate SNR (dF/F/sdF)
bline_avg=avg((istim1-1500):istim1);
sdF_avg = std(bline_avg);
SNR_avg=abs(amp_avg)/sdF_avg;

%FWHM from baseline to peak
peakprofile_avg=avg(ap_loc:(ap_loc+1000));
time=[0:0.01:(0.01*(length(peakprofile_avg)-1))];
HM_avg=(dF_avg-F_avg)/2+F_avg;
aboveHM_avg=peakprofile_avg<HM_avg;
FWHM_intpos1_avg = find(aboveHM_avg, 1, 'first');
FWHM_intpos2_avg = find(aboveHM_avg, 1, 'last');
FWHM_avg=time(FWHM_intpos2_avg)-time(FWHM_intpos1_avg);
FWHM_time1_avg = time(FWHM_intpos1_avg)+(ap_loc)*0.01-0.01;
FWHM_time2_avg = time(FWHM_intpos2_avg)+(ap_loc)*0.01-0.01;

%Calculate 20-80% rise time on the average
riseprofile_avg=avg(ap_loc:peakpos_avg);
%[~, t20] = min(abs(riseprofile_avg-(0.2*(dF_avg-F_avg)+F_avg)));
%[~, t80] = min(abs(riseprofile_avg-(0.8*(dF_avg-F_avg)+F_avg)));
mark20=F_avg+(dF_avg-F_avg)*0.2;
mark80=F_avg+(dF_avg-F_avg)*0.8;
below20mark=riseprofile_avg>mark20;
t20 = find(below20mark, 1, 'last');
above80mark=riseprofile_avg<mark80;
t80 = find(above80mark, 1, 'first');
TF = isempty(t20);
if TF==1
    t20=1;
    i20=peakprofile_avg(t20);
i80=peakprofile_avg(t80);
RT_avg=0;
else
    i20=peakprofile_avg(t20);
i80=peakprofile_avg(t80);
RT_avg=time(t80)-time(t20)-0.01;
end
t20_avg = time(t20)+ap_loc*0.01-0.01;
t80_avg = time(t80)+ap_loc*0.01-0.01;
%Calculate 80-20% decay time on the average
decayprofile_avg=avg((peakpos_avg+20):(ap_loc+1500));
time=[0:0.01:(0.01*(length(decayprofile_avg)-1))];
below20mark=decayprofile_avg>mark20;
t20d = find(below20mark, 1, 'first');
TF = isempty(t20d);
if TF==1
t20d=1000;
i20d=decayprofile_avg(t20d);
below80mark=decayprofile_avg>mark80;
t80d = find(below80mark, 1, 'first');
i80d=decayprofile_avg(t80d);
decay8020_avg=0;
else
i20d=decayprofile_avg(t20d);
below80mark=decayprofile_avg>mark80;
t80d = find(below80mark, 1, 'first');
i80d=decayprofile_avg(t80d);
decay8020_avg=time(t20d)-time(t80d);
end
t20d_avg = time(t20d)+(peakpos_avg+20)*0.01-0.01;
t80d_avg = time(t80d)+(peakpos_avg+20)*0.01-0.01;
%fit double exponential to average decay profile and calculate decay tau
decayprofile=transpose(decayprofile_avg);
decaytime=[0:0.01:(0.01*(length(decayprofile)-1))];
decaytime=transpose(decaytime);
decayfit = fit(decaytime, decayprofile,'exp2');
decayfig=decayfit(decaytime);
decay_coeff = coeffvalues(decayfit);
decay_avg=zeros(1,2);
decay_avg(1)=-1/decay_coeff(2);
decay_avg(2)=-1/decay_coeff(4);
%plot it all to check
time=[0:0.01:(0.01*(length(avg)-1))];
hfig=figure;
plot(time,intprofile,':k')
hold on
plot(time,avg,'r', 'LineWidth',1.5)
hold on
plot(time(peakpos_avg),avg(peakpos_avg),'p','MarkerSize',10, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'm')
hold on
line([FWHM_time1_avg FWHM_time2_avg], [HM_avg HM_avg], 'Color', 'b', 'LineWidth', 2);
hold on
line([t20_avg t80_avg], [i20 i80], 'Color', 'c', 'LineWidth', 2);
hold on
line([t20d_avg t80d_avg], [i20d i80d], 'Color', 'y', 'LineWidth', 2);
hold on
plot(time((peakpos_avg+20):(ap_loc+1500)),decayfig,'c', 'LineWidth',2)
waitfor(hfig)

end