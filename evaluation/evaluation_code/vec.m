function v = vec(A)
if iscell(A)
  v = cell2mat(cellfun(@(Aij) Aij(:), A, 'UniformOutput', false));
  v = v(:);
else
  v = A(:);
end