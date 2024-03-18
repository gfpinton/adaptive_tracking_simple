function [displacement correlation] = launchSimple (rf,kernel_length,search_up,search_down,idc)

RF_t = size(rf,1);
RF_T = size(rf,2);
push_locations = size(rf,3); 

nullvec = zeros(0);
fid = fopen('rf.dat','wb')
fwrite(fid,nullvec);
fclose(fid)

fid = fopen('rf.dat','a')
for k=1:size(rf,3)
  for j=1:size(rf,2)
    fwrite(fid,rf(:,j,k),'double');
  end
end
fclose(fid);


fid=fopen('RF_t.dat','wb'); fwrite(fid,RF_t,'int'); fclose(fid);
fid=fopen('RF_T.dat','wb'); fwrite(fid,RF_T,'int'); fclose(fid);
fid=fopen('push_locations.dat','wb'); fwrite(fid,push_locations,'int'); fclose(fid);
fid=fopen('kernel_length.dat','wb'); fwrite(fid,kernel_length,'int'); fclose(fid);
fid=fopen('search_up.dat','wb'); fwrite(fid,search_up,'int'); fclose(fid);
fid=fopen('search_down.dat','wb'); fwrite(fid,search_down,'int'); fclose(fid);
fid=fopen('idc.dat','wb'); fwrite(fid,idc,'int'); fclose(fid);

%!./try2
try2_mex

fname='displacement.dat'
fid = fopen(fname,'rb');
displacement = fread(fid,'double=>float');
fclose(fid);
displacement = reshape(displacement,[],RF_T-1,push_locations);

fname='correlation.dat'
fid = fopen(fname,'rb');
correlation = fread(fid,'double=>float');
fclose(fid);
correlation = reshape(correlation,[],RF_T-1,push_locations);

