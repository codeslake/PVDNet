%Bradley and Ozhawa masking functions
%Niranjan Damera-Venkata
%March 1998

function y=cmaskn(c,ci,a,ai,i,N)

c=c(:);
ci=ci(:);

t=find(abs(ci)>1);
ci(t)=1;
ai=ai(:);
a=a(:);

ct=ctf(i);
T=ct*(.86*((c/ct)-1)+.3);

a1=find( (abs(ci-c)-T)<0);

ai(a1)=a(a1);

y=reshape(ai,N,N);

