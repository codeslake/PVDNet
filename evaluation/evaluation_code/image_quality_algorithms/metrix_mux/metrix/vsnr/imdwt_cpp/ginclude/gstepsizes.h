
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

//===========================================================================
#ifndef gstepsizesH
#define gstepsizesH
//===========================================================================

#include <cassert>
#include "gbuffer.h"
//===========================================================================

namespace buf {

template <class Type>
class GStepSizes
{
public:
  typedef Type data_type;
  typedef unsigned char scale_type;
  typedef typename GBuffer<Type>::size_type size_type;

public:
  GStepSizes(scale_type num_scales = 5)
    : num_steps_(static_cast<size_type>(1.5 + 3.0*num_scales))
    {
      Steps_.Resize(1, num_steps_, GBuffer<Type>::rt_none);
      Steps_.ZeroData();
    }

  size_type NumSteps() const { return num_steps_; }
  Type const* Data() const { return Steps_.Data(); }
  Type* Data() { return Steps_.Data(); }

  scale_type NumScales() const
    {
      return static_cast<scale_type>(0.5 + (num_steps_ - 1) / 3.0);
    }
  void NumScales(scale_type num_scales)
    {
      num_steps_ = static_cast<size_type>(1.5 + 3.0*num_scales);
      Steps_.Resize(num_steps_, 1, false);
      Steps_.ZeroData();
    }

  Type LL() const
    {
      assert(num_steps_ > 0);
      return Steps_.Data(0);
    }
  Type LH(scale_type scale_index) const
    {
      assert(static_cast<size_type>(3*scale_index) < num_steps_);
      return Steps_.Data(num_steps_ - 3*scale_index);
    }
  Type HL(scale_type scale_index) const
    {
      assert(static_cast<size_type>(3*scale_index - 1) < num_steps_);
      return Steps_.Data(num_steps_ - 3*scale_index + 1);
    }
  Type HH(scale_type scale_index) const
    {
      assert(static_cast<size_type>(3*scale_index - 2) < num_steps_);
      return Steps_.Data(num_steps_ - 3*scale_index + 2);
    }

  void LL(Type Q)
    {
      assert(num_steps_ > 0);
      Steps_.Data(0, Q);
    }
  void LH(scale_type scale_index, Type Q)
    {
      assert(static_cast<size_type>(3*scale_index) < num_steps_);
      Steps_.Data(num_steps_ - 3*scale_index, Q);
    }
  void HL(scale_type scale_index, Type Q)
    {
      assert(static_cast<size_type>(3*scale_index - 1) < num_steps_);
      Steps_.Data(num_steps_ - 3*scale_index + 1, Q);
    }
  void HH(scale_type scale_index, Type Q)
    {
      assert(static_cast<size_type>(3*scale_index - 2) < num_steps_);
      Steps_.Data(num_steps_ - 3*scale_index + 2, Q);
    }

private:
  GBuffer<Type> Steps_;
  size_type num_steps_;
};

//////////////////////////////////////////////////////
// commonly-used aliases
//////////////////////////////////////////////////////
  typedef GStepSizes<int> GIntStepSizes;
  typedef GStepSizes<short> GShortStepSizes;
  typedef GStepSizes<float> GFloatStepSizes;
  typedef GStepSizes<double> GDoubleStepSizes;
  typedef GStepSizes<unsigned char> GByteStepSizes;
  typedef GStepSizes<unsigned short> GWordStepSizes;
  typedef GStepSizes<unsigned int> GDWordStepSizes;
  typedef GStepSizes<short> GShortStepSizes;
//////////////////////////////////////////////////////

} // namespace buf

//===========================================================================
#endif // gstepsizesH
//===========================================================================

