
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
#ifndef gwavelistH
#define gwavelistH
//=========================================================================

//#if defined(_MSC_VER)
//  #include <cmath>
//#else
//  #include <math.h>
//#endif
#include "gbufferlist.h"
#include "gstepsizes.h"
//=========================================================================

#if defined(__BORLANDC__)
  #pragma warn -8027
#endif

namespace buf {

template <class BufferType>
class GWaveList : public GBufferList<BufferType>
{
public:
  typedef BufferType buf_type;
  typedef typename buf_type::data_type buf_data_type;
  typedef typename GBufferList<buf_type>::size_type size_type;
  typedef unsigned char index_type;
  typedef std::runtime_error except_type;  

  // default constructor
  GWaveList() : GBufferList<buf_type>(), padX_(0), padY_(0) {}
  // constuctor for specifying the source image
  GWaveList(buf_type const& SrcImage) : padX_(0), padY_(0)
    {
      Image(SrcImage);
    }
  // constuctor for specifying the source image dimensions
  GWaveList(size_type cx, size_type cy) : padX_(0), padY_(0)
    {
      Image(cx, cy);
    }
  // copy constructor
  GWaveList(GWaveList<buf_type> const& copy)
    : GBufferList<buf_type>(copy), padX_(copy.PadX()),
      padY_(copy.PadY()) {}
  // assignment operator
  GWaveList<buf_type>& operator =(GWaveList<buf_type> const& rhs)
    {
      GBufferList<buf_type>::operator=(rhs);
      padX_ = rhs.PadX();
      padY_ = rhs.PadY();
    }
  // parenthesis operator (band access)
  buf_type const& operator ()(index_type scale_index,
    index_type orient_index) const
    {
      return Band(scale_index, orient_index);
    }
  buf_type& operator ()(index_type scale_index,
    index_type orient_index)
    {
      return Band(scale_index, orient_index);
    }

  // copies only the subbands required for reconstruction
  void Assign(const GWaveList<buf_type>& copy)
    {
      if (this->Count() != copy.Count())
      {
        // punt to the assignment operator
        *this = copy;
      }
      else
      {
        //
        // copy only the 2-D AC subbands and
        // the highest-level 2-D LL subband
        //
        index_type const num_scales = NumScales();
        LL(num_scales) = copy.LL(num_scales);
        for (index_type index = 1; index <= num_scales; ++index)
        {
          LH(index) = copy.LH(index);
          HL(index) = copy.HL(index);
          HH(index) = copy.HH(index);
        }
      }
    }

  void Quantize(const GStepSizes<buf_data_type>& Steps)
    {
      index_type const num_scales = NumScales();
      LL(num_scales).Quantize(Steps.LL());
      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        LH(iScale).Quantize(Steps.LH(iScale));
        HL(iScale).Quantize(Steps.HL(iScale));
        HH(iScale).Quantize(Steps.HH(iScale));
      }
    }
 void QuantizeInt(const GStepSizes<buf_data_type>& Steps)
    {
      index_type const num_scales = NumScales();
      LL(num_scales).QuantizeInt(Steps.LL());
      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        LH(iScale).QuantizeInt(Steps.LH(iScale));
        HL(iScale).QuantizeInt(Steps.HL(iScale));
        HH(iScale).QuantizeInt(Steps.HH(iScale));
      }
    }
  void DeQuantizeInt(const GStepSizes<buf_data_type>& Steps)
    {
      index_type const num_scales = NumScales();
      LL(num_scales).DeQuantizeInt(Steps.LL());
      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        LH(iScale).DeQuantizeInt(Steps.LH(iScale));
        HL(iScale).DeQuantizeInt(Steps.HL(iScale));
        HH(iScale).DeQuantizeInt(Steps.HH(iScale));
      }
    }
  void QuantizeDZ(const GStepSizes<buf_data_type>& Steps)
    {
      index_type const num_scales = NumScales();
      LL(num_scales).QuantizeDZ(Steps.LL());
      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        LH(iScale).QuantizeDZ(Steps.LH(iScale));
        HL(iScale).QuantizeDZ(Steps.HL(iScale));
        HH(iScale).QuantizeDZ(Steps.HH(iScale));
      }
    }
  void QuantizeDZInt(const GStepSizes<buf_data_type>& Steps)
    {
      index_type const num_scales = NumScales();
      LL(num_scales).QuantizeDZInt(Steps.LL());
      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        LH(iScale).QuantizeDZInt(Steps.LH(iScale));
        HL(iScale).QuantizeDZInt(Steps.HL(iScale));
        HH(iScale).QuantizeDZInt(Steps.HH(iScale));
      }
    }
  void DeQuantizeDZInt(const GStepSizes<buf_data_type>& Steps)
    {
      index_type const num_scales = NumScales();
      LL(num_scales).DeQuantizeDZInt(Steps.LL());
      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        LH(iScale).DeQuantizeDZInt(Steps.LH(iScale));
        HL(iScale).DeQuantizeDZInt(Steps.HL(iScale));
        HH(iScale).DeQuantizeDZInt(Steps.HH(iScale));
      }
    }

  index_type NumScales() const
    {
      return static_cast<index_type>(0.5 + (Count() - 1) / 6.0);
    }
  index_type NumBands() const
    {
      return static_cast<index_type>(1.5 + 3.0 * NumScales());
    }
  buf_type const& Image() const
    {
      return LL(0);
    }
  void Image(buf_type const& NewImage)
    {
      if (Count() <= 0)
      {
        Add(NewImage);
      }
      else Items(0) = NewImage;
    }
  void Image(size_type cx, size_type cy)
    {
      Add(buf_type(cx, cy));
    }

  buf_type const& LL(index_type scale_index) const
    {
      return Items(scale_index * 6);
    }
  buf_type const& LH(index_type scale_index) const
    {
      return Items((scale_index * 6) - 1);
    }
  buf_type const& HL(index_type scale_index) const
    {
      return Items((scale_index * 6) - 2);
    }
  buf_type const& HH(index_type scale_index) const
    {
      return Items((scale_index * 6) - 3);
    }
  buf_type const& H(index_type scale_index) const
    {
      return Items((scale_index * 6) - 4);
    }
  buf_type const& L(index_type scale_index) const
    {
      return Items((scale_index * 6) - 5);
    }
  buf_type const& Band(index_type scale_index,
    index_type orient_index) const
    {
      switch (orient_index)
      {
        case 0: return LH(scale_index);
        case 1: return HL(scale_index);
        case 2: return HH(scale_index);
      }
    }

  buf_type& Image()
    {
      return LL(0);
    }
  buf_type& LL(index_type scale_index)
    {
      return Items(scale_index * 6);
    }
  buf_type& LH(index_type scale_index)
    {
      return Items((scale_index * 6) - 1);
    }
  buf_type& HL(index_type scale_index)
    {
      return Items((scale_index * 6) - 2);
    }
  buf_type& HH(index_type scale_index)
    {
      return Items((scale_index * 6) - 3);
    }
  buf_type& H(index_type scale_index)
    {
      return Items((scale_index * 6) - 4);
    }
  buf_type& L(index_type scale_index)
    {
      return Items((scale_index * 6) - 5);
    }
  buf_type& Band(index_type scale_index,
    index_type orient_index)
    {
      switch (orient_index)
      {
        case 0: return LH(scale_index);
        case 1: return HL(scale_index);
        case 2: return HH(scale_index);
      }
      throw except_type("Invalid subband index");
    }

  size_type PadX() const { return padX_; }
  size_type PadY() const { return padY_; }
  void AddPadding(index_type num_scales)
    {
      buf_type& SrcImage = Image();
      size_type const cx = SrcImage.Width();
      size_type const cy = SrcImage.Height();

      // ensure that we always have an even-sized subband
      size_type const step = static_cast<size_type>(
         0.5 + std::pow(2.0, num_scales)
         );
      padX_ = (cx % step != 0) ? step - (cx % step) : 0;
      padY_ = (cy == 1) ? 0 :
        ((cy % step != 0) ? step - (cy % step) : 0);
      if (padX_ != 0 || padY_ != 0)
      {
        SrcImage.Resize(cx + padX_, cy + padY_, buf_type::rt_copy);
      }
    }
  void RemovePadding()
    {
      // remove the padding that was added to the image
      buf_type& RecImage = Image();
      RecImage.Resize(
        RecImage.Width() - padX_, RecImage.Height() - padY_,
        buf_type::rt_copy
        );
   }
  void AllocBands(index_type num_scales)
    {
      // no-op if we already have the memory
      if (CanRecycleBands(num_scales))
      {
        return;
      }

      // clear all bands except LL(0)
      size_type count = Count();
      for (size_type index = count - 1; index > 0; --index)
      {
        Delete(index);
      }

      buf_type const& SrcImage = Image();
      size_type const cx = SrcImage.Width();
      size_type cy = SrcImage.Height();
      size_type half_cx = cx >> 1;
      size_type half_cy = cy >> 1;

      // add the required subbands to the list
      Reserve(static_cast<size_type>(1.5 + 3.0 * num_scales));
      for (index_type iLevel = 1; iLevel <= num_scales; ++iLevel)
      {
        // make room for the L and H subbands
        Add(half_cx, cy);
        Add(half_cx, cy);

        if (cy > 1)
        {
          // make room for the HH, HL, HL, and LL subbands
          Add(half_cx, half_cy);
          Add(half_cx, half_cy);
          Add(half_cx, half_cy);
          Add(half_cx, half_cy);

          // divide the dimensions by 2 for the next scale
          cy >>= 1; half_cx >>= 1; half_cy >>= 1;
        }
        else
        {
          // make placeholders for the HH, HL, HL, and LL subbands
          Add(0, 0);
          Add(0, 0);
          Add(0, 0);
          Add(0, 0);

          // divide the horz. dimension by 2 for the next scale
          half_cx >>= 1;
        }
      }
    }

private:
  bool CanRecycleBands(index_type num_scales)
    {
      if (num_scales != NumScales())
      {
        return false;
      }

      buf_type const& SrcImage = Image();
      size_type const cx = SrcImage.Width();
      size_type cy = SrcImage.Height();
      size_type half_cx = cx >> 1;
      size_type half_cy = cy >> 1;

      for (index_type iScale = 1; iScale <= num_scales; ++iScale)
      {
        if (L(iScale).Height() != cy) return false;
        if (H(iScale).Height() != cy) return false;
        if (L(iScale).Width() != half_cx) return false;
        if (H(iScale).Width() != half_cx) return false;
        if (cy > 1)
        {
          if (HH(iScale).Width() != half_cx) return false;
          if (HL(iScale).Width() != half_cx) return false;
          if (LH(iScale).Width() != half_cx) return false;
          if (LL(iScale).Width() != half_cx) return false;
          if (HH(iScale).Height() != half_cy) return false;
          if (HL(iScale).Height() != half_cy) return false;
          if (LH(iScale).Height() != half_cy) return false;
          if (LL(iScale).Height() != half_cy) return false;

          // divide the dimensions by 2 for the next scale
          cy >>= 1; half_cx >>= 1; half_cy >>= 1;
        }
        else
        {
          // divide the horz. dimensions by 2 for the next scale
          half_cx >>= 1;
        }
      }
      return true;
    }

private:
  size_type padX_;
  size_type padY_;
};
//-------------------------------------------------------------------------

//////////////////////////////////////////////////////////
// commonly-used aliases
//////////////////////////////////////////////////////////
  typedef GWaveList<GFloatBuffer> GFloatWaveList;
  typedef GWaveList<GDoubleBuffer> GDoubleWaveList;
  typedef GWaveList<GByteBuffer> GByteWaveList;
  typedef GWaveList<GIntBuffer> GIntWaveList;
  typedef GWaveList<GDWordBuffer> GDWordWaveList;
  typedef GWaveList<GShortBuffer> GShortWaveList;
  typedef GWaveList<GWordBuffer> GWordWaveList;
  typedef GWaveList<GBoolBuffer> GBoolWaveList;
//////////////////////////////////////////////////////////

} // namespace buf

#if defined(__BORLANDC__)
  #pragma warn .8027
#endif

//=========================================================================
#endif // gwavelistH
//=========================================================================
