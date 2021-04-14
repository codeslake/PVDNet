
////////////////////////////////////////////////////////////////////////////
//                                                                        //
// COPYRIGHT (c) 1998, 2002, VCL                                          //
// ------------------------------                                         //
// Permission to use, copy, modify, distribute and sell this software     //
// and its documentation for any purpose is hereby granted without fee,   //
// provided that the above copyright notice appear in all copies and      //
// that both that copyright notice and this permission notice appear      //
// in supporting documentation.  VCL makes no representations about       //
// the suitability of this software for any purpose.                      //
//                                                                        //
// DISCLAIMER:                                                            //
// -----------                                                            //
// The code provided hereunder is provided as is without warranty         //
// of any kind, either express or implied, including but not limited      //
// to the implied warranties of merchantability and fitness for a         //
// particular purpose.  The author(s) shall in no event be liable for     //
// any damages whatsoever including direct, indirect, incidental,         //
// consequential, loss of business profits or special damages.            //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

//=========================================================================
#ifndef gtransformH
#define gtransformH
//=========================================================================

#include "gwavelist.h"
//=========================================================================

namespace wavlet {
 
template <class ListType>
class GTransform
{
public:
  typedef ListType list_type;
  typedef typename list_type::buf_type buf_type;
  typedef typename buf_type::size_type size_type;
  typedef typename list_type::index_type index_type;

  // default destructor
  virtual ~GTransform() {}

  virtual void Decompose(list_type& WaveList, index_type num_scales);
  virtual void Reconstruct(list_type& WaveList);
  virtual void ReconstructOne(list_type& WaveList,
    index_type non_zero_scale, index_type non_zero_orient);

protected:
  // forward DWT (pure virtual functions--must be overriden or augmented)
  virtual void DoTransformRows(
    const buf_type& Buffer, buf_type& L, buf_type& H
    ) = 0;
  virtual void DoTransformCols(
    const buf_type& Buffer, buf_type& L, buf_type& H
    ) = 0;

  // inverse DWT (pure virtual functions--must be overriden or augmented)
  virtual void DoUntransformRows(
    buf_type& Buffer, const buf_type& L, const buf_type& H
    ) = 0;
  virtual void DoUntransformCols(
    buf_type& Buffer, const buf_type& L, const buf_type& H
    ) = 0;

  virtual void DoDecompose(list_type& WaveList, index_type scale_index);
  virtual void DoReconstruct(list_type& WaveList, index_type scale_index);
  virtual void DoReconstructOne(list_type& WaveList, index_type scale_index,
    index_type non_zero_scale, index_type non_zero_orient);
};
//=========================================================================

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Each level of decomposition yields a GWaveList with seven images:
//
// WaveList =
// ... ------------------------------------------------------- ...
// ...         LL0  | L1  | H1  | HH1 | HL1 | LH1 | LL1        ...
// ... ------------------------------------------------------- ...
//             [0]   [1]   [2]   [3]   [4]   [5]   [6]
//                   [7]   [8]   [9]   [10]  [11]  [12]
//                   [13]  [14]  [15]  [16]  [17]  [18]
//                   [19]  [20]  [21]  [22]  [23]  [24]
//                   [25]  [26]  [27]  [28]  [29]  [30]
//
// The Decompose() method uses the first image in the list as the
// source image.  It then decomposes (forward DWTs) this image
// and stores the results as depicted above, in the list.  The
// source image, WaveList->Image() remains untouched.  L1 is
// the smooth (low-passed) image whose rows have been transformed.
// H1 is the detail (high-passed) image whose rows have been
// transformed.  HH1 is the detail (high-high passed) image whose
// rows then columns have been transformed.  HL1 is the detail
// (high-low passed) image whose rows then columns have been
// transformed.  LH1 is the detail (low-high passed) image whose
// rows then columns have been transformed.  Finally, LL1 is the
// smooth (low-low-passed) image whose rows then columns have been
// transformed.  LL1 is used as the source image for the next
// level of decomposition.  For this reason, the LL buffers are
// stored last in the zero-based indices [0, 6, 12, 18, 24, ...].
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

template<class ListType>
void GTransform<ListType>::Decompose(
   list_type& WaveList,
   index_type num_scales
  )
{
  // assure that the source image is appropriately sized
  WaveList.AddPadding(num_scales);
  // assure that there's room for the subbands
  WaveList.AllocBands(num_scales);
  // perform the forward DWT
  for (index_type scale_index = 0; scale_index < num_scales;
       ++scale_index)
  {
    DoDecompose(WaveList, scale_index);
  }
}
//-------------------------------------------------------------------------

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// The Reconstruct() method uses the last four buffers (HHn, HLn,
// LHn, LLn) in the list as the starting point, and then inverse
// transforms their columns, storing the result in the fourth and
// fifth from the last positions (Hn and Ln, repsectively).  It
// then inverse transforms these results, storing the result in
// the LL(n-1) position.  This latter result is then used to
// reconstruct the next level.  Upon completion, the inverse
// transformed image is stored in the first position of the list.
//
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

template<class ListType>
void GTransform<ListType>::Reconstruct(
   list_type& WaveList
  )
{
  // perform the inverse DWT
  const index_type num_scales = WaveList.NumScales();
  for (index_type scale_index = num_scales; scale_index >= 1;
       --scale_index)
  {
    DoReconstruct(WaveList, scale_index);
  }
  // remove the padding from the image, if neccessary
  WaveList.RemovePadding();
}
//-------------------------------------------------------------------------

template<class ListType>
void GTransform<ListType>::ReconstructOne(
   list_type& WaveList,
   index_type non_zero_scale,
   index_type non_zero_orient
  )
{
  // perform the inverse DWT
  const index_type num_scales = WaveList.NumScales();
  for (index_type scale_index = num_scales; scale_index >= 1;
       --scale_index)
  {
    DoReconstructOne(WaveList, scale_index,
      non_zero_scale, non_zero_orient);
  }
  // remove the padding from the image, if neccessary
  WaveList.RemovePadding();
}
//-------------------------------------------------------------------------



template<class ListType>
void GTransform<ListType>::DoDecompose(
   list_type& WaveList,
   index_type scale_index
  )
{
  // 2D transform
  if (WaveList.Image().Height() > 1)
  {
    //
    // extract the source image (or the LL subband
    // from the previous level of decomposition)
    //
    buf_type& LL = WaveList.LL(scale_index);
    ++scale_index; // analysis will be stored at the next scale

    // grab a reference to the L and H subbands
    buf_type& L = WaveList.L(scale_index);
    buf_type& H = WaveList.H(scale_index);

    // filter the rows and downsample horizontally
    DoTransformRows(LL, L, H);
    if (scale_index > 0)
    {
      LL.Sleep();
    }

    // filter the columns and downsample vertically
    DoTransformCols(
      H, WaveList.HL(scale_index), WaveList.HH(scale_index)
      );
    DoTransformCols(
      L, WaveList.LL(scale_index), WaveList.LH(scale_index)
      );
    H.Sleep();
    L.Sleep();
  }
  else // 1D transform
  {
    //
    // extract the source signal (or the L subband
    // from the previous level of decomposition)
    //
    buf_type& Lprev = (scale_index == 0) ?
      WaveList.Image() : WaveList.L(scale_index);
    ++scale_index; // analysis will be stored at the next scale

    // grab a reference to the L and H subbands
    buf_type& L = WaveList.L(scale_index);
    buf_type& H = WaveList.H(scale_index);

    // filter the rows and downsample horizontally
    DoTransformRows(Lprev, L, H);
    if (scale_index > 0)
    {
      Lprev.Sleep();
    }
  }
}
//-------------------------------------------------------------------------

template<class ListType>
void GTransform<ListType>::DoReconstruct(
   list_type& WaveList,
   index_type scale_index
  )
{
  // 2D transform
  if (WaveList.Image().Height() > 1)
  {
    // extract the HH and HL subbands from the list
    const buf_type& HH = WaveList.HH(scale_index);
    const buf_type& HL = WaveList.HL(scale_index);
    //
    // extract the H subband from the list
    // (this buffer will be overwritten)
    //
    buf_type& H = WaveList.H(scale_index);
    H.Awaken();
    //
    // upsample vertically, filter the columns, and then
    // sum the results (which are stored in H)
    // H = filter(HL_up_2 w/ filt7) + filter(HH_up_2 w/ filt9)
    //
    DoUntransformCols(H, HL, HH);

    // extract the LH and LL subbands from the list
    const buf_type& LH = WaveList.LH(scale_index);
    const buf_type& LL = WaveList.LL(scale_index);
    //
    // extract the L subband from the list
    // (this buffer will be overwritten)
    //
    buf_type& L = WaveList.L(scale_index);
    L.Awaken();
    //
    // upsample vertically, filter the columns, and then
    // sum the results (which are stored in L)
    // L = filter(LL_up_2 w/ filt7) + filter(LH_up_2 w/ filt9)
    //
    DoUntransformCols(L, LL, LH);

    //
    // extract the buffer for the reconstructed image
    // (this buffer will be overwritten)
    //
    buf_type& LLprev = WaveList.LL(scale_index - 1);
    LLprev.Awaken();
    //
    // upsample horizontally, filter the rows, and then
    // sum the results (which are stored in LL_prev_scale)
    // LLprev = filter(L_up_2 w/ filt7) + filter(H_up_2 w/ filt9)
    //
    DoUntransformRows(LLprev, L, H);
  }
  else // 1D transform
  {
    //
    // extract the buffer for the reconstructed signal
    // (this buffer will be overwritten)
    //
    buf_type& Lprev = (scale_index == 1) ?
      WaveList.Image() : WaveList.L(scale_index - 1);
    Lprev.Awaken();

    // extract the component subbands
    buf_type& H = WaveList.H(scale_index);
    H.Awaken();
    buf_type& L = WaveList.L(scale_index);
    L.Awaken();

    //
    // upsample horizontally, filter the rows, and then
    // sum the results (which are stored in Lprev)
    // Lprev = filter(L_up_2 w/ filt7) + filter(H_up_2 w/ filt9)
    //
    DoUntransformRows(Lprev, L, H);
  }
}
//-------------------------------------------------------------------------

template<class ListType>
void GTransform<ListType>::DoReconstructOne(
   list_type& WaveList,
   index_type scale_index,
   index_type non_zero_scale,
   index_type non_zero_orient
  )
{
  // if this scale, doesn't contain the non-zero subband,
  // there's no need to synthesize (compute the LL band)
  // for this scale, just skip it altogether
  if (scale_index > non_zero_scale)
  {
    buf_type& LLprev = WaveList.LL(scale_index - 1);
    LLprev.Awaken();
    LLprev = 0;
    return;
  }
  else if (scale_index < non_zero_scale)
  {
    non_zero_orient = 4;
  }

  // at this point, we're synthesizing the scale
  // that contains the non-zero subband; we can
  // still skip the branch (LL/LH or HL/HH) whose
  // bands are all zeros...

  // extract the H and L subbands from the list
  buf_type& H = WaveList.H(scale_index);
  buf_type& L = WaveList.L(scale_index);
  H.Awaken();  
  L.Awaken();

  switch (non_zero_orient)
  {
    // the HH or HL band is non-zero,
    // so perform the HL/HH branch
    case 1:
    case 2:
    {
      // extract the HH and HL subbands from the list
      const buf_type& HH = WaveList.HH(scale_index);
      const buf_type& HL = WaveList.HL(scale_index);

      // upsample vertically, filter the columns, and then
      // sum the results (which are stored in H)
      // H = filter(HL_up_2 w/ filt7) + filter(HH_up_2 w/ filt9)
      DoUntransformCols(H, HL, HH);
      L = 0;
      break;
    }
    // the LH band is non-zero,
    // so perform the LL/LH branch
    case 0:
    case 4:
    {
      // extract the LH and LL subbands from the list
      const buf_type& LH = WaveList.LH(scale_index);
      const buf_type& LL = WaveList.LL(scale_index);

      // upsample vertically, filter the columns, and then
      // sum the results (which are stored in L)
      // L = filter(LL_up_2 w/ filt7) + filter(LH_up_2 w/ filt9)
      DoUntransformCols(L, LL, LH);
      H = 0;
      break;
    }
  }

  // extract the buffer for the reconstructed image
  // (this buffer will be overwritten)
  buf_type& LLprev = WaveList.LL(scale_index - 1);
  LLprev.Awaken();

  // upsample horizontally, filter the rows, and then
  // sum the results (which are stored in LL_prev_scale)
  // LLprev = filter(L_up_2 w/ filt7) + filter(H_up_2 w/ filt9)
  DoUntransformRows(LLprev, L, H);
}
//-------------------------------------------------------------------------

} // namspace wavlet

//=========================================================================
#endif // GTRANSFORM_H
//=========================================================================

