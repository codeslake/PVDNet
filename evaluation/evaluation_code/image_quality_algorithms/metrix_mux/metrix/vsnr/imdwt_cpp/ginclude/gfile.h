
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
#ifndef gfileH
#define gfileH
//=========================================================================

#include "gtypes.h"
#include <vector>

#if defined(_MSC_VER)
  namespace std {
    using ::FILE;
    using ::fread;
    using ::fwrite;
    using ::fopen;
    using ::fclose;
    using ::fseek;
    using ::ftell;
    }
#endif
//=========================================================================

namespace file {

template <typename Type>
inline Type swap_end16(Type val)
{
  type::GByte* const cptr = reinterpret_cast<type::GByte*>(&val);
  type::GByte const tmp = cptr[0];
  cptr[0] = cptr[1];
  cptr[1] = tmp;
  return val;
}
//---------------------------------------------------------------------

template <typename Type>
inline Type swap_end32(Type val)
{
  type::GByte* const cptr = reinterpret_cast<type::GByte*>(&val);
  type::GByte tmp = cptr[0];
  cptr[0] = cptr[3];
  cptr[3] = tmp;
  tmp = cptr[1];
  cptr[1] = cptr[2];
  cptr[2] = tmp;
  return val;
}
//---------------------------------------------------------------------

template <typename Type>
inline Type swap_end(Type val)
{
  if (sizeof(Type) == 2)
  {
    return swap_end16(val);
  }
  else if (sizeof(Type) == 4)
  {
    return swap_end32(val);
  }
  return val;
}
//---------------------------------------------------------------------


class GFile
{
public:
  typedef type::GSize size_type;
  typedef type::GString str_type;
  typedef std::runtime_error except_type;

public:
  GFile(str_type const& fname, str_type const& mode) : p_file_(NULL)
    {
      p_file_ = std::fopen(fname.c_str(), mode.c_str());
      if (p_file_ == NULL)
      {
        throw except_type("Error opening file: " + fname);
      }
    }
  ~GFile()
    {
      if (p_file_ != NULL)
      {
        std::fclose(p_file_);
      }
    }
    
public:
  std::FILE* Handle() const { return p_file_; }
    
public:
  template <typename Type>
  Type Read(bool swap = false) const
    {
      Type val;
      if (std::fread(&val, sizeof(Type), 1, p_file_) != 1)
      {
        throw except_type("Error reading data: " + type::type2str(val));
      }
      return (swap) ? swap_end(val) : val;
    }    
  template <typename Type>
  void Read(Type* p_val, size_type num_items, bool swap = false)
    const
    {
      if (std::fread(p_val, sizeof(Type), num_items, p_file_) 
          != num_items)
      {
        throw except_type("Error reading data");
      }
      if (swap)
      {
        for (size_type index = 0; index < num_items; ++index)
        {
          p_val[index] = swap_end(p_val[index]);
        }
      }
    }
  template <typename Type>
  void Write(Type val, bool swap = false) const
    {
      if (swap)
      {
        val = swap_end(val);
      }      
      if (std::fwrite(&val, sizeof(Type), 1, p_file_) != 1)
      {
        throw except_type("Error writing data: " + type::type2str(val));      
      }
    }    
  template <typename Type>
  void Write(Type const* p_val, size_type num_items, bool swap = false)
    const
    {
      if (swap)
      {
        for (size_type index = 0; index < num_items; ++index)
        {
          Type const val = swap_end(p_val[index]);
          if (std::fwrite(&val, sizeof(Type), 1, p_file_) != 1)
          {
            throw except_type("Error writing data");
          }          
        }      
      }
      else
      {
        if (std::fwrite(p_val, sizeof(Type), num_items, p_file_) 
            != num_items)
        {
          throw except_type("Error writing data");
        }
      }
    }

private:
  std::FILE* p_file_;
};
//---------------------------------------------------------------------

} // namspace file

//=========================================================================
#endif
//=========================================================================
