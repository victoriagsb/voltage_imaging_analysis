function [profile]=extractprofile_nobackground(allarray, mask)
nFrames=size(allarray,3);
roi=zeros(size(mask,1),size(mask,2),nFrames);
 roi(:,:,:) = allarray(:,:,:).*mask(:,:);
  %extract intensity profile over time
profile=zeros(nFrames,1);
    for p = 1:nFrames
        profile(p) = mean2(nonzeros(roi(:,:,p)));
    end
end