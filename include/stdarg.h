/*
 *Copyright 2013-2014 by 2013-2014 by Explorer OS Developer. All rights reserved.
 *made by 迷彩红星<1@GhostBirdOS.org>
 *stdarg.h
 *Explorer/Kernel/include/stdarg.h
 *8/15/2014 12:15 AM
 */

#ifndef _STDARG_H_
#define _STDARG_H_

#ifndef    _VA_LIST
#define _VA_LIST
typedef char* va_list;
#endif

/*t类型参数在参数列表(堆栈中)所需空间的大小*/

#define __va_argsiz(t)    \
    (((sizeof(t) + sizeof(int) - 1) / sizeof(int)) * sizeof(int))


/*
 * Start variable argument list processing by setting AP to point to the
 * argument after pN.
 */
#ifdef    __GNUC__
/*
 * In GNU the stack is not necessarily arranged very neatly in order to
 * pack shorts and such into a smaller argument list. Fortunately a
 * neatly arranged version is available through the use of __builtin_next_arg.
 */
#define va_start(ap, pN)    \
    ((ap) = ((va_list) __builtin_next_arg(pN)))
#else
/*
 * For a simple minded compiler this should work (it works in GNU too for
 * vararg lists that don't follow shorts and such).
 */
#define va_start(ap, pN)    \
    ((ap) = ((va_list) (&pN) + __va_argsiz(pN)))
#endif


/*
 * End processing of variable argument list. In this case we do nothing.
 */
#define va_end(ap)    ((void)0)


/*
 * Increment ap to the next argument in the list while returing a
 * pointer to what ap pointed to first, which is of type t.
 *
 * We cast to void* and then to t* because this avoids a warning about
 * increasing the alignment requirement.
 */

#define va_arg(ap, t)                    \
     (((ap) = (ap) + __va_argsiz(t)),        \
      *((t*) (void*) ((ap) - __va_argsiz(t))))

#endif /* Not RC_INVOKED */
