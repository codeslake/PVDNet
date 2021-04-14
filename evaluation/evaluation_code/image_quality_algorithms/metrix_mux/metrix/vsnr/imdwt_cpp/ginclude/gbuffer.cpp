
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
#include "gbuffer.h"
// template class
//=========================================================================

//
// Utility functions for use with Visual C++;
// other compilers can use the copy constructors.
//
namespace buf {

GFloatBuffer byte2float(const GByteBuffer& BufferIn)
{
  GByteBuffer::data_type const* pDataIn = BufferIn.Data();
  GByteBuffer::size_type const size = BufferIn.Size();
  GFloatBuffer BufferOut(BufferIn.Width(), BufferIn.Height());
  GFloatBuffer::data_type* pDataOut = BufferOut.Data();

  BufferOut.TagX(BufferIn.TagX());
  BufferOut.TagY(BufferIn.TagY());  
  for (GByteBuffer::size_type index = 0; index < size; ++index)
  {
     pDataOut[index] = static_cast<float>(pDataIn[index]);
  }
  return BufferOut;
}
//-------------------------------------------------------------------------

GByteBuffer float2byte(const GFloatBuffer& BufferIn)
{
  GFloatBuffer::data_type const* pDataIn = BufferIn.Data();
  GFloatBuffer::size_type const size = BufferIn.Size();
  GByteBuffer BufferOut(BufferIn.Width(), BufferIn.Height());
  GByteBuffer::data_type* pDataOut = BufferOut.Data();

  BufferOut.TagX(BufferIn.TagX());
  BufferOut.TagY(BufferIn.TagY());  
  for (GFloatBuffer::size_type index = 0; index < size; ++index)
  {
    pDataOut[index] = static_cast<unsigned char>(
      type::round2byte(pDataIn[index])
      );
  }
  return BufferOut;
}
//-------------------------------------------------------------------------

GFloatBuffer int2float(const GIntBuffer& BufferIn)
{
  GIntBuffer::data_type const* pDataIn = BufferIn.Data();
  GIntBuffer::size_type const size = BufferIn.Size();
  GFloatBuffer BufferOut(BufferIn.Width(), BufferIn.Height());
  GFloatBuffer::data_type* pDataOut = BufferOut.Data();

  BufferOut.TagX(BufferIn.TagX());
  BufferOut.TagY(BufferIn.TagY());  
  for (GIntBuffer::size_type index = 0; index < size; ++index)
  {
    pDataOut[index] = static_cast<float>(pDataIn[index]);
  }
  return BufferOut;
}
//-------------------------------------------------------------------------

GIntBuffer float2int(const GFloatBuffer& BufferIn)
{
  GFloatBuffer::data_type const* pDataIn = BufferIn.Data();
  GFloatBuffer::size_type const size = BufferIn.Size();
  GIntBuffer BufferOut(BufferIn.Width(), BufferIn.Height());
  GIntBuffer::data_type* pDataOut = BufferOut.Data();

  BufferOut.TagX(BufferIn.TagX());
  BufferOut.TagY(BufferIn.TagY());  
  for (GFloatBuffer::size_type index = 0; index < size; ++index)
  {
    pDataOut[index] = static_cast<int>(pDataIn[index]);
  }
  return BufferOut;
}
//-------------------------------------------------------------------------

GIntBuffer byte2int(const GByteBuffer& BufferIn)
{
  GByteBuffer::data_type const* pDataIn = BufferIn.Data();
  GByteBuffer::size_type const size = BufferIn.Size();
  GIntBuffer BufferOut(BufferIn.Width(), BufferIn.Height());
  GIntBuffer::data_type* pDataOut = BufferOut.Data();

  BufferOut.TagX(BufferIn.TagX());
  BufferOut.TagY(BufferIn.TagY());  
  for (GByteBuffer::size_type index = 0; index < size; ++index)
  {
    pDataOut[index] = static_cast<int>(pDataIn[index]);
  }
  return BufferOut;
}
//-------------------------------------------------------------------------

GByteBuffer int2byte(const GIntBuffer& BufferIn)
{
  GIntBuffer::data_type const* pDataIn = BufferIn.Data();
  GIntBuffer::size_type const size = BufferIn.Size();
  GByteBuffer BufferOut(BufferIn.Width(), BufferIn.Height());
  GByteBuffer::data_type* pDataOut = BufferOut.Data();

  BufferOut.TagX(BufferIn.TagX());
  BufferOut.TagY(BufferIn.TagY());  
  for (GIntBuffer::size_type index = 0; index < size; ++index)
  {
    pDataOut[index] = static_cast<unsigned char>(
      type::int2byte(pDataIn[index])
      );
  }
  return BufferOut;
}
//-------------------------------------------------------------------------

} // namespace buf

//=========================================================================
