
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
#ifndef gwaveliftH
#define gwaveliftH
//=========================================================================

#include "gtransform.h"
//=========================================================================

#if defined(__BORLANDC__)
  #pragma warn -8058
#endif

namespace wavlet {

static const float ALPHA =   -1.586134342f; // -1.5861343f;
static const float BETA =    -0.052980118f; // -0.0529801f;
static const float GAMMA =    0.882911075f; // 0.8829111f;
static const float DELTA =    0.443506852f; // 0.4435069f;
static const float TWOALPHA = 2 * ALPHA;
static const float TWOBETA =  2 * BETA;
static const float TWOGAMMA = 2 * GAMMA;
static const float TWODELTA = 2 * DELTA;

#if defined(GWAVELIFT_NORM_1_1)
  static const float B0 =       1.0/1.23017410558578;
  static const float B1 =       1.0/1.62578613134411;
#else
  static const float K =        0.8698643f; // 0.8698654f
  static const float KINV =     1.1496046f; // 1.1496038f;
#endif

//
// jp2 analyze:
// lo *= 0.81289306567205
// hi *= 0.61508705279289
//
// dc analyze:
// lo *= 1.1496046
// hi *= -0.8698643
//
// jp2 synthesize:
// lo *= 1.0 / 0.81289306567205
// hi *= 1.0 / 0.61508705279289
//
// dc synthesize:
// lo *= -0.8698643
// hi *= 1.1496046
//

template <class ListType>
class GWavelift : public GTransform<ListType>
{
public:
  typedef ListType list_type;
  typedef typename list_type::buf_type buf_type;
  typedef typename buf_type::size_type size_type;
  typedef typename buf_type::data_type buf_data_type;

protected:
  virtual void DoTransformRows(const buf_type& Buffer,
    buf_type& LBuffer, buf_type& HBuffer);
  virtual void DoTransformCols(const buf_type& Buffer,
    buf_type& LBuffer, buf_type& HBuffer);

  virtual void DoUntransformRows(buf_type& Buffer,
    const buf_type& LBuffer, const buf_type& HBuffer);
  virtual void DoUntransformCols(buf_type& Buffer,
    const buf_type& LBuffer, const buf_type& HBuffer);
};
//=========================================================================



template<class ListType>
void GWavelift<ListType>::DoTransformRows(
   const buf_type& Buffer,
   buf_type& SBuffer,
   buf_type& DBuffer
  )
{
#define GETXVAL(p, x) *(p + (x))
#define SETXVAL(p, x, v) *(p + (x)) = (v)

  const size_type xw = Buffer.Width();
  const size_type dw = DBuffer.Width();
  const size_type sw = SBuffer.Width();
  const size_type sh = SBuffer.Height();
  const size_type sw_minus_one = sw - 1;

  const buf_data_type* px = Buffer.Data();
  buf_data_type* pd = DBuffer.Data();
  buf_data_type* ps = SBuffer.Data();

  register const buf_data_type* px_row;
  register buf_data_type* pd_row;
  register buf_data_type* ps_row;

  register size_type x;
  register buf_data_type d_res0, old_d_res, d_res, X2n;
  for (size_type y = 0; y < sh; ++y)
  {
    px_row = px + (xw * y);
    pd_row = pd + (dw * y);
    ps_row = ps + (sw * y);

    d_res0 = old_d_res =
      GETXVAL(px_row, 1) + ALPHA * (*px_row + GETXVAL(px_row, 2));
    *pd_row = old_d_res;
    for (x = 1; x < sw_minus_one; ++x)
    {
      X2n = GETXVAL(px_row, x << 1);
      d_res =
        GETXVAL(px_row, (x << 1) + 1) +
        ALPHA * (X2n + GETXVAL(px_row, (x << 1) + 2));

      SETXVAL(pd_row, x, d_res);
      SETXVAL(ps_row, x, X2n + BETA * (d_res + old_d_res));
      old_d_res = d_res;
    }
    d_res =
      GETXVAL(px_row, (sw << 1) - 1) +
      TWOALPHA * GETXVAL(px_row, (sw << 1) - 2);
    SETXVAL(pd_row, sw_minus_one, d_res);
    *ps_row = *px_row + TWOBETA * d_res0;
    SETXVAL(ps_row, sw_minus_one,
      GETXVAL(px_row, sw_minus_one << 1) +
      BETA * (d_res + old_d_res)
      );

    d_res0 = old_d_res =
      *pd_row + GAMMA * (*ps_row + GETXVAL(ps_row, 1));
    *pd_row = old_d_res;
    for (x = 1; x < sw_minus_one; ++x)
    {
      d_res =
        GETXVAL(pd_row, x) + GAMMA * (
          GETXVAL(ps_row, x) + GETXVAL(ps_row, x + 1)
          );
      SETXVAL(pd_row, x, d_res);
      SBuffer.IncPixels(x, y, DELTA * (d_res + old_d_res));
      old_d_res = d_res;
    }
    d_res =
      GETXVAL(pd_row, sw_minus_one) +
      TWOGAMMA * GETXVAL(ps_row, sw_minus_one);
    SETXVAL(pd_row, sw_minus_one, d_res);
    SBuffer.IncPixels(
      0, y, TWODELTA * d_res0
      );
    SBuffer.IncPixels(
      sw_minus_one, y, DELTA * (d_res + old_d_res)
      );
  }

#if defined(GWAVELIFT_NORM_1_1)
  SBuffer *= B0;
  DBuffer *= B1;
#else
  SBuffer *= KINV;
  DBuffer *= -K;
#endif   

#undef SETXVAL
#undef GETXVAL
}
//-------------------------------------------------------------------------

template<class ListType>
void GWavelift<ListType>::DoTransformCols(
   const buf_type& Buffer,
   buf_type& SBuffer,
   buf_type& DBuffer
  )
{
#define GETYVAL(p, w, y) *(p + (w * (y)))
#define SETYVAL(p, w, y, v) *(p + (w * (y))) = (v)

  const size_type xw = Buffer.Width();
  const size_type dw = DBuffer.Width();
  const size_type sw = SBuffer.Width();
  const size_type sh = SBuffer.Height();
  const size_type sh_minus_one = sh - 1;

  const buf_data_type* px = Buffer.Data();
  buf_data_type* pd = DBuffer.Data();
  buf_data_type* ps = SBuffer.Data();

  const buf_data_type* px_col;
  buf_data_type* pd_col;
  buf_data_type* ps_col;

  register size_type y;
  register size_type ysave0, ysave1;
  register buf_data_type d_res0, old_d_res, d_res, X2n;
  for (size_type x = 0; x < sw; ++x)
  {
    px_col = px + x;
    pd_col = pd + x;
    ps_col = ps + x;

    d_res0 = old_d_res =
      GETYVAL(px_col, xw, 1) + ALPHA * (
        *px_col + GETYVAL(px_col, xw, 2)
        );
    *pd_col = old_d_res;
    for (y = 1; y < sh_minus_one; ++y)
    {
      ysave0 = xw * (y << 1);
      ysave1 = dw * y;

      X2n = *(px_col + ysave0);
      d_res =
        *(px_col + ysave0 + xw) +
        ALPHA * (X2n + *(px_col + ysave0 + xw + xw));

      *(pd_col + ysave1) = d_res;
      *(ps_col + ysave1) = X2n + BETA * (d_res + old_d_res);
      old_d_res = d_res;
    }
    d_res =
      GETYVAL(px_col, xw, (sh << 1) - 1) +
      TWOALPHA * GETYVAL(px_col, xw, (sh << 1) - 2);
    SETYVAL(pd_col, dw, sh_minus_one, d_res);
    *ps_col = *px_col + TWOBETA * d_res0;
    SETYVAL(ps_col, sw, sh_minus_one,
      GETYVAL(px_col, xw, sh_minus_one << 1) +
      BETA * (d_res + old_d_res)
      );

    d_res0 = old_d_res =
      *pd_col + GAMMA * (*ps_col + GETYVAL(ps_col, sw, 1));
    *pd_col = old_d_res;
    for (y = 1; y < sh_minus_one; ++y)
    {
      ysave0 = dw * y;
      d_res = *(pd_col + ysave0) + GAMMA * (
        *(ps_col + ysave0) + *(ps_col + ysave0 + sw)
        );
      *(pd_col + ysave0) = d_res;
      SBuffer.IncPixels(x, y, DELTA * (d_res + old_d_res));
      old_d_res = d_res;
    }
    d_res =
      GETYVAL(pd_col, dw, sh_minus_one) +
      TWOGAMMA * GETYVAL(ps_col, sw, sh_minus_one);
    SETYVAL(pd_col, dw, sh_minus_one, d_res);
    SBuffer.IncPixels(x, 0, TWODELTA * d_res0);
    SBuffer.IncPixels(
      x, sh_minus_one, DELTA * (d_res + old_d_res)
      );
  }

#if defined(GWAVELIFT_NORM_1_1)
  SBuffer *= B0;
  DBuffer *= B1;
#else
  SBuffer *= KINV;
  DBuffer *= -K;
#endif

#undef SETYVAL
#undef GETYVAL
}
//-------------------------------------------------------------------------

template<class ListType>
void GWavelift<ListType>::DoUntransformCols(
   buf_type& Buffer,
   const buf_type& SBuffer,
   const buf_type& DBuffer
  )
{
#define GETYVAL(p, w, y) *(p + (w * (y)))
#define SETYVAL(p, w, y, v) *(p + (w * (y))) = (v)

  //
  // NOTE: all widths are the same while Buffer's
  // height is 2x that of SBuffer and DBuffer
  //
  const size_type xw = Buffer.Width();
  const size_type dw = DBuffer.Width();
  const size_type sw = SBuffer.Width();
  const size_type sh = SBuffer.Height();
  const size_type sh_minus_one = sh - 1;

  buf_data_type* px = Buffer.Data();
  const buf_data_type* pd = DBuffer.Data();
  const buf_data_type* ps = SBuffer.Data();

  buf_data_type* px_col;
  const buf_data_type* pd_col;
  const buf_data_type* ps_col;

  // for inline storage, create "mutable" references
  buf_type& SBufferMut = const_cast<buf_type&>(SBuffer);
  buf_type& DBufferMut = const_cast<buf_type&>(DBuffer);
  //
#if defined(GWAVELIFT_NORM_1_1)
  SBufferMut /= B0;
  DBufferMut /= B1;
#else
  SBufferMut *= K;
  DBufferMut *= -KINV;
#endif

  register size_type y;
  register size_type ysave0;
  register buf_data_type s_res, d_res, d_res0, d_res_last;
  for (size_type x = 0; x < sw; ++x)
  {
    px_col = px + x;
    pd_col = pd + x;
    ps_col = ps + x;

    SBufferMut.DecPixels(x, 0, TWODELTA * (*pd_col));
    for (y = 1; y < sh; ++y)
    {
      ysave0 = dw * y;
      SBufferMut.DecPixels(x, y, DELTA * (
        *(pd_col + ysave0) + *(pd_col + ysave0 - dw)
        ));
    }

    d_res0 = d_res_last =
      *pd_col - GAMMA * (*ps_col + GETYVAL(ps_col, sw, 1));
    *(const_cast<buf_data_type*>(pd_col)) = d_res_last;
    for (y = 1; y < sh_minus_one; ++y)
    {
      ysave0 = sw * y;

      s_res = *(ps_col + ysave0);
      d_res = *(pd_col + ysave0) -
        GAMMA * (s_res + *(ps_col + ysave0 + sw));

      *(const_cast<buf_data_type*>(pd_col) + ysave0) = d_res;
      SETYVAL(
        px_col, xw, y << 1, s_res - BETA * (d_res + d_res_last)
        );
      d_res_last = d_res;
    }
    d_res =
      GETYVAL(pd_col, dw, sh_minus_one) -
      TWOGAMMA * GETYVAL(ps_col, sw, sh_minus_one);
    SETYVAL(
      const_cast<buf_data_type*>(pd_col), dw, sh_minus_one, d_res
      );
    *px_col = *ps_col - TWOBETA * d_res0;
    SETYVAL(px_col, xw, sh_minus_one << 1,
      GETYVAL(ps_col, sw, sh_minus_one) -
      BETA * (d_res + d_res_last)
      );

    for (y = 0; y < sh_minus_one; ++y)
    {
      ysave0 = xw * (y << 1);
      *(px_col + ysave0 + xw) =
        GETYVAL(pd_col, dw, y) - ALPHA * (
          *(px_col + ysave0) + *(px_col + ysave0 + xw + xw)
          );
    }
    SETYVAL(px_col, xw, (sh << 1) - 1,
      GETYVAL(pd_col, dw, sh_minus_one) -
      TWOALPHA * GETYVAL(px_col, xw, (sh << 1) - 2)
      );
  }

#undef SETYVAL
#undef GETYVAL
}
//-------------------------------------------------------------------------

template<class ListType>
void GWavelift<ListType>::DoUntransformRows(
   buf_type& Buffer,
   const buf_type& SBuffer,
   const buf_type& DBuffer
  )
{
#define GETXVAL(p, x) *(p + (x))
#define SETXVAL(p, x, v) *(p + (x)) = (v)

  //
  // NOTE: widths and heights are the same
  //
  const size_type xw = Buffer.Width();
  const size_type dw = DBuffer.Width();
  const size_type sw = SBuffer.Width();
  const size_type sh = SBuffer.Height();
  const size_type sw_minus_one = sw - 1;

  buf_data_type* px = Buffer.Data();
  const buf_data_type* pd = DBuffer.Data();
  const buf_data_type* ps = SBuffer.Data();

  buf_data_type* px_row;
  const buf_data_type* pd_row;
  const buf_data_type* ps_row;

  // for inline storage, create "mutable" references
  buf_type& SBufferMut = const_cast<buf_type&>(SBuffer);
  buf_type& DBufferMut = const_cast<buf_type&>(DBuffer);
  //
#if defined(GWAVELIFT_NORM_1_1)
  SBufferMut /= B0;
  DBufferMut /= B1;
#else
  SBufferMut *= K;
  DBufferMut *= -KINV;
#endif

  register size_type x;
  register buf_data_type s_res, d_res, old_d_res, d_res0;
  for (size_type y = 0; y < sh; ++y)
  {
    px_row = px + (xw * y);
    pd_row = pd + (dw * y);
    ps_row = ps + (sw * y);

    SBufferMut.DecPixels(0, y, TWODELTA * (*pd_row));
    for (x = 1; x < sw; ++x)
    {
      SBufferMut.DecPixels(x, y, DELTA * (
        GETXVAL(pd_row, x) + GETXVAL(pd_row, x - 1)
        ));
    }

    d_res0 = old_d_res =
      *pd_row - GAMMA * ((*ps_row) + GETXVAL(ps_row, 1));
    *(const_cast<buf_data_type*>(pd_row)) = old_d_res;
    for (x = 1; x < sw_minus_one; ++x)
    {
      s_res = GETXVAL(ps_row, x);
      d_res =
        GETXVAL(pd_row, x) -
        GAMMA * (s_res + GETXVAL(ps_row, x + 1));

      SETXVAL(const_cast<buf_data_type*>(pd_row), x, d_res);
      SETXVAL(px_row, x << 1, s_res - BETA * (d_res + old_d_res));
      old_d_res = d_res;
    }
    d_res =
      GETXVAL(pd_row, sw_minus_one) -
      TWOGAMMA * GETXVAL(ps_row, sw_minus_one);
    SETXVAL(const_cast<buf_data_type*>(pd_row), sw_minus_one, d_res);
    *px_row = *ps_row - TWOBETA * d_res0;
    SETXVAL(px_row, sw_minus_one << 1,
      GETXVAL(ps_row, sw_minus_one) - BETA * (d_res + old_d_res)
      );

    for (x = 0; x < sw_minus_one; ++x)
    {
      SETXVAL(px_row, (x << 1) + 1,
        GETXVAL(pd_row, x) - ALPHA * (
          GETXVAL(px_row, x << 1) +
          GETXVAL(px_row, (x << 1) + 2)
          )
        );
    }
    SETXVAL(px_row, (sw << 1) - 1,
      GETXVAL(pd_row, sw_minus_one) -
      TWOALPHA * GETXVAL(px_row, (sw << 1) - 2)
      );
  }

#undef SETXVAL
#undef GETXVAL
}
//-------------------------------------------------------------------------

////////////////////////////////////////////////////////////
// commonly-used aliases
////////////////////////////////////////////////////////////
  typedef GWavelift<buf::GFloatWaveList> GFloatWavelift;
  typedef GWavelift<buf::GDoubleWaveList> GDoubleWavelift;
  typedef GWavelift<buf::GByteWaveList> GByteWavelift;
  typedef GWavelift<buf::GIntWaveList> GIntWavelift;
  typedef GWavelift<buf::GDWordWaveList> GDWordWavelift;
  typedef GWavelift<buf::GShortWaveList> GShortWavelift;
  typedef GWavelift<buf::GWordWaveList> GWordWavelift;
  typedef GWavelift<buf::GBoolWaveList> GBoolWavelift;
////////////////////////////////////////////////////////////

} // namespace wavlet

#if defined(__BORLANDC__)
  #pragma warn .8058
#endif

//=========================================================================
#endif // gwavelift
//=========================================================================

