
#define GBUFFER_NO_RANGE_CHECK

#include <mex.h>
#include "ginclude/gwavelift.h"
#if defined(_MSC_VER) && (_MSC_VER <= 1200)
  namespace std {
    using ::atoi;
    using ::atof;
    using ::FILE;
    using ::fread;
    using ::fwrite;
    using ::fclose;
    }
#endif
#pragma warning(disable:4244)
    
typedef buf::GFloatBuffer band_type;
typedef buf::GFloatWaveList bands_type;
typedef wavlet::GFloatWavelift wave_type;
typedef band_type::data_type data_type;
typedef band_type::size_type size_type;
//---------------------------------------------------------------------------

void mexFunction(
   int nlhs,
   mxArray *plhs[],
   int nrhs,
   const mxArray *prhs[]
  )
{
  if (nlhs != 1)
  {
    mexErrMsgTxt("Invalid number of output arguments.");
  }
  if (nrhs < 1)
  {
    mexErrMsgTxt("Invalid number of input arguments.");
  }

  // get vector of evaluation points
  double* p_img = mxGetPr(prhs[0]);
  size_type const cy = mxGetN(prhs[0]);
  size_type const cx = mxGetM(prhs[0]);
  
  // get number of DWT levels
  int const num_levels = (nrhs > 1) ? mxGetScalar(prhs[1]) : 5;
  
  // load the source image
  bands_type bands(cx, cy);
  size_type size = bands.Image().Size();
  data_type* p_img_cpp = bands.Image().Data();
  for (size_type idx = 0; idx < size; ++idx)
  {
    *p_img_cpp++ = *p_img++;
  }  
  
  // perform the forward DWT
  wave_type().Decompose(bands, num_levels);

//  mexPrintf("mean = %f\n", bands.Image().Mean());
//  mexPrintf("cx = %d, cy = %d\n", cx, cy);
//  mexPrintf("num_levels = %d\n", num_levels);

  // allocate memory and assign output pointer
  int idx = 0;
  mxArray* p_cell_mx = mxCreateCellMatrix(num_levels, 1);  
  for (int s = 1; s <= num_levels; ++s)  
  {    
    int const num_orients = (s == num_levels) ? 4 : 3;
    mxArray* p_cell_orient_mx = 
      mxCreateCellMatrix(num_orients, 1);
    mxSetCell(p_cell_mx, s - 1, p_cell_orient_mx);
    
    for (int o = 0; o < num_orients; ++o)
    {
      band_type const& band = (o < 3) ? 
        bands(s, o) : bands.LL(num_levels);
      mxArray* p_band_mx = 
        mxCreateDoubleMatrix(band.Width(), band.Height(), mxREAL);
      mxSetCell(p_cell_orient_mx, o, p_band_mx);
      
      double* p_band = mxGetPr(p_band_mx);
      data_type const* p_band_cpp = band.Data();
      int const band_size = band.Size();
      for (int idx_band = 0; idx_band < band_size; ++idx_band)
      {
        *p_band++ = *p_band_cpp++;
      }
    }
  }
  plhs[0] = p_cell_mx;
}
//---------------------------------------------------------------------------

