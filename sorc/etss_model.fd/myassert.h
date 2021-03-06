/*****************************************************************************
 * myassert.h
 *
 * DESCRIPTION
 *    This file contains the code to handle assert statements.  There is no
 * actual code unless DEBUG is defined.
 *
 * HISTORY
 *   12/2003 Arthur Taylor (MDL / RSIS): Created.
 *
 * NOTES
 *****************************************************************************
 */
#ifndef MYASSERT_H
#define MYASSERT_H

/*
#ifdef MEMWATCH
  #include "memwatch.h"
#endif
*/

#ifdef DEBUG
   void _myAssert (const char *file, int lineNum);
   #define myAssert(f) \
      if (f)          \
         {}           \
      else            \
         _myAssert (__FILE__, __LINE__)
#else
   #define myAssert(f)
#endif

#endif
