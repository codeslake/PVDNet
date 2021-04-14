function [index map gabors] = MAD_index( ref_img, dst_img, thresh )
% MAD_INDEX Compute Perceived Difference of two images
%   index = MAD_INDEX(ref_img, dst_img) where ref_img and dst_img are
%   uint8 images and dst_img is a distorted version of ref_img
%   returns the similarity score for the reference and distorted image as 
%   a structure:
%     index.MAD: the difference score, higher means more different
%     index.LO : the difference score based on assumption that distortions
%       are highly visible (low quality image)
%     index.HI : the difference score based on assumption that distortions
%       are diffcult to see (high quality image)
%     index.sig: blending parameter used to mix HI and LO into MAD score
% 
% [index map] = MAD_INDEX(ref_img, dst_img) also returns maps used
% in calculating the scores:
%   map.LO: returns an estimate of perceived annoyance of the highly 
%     visible distortion artifacts as an image the same size as the inputs
%   map.HI: returns an estimate of the visibility of artifacts in the image
%     as an image the same size as the inputs

% Author: Eric Larson
% Department of Electrical and Computer Engineering
% Oklahoma State University, 2008
% University Of Washington Seattle, 2009
% Image Coding and Analysis Lab

% 2008: Eric Larson, MAD code creation
% 2009: Eric Larson, Added mex file support
% 2010: (april) Releasing beta version of code
% 2010: (june) Fixed constant of 200 on d_detect
% 2010: (november) Fixed output gabor handling and non integer input images
% 2011: (september) Mad is now faster!

if( nargin == 0 )
  %error( 'No valid input given. Please provide images or image names.' );
  index = hi_index;
  return;
elseif( ~isinteger( ref_img ) && ~isfloat( ref_img ))
  % read in the image names
  ref_img = imread( ref_img );
  dst_img = imread( dst_img );
end

% Parameterize the input
% Initializations
index.LO  = -1;
index.HI  = -1;
index.MAD = -1;
map.LO    = zeros( size( ref_img ) );
map.HI    = zeros( size( ref_img ) );
map.sig   = -1;

% Ready data for processing
if( ndims( ref_img ) == 3 )
  ref_img = myrgb2gray( ref_img );
end

if( ndims( dst_img ) == 3 )
  dst_img = myrgb2gray( dst_img );
end

ref = double( ref_img );
dst = double( dst_img );

% Calculate high quality index
% Calculate low quality index

[index.HI map.HI] = hi_index( ref_img, dst_img );

if nargout >= 3
  [index.LO map.LO gabors] = lo_index( ref, dst );
else  
  [index.LO map.LO] = lo_index( ref, dst );  
end

% Combine outputs using sigmoid blend
if( nargin > 3 )
  thresh1 = thresh(1);
  thresh2 = thresh(2);
else
  thresh1   = 2.55;
  thresh2   = 3.35;
end
b1        = exp(-thresh1/thresh2);
b2        = 1/(log(10)*thresh2);

sig       = 1 ./ ( 1 + b1*index.HI^b2 ) ;
index.sig   = sig;
index.MAD = ( index.LO^(1-sig) .* index.HI.^(sig) );

% Not used, reserved for future version of MAD
%[map.ADAPT map.ALPHA index.SMAD] = adapt_map(map,[thresh1 thresh2]);
% profile off
% profile report

end

%===========================================
% OTHER FUNCTIONS
%-------------------------------------------

%-----------------------------------------------------
function [I mp imgs] = hi_index( ref_img, dst_img )
% Calculate the high quality index by calculating the masking map and
% then approximating the local statistics, using filtering.
% Author: Eric Larson
% Department of Electrical and Computer Engineering
% Oklahoma State University, 2008
% Image Coding and Analysis Lab

% Masking/luminance parameters
k = 0.02874;
G = 0.5 ;       % luminance threshold
C_slope = 1;    % slope of detection threshold
Ci_thrsh= -5;   % contrast to start slope, rather than const threshold
Cd_thrsh= -5;   % saturated threshold
ms_scale= 1;    % scaling constant
if(nargin==0)% for debug only,
  I={'collapsing (mask) and raw lmse',...
    'using c code',...
    'using log scale',...
    'two norm',...
    sprintf('Ci = %.2f',Ci_thrsh),...
    sprintf('Cslope = %.2f',C_slope),...
    sprintf('Cd = %.2f',Cd_thrsh),...
    sprintf('G = %.2f',G),...
    'LO QUALITY',...
    };
  return;
end
% log(Contrast of  ref-dst)   vs.   log(Contrast of reference)
%              /
%             /
%            /  _| <- Cslope
%           /
%----------+ <- Cdthresh (y axis height)
%          /\
%          ||
%       Ci thresh (x axis value)

% TAKE TO LUMINANCE DOMAIN USING LUT
if isinteger(ref_img)
   LUT = 0:1:255; %generate LUT  
   LUT = k .* LUT .^ (2.2/3);
  ref = LUT( ref_img + 1 );
  dst = LUT( dst_img + 1 );
else % don't use the speed up
  ref = k .* ref_img .^ (2.2/3);
  dst = k .* dst_img .^ (2.2/3);
end

[M N] = size( ref );

% ACCOUNT FOR CONTRAST SENSITIVITY
csf = make_csf( M, N, 32 )';
ref = real( ifft2( ifftshift( fftshift( fft2( ref ) ).* csf ) ) );
dst = real( ifft2( ifftshift( fftshift( fft2( dst ) ).* csf ) ) );
refS = ref;
dstS = dst;

% Use c code to get fast local stats
[std_2 std_1 m1_1] = ical_std( dst-ref, ref );

BSIZE = 16;

Ci_ref = log(std_1./m1_1); % contrast of reference (also a measure of entropy)
Ci_dst = log(std_2./m1_1); % contrast of distortions (also a measure of entropy)
Ci_dst( find( m1_1 < G ) ) = -inf;

msk       = zeros( size(Ci_dst) );
idx1      = find( (Ci_ref > Ci_thrsh) ...
  & (Ci_dst > (C_slope * (Ci_ref - Ci_thrsh) + Cd_thrsh) ) );
idx2      = find( (Ci_ref <= Ci_thrsh) & (Ci_dst > Cd_thrsh) );

msk(idx1) = ( Ci_dst( idx1 ) - (C_slope * (Ci_ref( idx1 )-Ci_thrsh) + Cd_thrsh) ) ./ ms_scale;
msk(idx2) = ( Ci_dst( idx2 ) - Cd_thrsh ) ./ ms_scale;
%= ( Contrast of heavy Dst - 0.75 * Contrast Ref ) / normalize
%= ( Contrast of low Dst  - Threshold ) / normalize

% Use lmse and weight by distortion mask
win = ones( BSIZE ) ./ BSIZE^2;

% Michael Hirsch: replaced imfilter with filter2 which is shipped
% with MATLAB -> no need for image toolbox
%lmse  = ( imfilter( ( double(ref_img) - double(dst_img) ).^2, ...
%  win,  'symmetric', 'same', 'conv' ) );
lmse  = ( filter2( win, ( double(ref_img) - double(dst_img) ).^2, 'same' ) );

mp    = msk .* lmse;

% kill the edges
mp2 = mp( BSIZE+1:end-BSIZE-1, BSIZE+1:end-BSIZE-1);

I = norm( mp2(:) , 2 ) ./ sqrt( length( mp2(:) ) ) .* 200;

if( nargout > 2)
  imgs.ref = refS;
  imgs.dst = dstS;
end


end
%-----------------------------------------------------

% %-----------------------------------------------------
function [I mp gabors] = lo_index( ref, dst )
% Calculate the low quality index by calculating the Gabor analysis and
% then the local statistics,
% Author: Eric Larson
% Department of Electrical and Computer Engineering
% Oklahoma State University, 2008
% Image Coding and analysis lab


% Decompose using Gabor Analysis
gabRef  = gaborconvolve( double( ref ) );
gabDst  = gaborconvolve( double( dst ) );

[M N]   = size( gabRef{1,1} );
O       = size( gabRef, 1 ) * size( gabRef, 2 );
s       = [0.5 0.75 1 5 6];
mp      = zeros( M, N );
s       = s./sum(s(:));


if( nargout == 3)
  gabors.dst = zeros( M, N, 5*4*3 );
  gabors.ref = zeros( M, N, 5*4*3 );
end

im_k = 0;
BSIZE = 16;
for gb_i = 1:5
  for gb_j = 1:4
    
    im_k  = im_k + 1;
    fprintf('%d ',im_k)
    
    if( nargout == 3 )
      [gabors.ref(:,:,3*(im_k-1)+1), gabors.ref(:,:,3*(im_k-1)+2), gabors.ref(:,:,3*(im_k-1)+3)] ...
        = ical_stat( abs( gabRef{gb_i,gb_j} ) );
      
      [gabors.dst(:,:,3*(im_k-1)+1), gabors.dst(:,:,3*(im_k-1)+2), gabors.dst(:,:,3*(im_k-1)+3)] ...
        = ical_stat( abs( gabDst{gb_i,gb_j} ) );
      
    else
      % otherwise keep memory footprint to a minimum
      [std.ref, skw.ref, krt.ref] ...
        = ical_stat( abs( gabRef{gb_i,gb_j} ) );
      [std.dst, skw.dst, krt.dst] ...
        = ical_stat( abs( gabDst{gb_i,gb_j} ) );
      
      mp = mp + s(gb_i) .* ( abs( std.ref - std.dst )... std
        + 2.*abs( skw.ref - skw.dst )...              skew
        +    abs( krt.ref - krt.dst ) ); %        kurtosis
    end
  end
end

fprintf('\n ')

% kill the edges
mp2 = mp( BSIZE+1:end-BSIZE-1, BSIZE+1:end-BSIZE-1);

I = norm( mp2 (:), 2 ) / sqrt( length( mp2(:) ) ) ;
% = norm of statistical diff map / ( root image size * normalization )
end
%-----------------------------------------------------
% %-----------------------------------------------------
% function [I mp gabors] = lo_index( ref, dst )
% % Calculate the low quality index by calculating the Gabor analysis and
% % then the local statistics,
% % Author: Eric Larson
% % Department of Electrical and Computer Engineering
% % Oklahoma State University, 2008
% % Image Coding and analysis lab
% 
% % Decompose using Gabor Analysis
% gabRef  = gaborconvolve( double( ref ) );
% gabDst  = gaborconvolve( double( dst ) );
% [M N]   = size( gabRef{1,1} );
% O       = size( gabRef, 1 ) * size( gabRef, 2 );
% s       = [0.5 0.75 1 5 6];
% mp      = zeros( M, N );
% mp_cell = cell(5*4,1);
% s       = s./sum(s(:));
% NAR = nargout;
% 
% if( NAR == 3)
% %   gabors.dst = zeros( M, N, 5*4*3 );
% %   gabors.ref = zeros( M, N, 5*4*3 );
%   gabors_dst1 = cell(5*4,1);
%   gabors_dst2 = cell(5*4,1);
%   gabors_dst3 = cell(5*4,1);
%   gabors_ref1 = cell(5*4,1);
%   gabors_ref2 = cell(5*4,1);
%   gabors_ref3 = cell(5*4,1);
% end
% 
% % im_k = 0;
% BSIZE = 16;
% % for gb_i = 1:5
% %   for gb_j = 1:4
% %     im_k  = im_k + 1;
% if( NAR == 3 )
%   parfor it=1:20
%     im_k = it;
%     gb_j = mod(it-1,4)+1;
%     gb_i = (it - gb_j)/4 + 1;
%       fprintf('%d ',im_k)
% %       [gabors.ref(:,:,3*(im_k-1)+1), gabors.ref(:,:,3*(im_k-1)+2), gabors.ref(:,:,3*(im_k-1)+3)] ...
% %          = ical_stat( abs( gabRef{gb_i,gb_j} ) );
%         [gabors_ref1{it} gabors_ref2{it} gabors_ref3{it}] = ical_stat( abs( gabRef{gb_i,gb_j} ) );
%        
% %       [gabors.dst(:,:,3*(im_k-1)+1), gabors.dst(:,:,3*(im_k-1)+2), gabors.dst(:,:,3*(im_k-1)+3)] ...
% %          =    ical_stat( abs( gabDst{gb_i,gb_j} ) );
%         [gabors_dst1{it} gabors_dst2{it} gabors_dst3{it}] =  ical_stat( abs( gabDst{gb_i,gb_j} ) );
%   end
% else
%   parfor it=1:20
%     im_k = it;
%     gb_j = mod(it-1,4)+1;
%     gb_i = (it - gb_j)/4 + 1;
%       fprintf('%d ',im_k)
%       % otherwise keep memory footprint to a minimum
%       [std_ref, skw_ref, krt_ref] ...
%         = ical_stat( abs( gabRef{gb_i,gb_j} ) );
%       [std_dst, skw_dst, krt_dst] ...
%         = ical_stat( abs( gabDst{gb_i,gb_j} ) );
%       
%       mp_cell{it} = s(gb_i) .* ( abs( std_ref - std_dst )... std
%         + 2.*abs( skw_ref - skw_dst )...              skew
%         +    abs( krt_ref - krt_dst ) ); %        kurtosis
%   end
% end
% 
% % Process variables after parfor!
% if( NAR == 3)
%   gabors.dst = zeros( M, N, 5*4*3 );
%   gabors.ref = zeros( M, N, 5*4*3 );
%   for im_k=1:20
%     gabors.ref(:,:,3*(im_k-1)+1) = gabors_ref1{im_k};
%     gabors.ref(:,:,3*(im_k-1)+2) = gabors_ref2{im_k};
%     gabors.ref(:,:,3*(im_k-1)+3) = gabors_ref3{im_k};
%     gabors.dst(:,:,3*(im_k-1)+1) = gabors_dst1{im_k};
%     gabors.dst(:,:,3*(im_k-1)+2) = gabors_dst2{im_k};
%     gabors.dst(:,:,3*(im_k-1)+3) = gabors_dst3{im_k};
%   end
% else
%   for it=1:20
%     mp = mp + mp_cell{it};
%   end
% end
% 
% fprintf('\n ')
% 
% % kill the edges
% mp2 = mp( BSIZE+1:end-BSIZE-1, BSIZE+1:end-BSIZE-1);
% 
% I = norm( mp2 (:), 2 ) / sqrt( length( mp2(:) ) ) ;
% % = norm of statistical diff map / ( root image size * normalization )
% end
% %-----------------------------------------------------

%-----------------------------------------------------
function [res] = make_csf(x, y, nfreq)
[xplane,yplane]=meshgrid(-x/2+0.5:x/2-0.5, -y/2+0.5:y/2-0.5);	% generate mesh
plane=(xplane+1i*yplane)/y*2*nfreq;
radfreq=abs(plane);				% radial frequency

% We modify the radial frequency according to angle.
% w is a symmetry parameter that gives approx. 3 dB down along the
% diagonals.
w=0.7;
s=(1-w)/2*cos(4*angle(plane))+(1+w)/2;
radfreq=radfreq./s;

% Now generate the CSF
csf = 2.6*(0.0192+0.114*radfreq).*exp(-(0.114*radfreq).^1.1);
f=find( radfreq < 7.8909 ); csf(f)=0.9809+zeros(size(f));

res = csf;
end
%-----------------------------------------------------
% 
% %-----------------------------------------------------
% function EO = gaborconvolve( im )
% % GABORCONVOLVE - function for convolving image with log-Gabor filters
% %
% %   Usage: EO = gaborconvolve(im,  nscale, norient )
% %
% % For details of log-Gabor filters see:
% % D. J. Field, "Relations Between the Statistics of Natural Images and the
% % Response Properties of Cortical Cells", Journal of The Optical Society of
% % America A, Vol 4, No. 12, December 1987. pp 2379-2394
% % Notes on filter settings to obtain even coverage of the spectrum
% % dthetaOnSigma 1.5
% % sigmaOnf  .85   mult 1.3
% % sigmaOnf  .75   mult 1.6     (bandwidth ~1 octave)
% % sigmaOnf  .65   mult 2.1
% % sigmaOnf  .55   mult 3       (bandwidth ~2 octaves)
% %
% % Author: Peter Kovesi
% % Department of Computer Science & Software Engineering
% % The University of Western Australia
% % pk@cs.uwa.edu.au  www.cs.uwa.edu.au/~pk
% %
% % May 2001
% % Altered, 2008, Eric Larson
% 
% nscale          = 5;      %Number of wavelet scales.
% norient         = 4;      %Number of filter orientations.
% minWaveLength   = 3;      %Wavelength of smallest scale filter.
% mult            = 3;      %Scaling factor between successive filters.
% sigmaOnf        = 0.55;   %Ratio of the standard deviation of the
% %Gaussian describing the log Gabor filter's transfer function
% %in the frequency domain to the filter center frequency.
% %Orig: 3 6 12 27 64
% wavelength      = [minWaveLength ...
%   minWaveLength*mult ...
%   minWaveLength*mult^2 ...
%   minWaveLength*mult^3 ...
%   minWaveLength*mult^4 ];
% 
% dThetaOnSigma   = 1.5;    %Ratio of angular interval between filter orientations
% % 			       and the standard deviation of the angular Gaussian
% % 			       function used to construct filters in the
% %                              freq. plane.
% 
% 
% [rows cols] = size( im );
% imagefft    = fft2( im );            % Fourier transform of image
% 
% EO = cell( nscale, norient );        % Pre-allocate cell array
% 
% % Pre-compute to speed up filter construction
% 
% x = ones(rows,1) * (-cols/2 : (cols/2 - 1))/(cols/2);
% y = (-rows/2 : (rows/2 - 1))' * ones(1,cols)/(rows/2);
% radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius from centre.
% radius(round(rows/2+1),round(cols/2+1)) = 1; % Get rid of the 0 radius value in the middle
% % so that taking the log of the radius will
% % not cause trouble.
% 
% % Precompute sine and cosine of the polar angle of all pixels about the
% % centre point
% 
% theta = atan2(-y,x);              % Matrix values contain polar angle.
% % (note -ve y is used to give +ve
% % anti-clockwise angles)
% sintheta = sin(theta);
% costheta = cos(theta);
% clear x; clear y; clear theta;      % save a little memory
% 
% thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
% % angular Gaussian function used to
% % construct filters in the freq. plane.
% % The main loop...
% for o = 1:norient,                   % For each orientation.
%   fprintf('.');
%   angl = (o-1)*pi/norient;           % Calculate filter angle.
%   
%   % Pre-compute filter data specific to this orientation
%   % For each point in the filter matrix calculate the angular distance from the
%   % specified filter orientation.  To overcome the angular wrap-around problem
%   % sine difference and cosine difference values are first computed and then
%   % the atan2 function is used to determine angular distance.
%   
%   ds = sintheta * cos(angl) - costheta * sin(angl);     % Difference in sine.
%   dc = costheta * cos(angl) + sintheta * sin(angl);     % Difference in cosine.
%   dtheta = abs(atan2(ds,dc));                           % Absolute angular distance.
%   spread = exp((-dtheta.^2) / (2 * thetaSigma^2));      % Calculate the angular filter component.
%   
%   for s = 1:nscale,                  % For each scale.
%     
%     % Construct the filter - first calculate the radial filter component.
%     fo = 1.0/wavelength(s);                  % Centre frequency of filter.
%     rfo = fo/0.5;                         % Normalised radius from centre of frequency plane
%     % corresponding to fo.
% %     logGabor = exp(    (-(log(radius/rfo)).^2) / (2 * log(sigmaOnf)^2)    );
%     logGabor = exp(    (-(log(radius/rfo)).^2) / (2 * log(sigmaOnf)^2)    );
%     logGabor( round(rows/2+1), round(cols/2+1) ) = 0; % Set the value at the center of the filter
%     % back to zero (undo the radius fudge).
%     
%     filter = fftshift( logGabor .* spread ); % Multiply by the angular spread to get the filter
%     % and swap quadrants to move zero frequency
%     % to the corners.
%     
%     % Do the convolution, back transform, and save the result in EO
%     EO{s,o} = ifft2( imagefft .* filter );
%     
%     
%   end                                     % ... and process the next scale
%   
% end  % For each orientation
% 
% end
% %-----------------------------------------------------
function EO = gaborconvolve( im )

% GABORCONVOLVE - function for convolving image with log-Gabor filters
%
%   Usage: EO = gaborconvolve(im,  nscale, norient )
%
% For details of log-Gabor filters see:
% D. J. Field, "Relations Between the Statistics of Natural Images and the
% Response Properties of Cortical Cells", Journal of The Optical Society of
% America A, Vol 4, No. 12, December 1987. pp 2379-2394
% Notes on filter settings to obtain even coverage of the spectrum
% dthetaOnSigma 1.5
% sigmaOnf  .85   mult 1.3
% sigmaOnf  .75   mult 1.6     (bandwidth ~1 octave)
% sigmaOnf  .65   mult 2.1
% sigmaOnf  .55   mult 3       (bandwidth ~2 octaves)
%
% Author: Peter Kovesi
% Department of Computer Science & Software Engineering
% The University of Western Australia
% pk@cs.uwa.edu.au  www.cs.uwa.edu.au/~pk
%
% May 2001
% Altered, 2008, Eric Larson
% Altered precomputations, 2011, Eric Larson

nscale          = 5;      %Number of wavelet scales.
norient         = 4;      %Number of filter orientations.
minWaveLength   = 3;      %Wavelength of smallest scale filter.
mult            = 3;      %Scaling factor between successive filters.
sigmaOnf        = 0.55;   %Ratio of the standard deviation of the
%Gaussian describing the log Gabor filter's transfer function
%in the frequency domain to the filter center frequency.
%Orig: 3 6 12 27 64
wavelength      = [minWaveLength ...
  minWaveLength*mult ...
  minWaveLength*mult^2 ...
  minWaveLength*mult^3 ...
  minWaveLength*mult^4 ];

dThetaOnSigma   = 1.5;    %Ratio of angular interval between filter orientations
% 			       and the standard deviation of the angular Gaussian
% 			       function used to construct filters in the
%                              freq. plane.


[rows cols] = size( im );
imagefft    = fft2( im );            % Fourier transform of image

EO = cell( nscale, norient );        % Pre-allocate cell array

% Pre-compute to speed up filter construction
x = ones(rows,1) * (-cols/2 : (cols/2 - 1))/(cols/2);
y = (-rows/2 : (rows/2 - 1))' * ones(1,cols)/(rows/2);
radius = sqrt(x.^2 + y.^2);       % Matrix values contain *normalised* radius from centre.
radius(round(rows/2+1),round(cols/2+1)) = 1; % Get rid of the 0 radius value in the middle
radius = log(radius);
% so that taking the log of the radius will
% not cause trouble.

% Precompute sine and cosine of the polar angle of all pixels about the
% centre point

theta = atan2(-y,x);              % Matrix values contain polar angle.
% (note -ve y is used to give +ve
% anti-clockwise angles)
sintheta = sin(theta);
costheta = cos(theta);
clear x; clear y; clear theta;      % save a little memory

thetaSigma = pi/norient/dThetaOnSigma;  % Calculate the standard deviation of the
% angular Gaussian function used to
% construct filters in the freq. plane.
rows = round(rows/2+1);
cols = round(cols/2+1);
% precompute the scaling filters
logGabors = cell(1,nscale);
for s = 1:nscale                  % For each scale.
    
    % Construct the filter - first calculate the radial filter component.
    fo = 1.0/wavelength(s);                  % Centre frequency of filter.
    rfo = fo/0.5;                         % Normalised radius from centre of frequency plane
    % corresponding to fo.
    tmp = -(2 * log(sigmaOnf)^2);
    tmp2= log(rfo);
    logGabors{s} = exp( (radius-tmp2).^2 /tmp  );

    logGabors{s}( rows, cols ) = 0; % Set the value at the center of the filter
    % back to zero (undo the radius fudge).
end


% The main loop...
for o = 1:norient,                   % For each orientation.
  fprintf('.');
  angl = (o-1)*pi/norient;           % Calculate filter angle.
  
  % Pre-compute filter data specific to this orientation
  % For each point in the filter matrix calculate the angular distance from the
  % specified filter orientation.  To overcome the angular wrap-around problem
  % sine difference and cosine difference values are first computed and then
  % the atan2 function is used to determine angular distance.
  
  ds = sintheta * cos(angl) - costheta * sin(angl);     % Difference in sine.
  dc = costheta * cos(angl) + sintheta * sin(angl);     % Difference in cosine.
  dtheta = abs(atan2(ds,dc));                           % Absolute angular distance.
  spread = exp((-dtheta.^2) / (2 * thetaSigma^2));      % Calculate the angular filter component.
  
  for s = 1:nscale,                  % For each scale.

    filter = fftshift( logGabors{s} .* spread ); % Multiply by the angular spread to get the filter
    % and swap quadrants to move zero frequency
    % to the corners.
    
    % Do the convolution, back transform, and save the result in EO
    EO{s,o} = ifft2( imagefft .* filter );
    
    
  end  % ... and process the next scale
  
end  % For each orientation

end
% function [mp alpha I] = adapt_map( map, thresh )
% 
% if( ndims(map.LO) == 1 )
%   hi = map.HI;
%   lo = map.LO;
% else
%   hi = sum( map.HI, 3 ) ./ 3;
%   lo = map.LO;
% end
% 
% b1 = exp( -thresh(1)/thresh(2) );
% b2 = 1 / ( log(10)*thresh(2) );
% 
% alpha = 1 ./ ( 1 + b1 .* (abs(hi).^b2) );
% 
% mp = hi.^(alpha) .* lo.^(1-alpha);
% 
% BSIZE = 16;
% mp2 = mp( BSIZE+1:end-BSIZE-1, BSIZE+1:end-BSIZE-1);
% I = mean( mp2 (:) ) ;
% end
% 
% %-----------------------------------------------------
% function s = stdmod( block )
% 
% [a b] = size( block );
% b11   = block( 1:a/2  , 1:b/2   );
% b12   = block( 1:a/2  , b/2+1:b );
% b21   = block( a/2+1:a, 1:b/2 );
% b22   = block( a/2+1:a, b/2+1:b );
% 
% s     = min( [ std( b11(:) ), std( b12(:) ), ...
%   std( b21(:) ), std( b22(:) )] );
% end
% %-----------------------------------------------------