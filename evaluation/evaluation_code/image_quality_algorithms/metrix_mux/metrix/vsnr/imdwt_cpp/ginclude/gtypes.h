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
#ifndef gtypesH
#define gtypesH
//=========================================================================

#include <ctime>
#include <cstddef>
#include <cstring>
#include <sstream>
#include <string>
//=========================================================================

namespace type {

typedef bool GBool;
typedef unsigned char GByte;
typedef int GInt;
typedef unsigned int GUInt;
typedef float GFloat;
typedef double GDouble;
typedef std::size_t GSize;
typedef short GShort;
typedef unsigned short GWord;
typedef unsigned int GDWord;
typedef long int GLong;
typedef std::string GString;
//---------------------------------------------------------------------

struct GRGB {
   GByte r, g, b;
   };
//---------------------------------------------------------------------

struct GRect {
   GSize x, y, w, h;
   };
//---------------------------------------------------------------------

class GPoint
{
public:
   GPoint() {};
   GPoint(int x, int y) : x_(x), y_(y) {};
   bool operator ==(GPoint const& rhs)
      {
         return (x_ == rhs.x() && y_ == rhs.y());
      }
   int x() const { return x_; }
   int y() const { return y_; }
   void x(int x) { x_ = x; }
   void y(int y) { y_ = y; }

private:
   int x_;
   int y_;
};
//---------------------------------------------------------------------

template <typename Type>
class GData3D
{
public:
   typedef Type data_type;

public:
   // constructors
   GData3D() :
      x_(0), y_(0), z_(0) {}
   GData3D(data_type val) :
      x_(val), y_(val), z_(val) {}
   GData3D(data_type x, data_type y, data_type z) :
      x_(x), y_(y), z_(z) {}
   GData3D(const GData3D& copy) :
      x_(copy.x()), y_(copy.y()), z_(copy.z()) {}

   // operators
   GData3D& operator =(const GData3D& rhs)
      {
         if (&rhs != this)
        {
            x_ = rhs.x();
            y_ = rhs.y();
            z_ = rhs.z();
        }
        return *this;
      }
   GData3D& operator +=(const GData3D& rhs)
      {
         if (&rhs != this)
        {
            x_ += rhs.x();
            y_ += rhs.y();
            z_ += rhs.z();
        }
        return *this;
      }
   GData3D& operator *=(const GData3D& rhs)
      {
         if (&rhs != this)
        {
            x_ *= rhs.x();
            y_ *= rhs.y();
            z_ *= rhs.z();
        }
        return *this;
      }
   GData3D operator +(const GData3D& rhs) const
      {
         return GData3D(x_ + rhs.x(), y_ + rhs.y(), z_ + rhs.z());
      }
   GData3D operator -(const GData3D& rhs) const
      {
         return GData3D(x_ - rhs.x(), y_ - rhs.y(), z_ - rhs.z());
      }
   GData3D operator *(const GData3D& rhs) const
      {
         return GData3D(x_ * rhs.x(), y_ * rhs.y(), z_ * rhs.z());
      }
   GData3D operator /(const GData3D& rhs) const
      {
         return GData3D(x_ / rhs.x(), y_ / rhs.y(), z_ / rhs.z());
      }
   bool operator ==(const GData3D& rhs) const
      {
         return (x_ == rhs.x() && y_ == rhs.y() && z_ == rhs.z());
      }
   friend GData3D operator *(const data_type lhs, const GData3D& rhs)
      {
         return GData3D(lhs * rhs.x(), lhs * rhs.y(), lhs * rhs.z());
      }

   // member functions
   data_type x() const { return x_; }
   data_type y() const { return y_; }
   data_type z() const { return z_; }
   void x(data_type x) { x_ = x; }
   void y(data_type y) { y_ = y; }
   void z(data_type z) { z_ = z; }

private:
   data_type x_, y_, z_;
};

///////////////////////////////////////////////////
// commonly-used aliases
///////////////////////////////////////////////////
   typedef GData3D<GInt> GInt3D;
   typedef GData3D<GBool> GBool3D;
   typedef GData3D<GFloat> GFloat3D;
   typedef GData3D<GDouble> GDouble3D;
   typedef GData3D<GByte> GByte3D;
   typedef GData3D<GWord> GWord3D;
   typedef GData3D<GUInt> GDWord3D;
   typedef GData3D<GShort> GShort3D;
   typedef GData3D<GByte> GByte3D;
///////////////////////////////////////////////////
//---------------------------------------------------------------------

inline GInt round2int(float val)
{
  val += 0.5f;
  return static_cast<GInt>(val);
}
//---------------------------------------------------------------------

inline GByte round2byte(float val)
{
#define BYTECLIP(x) (x > 255) ? 255 : (x < 0) ? 0 : x
  val += 0.5f;
  return static_cast<GByte>(BYTECLIP(val));
#undef BYTECLIP
}
//---------------------------------------------------------------------

inline GByte int2byte(int val)
{
#define BYTECLIP(x) (x > 255) ? 255 : (x < 0) ? 0 : x
  return static_cast<GByte>(BYTECLIP(val));
#undef BYTECLIP
}
//---------------------------------------------------------------------

template <typename Type>
inline GString type2str(Type val)
{
  std::ostringstream ss;
  ss << val;
  return ss.str();
}
//---------------------------------------------------------------------

inline std::time_t tic()
{
  return std::time(NULL);  
}
//---------------------------------------------------------------------

inline int toc(std::time_t tic_val)
{
  return std::time(NULL) - tic_val;
}
//---------------------------------------------------------------------

} // namespace type

//=========================================================================
#endif
//=========================================================================
