%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%CODE FOR ANALYSIS OF TIME SERIES OF FLUORESCENT VOLTAGE IMAGING RECORDINGS
%
%AUTHOR: Victoria Gonzalez Sabater
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%FILE:main.m
%
%CODE DESCRIPTION:Code for importing series of tiff images, extracting a
%fluorescent profile from manualy selected ROIs and analysis of the
%resulting voltage trace.
%
%Read tiff files
%find folder
folder_name = uigetdir;
oldFolder = cd(folder_name);

% Calculate the number of image stacks, images per stack and total image number
dirOutput = dir (fullfile('Capture*.tif'));
fileNames = {dirOutput.name};
nsweeps = length(fileNames);
FileTif=fileNames{1};
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
s=length(InfoImage);
nFrames=s*nsweeps;

%Create array and load images
allarray=zeros(nImage,mImage,nFrames);
for p = 1:nsweeps
TifLink = Tiff(fileNames{p}, 'r');
for i=1:s
   TifLink.setDirectory(i);
   n=i+(p-1)*s;
   allarray(:,:,n)=double(TifLink.read());
end
TifLink.close();
end
cd(oldFolder);
%
%prepare to choose roi: do a z-max projection and autostretch
M = max(allarray, [], 3);
zmax=uint16(M);
cmax = imadjust(zmax,stretchlim(zmax),[]);
%cmax=cmax.*10;
imwrite(cmax, 'maxprojection.tif');
%
%choose roi
promptMessage = sprintf('Set desired zoom, then click START to choose ROIs. Pick as many ROIs as necessary.');
button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
if strcmpi(button, 'Cancel')
	return;
end
[mask] = draw_multiple_roi('maxprojection.tif');
  %crop chosen roi for all boutons out of original array and store in 5D
  %matrix (separated for sweeps and boutons). 
  bnum=size(mask,3);
  profile=zeros(nFrames,bnum);
 for b=1:bnum
 profile(:,b)=extractprofile_nobackground(allarray, mask(:,:,b));
 end

%split profile into repeats

sprofile=zeros(s,nsweeps,bnum);
for n=1:bnum
for p=1:nsweeps
sprofile (:,p,n) = profile((1+(p-1)*s):(p*s),n);
end
end

%show resulting profile

for b=1:bnum
 figure(b)
 plot(sprofile(:,:,b))
end

 promptMessage = sprintf('Do you want to save your analysis?');
button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
if strcmpi(button, 'Cancel')
	return;
end

folder_name = uigetdir;
oldFolder = cd(folder_name);
%save stuff
csvwrite('profile.csv',profile);
csvwrite('mask.csv',mask);
cd(oldFolder);

avg=zeros(1,s);
for j=1:s
avg (j) = mean(sprofile(j,:,1));
end

%select time point of stim using brush tool
hfig=figure('Name','Select time point of first stim');
p2=plot(avg,'b');
hbrush=brush;
set(hbrush,'Enable','on');
hstart = uicontrol('Position',[250 10 80 20],'String','Ok',...
              'Callback','uiresume(gcbf)');
uiwait(gcf); 
brushed_locs = get(p2, 'BrushData');
close(hfig);
stim1=find(brushed_locs==1);
%select time point of end of stim using brush tool
hfig=figure('Name','Select time point of end of train');
p2=plot(avg,'b');
hbrush=brush;
set(hbrush,'Enable','on');
hstart = uicontrol('Position',[250 10 80 20],'String','Ok',...
              'Callback','uiresume(gcbf)');
uiwait(gcf); 
brushed_locs = get(p2, 'BrushData');
close(hfig);
trainend=find(brushed_locs==1);

%get start of background position
hfig=figure('Name','Select time point of start of background');
p2=plot(avg,'b');
hbrush=brush;
set(hbrush,'Enable','on');
hstart = uicontrol('Position',[250 10 80 20],'String','Ok',...
              'Callback','uiresume(gcbf)');
uiwait(gcf);
brushed_locs = get(p2, 'BrushData');
close(hfig);
startprofile=find(brushed_locs==1);

profilebckg=zeros(50,1,bnum);
bckg=zeros(1,bnum);
for n=1:bnum
        for p = 1:50
        tempprofilebckg=(sprofile((startprofile+p),:,n));
        select = ~isnan( tempprofilebckg ) ; 
        profilebckg(p,n) = mean(tempprofilebckg(select));
        end
        bckg(1,n)=mean(profilebckg(:,n));
        sprofile(:,:,n)=sprofile(:,:,n)-bckg(1,n);
end
 
%set number of action potentials within train
apnum=5;

for p=1:bnum
p
%bleach correct trace
[~, bcprofile1, bcintprofile1, bcfiltprofile1,istim1]=bleachcorrect_interpolate(sprofile(:,:,p), stim1, trainend);
results_raw=zeros(6,apnum);
for n=1:apnum
[avg, amp_avg, SNR_avg,FWHM_avg, RT_avg, decay_avg, decay8020_avg]=analysis_1actionpotential(bcintprofile1,stim1,n);
results_raw(:,n)=[amp_avg;FWHM_avg;RT_avg;min(abs(decay_avg));decay8020_avg;SNR_avg];
end
avg_all_raw=transpose(avg);
end

folder_name = uigetdir;
oldFolder = cd(folder_name);
%save stuff
csvwrite('results.csv',results_raw);
csvwrite('avg_all.csv',avg_all_raw);
csvwrite('bcintprofile1.csv',bcintprofile1);
cd(oldFolder); 