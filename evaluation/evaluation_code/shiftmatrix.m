function A = shiftmatrix(n, d)

if length(n) == 1 || n(2) == 1
  A = shiftmatrix1d(n, d);
elseif length(n) == 2
  A1 = shiftmatrix1d(n(1), d(1));
  A2 = shiftmatrix1d(n(2), d(2));
  A = kron(A1, A2);
else
  error('not implemented yet');
end


function A = shiftmatrix1d(n, d)

sd = sign(d);
d = abs(d);
m = n - ceil(d);  % size of the new vector
if m < 0
  error('n must be greater than abs(d)')
end
cd = ceil(d);
d = d - cd + 1;
if sd > 0
  A = [zeros(m, cd), speye(m), zeros(m, cd-1), speye(m), zeros(m, 1)];
  B = kron([d; 1-d], speye(n));
elseif sd == 0
  A = [speye(m), speye(m)];
  B = kron([d; 1-d], speye(n));
else
  A = [zeros(m, 1), speye(m), zeros(m, cd-1), speye(m), zeros(m, cd)];
  B = kron([1-d; d], speye(n));
end
A = A * B;
