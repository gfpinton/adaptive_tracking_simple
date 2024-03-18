function [RF] = IQ2RF (IQ,fs,fc,nt,nZ)

RF = zeros(nt,size(IQ,2),size(IQ,3));

idx = (0:nt-1)/(nt-1)*(nZ-1)+1;
t = 0:1/fs:(nt-1)/fs;

fprintf(1,'Progress:     ');
for j=1:size(IQ,2)
fprintf(1,'\b\b\b\b\b%0.3f',j/size(IQ,2));
  parfor k=1:size(IQ,3)    
    I = interp1(real(IQ(:,j,k)),idx,'spline');
    Q = interp1(imag(IQ(:,j,k)),idx,'spline');
    RF(:,j,k) = I.*cos(2*pi*fc*t)+Q.*sin(2*pi*fc*t);
  end
end
fprintf(1,'\n');
    
