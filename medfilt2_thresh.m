% GIANMARCO PINTON

function A3 = medfilt2_thresh(A,B,vec)

if(max(size(vec))==1)
  Nhalfx=vec;
  Nhalfy=vec;
end
if(max(size(vec))==2)
  Nhalfx=vec(1);
  Nhalfy=vec(2);
end

%B=zeros(size(A));
%B(find(A>0.5))=1;
A2=padarray(A,[Nhalfx Nhalfy],'symmetric');
B2=padarray(B,[Nhalfx Nhalfy],'symmetric');
A3=zeros(size(A));
Nhalf=4;
for i=Nhalfx+1:size(A2,1)-Nhalfx
  for j=Nhalfy+1:size(A2,2)-Nhalfy
    Amat=A2(i-Nhalfx:i+Nhalfx,j-Nhalfy:j+Nhalfy);
    Bmat=B2(i-Nhalfx:i+Nhalfx,j-Nhalfy:j+Nhalfy);
    ord=round(length(find(Bmat==1))/2);
    if(ord)
      C=ordfilt2(Amat,ord,Bmat);
      A3(i-Nhalfx,j-Nhalfy)=C(Nhalfx+1,Nhalfy+1);
    end
  end
end
