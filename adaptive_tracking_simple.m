%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITTEN BY GIANMARCO PINTON 
% FIRST CREATED:  2014-11-19
% LAST MODIFIED: 2024-03-18
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load NL_Oblique_100Hz_5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:10:size(IQ,3)
  imagesc(abs(IQ(:,:,k)))
  drawnow
end

%rf=IQ2RF(IQ,fs,fc,nt,nZ);
%for k=1:size(rf,3)
%  imagesc(squeeze(rf(:,:,k))), colorbar, title(num2str(k)),drawnow
%end

fc = UF.TwFreq*1e6;
omega0 = 2*pi*fc;
c0=1540;
fs=60e6;

dep=(UFBfInfo.Depth(2)-UFBfInfo.Depth(1))*1e-3;
tline=dep/c0;
dT2=tline/size(IQ,1);

fs=80e6;
nT = round(size(IQ,1)*fs*dT2);
rf=IQ2RF(IQ(:,:,[500 502]),fs,fc,nT,size(IQ,1));
for k=1:10:size(rf,3)
  imagesc(abs(rf(:,:,k)))
  title(num2str(k))
  drawnow
end

u = kasai(real(IQ(:,:,500)),imag(IQ(:,:,500)),real(IQ(:,:,502)),real(IQ(:,:,502)),1540,8e6);
imagesc(u)
axis1=(1:size(IQ,1))/size(IQ,1)*4;
axis2=(1:size(IQ,2))*0.05;
imagesc(axis2,axis1,u*5000)
caxis([-1 1]*1.5), axis equal, axis tight
xlabel('Lateral (cm)'), ylabel('Depth (cm)')
cbar=colorbar
title(cbar,'m/s')
colormap jet
print -djpeg figures/kasai2
print -depsc figures/kasai2
colormap gray 
print -djpeg figures/kasai2_bw
print -depsc figures/kasai2_bw


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Non-adaptive tracking 10000 Frame rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fs=80e6;
nT = round(size(IQ,1)*fs*dT2);
rf=IQ2RF(IQ(:,:,[500 501]),fs,fc,nT,size(IQ,1));
for k=1:10:size(rf,3)
  imagesc(abs(rf(:,:,k)))
  title(num2str(k))
  drawnow
end

rf2=permute(rf,[1 3 2]);
push_locations = size(rf2,3);
thresh=0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dd=zeros(length(rf2),push_locations); 
cc=zeros(length(rf2),push_locations); 
idcc=zeros(length(rf2),push_locations);
idc=zeros(length(rf2),push_locations);
err=0; 
M=8; skr=1/8; sfac = 0.5 
kernel_length=round(fs/fc*M)
search_up=round(kernel_length*skr); 
search_down=search_up 
kernel_length_min=round(fs/fc);

counter=1;
while(kernel_length>kernel_length_min)
  % displacement and correlation
  [displacement correlation]=launchSimple(rf2,kernel_length,search_up,search_down,idc);
  cc(search_up+round(kernel_length/2)+1:search_up+round(kernel_length/2)+length(displacement),:,counter)=squeeze(correlation);
  dd(search_up+round(kernel_length/2)+1:search_up+round(kernel_length/2)+length(displacement),:,counter)=squeeze(displacement);
  
  % intial estimate filtering
  idc=dd(:,:,counter);
  idc(find(cc(:,:,counter)<thresh))=0;
  idc=round(idc);
  idcc(:,:,counter)=idc;
  
  figure(1)
  plot(-dd(:,1,counter),'r')
  title(num2str(counter))
  grid on
  ylim([-1 1]*10)

  figure(2)
  imagesc(idcc(:,:,end),[-1 1]*12), colorbar
  title(num2str(counter))

  figure(3)
  imagesc(dd(:,:,end),[-1 1]*12), colorbar
  title(num2str(counter))
    
  figure(4)
  imagesc(dd(:,:,1),[-1 1]*12), colorbar
  title(num2str(1))

  
  drawnow
  
  counter = counter+1;
  M=M*sfac;   
  kernel_length=round(fs/fc*M)
  search_up=round(kernel_length*skr); search_down=search_up
end

ncc_a.idcc=idcc; ncc_a.dd=dd; ncc_a.cc=cc; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quality weighted adaptive tracking 10000 Frame rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dd=zeros(length(rf2),push_locations); 
cc=zeros(length(rf2),push_locations); 
idcc=zeros(length(rf2),push_locations);
idc=zeros(length(rf2),push_locations);
err=0; 
M=8; skr=1/8; sfac = 0.5 
kernel_length=round(fs/fc*M)
search_up=round(kernel_length*skr); 
search_down=search_up 
kernel_length_min=round(fs/fc);

counter=1;
while(kernel_length>kernel_length_min)
  % displacement and correlation
  [displacement correlation]=launchSimple(rf2,kernel_length,search_up,search_down,idc);
  cc(search_up+round(kernel_length/2)+1:search_up+round(kernel_length/2)+length(displacement),:,counter)=squeeze(correlation);
  dd(search_up+round(kernel_length/2)+1:search_up+round(kernel_length/2)+length(displacement),:,counter)=squeeze(displacement);
  
  % intial estimate filtering
  idc=dd(:,:,counter);
  idx=find(cc(:,:,counter)<thresh);
  B=ones(size(idc)); B(idx)=0;
  idc=medfilt2_thresh(idc,B,[20 4]);
  idc=round(idc);
  idcc(:,:,counter)=idc;

  figure(1)
  plot(-dd(:,1,counter),'r')
  title(num2str(counter))
  grid on
  ylim([-1 1]*10)

  figure(2)
  imagesc(idcc(:,:,end),[-1 1]*12), colorbar
  title(num2str(counter))

  figure(3)
  imagesc(dd(:,:,end),[-1 1]*12), colorbar
  title(num2str(counter))
    
  figure(4)
  imagesc(dd(:,:,1),[-1 1]*12), colorbar
  title(num2str(1))

  
  drawnow
  
  counter = counter+1;
  M=M*sfac;   
  kernel_length=round(fs/fc*M)
  search_up=round(kernel_length*skr); search_down=search_up
end

ncc_a_m_w.idcc=idcc; ncc_a_m_w.dd=dd; ncc_a_m_w.cc=cc; 


figure(1)
imagesc(ncc_a.dd(:,:,end),[-1 1]*12), colorbar
title(['Normalized cross correlation'])
figure(2)
imagesc(ncc_a_m_w.dd(:,:,end),[-1 1]*12), colorbar
title('Quality-weighted adaptive normalized cross-correlation')
