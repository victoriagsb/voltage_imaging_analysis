function [intprofile3, bcprofile, bcintprofile, bcintprofile3,istim1]=bleachcorrect_interpolate(sprofile, stim1, trainend)
s=size(sprofile,1);
nsweeps=size(sprofile,2);
%define array for filtered profile and apply averaging filter over a
%sliding window of 3
filtprofile=zeros(s, nsweeps);
coeff3 = ones(1, 3)/3;
coeff5 = ones(1, 5)/5;
delay = mean(grpdelay(coeff3,1));
for p = 1:nsweeps
    filtprofile(:,p) = filter(coeff3, 1, sprofile(:,p)); 
end
%delete values corresponding to delay created by filter and correct first
%value, substituting it by the second value.
filtprofile(1:delay,:)=[];
filtprofile(1,:)=filtprofile(2,:);
%define time scale vectors, where timef corresponds to filtered data, time0
%is original data and timei is interpolated values
timef=0:0.312:0.312*(length(filtprofile(:,1))-1);
time0=0:0.312:0.312*(length(sprofile(:,1))-1);
timeif = 0:0.01:0.312*(length(filtprofile(:,1))-1);
timei = 0:0.01:0.312*(length(filtprofile(:,1)));
[~, istim1] = min(abs(timeif-time0(stim1)));
[~, itrainend] = min(abs(timeif-time0(trainend)));
%interpolate data, resampled at frequency defined by timei
intprofile3=zeros(length(timeif), nsweeps);
for p = 1:nsweeps
    intprofile3(:,p) = spline(timef,filtprofile(:,p),timeif); 
end
intprofile=zeros(length(timei), nsweeps);
for p = 1:nsweeps
    intprofile(:,p) = spline(time0,sprofile(:,p),timei); 
end
%bleach correct
%select points with light but no stim in profile and time vector of
%interpolated data
bleachprofile=[intprofile3((istim1-40000):istim1,:); intprofile3(itrainend:(itrainend+5000),:)];
bleachtime=transpose([timeif(1,(istim1-40000):istim1),timeif(1,itrainend:(itrainend+5000))]);
%fit double exponential to those points, resample at original data frequency
%and correct original data. Same for interpolated profile
bcprofile=zeros(size(sprofile));
bcintprofile3=zeros(size(intprofile3));
bcintprofile=zeros(size(intprofile));
for p=1:nsweeps
bleachfit = fit(bleachtime(:,1), bleachprofile(:,p),'exp1');
bleachfactor=bleachfit(time0);
ibleachfactor=bleachfit(timeif);
intbleachfactor=bleachfit(timei);
bcprofile(:,p)=sprofile(:,p)./bleachfactor;
bcintprofile3(:,p)=intprofile3(:,p)./ibleachfactor;
bcintprofile(:,p)=intprofile(:,p)./intbleachfactor;
end

fh=figure(p);
plot(bcintprofile((istim1-50000):(itrainend+5000),:),'r')
waitfor(fh)
end