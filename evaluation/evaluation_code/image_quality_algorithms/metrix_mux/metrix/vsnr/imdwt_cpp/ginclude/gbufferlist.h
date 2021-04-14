
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
#ifndef gbufferlistH
#define gbufferlistH
//=========================================================================

#include <vector>
#include <memory>
#include <stdexcept>
#include "gbuffer.h"

#if defined(__BORLANDC__)
  #pragma warn -8027
#endif
//=========================================================================

namespace buf {

template <class BufferType>
class GBufferList
{
typedef std::out_of_range GInvalidIndex;
typedef std::vector<BufferType*> Container;
typedef typename Container::iterator Iterator;

public:
  typedef BufferType buf_type;
  typedef typename Container::size_type size_type;
  typedef typename buf_type::size_type buf_size_type;

  // default constructor
  GBufferList() {}
  // constructor that creates 'count' empty elements
  GBufferList(size_type count);
  // copy constructor
  GBufferList(const GBufferList<BufferType>& copy);
   
  // destructor
  virtual ~GBufferList();
   
  // assignment operator
  GBufferList<BufferType>& operator =(
    const GBufferList<BufferType>& rhs);

  // list-related member functions
  Container& Items()
    {
      return items_;
    }
  Container const& Items() const
    {
      return items_;
    }
  virtual const BufferType& Items(size_type index) const
    {
    #ifndef GBUFFERLIST_NO_RANGE_CHECK
      if (index >= Count())
      {
        throw GInvalidIndex("Items(index)");
      }
    #endif
      return **(items_.begin() + index);
    }

  virtual BufferType& Items(size_type index)
    {
    #ifndef GBUFFERLIST_NO_RANGE_CHECK
      if (index >= Count())
      {
        throw GInvalidIndex("Items(index)");
      }
    #endif
      return **(items_.begin() + index);
    }

  virtual BufferType& Add(const buf_type& Item);
  virtual BufferType& Add(buf_size_type width = 0,
    buf_size_type height = 0);

  virtual BufferType& Insert(size_type index, const buf_type& Item);
  virtual BufferType& Insert(size_type index,
    buf_size_type width = 0, buf_size_type height = 0);

  virtual void Replace(size_type index, const buf_type& Item);
  virtual void Delete(size_type index);
  virtual void Clear();

  void Alloc(size_type count)
    {
      Reserve(count);
      for (size_type index = 0; index < count; index++)
      {
        Add(0, 0);
      }
    }
  size_type Count() const
    {
      return items_.size();
    }
  bool Empty() const
    {
      return items_.empty();
    }
  void Reserve(size_type count)
    {
      items_.reserve(Count() + count);
    }

private:
  Container items_;
};

//=========================================================================



// constructor that creates 'count' empty elements
template <class BufferType>
GBufferList<BufferType>::GBufferList(
    size_type count
   )
{
   Alloc(count);
}
//-------------------------------------------------------------------------

// copy constructor
template <class BufferType>
GBufferList<BufferType>::GBufferList(
    const GBufferList<BufferType>& copy
   )
{
   Clear();
   const size_type count = copy.Count();
   for (size_type index = 0; index < count; index++)
   {
      Add(copy.Items(index));
   }
}
//-------------------------------------------------------------------------

// default destructor
template <class BufferType>
GBufferList<BufferType>::~GBufferList()
{
   const Iterator items_end = items_.end();
   for (Iterator iter = items_.begin(); iter != items_end; ++iter)
   {
      delete *iter;
   }
}
//-------------------------------------------------------------------------

// assignment operator
template <class BufferType>
GBufferList<BufferType>& GBufferList<BufferType>::operator =(
    const GBufferList<BufferType>& rhs
   )
{
   if (&rhs != this)
   {
      Clear();
      const size_type count = rhs.Count();
      for (size_type index = 0; index < count; index++)
      {
         Add(rhs.Items(index));
      }
   }
   return *this;
}
//-------------------------------------------------------------------------

template <class BufferType>
BufferType& GBufferList<BufferType>::Add(
    buf_size_type width,
    buf_size_type height
   )
{
   BufferType* pItem = new BufferType(width, height);
   try
   {
      items_.push_back(pItem);
      return *pItem;
   }
   catch (...)
   {
      delete pItem;
      throw;
   }
}
//-------------------------------------------------------------------------

template <class BufferType>
BufferType& GBufferList<BufferType>::Add(
    const buf_type& Item
   )
{
   BufferType* pItem = new BufferType(Item);
   try
   {
      items_.push_back(pItem);
      return *pItem;
   }
   catch (...)
   {
      delete pItem;
      throw;
   }
}
//-------------------------------------------------------------------------

template <class BufferType>
BufferType& GBufferList<BufferType>::Insert(
    size_type index,
    buf_size_type width,
    buf_size_type height
   )
{
#ifndef GBUFFERLIST_NO_RANGE_CHECK
   if (index >= Count())
   {
      throw GInvalidIndex("Insert(index, width, height)");
   }
#endif

   BufferType* pItem = new BufferType(width, height);
   try
   {
      return **items_.insert(items_.begin() + index + 1, pItem);
   }
   catch (...)
   {
      delete pItem;
      throw;
   }
}
//-------------------------------------------------------------------------

template <class BufferType>
BufferType& GBufferList<BufferType>::Insert(
    size_type index,
    const buf_type& Item
   )
{
#ifndef GBUFFERLIST_NO_RANGE_CHECK
   if (index >= Count())
   {
      throw GInvalidIndex("Insert(index, Item)");
   }
#endif   

   BufferType* pItem = new BufferType(Item);
   try
   {
      return **items_.insert(items_.begin() + index + 1, pItem);
   }
   catch (...)
   {
      delete pItem;
      throw;
   }
}
//-------------------------------------------------------------------------

template <class BufferType>
void GBufferList<BufferType>::Replace(
    size_type index,
    const buf_type& Item
   )
{
#ifndef GBUFFERLIST_NO_RANGE_CHECK
   if (index >= Count())
   {
      throw GInvalidIndex("Replace()");
   }
#endif
   Items(index) = Item;
}
//-------------------------------------------------------------------------

template <class BufferType>
void GBufferList<BufferType>::Delete(
    size_type index
   )
{
#ifndef GBUFFERLIST_NO_RANGE_CHECK
   if (index >= Count())
   {
      throw GInvalidIndex("Delete()");
   }
#endif     
   delete *(items_.begin() + index);
   items_.erase(items_.begin() + index);
}
//-------------------------------------------------------------------------

template <class BufferType>
void GBufferList<BufferType>::Clear()
{
   const Iterator items_end = items_.end();
   for (Iterator iter = items_.begin(); iter != items_end; ++iter)
   {
      delete *iter;
   }
   items_.clear();
}
//-------------------------------------------------------------------------

//////////////////////////////////////////////////////////////
// commonly-used aliases
//////////////////////////////////////////////////////////////
   typedef GBufferList<buf::GFloatBuffer> GFloatBufferList;
   typedef GBufferList<buf::GDoubleBuffer> GDoubleBufferList;
   typedef GBufferList<buf::GByteBuffer> GByteBufferList;
   typedef GBufferList<buf::GIntBuffer> GIntBufferList;
   typedef GBufferList<buf::GDWordBuffer> GDWordBufferList;
   typedef GBufferList<buf::GShortBuffer> GShortBufferList;
   typedef GBufferList<buf::GWordBuffer> GWordBufferList;
   typedef GBufferList<buf::GBoolBuffer> GBoolBufferList;
//////////////////////////////////////////////////////////////

} // namespace buf

#if defined(__BORLANDC__)
  #pragma warn .8027
#endif

//=========================================================================
#endif // gbufferlistH
//=========================================================================

