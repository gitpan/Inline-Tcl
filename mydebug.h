#ifndef MYDEBUG_H
#define MYDEBUG_H

#include <stdio.h>

#ifndef PDEBUG
#  define PDEBUG(fmt, args...); fprintf(stderr,"MSG $%s$ Line %d: ",__FILE__,__LINE__); fprintf(stderr,fmt, ## args ); fflush(NULL);
#endif

#ifndef PERROR
#define PERROR(fmt, args...); fprintf(stderr,"ERROR $%s$ Line %d: ",__FILE__,__LINE__); fprintf(stderr,fmt, ## args ); fflush(NULL);
#endif

#ifndef PFATAL
#define PFATAL(fmt, args...); fprintf(stderr,"FATAL $%s$ Line %d: ",__FILE__,__LINE__); fprintf(stderr,fmt, ## args ); fflush(NULL); exit(0);
#endif


#ifndef PDEBUGG
#  define PDEBUGG(fmt, args...); 
#endif

#endif


