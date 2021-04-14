%Global detection thresholds
%Niranjan Damera-Venkata
%March 1998

function y=gthresh(x,T,z,N)

x=x(:);
z=z(:);
a=find(abs(x)<T);

z(a)=zeros(size(a));

y=reshape(z,N,N);
