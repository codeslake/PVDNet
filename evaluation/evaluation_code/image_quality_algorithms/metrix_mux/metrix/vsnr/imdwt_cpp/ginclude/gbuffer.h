
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
#ifndef gbufferH
#define gbufferH
//=========================================================================

#if defined(__BORLANDC__)
  #pragma warn -8027
#endif

#include <cstdlib>
#include <cstddef>
#include <cassert>
#include <cstdio>
#include <cmath>

#include <algorithm>
#include <stdexcept>
#include <string>
#include <map>

#if !defined(__GNUG__) || (__GNUG__ > 2)
  #include <limits>
#endif

#include "gtypes.h"
#include "gfile.h"

#if defined(_MSC_VER)
  #pragma warning(disable:4786)
  #ifdef min
    #undef min
  #endif
  #ifdef max
    #undef max
  #endif
  #if (_MSC_VER <= 1200)
    namespace std {
      using ::size_t;
      using ::exp;
      using ::log;
      using ::log10;
      using ::fabs;
      using ::pow;
      using ::sqrt;
      template <typename T> inline T min(T a, T b)
        { return (a > b) ? b : a; }
      template <typename T> inline T max(T a, T b)
        { return (a > b) ? a : b; }
      }
  #endif
#endif
//=========================================================================

namespace buf {

// forward declaration
template <typename Type> class GBuffer;

template <typename Type>
GBuffer<Type> operator *(
   Type lhs,
   GBuffer<Type> const& rhs
  )
{
  assert(!rhs.sleeping_);

  typename GBuffer<Type>::size_type const width = rhs.Width();
  typename GBuffer<Type>::size_type const height = rhs.Height();
  GBuffer<Type> temp(width, height);
  for (typename GBuffer<Type>::size_type y = 0; y < height; ++y)
  {
    for (typename GBuffer<Type>::size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, lhs * rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> operator /(
   Type lhs,
   GBuffer<Type> const& rhs
  )
{
  assert(!rhs.sleeping_);

  typename GBuffer<Type>::size_type const width = rhs.Width();
  typename GBuffer<Type>::size_type const height = rhs.Height();
  GBuffer<Type> temp(width, height);
  for (typename GBuffer<Type>::size_type y = 0; y < height; ++y)
  {
    for (typename GBuffer<Type>::size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, lhs / rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> operator +(
   Type lhs,
   GBuffer<Type> const& rhs
  )
{
  assert(!rhs.sleeping_);

  typename GBuffer<Type>::size_type const width = rhs.Width();
  typename GBuffer<Type>::size_type const height = rhs.Height();
  GBuffer<Type> temp(width, height);
  for (typename GBuffer<Type>::size_type y = 0; y < height; ++y)
  {
    for (typename GBuffer<Type>::size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, lhs + rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> operator -(
   Type lhs,
   GBuffer<Type> const& rhs
  )
{
  assert(!rhs.sleeping_);

  typename GBuffer<Type>::size_type const width = rhs.Width();
  typename GBuffer<Type>::size_type const height = rhs.Height();
  GBuffer<Type> temp(width, height);
  for (typename GBuffer<Type>::size_type y = 0; y < height; ++y)
  {
    for (typename GBuffer<Type>::size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, lhs - rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

#if !defined(__GNUG__)
template <typename Type>
GBuffer<Type> operator ^(
   Type lhs,
   GBuffer<Type> const& rhs
  )
{
  assert(!rhs.sleeping_);

  typename GBuffer<Type>::size_type const width = rhs.Width();
  typename GBuffer<Type>::size_type const height = rhs.Height();
  GBuffer<Type> temp(width, height);
  for (typename GBuffer<Type>::size_type y = 0; y < height; ++y)
  {
    for (typename GBuffer<Type>::size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, std::pow(lhs, rhs.Pixels(x, y)));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------
#endif

template <typename Type>
class GBuffer
{
public:
  typedef Type data_type;
  typedef type::GInt index_type;
  typedef type::GSize size_type;
  typedef type::GDouble real_type;
  typedef std::map<Type, type::GSize> hist_type;
  typedef file::GFile file_type;
  typedef std::runtime_error except_type;
  typedef std::out_of_range range_except_type;
  enum resize_type {rt_none, rt_copy, rt_near, rt_blin, rt_bcub};

public:
  // default constructor
  GBuffer(size_type width = 0, size_type height = 0);
  // constructor for raw Type data
  GBuffer(Type Data, size_type width, size_type height);
  // constructor for raw Type* data
  GBuffer(Type const* pData, size_type width, size_type height);
  // copy constructor
  GBuffer(GBuffer<Type> const& copy);
#if !defined(_MSC_VER)
  template <typename OtherType>
    GBuffer(const GBuffer<OtherType>& copy);
#endif
  // destructor
  ~GBuffer();

  // assignment operator
  GBuffer<Type>& operator =(GBuffer<Type> const& rhs);
  // assignment operator
  GBuffer<Type>& operator =(Type rhs);
  // equality operator
  type::GBool operator ==(GBuffer<Type> const& rhs) const;
  // inequality operator
  type::GBool operator !=(GBuffer<Type> const& rhs) const;
  // negation operator
  GBuffer<Type> operator -() const;

  // element-by-element multiplication operator
  GBuffer<Type> operator *(GBuffer<Type> const& rhs) const;
  // element-by-element division operator
  GBuffer<Type> operator /(GBuffer<Type> const& rhs) const;
  // element-by-element addition operator
  GBuffer<Type> operator +(GBuffer<Type> const& rhs) const;
  // element-by-element subtraction operator
  GBuffer<Type> operator -(GBuffer<Type> const& rhs) const;

  // Type multiplication operator
  GBuffer<Type> operator *(Type rhs) const;
  // Type division operator
  GBuffer<Type> operator /(Type rhs) const;
  // Type addition operator
  GBuffer<Type> operator +(Type rhs) const;
  // Type subtraction operator
  GBuffer<Type> operator -(Type rhs) const;
  // Type exponentiation operator
  GBuffer<Type> operator ^(Type rhs) const;

#if !defined(_MSC_VER) && !defined(__GNUG__)
  friend GBuffer<Type> operator *<Type>(Type lhs, GBuffer<Type> const& rhs);
  friend GBuffer<Type> operator /<Type>(Type lhs, GBuffer<Type> const& rhs);
  friend GBuffer<Type> operator +<Type>(Type lhs, GBuffer<Type> const& rhs);
  friend GBuffer<Type> operator -<Type>(Type lhs, GBuffer<Type> const& rhs);
  friend GBuffer<Type> operator ^<Type>(Type lhs, GBuffer<Type> const& rhs);
#endif

  // element-by-element multiplication-assignment operator
  GBuffer<Type>& operator *=(GBuffer<Type> const& rhs);
  // element-by-element division-assignment operator
  GBuffer<Type>& operator /=(GBuffer<Type> const& rhs);
  // element-by-element addition-assignment operator
  GBuffer<Type>& operator +=(GBuffer<Type> const& rhs);
  // element-by-element subtraction-assignment operator
  GBuffer<Type>& operator -=(GBuffer<Type> const& rhs);

  // Type multiplication-assignment operator
  GBuffer<Type>& operator *=(Type rhs);
  // Type division-assignment operator
  GBuffer<Type>& operator /=(Type rhs);
  // Type addition-assignment operator
  GBuffer<Type>& operator +=(Type rhs);
  // Type subtraction-assignment operator
  GBuffer<Type>& operator -=(Type rhs);
  // Type exponentiation-assignment operator
  GBuffer<Type>& operator ^=(Type rhs);

  // element access operators (slow)
  Type& operator ()(index_type pos)
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (pos < 0 || static_cast<size_type>(pos) >= Size())
      {
        throw range_except_type("operator()");
      }
    #endif
      return *(pData_ + pos);
    }
  Type& operator ()(index_type X, index_type Y)
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (X < 0 || static_cast<size_type>(X) >= width_ ||
          Y < 0 || static_cast<size_type>(Y) >= height_)
      {
        throw range_except_type("operator()");
      }
    #endif
      return *(pData_ + X + (width_ * Y));
    }
  Type const& operator ()(index_type pos) const
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (pos < 0 || static_cast<size_type>(pos) >= Size())
      {
        throw range_except_type("operator()");
      }
    #endif
      return *(pData_ + pos);
    }
  Type const& operator ()(index_type X, index_type Y) const
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (X < 0 || static_cast<size_type>(X) >= width_ ||
          Y < 0 || static_cast<size_type>(Y) >= height_)
      {
        throw range_except_type("operator()");
      }
    #endif
      return *(pData_ + X + (width_ * Y));
    }

  // access and specification member functions
  size_type Width() const
    {
      return width_;
    }
  size_type Height() const
    {
      return height_;
    }
  void Width(size_type width)
    {
      if (width_ != width)
      {
        width_ = width;
        UpdateMemory(true);
      }
    }
  void Height(size_type height)
    {
      if (height_ != height)
      {
        height_ = height;
        UpdateMemory(true);
      }
    }
  size_type Size() const
    {
      return (width_ * height_);
    }
  size_type SizeOf() const
    {
      return (width_ * height_ * sizeof(Type));
    }
  type::GInt TagX() const
    {
      return tagX_;
    }
  void TagX(type::GInt tagX)
    {
      tagX_ = tagX;
    }
  type::GInt TagY() const
    {
      return tagY_;
    }
  void TagY(type::GInt tagY)
    {
      tagY_ = tagY;
    }
  const std::string& Name() const
    {
      return name_;
    }
  std::string& Name()
    {
      return name_;
    }
  Type const* Data() const
    {
      return pData_;
    }
  Type* Data()
    {
      return pData_;
    }
  Type Data(index_type pos) const
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (static_cast<size_type>(pos) >= Size() || pos < 0)
      {
        type::GString s = "GBuffer::Data(): Invalid index (";
        s += type::type2str(pos);
        s += ").";
        throw range_except_type(s);
      }
    #endif
      return *(pData_ + pos);
    }
  void Data(index_type pos, Type value)
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (static_cast<size_type>(pos) >= Size() || pos < 0)
      {
        type::GString s = "GBuffer::Data(): Invalid index (";
        s += type::type2str(pos);
        s += ").";
        throw range_except_type(s);
      }
    #endif
      *(pData_ + pos) = value;
    }
  void IncData(index_type pos, Type val)
    {
      *(pData_ + pos) += val;
    }
  void DecData(index_type pos, Type val)
    {
      *(pData_ + pos) -= val;
    }
  void MulData(index_type pos, Type val)
    {
      *(pData_ + pos) *= val;
    }
  void DivData(index_type pos, Type val)
    {
      *(pData_ + pos) /= val;
    }
  Type Pixels(index_type X, index_type Y) const
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (X < 0 || static_cast<size_type>(X) >= width_ ||
          Y < 0 || static_cast<size_type>(Y) >= height_)
      {
        throw range_except_type("GBuffer::Pixels(): Invalid index");
      }
     #endif
      return *(pData_ + X + (width_ * Y));
     }
  void Pixels(index_type X, index_type Y, Type value)
    {
    #ifndef GBUFFER_NO_RANGE_CHECK
      if (X < 0 || static_cast<size_type>(X) >= width_ ||
          Y < 0 || static_cast<size_type>(Y) >= height_)
      {
        throw range_except_type("GBuffer::Pixels(): Invalid index");
      }
    #endif
      *(pData_ + X + (width_ * Y)) = value;
    }
  Type PixelsCE(index_type X, index_type Y) const
    {
      // perform inline circular extension
      if (X < 0) X = X + width_;
      else if (static_cast<size_type>(X) >= width_) X = X - width_;
      if (Y < 0) Y = Y + height_;
      else if (static_cast<size_type>(Y) >= height_) Y = Y - height_;
      return *(pData_ + X + (width_ * Y));
    }
  Type PixelsSE(index_type X, index_type Y) const
    {
      // perform inline symmetric extension
      if (X < 0) X = -X;
      else if (static_cast<size_type>(X) >= width_)
      {
        X = (width_ << 1) - X - 2;
      }
      if (Y < 0) Y = -Y;
      else if (static_cast<size_type>(Y) >= height_)
      {
        Y = (height_ << 1) - Y - 2;
      }
      return *(pData_ + X + (width_ * Y));
    }
  Type PixelsZP(index_type X, index_type Y) const
    {
      // perform inline symmetric extension
      if (X < 0 || Y < 0 ||
        static_cast<size_type>(X) >= width_ ||
        static_cast<size_type>(Y) >= height_)
      {
        return 0;
      }
      return *(pData_ + X + (width_ * Y));
    }
  Type PixelsHorzSE(index_type X, index_type Y) const
    {
      // perform inline symmetric extension on X
      if (X < 0) X = -X;
      else if (static_cast<size_type>(X) >= width_)
      {
        X = (width_ << 1) - X - 2;
      }
      return *(pData_ + X + (width_ * Y));
    }
  Type PixelsVertSE(index_type X, index_type Y) const
    {
      // perform inline symmetric extension on Y
      if (Y < 0) Y = -Y;
      else if (static_cast<size_type>(Y) >= height_)
      {
        Y = (height_ << 1) - Y - 2;
      }
      return *(pData_ + X + (width_ * Y));
    }
  void IncPixels(index_type X, index_type Y, Type val)
    {
      *(pData_ + X + (width_ * Y)) += val;
    }
  void DecPixels(index_type X, index_type Y, Type val)
    {
      *(pData_ + X + (width_ * Y)) -= val;
    }
  void MulPixels(index_type X, index_type Y, Type val)
    {
      *(pData_ + X + (width_ * Y)) *= val;
    }
  void DivPixels(index_type X, index_type Y, Type val)
    {
      *(pData_ + X + (width_ * Y)) /= val;
    }

  // streaming member functions
  void Load(std::string const& fname, bool swap_end = false);
  void Save(std::string const& fname, bool swap_end = false) const;
  void Load(file_type const& file, bool swap_end = false);
  void Save(file_type const& file, bool swap_end = false) const;

  // utility member functions
  void ZeroData();
  void FillData(Type value);
  void Offset(Type value);
  void Scale(Type value);
  void Normalize(Type min_val = 0, Type max_val = 1);
  void Abs();  
  void Clip(data_type MinVal, data_type MaxVal);
  void Threshold(data_type T, data_type val_lo = 0,
    data_type val_hi = 255);
  GBuffer<Type> Transpose() const;
  GBuffer<Type> Convolve(GBuffer<Type> const& h);
  void Resize(size_type width, size_type height,
    resize_type mode = rt_none);
  GBuffer<Type> Crop(size_type x, size_type y,
    size_type w, size_type h) const;
  GBuffer<Type> ToLuminance(real_type offset = 0,
    real_type scaling = 0.02874, real_type gamma = 2.2) const;
  GBuffer<Type> ToPixelVal(real_type offset = 0,
    real_type scaling = 0.02874, real_type gamma = 2.2) const;
  void BitBlt(size_type x_dst, size_type y_dst,
    GBuffer<Type> const& src_buf,
    size_type x_src = 0, size_type y_src = 0,
    size_type w_src = 0, size_type h_src = 0);

  // algorithm utilities
  void Sort();
  void Reverse();
  size_type Find(data_type val);
  Type NearestVal(real_type val, size_type& val_index) const;
  size_type Count(const Type& val) const;
  void ReplaceAll(const Type& old_val, const Type& new_val) const;

  // computation methods
  hist_type Histogram() const;
  type::GBool IsNull() const;
  Type Min() const;
  Type Max() const;
  Type Mode() const;
  Type Range() const;
  real_type Sum() const;
  real_type Mean() const;
  real_type Median() const;
  real_type Energy() const;
  real_type StdDev() const;
  real_type Variance() const;
  real_type Skewness() const;
  real_type Kurtosis() const;
  real_type Moment(type::GByte N) const;
  real_type Norm(type::GUInt N) const;
  real_type RMS() const;
  real_type SSE(GBuffer<Type> const& other_buf) const;
  real_type MSE(GBuffer<Type> const& other_buf) const;
  real_type RMSE(GBuffer<Type> const& other_buf) const;
  real_type PSNR(GBuffer<Type> const& other_buf) const;
  real_type Correlation(GBuffer<Type> const& other_buf) const;
  real_type Covariance(GBuffer<Type> const& other_buf) const;
  real_type Lmean(real_type offset = 0.0,
    real_type scaling = 0.02874, real_type gamma = 2.2) const;
  real_type Lrms(real_type offset = 0.0,
    real_type scaling = 0.02874, real_type gamma = 2.2) const;
  real_type Crms(real_type Lmean, real_type offset = 0.0,
    real_type scaling = 0.02874, real_type gamma = 2.2) const;
  real_type Entropy() const;

  //
  // quantization methods...
  //
  // uniform quantization
  void Quantize(real_type step_size);
  void QuantizeInt(real_type step_size);
  void DeQuantizeInt(real_type step_size);
  // dead-zone quantization
  void QuantizeDZ(real_type step_size);
  void QuantizeDZInt(real_type step_size);
  void DeQuantizeDZInt(real_type step_size);

  // memory-saving methods
  type::GBool Asleep() const
    {
      return sleeping_;
    }
  void Sleep()
    {
    #ifdef GBUFFER_SLEEPY
      if (!sleeping_)
      {
        sleeping_ = true;
        UpdateMemory(false);
      }
    #endif
    }
  void Awaken()
    {
    #ifdef GBUFFER_SLEEPY
      if (sleeping_)
      {
        sleeping_ = false;
        UpdateMemory(true);
      }
    #endif
    }

private:
  void UpdateMemory(type::GBool zero_init)
    {
      delete [] pData_;
      size_type const size = Size();
      if (!sleeping_ && size > 0)
      {
        pData_ = new Type[size];
        if (zero_init)
        {
        #if defined(_MSC_VER)
          memset(pData_, 0, size * sizeof(Type));
        #else
          std::memset(pData_, 0, size * sizeof(Type));
        #endif
        }
      }
      else pData_ = NULL;
    }

private:
  Type* pData_;
  size_type width_;
  size_type height_;
  type::GInt tagX_;
  type::GInt tagY_;  
  type::GBool sleeping_;
  std::string name_;
};
//=========================================================================

//-----------------------------------------------------------------//
//    Contructors and Destructor                                   //
//-----------------------------------------------------------------//

// default constructor
template <typename Type>
inline GBuffer<Type>::GBuffer(
   size_type width,
   size_type height
  ) : pData_(NULL), width_(width), height_(height),
      tagX_(0), tagY_(0), sleeping_(false)
{
  UpdateMemory(true);
}
//-------------------------------------------------------------------------

// constructor for raw Type data
template <typename Type>
inline GBuffer<Type>::GBuffer(
   Type Data,
   size_type width,
   size_type height
  ) : pData_(NULL), width_(width), height_(height),
      tagX_(0), tagY_(0), sleeping_(false)
{
  UpdateMemory(false);
  if (pData_)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = Data;
    }
  }
}
//-------------------------------------------------------------------------

// constructor for raw Type* data
template <typename Type>
inline GBuffer<Type>::GBuffer(
   Type const* pData,
   size_type width,
   size_type height
  ) : pData_(NULL), width_(width), height_(height),
      tagX_(0), tagY_(0), sleeping_(false)
{
  UpdateMemory(false);
  if (pData_ && pData)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = pData[index];
    }
  }
}
//-------------------------------------------------------------------------

// copy constructor
template <typename Type>
inline GBuffer<Type>::GBuffer(
   GBuffer<Type> const& copy
  ) : pData_(NULL), width_(copy.Width()), height_(copy.Height()),
      tagX_(copy.TagX()), tagY_(copy.TagY()), sleeping_(copy.Asleep())
{
  UpdateMemory(false);
  if (pData_ && copy.Data())
  {
  #if defined(_MSC_VER)
    memcpy(pData_, copy.Data(), copy.SizeOf());
  #else
    std::memcpy(pData_, copy.Data(), copy.SizeOf());
  #endif
  }
}
//-------------------------------------------------------------------------

#if !defined(_MSC_VER)
// copy constructor from GBuffer<OtherType> to GBuffer<Type>
template <typename Type> template <typename OtherType>
inline GBuffer<Type>::GBuffer(
   const GBuffer<OtherType>& copy
  ) : pData_(NULL), width_(copy.Width()), height_(copy.Height()),
      tagX_(copy.TagX()), tagY_(copy.TagY()), sleeping_(copy.Asleep())
{
  UpdateMemory(false);
  const OtherType* pData = copy.Data();
  if (pData_ && pData)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = static_cast<Type>(pData[index]);
    }
  }
}
//-------------------------------------------------------------------------
#endif // _MSC_VER

// destructor
template <typename Type>
inline GBuffer<Type>::~GBuffer()
{
  delete [] pData_;
}
//-------------------------------------------------------------------------


//-----------------------------------------------------------------//
//   Operators                                                     //
//-----------------------------------------------------------------//

template <typename Type>
inline GBuffer<Type>& GBuffer<Type>::operator =(
   GBuffer<Type> const& rhs
  )
{
  if (&rhs != this)
  {
    sleeping_ = rhs.Asleep();
    width_ = rhs.Width(); height_ = rhs.Height();
    tagX_ = rhs.TagX();
    tagY_ = rhs.TagY();

    UpdateMemory(false);
    if (pData_ && rhs.Data())
    {
    #if defined(_MSC_VER)
      memcpy(pData_, rhs.Data(), rhs.SizeOf());
    #else
      std::memcpy(pData_, rhs.Data(), rhs.SizeOf());
    #endif
    }
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
inline GBuffer<Type>& GBuffer<Type>::operator =(
   Type rhs
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] = rhs;
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
type::GBool GBuffer<Type>::operator ==(
   GBuffer<Type> const& rhs
  ) const
{
  assert(!sleeping_);

  if (width_ == rhs.Width() && height_ == rhs.Height())
  {
    size_type const size = Size();
    Type const* pRhsData = rhs.Data();
    for (size_type index = 0; index < size; ++index)
    {
      if (pData_[index] != pRhsData[index])
      {
        return false;
      }
    }
    return true;
  }
  return false;
}
//-------------------------------------------------------------------------

template <typename Type>
type::GBool GBuffer<Type>::operator !=(
   GBuffer<Type> const& rhs
  ) const
{
  assert(!sleeping_);

  if (width_ == rhs.Width() && height_ == rhs.Height())
  {
    size_type const size = Size();
    Type const* pRhsData = rhs.Data();
    for (size_type index = 0; index < size; ++index)
    {
      if (pData_[index] != pRhsData[index])
      {
        return true;
      }
    }
  }
  return false;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator -() const
{
  assert(!sleeping_);

  GBuffer<Type> temp(width_, height_);
  Type* pData = temp.Data();
  size_type const size = Size();

  for (size_type index = 0; index < size; ++index)
  {
    pData[index] = -pData_[index];
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator *(
   GBuffer<Type> const& rhs
  ) const
{
  assert(!sleeping_);

  size_type const width = std::min(width_, rhs.Width());
  size_type const height = std::min(height_, rhs.Height());
  GBuffer<Type> temp(width, height);

  for (size_type y = 0; y < height; ++y)
  {
    for (size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) * rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator /(
   GBuffer<Type> const& rhs
  ) const
{
  assert(!sleeping_);

  size_type const width = std::min(width_, rhs.Width());
  size_type const height = std::min(height_, rhs.Height());
  GBuffer<Type> temp(width, height);

  for (size_type y = 0; y < height; ++y)
  {
    for (size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) / rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator +(
   GBuffer<Type> const& rhs
  ) const
{
  assert(!sleeping_);

  size_type const width = std::min(width_, rhs.Width());
  size_type const height = std::min(height_, rhs.Height());
  GBuffer<Type> temp(width, height);

  for (size_type y = 0; y < height; ++y)
  {
    for (size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) + rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator -(
   GBuffer<Type> const& rhs
  ) const
{
  assert(!sleeping_);

  size_type const width = std::min(width_, rhs.Width());
  size_type const height = std::min(height_, rhs.Height());
  GBuffer<Type> temp(width, height);

  for (size_type y = 0; y < height; ++y)
  {
    for (size_type x = 0; x < width; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) - rhs.Pixels(x, y));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator *(
   Type rhs
  ) const
{
  assert(!sleeping_);

  GBuffer<Type> temp(width_, height_);
  for (size_type y = 0; y < height_; ++y)
  {
    for (size_type x = 0; x < width_; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) * rhs);
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator /(
   Type rhs
  ) const
{
  assert(!sleeping_);

  GBuffer<Type> temp(width_, height_);
  for (size_type y = 0; y < height_; ++y)
  {
    for (size_type x = 0; x < width_; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) / rhs);
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator +(
   Type rhs
  ) const
{
  assert(!sleeping_);

  GBuffer<Type> temp(width_, height_);
  for (size_type y = 0; y < height_; ++y)
  {
    for (size_type x = 0; x < width_; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) + rhs);
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator -(
   Type rhs
  ) const
{
  assert(!sleeping_);

  GBuffer<Type> temp(width_, height_);
  for (size_type y = 0; y < height_; ++y)
  {
    for (size_type x = 0; x < width_; ++x)
    {
      temp.Pixels(x, y, Pixels(x, y) - rhs);
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::operator ^(
   Type rhs
  ) const
{
  assert(!sleeping_);

  GBuffer<Type> temp(width_, height_);
  for (size_type y = 0; y < height_; ++y)
  {
    for (size_type x = 0; x < width_; ++x)
    {
      temp.Pixels(x, y, std::pow(Pixels(x, y), rhs));
    }
  }
  return temp;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator *=(
   GBuffer<Type> const& rhs
  )
{
  assert(!sleeping_);

  if (&rhs != this)
  {
    size_type const width = std::min(width_, rhs.Width());
    size_type const height = std::min(height_, rhs.Height());
    for (size_type y = 0; y < height; ++y)
    {
      for (size_type x = 0; x < width; ++x)
      {
        MulPixels(x, y, rhs.Pixels(x, y));
      }
    }
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator /=(
   GBuffer<Type> const& rhs
  )
{
  assert(!sleeping_);

  if (&rhs != this)
  {
    size_type const width = std::min(width_, rhs.Width());
    size_type const height = std::min(height_, rhs.Height());
    for (size_type y = 0; y < height; ++y)
    {
      for (size_type x = 0; x < width; ++x)
      {
        DivPixels(x, y, rhs.Pixels(x, y));
      }
    }
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator +=(
   GBuffer<Type> const& rhs
  )
{
  assert(!sleeping_);

  if (&rhs != this)
  {
    size_type const width = std::min(width_, rhs.Width());
    size_type const height = std::min(height_, rhs.Height());
    for (size_type y = 0; y < height; ++y)
    {
      for (size_type x = 0; x < width; ++x)
      {
        IncPixels(x, y, rhs.Pixels(x, y));
      }
    }
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator -=(
   GBuffer<Type> const& rhs
  )
{
  assert(!sleeping_);

  if (&rhs != this)
  {
    size_type const width = std::min(width_, rhs.Width());
    size_type const height = std::min(height_, rhs.Height());
    for (size_type y = 0; y < height; ++y)
    {
      for (size_type x = 0; x < width; ++x)
      {
        DecPixels(x, y, rhs.Pixels(x, y));
      }
    }
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator *=(
   Type rhs
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] *= rhs;
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator /=(
   Type rhs
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] /= rhs;
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator +=(
   Type rhs
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] += rhs;
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator -=(
   Type rhs
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] -= rhs;
  }
  return *this;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type>& GBuffer<Type>::operator ^=(
   Type rhs
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] = std::pow(pData_[index], rhs);
  }
  return *this;
}
//-------------------------------------------------------------------------



//-----------------------------------------------------------------//
//   Streaming                                                     //
//-----------------------------------------------------------------//

template <typename Type>
void GBuffer<Type>::Load(
   const std::string& filename,
   bool swap_end
  )
{
  assert(!sleeping_);

  file_type const file(filename.c_str(), "rb");
  Load(file, swap_end);
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Load(
   file_type const& file,
   bool swap_end
  )
{
  assert(!sleeping_);

  // read the width and height from the file
#if (__GNUG__ < 4)  
  width_ = file.template Read<size_type>(swap_end);
  height_ = file.template Read<size_type>(swap_end);  
#else
  width_ = file.Read<size_type>(swap_end);
  height_ = file.Read<size_type>(swap_end);  
#endif
  // allocate enough memory to hold the data
  UpdateMemory(false);

  // read the data from the file
#if (__GNUG__ < 4)   
  file.template Read<Type>(pData_, Size(), swap_end);
#else
  file.Read<Type>(pData_, Size(), swap_end);
#endif  
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Save(
   const std::string& filename,
   bool swap_end
  ) const
{
  assert(!sleeping_);

  // open the file for write access
  file_type const file(filename.c_str(), "wb");
  Save(file, swap_end);
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Save(
   file_type const& file,
   bool swap_end
  ) const
{
  assert(!sleeping_);

  // write the width and height to the stream
  file.Write(width_, swap_end);
  file.Write(height_, swap_end);

  // write the data to the file
  file.Write(pData_, Size(), swap_end);
}
//-------------------------------------------------------------------------


//-----------------------------------------------------------------//
//   Utility Methods                                               //
//-----------------------------------------------------------------//

template <typename Type>
inline void GBuffer<Type>::ZeroData()
{
  assert(!sleeping_);

#if defined(_MSC_VER)
  memset(pData_, 0, SizeOf());
#else
  std::memset(pData_, 0, SizeOf());
#endif
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::FillData(
   Type value
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] = value;
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Offset(
   Type value
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] += value;
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Scale(
   Type value
  )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] *= value;
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Normalize(
   Type min_val,
   Type max_val
  )
{
  min_val = std::abs(Min()) + min_val;
  Offset(min_val);

  Type const current_max_val = std::abs(Max());
  if (current_max_val > 1E-7)
  {
    Scale(max_val / current_max_val);
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Abs()
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] = std::abs(pData_[index]);
  }
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::Transpose() const
{
  assert(!sleeping_);

  size_type const cy = Height();
  size_type const cx = Width();
  GBuffer<Type> bufT(cy, cx);

  for (size_type y = 0; y < cy; ++y)
  {
    for (size_type x = 0; x < cx; ++x)
    {
      bufT.Pixels(y, x, Pixels(x, y));
    }
  }
  return bufT;
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::Convolve(
   GBuffer<Type> const& h
  )
{
/*
  assert(!sleeping_);

  size_type const cy = Height();
  size_type const cx = Width();
  GBuffer<Type> buf_out(cy, cx);
  GBuffer<Type> buf_out2(cy, cx);  

  Type val;  
  size_type const cy_h = h.Height();
  size_type const cx_h = h.Width();

  // if the filter is 1D, do separable filtering
  if (cy_h == 1)
  {
    int offset;
    int const num_taps = cx_h;
    if (num_taps % 2 != 0) // odd-length filter
    {
      offset = -num_taps / 2;
    }
    else
    {
      offset = -std::ceil(num_taps / 2.0f);
    }

    // filter the columns
    for (int y = 0; y < cy; ++y)
    {
      for (int x = 0; x < cx; ++x)
      {
        val = 0;
        for (int tap_idx = 0; tap_idx < cx_h; ++tap_idx)
        {
          val +=
            PixelsSE(x, y + offset + tap_idx) *
            h.Pixels(tap_idx, 0);
        }
        buf_out.Pixels(x, y, val);
      }
    }
    // filter the rows
    for (int y = 0; y < cy; ++y)
    {
      for (int x = 0; x < cx; ++x)
      {
        val = 0;
        for (int tap_idx = 0; tap_idx < cx_h; ++tap_idx)
        {
          val +=
            buf_out.PixelsSE(x + offset + tap_idx, y) *
            h.Pixels(tap_idx, 0);
        }
        buf_out.Pixels(x, y, val);
      }
    }
  }
  else
  {
    throw except_type("2D filtering not implemented.");
  }
  return buf_out;
*/

  assert(!sleeping_);

  int const cy = Height();
  int const cx = Width();
  GBuffer<Type> buf_out(cy, cx);

  Type val;
  int const cy_h = h.Height();
  int const cx_h = h.Width();

  // if the filter is 1D, do separable filtering
  if (cy_h == 1)
  {
    int offset;
    int const num_taps = cx_h;
    if (num_taps % 2 != 0) // odd-length filter
    {
      offset = -num_taps / 2;
    }
    else
    {
      offset = -std::floor(num_taps / 2.0f);
    }

    // filter the rows
    for (int y = 0; y < cy; ++y)
    {
      for (int x = 0; x < cx; ++x)
      {
        val = 0;
        for (int tap_idx = 0; tap_idx < cx_h; ++tap_idx)
        {
          val +=
//            PixelsSE(x + offset + tap_idx, y) *
            PixelsZP(x + offset + tap_idx, y) *
            h.Pixels(tap_idx, 0);
        }
        buf_out.Pixels(x, y, val);
      }
    }
    // filter the columns
    GBuffer<Type> buf_out2(cy, cx);    
    for (int x = 0; x < cx; ++x)
    {
      for (int y = 0; y < cy; ++y)
      {
        val = 0;
        for (int tap_idx = 0; tap_idx < cx_h; ++tap_idx)
        {
          val +=
//            buf_out.PixelsSE(x, y + offset + tap_idx) *
            buf_out.PixelsZP(x, y + offset + tap_idx) *
            h.Pixels(tap_idx, 0);
        }
        buf_out2.Pixels(x, y, val);
      }
    }
    return buf_out2;
  }
  else
  {
    int x_offset, y_offset;
    if (cx_h % 2 != 0) // odd-length filter
    {
      x_offset = -cx_h / 2;
    }
    else
    {
      x_offset = -std::floor(cx_h / 2.0f);
    }
    if (cy_h % 2 != 0) // odd-length filter
    {
      y_offset = -cy_h / 2;
    }
    else
    {
      y_offset = -std::floor(cy_h / 2.0f);
    }
  
    for (int x = 0; x < cx; ++x)
    {
      for (int y = 0; y < cy; ++y)
      {
        val = 0;
        for (int y_h = 0; y_h < cy_h; ++y_h)
        {
          for (int x_h = 0; x_h < cx_h; ++x_h)
          {
            val +=
              h.Pixels(x_h, y_h) *
//              PixelsSE(x + x_h + x_offset, y + y_h + y_offset);
              PixelsZP(x + x_h + x_offset, y + y_h + y_offset);
          }
        }
        buf_out.Pixels(x, y, val);
      }
    }
    return buf_out;    
  }
}
//-------------------------------------------------------------------------

inline float get_bicubic_weight(float x)
{
  float v1 = x + 2.0f;
  float v2 = x + 1.0f;
  float v3 = x;
  float v4 = x - 1.0f;

  v1 = (v1 > 0.0f) ? v1*v1*v1 : 0.0f;
  v2 = (v2 > 0.0f) ? 4.0f*v2*v2*v2 : 0.0f;
  v3 = (v3 > 0.0f) ? 6.0f*v3*v3*v3 : 0.0f;
  v4 = (v4 > 0.0f) ? 4.0f*v4*v4*v4 : 0.0f;

  return (v1 - v2 + v3 - v4);
}

template <typename Type>
void GBuffer<Type>::Resize(
   size_type width,
   size_type height,
   resize_type mode
  )
{
  if (width == width_ && height == height_)
  {
    // no-op, if the dimensions are unchanged
    return;
  }

  switch (mode)
  {
    case rt_none: // resize & discard current data
    {
      // update the dimensions
      width_ = width; height_ = height;

      // update the memory
      UpdateMemory(false);
      break;
    }
    case rt_copy: // resize & keep current data (but don't interpolate)
    {
      // make a copy of the current data
      GBuffer<Type> SaveBuffer(*this);

      // update the dimensions
      width_ = width; height_ = height;

      // update the memory
      UpdateMemory(false);

      // restore the data
      if (pData_)
      {
        size_type const sizeX = std::min(width, SaveBuffer.Width());
        size_type const sizeY = std::min(height, SaveBuffer.Height());      
        for (size_type y = 0; y < sizeY; ++y)
        {
          for (size_type x = 0; x < sizeX; ++x)
          {
            Pixels(x, y, SaveBuffer.Pixels(x, y));
          }
        }
      }
      break;
    }
    case rt_near: // nearest-neighbor interpolation
    {
      int const src_cx = width_;
      int const src_cy = height_;
      int const dst_cx = width;
      int const dst_cy = height;

      float const ratio_cx =
        static_cast<float>(src_cx) / static_cast<float>(dst_cx);
      float const ratio_cy =
        static_cast<float>(src_cy) / static_cast<float>(dst_cy);

      float x_src_f, y_src_f;
      int x_src, y_src;

      GBuffer<Type> dst_buf(dst_cx, dst_cy);
      Type* p_dst_row = dst_buf.Data();
  
      for (int y_dst = 0; y_dst < dst_cy; ++y_dst)
      {
        y_src_f = y_dst * ratio_cy;
        y_src = y_src_f;

        for (int x_dst = 0; x_dst < dst_cx; ++x_dst)
        {
          x_src_f = x_dst * ratio_cx;
          x_src = x_src_f;

          p_dst_row[x_dst] = PixelsSE(x_src, y_src);
        }
        // move to the next row
        p_dst_row += dst_cy;    
      }
      *this = dst_buf;
      break;
    }
    case rt_blin: // bilinear interpolation
    {
      int const src_cx = width_;
      int const src_cy = height_;
      int const dst_cx = width;
      int const dst_cy = height;

      float const ratio_cx =
        static_cast<float>(src_cx) / static_cast<float>(dst_cx);
      float const ratio_cy =
        static_cast<float>(src_cy) / static_cast<float>(dst_cy);

      float x_src_f, y_src_f;
      int x_src, y_src;

      GBuffer<Type> dst_buf(dst_cx, dst_cy);
      Type* p_dst_row = dst_buf.Data();
  
      float val;
      for (int y_dst = 0; y_dst < dst_cy; ++y_dst)
      {
        y_src_f = y_dst * ratio_cy;
        y_src = y_src_f;

        for (int x_dst = 0; x_dst < dst_cx; ++x_dst)
        {
          x_src_f = x_dst * ratio_cx;
          x_src = x_src_f;

          val  = PixelsSE(x_src    , y_src - 1) * 0.125f;
          val += PixelsSE(x_src - 1, y_src    ) * 0.125f;
          val += PixelsSE(x_src    , y_src    ) * 0.5f;
          val += PixelsSE(x_src + 1, y_src    ) * 0.125f;
          val += PixelsSE(x_src    , y_src + 1) * 0.125f;
          
          p_dst_row[x_dst] = val;
        }
        // move to the next row
        p_dst_row += dst_cy;    
      }
      *this = dst_buf;
      break;
    }
    case rt_bcub: // bicubic interpolation
    {
      int const src_cx = width_;
      int const src_cy = height_;
      int const dst_cx = width;
      int const dst_cy = height;

      float const ratio_cx =
        static_cast<float>(src_cx) / static_cast<float>(dst_cx);
      float const ratio_cy =
        static_cast<float>(src_cy) / static_cast<float>(dst_cy);

      float dx, dy;
      float x_src_f, y_src_f;
      int x_src, y_src;

      float weight;
      float weight_x0, weight_x1, weight_x2, weight_x3;
      float weight_y0, weight_y1, weight_y2, weight_y3;

      GBuffer<Type> dst_buf(dst_cx, dst_cy);
      Type* p_dst_row = dst_buf.Data();
  
      float val;
      for (int y_dst = 0; y_dst < dst_cy; ++y_dst)
      {
        y_src_f = y_dst * ratio_cy;
        y_src = y_src_f;
        dy = y_src_f - y_src;

        weight_y0 = get_bicubic_weight(dy + 1) / 36.0f;
        weight_y1 = get_bicubic_weight(dy) / 36.0f;
        weight_y2 = get_bicubic_weight(dy - 1) / 36.0f;
        weight_y3 = get_bicubic_weight(dy - 2) / 36.0f;

        for (int x_dst = 0; x_dst < dst_cx; ++x_dst)
        {
          x_src_f = x_dst * ratio_cx;
          x_src = x_src_f;
          dx = x_src_f - x_src;

          weight_x0 = get_bicubic_weight(-1 - dx);
          weight_x1 = get_bicubic_weight(-dx);
          weight_x2 = get_bicubic_weight(1 - dx);
          weight_x3 = get_bicubic_weight(2 - dx);

          val = 0.0f;
          weight = weight_x0 * weight_y0;
          val += PixelsSE(x_src - 1, y_src - 1) * weight;
          weight = weight_x1 * weight_y0;
          val += PixelsSE(x_src    , y_src - 1) * weight;
          weight = weight_x2 * weight_y0;
          val += PixelsSE(x_src + 1, y_src - 1) * weight;
          weight = weight_x3 * weight_y0;
          val += PixelsSE(x_src + 2, y_src - 1) * weight;

          weight = weight_x0 * weight_y1;
          val += PixelsSE(x_src - 1, y_src    ) * weight;
          weight = weight_x1 * weight_y1;
          val += PixelsSE(x_src    , y_src    ) * weight;
          weight = weight_x2 * weight_y1;
          val += PixelsSE(x_src + 1, y_src    ) * weight;
          weight = weight_x3 * weight_y1;
          val += PixelsSE(x_src + 2, y_src    ) * weight;

          weight = weight_x0 * weight_y2;
          val += PixelsSE(x_src - 1, y_src + 1) * weight;
          weight = weight_x1 * weight_y2;
          val += PixelsSE(x_src    , y_src + 1) * weight;
          weight = weight_x2 * weight_y2;
          val += PixelsSE(x_src + 1, y_src + 1) * weight;
          weight = weight_x3 * weight_y2;
          val += PixelsSE(x_src + 2, y_src + 1) * weight;

          weight = weight_x0 * weight_y3;
          val += PixelsSE(x_src - 1, y_src + 2) * weight;
          weight = weight_x1 * weight_y3;
          val += PixelsSE(x_src    , y_src + 2) * weight;
          weight = weight_x2 * weight_y3;
          val += PixelsSE(x_src + 1, y_src + 2) * weight;
          weight = weight_x3 * weight_y3;
          val += PixelsSE(x_src + 2, y_src + 2) * weight;

          p_dst_row[x_dst] = val;
        }
        // move to the next row
        p_dst_row += dst_cy;    
      }
      *this = dst_buf;
      break;
    }
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Clip(
  data_type MinVal,
  data_type MaxVal
 )
{
 assert(!sleeping_);

 size_type const size = Size();
 for (size_type index = 0; index < size; ++index)
 {
   if (pData_[index] > MaxVal)
   {
     pData_[index] = MaxVal;
   }
   else if (pData_[index] < MinVal)
   {
     pData_[index] = MinVal;
   }
 }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Threshold(
  data_type T,
  data_type val_lo,
  data_type val_hi
 )
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] = (pData_[index] >= T) ? val_hi : val_lo;
  }
}
//-------------------------------------------------------------------------

template <typename Type>
GBuffer<Type> GBuffer<Type>::Crop(
   size_type x,
   size_type y,
   size_type w,
   size_type h
  ) const
{
  assert(x + w <= width_);
  assert(y + h <= height_);

  GBuffer<Type> chunk(w, h);
  size_type const maxX = x + w;
  size_type const maxY = y + h;

  for (size_type Y = y; Y < maxY; ++Y)
  {
    for (size_type X = x; X < maxX; ++X)
    {
      chunk.Pixels(X - x, Y - y, Pixels(X, Y));
    }
  }
  return chunk;
}
//-------------------------------------------------------------------------

//
// returns a luminance version of the image
//
template <typename Type>
GBuffer<Type> GBuffer<Type>::ToLuminance(
   real_type offset,  // black level offset
   real_type scaling, // pixel-value to voltage scaling factor
   real_type gamma    // exponent of the power function
  ) const
{
  assert(!sleeping_);

  size_type const size = Size();
  GBuffer<Type> LuminanceBuffer(width_, height_);
  Type* pData = LuminanceBuffer.Data();
  for (size_type index = 0; index < size; ++index)
  {
    pData[index] = std::pow(offset + scaling*pData_[index], gamma);
  }
  return LuminanceBuffer;
}
//-------------------------------------------------------------------------

//
// returns a pixel-value version of the image
//
template <typename Type>
GBuffer<Type> GBuffer<Type>::ToPixelVal(
   real_type offset,  // black level offset
   real_type scaling, // pixel-value to voltage scaling factor
   real_type gamma    // exponent of the power function
  ) const
{
  assert(!sleeping_);
  assert(gamma != 0);
  assert(scaling != 0);

  const real_type inv_gamma = 1.0 / gamma;
  const real_type inv_scaling = 1.0 / scaling;

  size_type const size = Size();
  GBuffer<Type> PixelValBuffer(*this);
  Type* pData = PixelValBuffer.Data();
  for (size_type index = 0; index < size; ++index)
  {
    pData[index] = (pData[index] <= 0) ? 0 : inv_scaling * (
      std::pow(static_cast<real_type>(pData[index]), inv_gamma) -
      offset
      );
  }
  return PixelValBuffer;
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::BitBlt(
   size_type x_dst,
   size_type y_dst,
   GBuffer<Type> const& src_buf,
   size_type x_src,
   size_type y_src,
   size_type w_src,
   size_type h_src
  )
{
  if (&src_buf == this)
  {
    // no op required; source and target are the same
    return;
  }

  assert(!sleeping_);

  size_type x_src_max, y_src_max;
  if (w_src == 0 && h_src == 0)
  {
    x_src_max = src_buf.Width();
    y_src_max = src_buf.Height();
  }
  else
  {
    x_src_max = x_src + w_src;
    y_src_max = y_src + h_src;
  }

  size_type x_dst_copy;
  for (size_type y = y_src; y < y_src_max; ++y)
  {
    x_dst_copy = x_dst;
    for (size_type x = x_src; x < x_src_max; ++x)
    {
      Pixels(x_dst_copy++, y_dst, src_buf.Pixels(x, y));
    }
    ++y_dst;
  }
}
//-------------------------------------------------------------------------


//-----------------------------------------------------------------//
//   Computation Methods                                           //
//-----------------------------------------------------------------//

template <typename Type>
void GBuffer<Type>::Sort()
{
 assert(!sleeping_);
 std::sort(pData_, pData_ + Size());
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::Reverse()
{
 assert(!sleeping_);
 std::reverse(pData_, pData_ + Size());
}
//-------------------------------------------------------------------------

template <typename Type>
typename GBuffer<Type>::size_type GBuffer<Type>::Find(data_type val)
{
 assert(!sleeping_);

 size_type const size = Size();
 data_type const* pVal = std::find(pData_, pData_ + size, val);
 return (pVal - pData_);
}
//-------------------------------------------------------------------------

template <typename Type>
Type GBuffer<Type>::NearestVal(
   real_type val,
   size_type& val_index
  ) const
{
 assert(!sleeping_);

 Type closest_val = 0;
 size_type const size = Size();
 real_type min_dist = std::numeric_limits<real_type>::max();
 for (size_type index = 0; index < size; ++index)
 {
   const real_type dist = std::fabs(pData_[index] - val);
   if (dist <= min_dist)
   {
     min_dist = dist;
     closest_val = pData_[index];
     val_index = index;
   }
 }
 return closest_val;
}
//-------------------------------------------------------------------------

template <typename Type>
typename GBuffer<Type>::size_type GBuffer<Type>::Count(
   const Type& val
  ) const
{
  assert(!sleeping_);
  return std::count(pData_, pData_ + Size(), val);
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::ReplaceAll(
   const Type& old_val,
   const Type& new_val
  ) const
{
  assert(!sleeping_);
  return std::replace(pData_, pData_ + Size(), old_val, new_val);
}
//-------------------------------------------------------------------------

template <typename Type>
typename GBuffer<Type>::hist_type GBuffer<Type>::Histogram() const
{
  assert(!sleeping_);

  hist_type hist;
  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    ++hist[pData_[index]];
  }
  return hist;
}
//-------------------------------------------------------------------------

template <typename Type>
type::GBool GBuffer<Type>::IsNull() const
{
  assert(!sleeping_);

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    if (pData_[index] != 0)
    {
      return false;
    }
  }
  return true;
}
//-------------------------------------------------------------------------

template <typename Type>
Type GBuffer<Type>::Min() const
{
  assert(!sleeping_);

//#if !defined(__GNUG__) || (__GNUG__ > 2)
  Type min_val = std::numeric_limits<Type>::max();
  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    if (pData_[index] < min_val)
    {
      min_val = pData_[index];
    }
  }
  return min_val;
//#else
  // punt on older versions of g++ that
  // don't support the numeric_limits class
  //return 0;
//#endif
}
//-------------------------------------------------------------------------

template <typename Type>
Type GBuffer<Type>::Max() const
{
  assert(!sleeping_);

//#if !defined(__GNUG__) || (__GNUG__ > 2)

#if defined(__BORLANDC__)
 #pragma warn -8008
 #pragma warn -8041
 #pragma warn -8066
#endif

  Type max_val;
  if (std::numeric_limits<Type>::is_integer)
  {
    max_val = std::numeric_limits<Type>::min();
  }
  else
  {
    max_val = -std::numeric_limits<Type>::max();
  }

#if defined(__BORLANDC__)
 #pragma warn .8008
 #pragma warn .8041
 #pragma warn .8066
#endif

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    if (pData_[index] > max_val)
    {
      max_val = pData_[index];
    }
  }
  return max_val;

//#else
  // punt on older versions of g++ that
  // don't support the numeric_limits class
//  return 0;
//#endif
}
//-------------------------------------------------------------------------

template <typename Type>
Type GBuffer<Type>::Range() const
{
  assert(!sleeping_);

  return (Max() - Min());
}
//-------------------------------------------------------------------------

template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Sum() const
{
  assert(!sleeping_);

  real_type sum_of_x = 0;
  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    sum_of_x += pData_[index];
  }
  return sum_of_x;
}
//-------------------------------------------------------------------------

//
// Mean = E{X} = (1/size)*sum(X)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Mean() const
{
  assert(!sleeping_);

  return (Sum() / Size());
}
//-------------------------------------------------------------------------

//
// Median = middle( sort(X) )
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Median() const
{
  assert(!sleeping_);

  GBuffer<Type> temp(*this);
  temp.Sort();

  size_type const size = Size();
  if (size % 2 != 0)
  {
    return temp.Data(static_cast<index_type>(0.5 * size));
  }
  else
  {
    return 0.5 * (
      temp.Data(static_cast<index_type>(0.5 * size - 0.5)) +
      temp.Data(static_cast<index_type>(0.5 * size + 0.5))
      );
  }
}
//-------------------------------------------------------------------------

//
// Mode = most frequenlty occurring value
//
template <typename Type>
Type GBuffer<Type>::Mode() const
{
  assert(!sleeping_);

  typename hist_type::key_type max_hist_bin = 0;
  typename hist_type::mapped_type max_hist_val = 0;

  hist_type hist(Histogram());
  typename hist_type::iterator hist_end = hist.end();
  for (typename hist_type::iterator iter = hist.begin();
       iter != hist_end; ++iter)
  {
    if ((*iter).second >= max_hist_val)
    {
      max_hist_bin = (*iter).first;
      max_hist_val = (*iter).second;
    }
  }
  return max_hist_bin;
}
//-------------------------------------------------------------------------

//
// Energy = E{X^2} = (1/size)*sum(X)
// NOTE: Energy(X) equals Variance(X) if Mean(X) is 0
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Energy() const
{
  assert(!sleeping_);

  real_type sum_of_xSquared = 0.0;
  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    sum_of_xSquared += (pData_[index] * pData_[index]);
  }
  return (sum_of_xSquared / size);
}
//-------------------------------------------------------------------------

//
// StdDev = sqrt(E{X^2} - (E{X})^2) = sqrt(Variance(X))
// NOTE: StdDev(X) equals RMS(X) if Mean(X) is 0
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::StdDev() const
{
  assert(!sleeping_);

  return std::sqrt(Variance());
}
//-------------------------------------------------------------------------

//
// Variance = E{X^2} - (E{X})^2 = (1/size)*sum((X - Mean(X))^2)
// NOTE: Variance(X) equals Energy(X) if Mean(X) is 0
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Variance() const
{
  assert(!sleeping_);

  real_type const avg_of_x = Mean();
  real_type sum_of_xSquared = 0.0;
  size_type const size = Size();

  for (size_type index = 0; index < size; ++index)
  {
    real_type const x0 = pData_[index] - avg_of_x;
    sum_of_xSquared += (x0 * x0);
  }
  return (sum_of_xSquared / size);
}
//-------------------------------------------------------------------------

//
// Skewness = E{(X - E{X})^3} = (1/size)*sum((X - Mean(X))^3)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Skewness() const
{
  assert(!sleeping_);

  const Type avg_of_x = Mean();
  real_type sum_of_xCubed = 0.0;
  size_type const size = Size();

  for (size_type index = 0; index < size; ++index)
  {
    const real_type x0 = pData_[index] - avg_of_x;
    sum_of_xCubed += (x0 * x0 * x0);
  }

  const real_type std_dev = StdDev();
  sum_of_xCubed /= (std_dev * std_dev * std_dev);

  return (sum_of_xCubed / size);
}
//-------------------------------------------------------------------------

//
// Kurtosis = E{(X - E{X})^4} = (1/size)*sum((X - Mean(X))^4)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Kurtosis() const
{
  assert(!sleeping_);

  const real_type avg_of_x = Mean();
  real_type sum_of_xFourth = 0.0;
  size_type const size = Size();

  for (size_type index = 0; index < size; ++index)
  {
    const real_type x0 = pData_[index] - avg_of_x;
    sum_of_xFourth += (x0 * x0 * x0 * x0);
  }

  const real_type std_dev = StdDev();
  sum_of_xFourth /= (std_dev * std_dev * std_dev * std_dev);

  return (sum_of_xFourth / size);
}
//-------------------------------------------------------------------------

//
// Central moment = E{(X - E{X})^N} = (1/size)*sum((X - Mean(X))^N)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Moment(
   type::GByte N
  ) const
{
  assert(!sleeping_);

  const real_type avg_of_x = Mean();
  real_type sum_of_xN = 0.0;
  size_type const size = Size();

  for (size_type index = 0; index < size; ++index)
  {
    const real_type x0 = pData_[index] - avg_of_x;
    sum_of_xN += std::pow(x0, N);
  }
  sum_of_xN /= std::pow(StdDev(), N);

  return (sum_of_xN / size);
}
//-------------------------------------------------------------------------

//
// LN Norm = N-th root of the sum of the values to the N
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Norm(
   type::GUInt N
  ) const
{
  assert(!sleeping_);

  real_type sum = 0.0;
  size_type const size = Size();
  switch (N)
  {
    case 0: return 0.0;
    case 1: return Sum();
    case 2:
    {
      for (size_type index = 0; index < size; ++index)
      {
        sum += (pData_[index]*pData_[index]);
      }
      return std::sqrt(sum);
    }
    case 3:
    {
      for (size_type index = 0; index < size; ++index)
      {
        sum += (pData_[index]*pData_[index]*pData_[index]);
      }
      break;
    }
    case 4:
    {
      for (size_type index = 0; index < size; ++index)
      {
        sum += (
          pData_[index]*pData_[index]*pData_[index]*pData_[index]
          );
      }
      break;
    }
    default:
    {
      real_type val;
      for (size_type index = 0; index < size; ++index)
      {
        val = 1.0;
        for (size_type n = 0; n < N; ++n)
        {
          val *= pData_[index];
        }
        sum += val;
      }
      break;
    }
  }
  return std::pow(sum, 1.0/static_cast<real_type>(N));
}
//-------------------------------------------------------------------------

//
// (root-mean-square) RMS = sqrt(E{X^2}) = sqrt(Energy(X))
// NOTE: RMS(X) equals StdDev(X) if Mean(X) is 0
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::RMS() const
{
  assert(!sleeping_);

  return std::sqrt(Energy());
}
//-------------------------------------------------------------------------

//
// (sum-squared-error) SSE = Sum{(X1 - X2)^2}
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::SSE(
   GBuffer<Type> const& other_buf
  ) const
{
  assert(!sleeping_);

  size_type const sizeX = std::min(width_, other_buf.Width());
  size_type const sizeY = std::min(height_, other_buf.Height());
  real_type sum_squared_error = 0;

  real_type error;
  for (size_type y = 0; y < sizeY; ++y)
  {
    for (size_type x = 0; x < sizeX; ++x)
    {
      error = Pixels(x, y) - other_buf.Pixels(x, y);
      sum_squared_error += (error * error);
    }
  }
  return sum_squared_error;
}
//-------------------------------------------------------------------------

//
// (mean-squared-error) MSE = E{(X1 - X2)^2} = Mean((X1 - X2)^2)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::MSE(
   GBuffer<Type> const& other_buf
  ) const
{
  assert(!sleeping_);

  size_type const sizeX = std::min(width_, other_buf.Width());
  size_type const sizeY = std::min(height_, other_buf.Height());
  real_type sum_squared_error = 0;

  real_type error;
  for (size_type y = 0; y < sizeY; ++y)
  {
    for (size_type x = 0; x < sizeX; ++x)
    {
      error = Pixels(x, y) - other_buf.Pixels(x, y);
      sum_squared_error += (error * error);
    }
  }
  return (sum_squared_error / (sizeX * sizeY));
}
//-------------------------------------------------------------------------

//
// (root-mean-square-error) RMSE = RMS(X1 - X2) = sqrt(MSE(X1, X2))
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::RMSE(
   GBuffer<Type> const& other_buf
  ) const
{
  assert(!sleeping_);

  return std::sqrt(MSE(other_buf));
}
//-------------------------------------------------------------------------

//
// (peak signal-to-noise ratio) PSNR = 10*log10(255^2 / MSE(X1, X2))
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::PSNR(
   GBuffer<Type> const& other_buf
  ) const
{
  assert(!sleeping_);

  return (10.0 * std::log10(65025.0 / MSE(other_buf)));
  // NOTE: 65025.0 == 255*255
}
//-------------------------------------------------------------------------

//
// (correlation coefficient) R = sum(x.*y)/sqrt(sum(x.*x)*sum(y.*y))
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Correlation(
   GBuffer<Type> const& other_buf
  ) const
{
  assert(!sleeping_);

  size_type const sizeX = std::min(width_, other_buf.Width());
  size_type const sizeY = std::min(height_, other_buf.Height());

  real_type sum_xy = 0;
  real_type sum_xx = 0;
  real_type sum_yy = 0;

  real_type const mX = Mean();
  real_type const mY = other_buf.Mean();
  for (size_type y = 0; y < sizeY; ++y)
  {
    for (size_type x = 0; x < sizeX; ++x)
    {
      real_type const x_val = Pixels(x, y) - mX;
      real_type const y_val = other_buf.Pixels(x, y) - mY;
      sum_xy += (x_val * y_val);
      sum_xx += (x_val * x_val);
      sum_yy += (y_val * y_val);
    }
  }
  return (sum_xy / std::sqrt(sum_xx * sum_yy));
}
//-------------------------------------------------------------------------

//
// Covariance = E{X*Y} = sum(x.*y)/(size(x)*size(y))
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Covariance(
   GBuffer<Type> const& other_buf
  ) const
{
  assert(!sleeping_);

  size_type const sizeX = std::min(width_, other_buf.Width());
  size_type const sizeY = std::min(height_, other_buf.Height());

  const real_type mX = Mean();
  const real_type mY = other_buf.Mean();
  real_type sum_xy = 0;

  for (size_type y = 0; y < sizeY; ++y)
  {
    for (size_type x = 0; x < sizeX; ++x)
    {
      real_type const zm_x_val = Pixels(x, y) - mX;
      real_type const zm_y_val = other_buf.Pixels(x, y) - mY;
      sum_xy += (zm_x_val * zm_y_val);
    }
  }
  return (sum_xy / (sizeX * sizeY));
}
//-------------------------------------------------------------------------

//
// Lmean = E{luminance values}
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Lmean(
   real_type offset,  // black level offset
   real_type scaling, // pixel-value to voltage scaling factor
   real_type gamma    // exponent of the power function
  ) const
{
  assert(!sleeping_);

  real_type val;
  real_type lum_sum = 0.0f;
  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    val = offset + scaling*pData_[index];
    if (val > 0)
    {
      // lum_sum += std::pow(val, gamma);
      lum_sum += std::exp(gamma * std::log(val));
    }
  }
  return (lum_sum / size);
}
//-------------------------------------------------------------------------

//
// Lrms = StdDev(luminance values)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Lrms(
   real_type offset,  // black level offset
   real_type scaling, // pixel-value to voltage scaling factor
   real_type gamma    // exponent of the power function
  ) const
{
  assert(!sleeping_);

  size_type const size = Size();
  GBuffer<Type> LuminanceBuffer(*this);
  Type* pData = LuminanceBuffer.Data();
  for (size_type index = 0; index < size; ++index)
  {
     pData[index] = std::pow(offset + scaling*pData[index], gamma);
  }
  return LuminanceBuffer.StdDev();

/*
  real_type val;
  real_type lum_sum = 0;
  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    val = offset + scaling*pData_[index];
    if (val > 0)
    {
      val = std::exp(gamma * std::log(val)) - Lmean;
      lum_sum += (val * val);
    }
  }
  return std::sqrt(lum_sum / size);
*/
}
//-------------------------------------------------------------------------

//
// (RMS contrast) Crms = StdDev(luminance values)/Mean(luminance values)
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Crms(
   real_type Lmean,   // mean background luminance
   real_type offset,  // black level offset
   real_type scaling, // pixel-value to voltage scaling factor
   real_type gamma    // exponent of the power function
  ) const
{
  assert(!sleeping_);

  return (Lrms(offset, scaling, gamma) / Lmean);
}
//-------------------------------------------------------------------------

//
// (Entropy) H = -E{p(X)*log[p(X)]) = -(1/size)*sum(p(x)*log[p(x)])
//
template <typename Type>
typename GBuffer<Type>::real_type GBuffer<Type>::Entropy() const
{
  assert(!sleeping_);

  hist_type hist(Histogram());
  size_type const size = Size();

  real_type H = 0.0;
  for (typename hist_type::iterator iter = hist.begin();
       iter != hist.end(); ++iter)
  {
    real_type const p =
      static_cast<real_type>((*iter).second) /
      static_cast<real_type>(size);
    H += (p * std::log(p));
  }
  return -(H * 1.4426950); // 1.4426950 = 1/log(2)
}
//-------------------------------------------------------------------------



//-----------------------------------------------------------------//
//   Quantization Methods                                          //
//-----------------------------------------------------------------//

template <typename Type>
void GBuffer<Type>::Quantize(
   real_type step_size
  )
{
  assert(!sleeping_);

  if (std::fabs(step_size) < 0.00001) return;

  Type val;
  size_type const size = Size();
  real_type const half_step_size = 0.5f * step_size;
  for (size_type index = 0; index < size; ++index)
  {
    val = (pData_[index] >= 0) ?
      pData_[index] + half_step_size :
      pData_[index] - half_step_size;
    pData_[index] = step_size *
      static_cast<type::GInt>(val / step_size);
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::QuantizeInt(
   real_type step_size
  )
{
  assert(!sleeping_);

  if (std::fabs(step_size) < 0.00001) return;

  size_type const size = Size();
  real_type const inv_step_size = 1.0 / step_size;
  real_type const half_step_size = 0.5 * step_size;
  for (size_type index = 0; index < size; ++index)
  {
    const Type val = (pData_[index] >= 0) ?
      pData_[index] + half_step_size :
      pData_[index] - half_step_size;
    pData_[index] = static_cast<type::GInt>(val * inv_step_size);
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::DeQuantizeInt(
   real_type step_size
  )
{
  assert(!sleeping_);

  if (std::fabs(step_size) < 0.00001) return;

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    pData_[index] *= step_size;
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::QuantizeDZ(
   real_type step_size
  )
{
  assert(!sleeping_);

  if (std::fabs(step_size) < 0.00001) return;

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    const type::GInt q_index = pData_[index] / step_size;
    if (q_index > 0)
    {
      pData_[index] = step_size *
        (static_cast<real_type>(q_index) + 0.5);
    }
    else if (q_index < 0)
    {
      pData_[index] = step_size*
        (static_cast<real_type>(q_index) - 0.5);
    }
    else
    {
      pData_[index] = 0;
      // i.e., = (type::GInt)(pData_[index] / step_size);
      // i.e., = q_index
    }
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::QuantizeDZInt(
   real_type step_size
  )
{
  assert(!sleeping_);

  if (std::fabs(step_size) < 0.00001) return;

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    const type::GInt q_index = pData_[index] / step_size;
    pData_[index] = q_index;
  }
}
//-------------------------------------------------------------------------

template <typename Type>
void GBuffer<Type>::DeQuantizeDZInt(
   real_type step_size
  )
{
  assert(!sleeping_);

  if (std::fabs(step_size) < 0.00001) return;

  size_type const size = Size();
  for (size_type index = 0; index < size; ++index)
  {
    const type::GInt q_index = pData_[index];
    if (q_index > 0)
    {
      pData_[index] = step_size *
        (static_cast<real_type>(q_index) + 0.5);
    }
    else if (q_index < 0)
    {
      pData_[index] = step_size *
        (static_cast<real_type>(q_index) - 0.5);
    }
    else
    {
      pData_[index] = 0;
      // i.e., = (type::GInt)(pData_[index] / step_size);
      // i.e., = q_index
    }
  }
}
//-------------------------------------------------------------------------

///////////////////////////////////////////////////
// commonly-used aliases
///////////////////////////////////////////////////
  typedef GBuffer<type::GInt> GIntBuffer;
  typedef GBuffer<type::GBool> GBoolBuffer;
  typedef GBuffer<type::GFloat> GFloatBuffer;
  typedef GBuffer<type::GDouble> GDoubleBuffer;
  typedef GBuffer<type::GByte> GByteBuffer;
  typedef GBuffer<type::GWord> GWordBuffer;
  typedef GBuffer<type::GDWord> GDWordBuffer;
  typedef GBuffer<type::GShort> GShortBuffer;
  typedef GBuffer<type::GByte3D> GByte3DBuffer;
  typedef GBuffer<type::GFloat3D> GFloat3DBuffer;
///////////////////////////////////////////////////

#if !defined(_MSC_VER) && !defined(__GNUG__)

// copy constructor from GFloatBuffer to GByteBuffer
template <>
inline GByteBuffer::GBuffer(
   const GFloatBuffer& copy
  ) : pData_(NULL), width_(copy.Width()), height_(copy.Height()),
      tagX_(copy.TagX()), tagY_(copy.TagY()), sleeping_(copy.Asleep())
{
  UpdateMemory(false);
  const GFloatBuffer::data_type* pData = copy.Data();
  if (pData_ && pData)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = static_cast<GByteBuffer::data_type>(
        type::round2byte(pData[index])
        );
    }
  }
}
//-------------------------------------------------------------------------

// copy constructor from GFloatBuffer to GIntBuffer
template <>
inline GIntBuffer::GBuffer(
   const GFloatBuffer& copy
  ) : pData_(NULL), width_(copy.Width()), height_(copy.Height()),
      tagX_(copy.TagX()), tagY_(copy.TagY()), sleeping_(copy.Asleep())
{
  UpdateMemory(false);
  const GFloatBuffer::data_type* pData = copy.Data();
  if (pData_ && pData)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = static_cast<GIntBuffer::data_type>(
        0.5 + pData[index]
        );
    }
  }
}
//-------------------------------------------------------------------------

// copy constructor from GDoubleBuffer to GByteBuffer
template <>
inline GByteBuffer::GBuffer(
   const GDoubleBuffer& copy
  ) : pData_(NULL), width_(copy.Width()), height_(copy.Height()),
      tagX_(copy.TagX()), tagY_(copy.TagY()), sleeping_(copy.Asleep())
{
  UpdateMemory(false);
  const GDoubleBuffer::data_type* pData = copy.Data();
  if (pData_ && pData)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = static_cast<GByteBuffer::data_type>(
        type::round2byte(pData[index])
        );
     }
  }
}
//-------------------------------------------------------------------------

// copy constructor from GDoubleBuffer to GIntBuffer
template <>
inline GIntBuffer::GBuffer(
   const GDoubleBuffer& copy
  ) : pData_(NULL), width_(copy.Width()), height_(copy.Height()),
      tagX_(copy.TagX()), tagY_(copy.TagY()), sleeping_(copy.Asleep())
{
  UpdateMemory(false);
  const GDoubleBuffer::data_type* pData = copy.Data();
  if (pData_ && pData)
  {
    size_type const size = Size();
    for (size_type index = 0; index < size; ++index)
    {
      pData_[index] = static_cast<GIntBuffer::data_type>(
        0.5 + pData[index]
        );
    }
  }
}
//-------------------------------------------------------------------------

#endif // !defined(_MSC_VER)

// if Visual C++, use these utlity functions instead

//////////////////////////////////////////////////////
// type-conversion utility functions
//////////////////////////////////////////////////////
//
GFloatBuffer byte2float(const GByteBuffer& BufferIn);
GByteBuffer float2byte(const GFloatBuffer& BufferIn);
GFloatBuffer int2float(const GIntBuffer& BufferIn);
GIntBuffer float2int(const GFloatBuffer& BufferIn);
GIntBuffer byte2int(const GByteBuffer& BufferIn);
GByteBuffer int2byte(const GIntBuffer& BufferIn);
//
//////////////////////////////////////////////////////

} // namespace buf

#if defined(__BORLANDC__)
  #pragma warn .8027
#endif

//=========================================================================
#endif // gbufferH
//=========================================================================

