#ifndef MYDEBUG_H
#define MYDEBUG_H

#include <stdio.h>

#ifdef __GCC__

#ifndef PDEBUG
#  define PDEBUG(fmt, args...); fprintf(stderr,"MSG $%s$ Line %d: ",__FILE__,__LINE__); fprintf(stderr,fmt, ## args ); fflush(NULL);
#endif

#ifndef PERROR
#define PERROR(fmt, args...); fprintf(stderr,"ERROR $%s$ Line %d: ",__FILE__,__LINE__); fprintf(stderr,fmt, ## args ); fflush(NULL);
#endif

#ifndef PDEBUGG
#  define PDEBUGG(fmt, args...); 
#endif

#else

#ifndef PDEBUG
#define PDEBUG printf
#endif

#ifndef PERROR
#define PERROR printf
#endif

#ifndef PDEBUGG
#define PDEBUGG(fmt, args...) { }
#endif

#endif


#endif


