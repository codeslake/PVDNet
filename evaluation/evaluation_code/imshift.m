function xs = imshift(x, t, bbox)
% IMSHIFT x by d using subpixel interpolation.
%
% Input:    x      image to be shifted
%           t      2D vector, real
%           bbox   'crop' (default) or 'same' or 'full'
%
% Michael Hirsch, Stefan Harmeling * 16 August 2010

if ~exist('bbox', 'var')||isempty(bbox), bbox = 'crop'; end

if size(x,3) > 2
  for i = 1:size(x,3)
    xsi = colshift(x(:,:,i), t, bbox);
    if i == 1
      xs = zeros(size(xsi,1), size(xsi,2), size(x,3));
    end
    xs(:,:,i) = xsi;
  end
else
  xs = colshift(x, t, bbox);
end

return;

% --------------------------------------------------------------------------
% Helper function
% --------------------------------------------------------------------------

function xs = colshift(x, t, bbox)
sx = size(x);
switch bbox
  case {'crop','same'}
    if length(sx) == 1 || sx(2) == 1
        y = shiftmatrix(sx(1), -t(1)) * x;
    elseif length(sx) == 2
        y = shiftmatrix(sx(1), -t(1)) * x * shiftmatrix(sx(2), -t(2))';
    else
        error('not implemented yet')
    end
  case 'full'
    y = zeros(sx + abs(t));
    if t(1) >= 0 && t(2) >= 0
        y(1+t(1):end, 1+t(2):end) = x; 
    elseif t(1)<=0 && t(2)<=0
        y(1:end+t(1), 1:end+t(2)) = x;         
    elseif t(1)>=0 && t(2)<=0
        y(1+t(1):end, 1:end+t(2)) = x;             
    elseif t(1)<=0 && t(2)>=0
        y(1:end+t(1), 1+t(2):end) = x;  
    end
end

switch bbox
 case {'crop','full'}
  xs = y;
 case 'same'
  xs = zeros(sx);
  if t(1) >= 0 && t(2) >= 0
    xs(1+t(1):end, 1+t(2):end) = y; 
  elseif t(1)<=0 && t(2)<=0
    xs(1:end+t(1), 1:end+t(2)) = y;         
  elseif t(1)>=0 && t(2)<=0
    xs(1+t(1):end, 1:end+t(2)) = y;             
  elseif t(1)<=0 && t(2)>=0
    xs(1:end+t(1), 1+t(2):end) = y;  
  end
end
  