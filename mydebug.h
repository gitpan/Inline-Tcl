#ifndef MYDEBUG_H
#define MYDEBUG_H

#include <stdio.h>

#ifdef MYDEBUG

#ifndef PDEBUG
#  define PDEBUG printf("MSG $%s$ Line %d: ",__FILE__,__LINE__); fflush(NULL); printf
#endif

#ifndef PERROR
#  define PERROR printf("ERR $%s$ Line %d: ",__FILE__,__LINE__); fflush(NULL); printf
#endif

#ifndef PDEBUGG
#  define PDEBUGG(...); { }
# endif

#else
#include <perl.h>
#  define PDEBUG(...); { }
#  define PERROR(...); { assert(0); }
#  define PDEBUGG(...); { }

#endif

#endif


