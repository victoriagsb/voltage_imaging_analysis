function [mask]=draw_multiple_roi(x)
% Create figure, setting up properties
hfig = figure('Toolbar','none',...
              'Menubar', 'none',...
              'Name','Choose ROIs',...
              'NumberTitle','off',...
              'IntegerHandle','off');

% Display image in the figure
himage = imshow(x);

%add scrollbar and magnification tool
hpanel = imscrollpanel(hfig,himage);
hMagBox = immagbox(hfig,himage);

hstart = uicontrol('Position',[320 30 50 15],'String','Start',...
              'Callback','uiresume(gcbf)');
uiwait(gcf); 
% Call draw rectangle tool and extract position of the rectangle for each
% ROI
%Bouton ROI
count = 0;
while(1)
count = count + 1;
BW = roipoly;
mask(:,:,count) = double(BW);
choice = sprintf('Pick another ROI?');
button = questdlg(choice, 'confirm', 'yes', 'no', 'no');
  if strcmpi(button,'no')
      break; 
  end
end
close (hfig);
end
