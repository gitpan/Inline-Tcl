#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "tcl.h"

int   _tcl_argc;
char *_tcl_argv[] = {
  "tclsh",
};

Tcl_Interp *interp = NULL;

#define DECREF(x) { Tcl_DecrRefCount(x); }

#include "mydebug.h"

#ifndef SvPV_nolen
static STRLEN n_a;
#define SvPV_nolen(x) SvPV(x,n_a)
#endif

/****************************
 * SV* Tcl2Pl(Tcl_Obj *obj) 
 * 
 * Converts Tcl Objects to Perl data structures
 * 
 ****************************/
SV* Tcl2Pl (char *result, char *perl_class) {
   /* Here is how it does it:
    * o If obj is a String, Integer, or Float, we convert it to an SV;
    * o If obj is a List or Tuple, we convert it to an AV;
    * o If obj is a Dictionary, we convert it to an HV.
    */
    SV *s2;
    char *string;
    PDEBUGG("Tcl2Pl: %s:%s\n", perl_class, result)
    string = result;
    s2 = newSVpv(string,0);
    return s2;
}

/****************************
 * Tcl_Obj* Pl2Py(SV *obj)
 * 
 * Converts a Perl data structures to a Tcl Object
 ****************************/
char *Pl2Tcl (SV *obj) {
   Tcl_Obj *o;
   char *str;
   str = (char *)SvPV(obj, PL_na);
   PDEBUGG("Pl2Tcl: %s\n", str);
   return str;	
}

MODULE = Inline::Tcl   PACKAGE = Inline::Tcl

BOOT:
interp = Tcl_CreateInterp();
Tcl_Init(interp);

PROTOTYPES: DISABLE

void 
_Inline_parse_tcl_namespace()
 PREINIT:
    Tcl_Obj *listPtr, *elemObjPtr;
    Tcl_Obj **objvPtr;
    char *result;
    int objc,i;
    int status;
    AV* functions = newAV();
 PPCODE:
    /*
     * Get the pattern and find the "effective namespace" in which to
     * list commands.
     */

    if (TCL_ERROR == Tcl_Eval(interp, "info commands") ) {
	PERROR("Namespace: Eval Error\n");
    }

    listPtr = Tcl_GetObjResult(interp);
    /* error check ? */

    if (TCL_ERROR == Tcl_ListObjGetElements(interp, listPtr, &objc, &objvPtr)){
	PERROR("Namespace: List error\n");
    }

    if (TCL_ERROR == Tcl_ListObjLength(interp, listPtr, &objc) ) {
	PERROR("Namespace: List Length error\n");
    }

    PDEBUGG("OBJ %d\n", objc);

    for (i=0;i<objc;i++) {
	if (TCL_ERROR == Tcl_ListObjIndex(interp, listPtr, i, &elemObjPtr)){
	    PERROR("Namespace: List Length error\n");
        }
	result = Tcl_GetString(elemObjPtr); /* error check ? */
	PDEBUGG("RESULT = %s\n", result);
        av_push(functions, newSVpv(result,0));
    }

    PUSHs(newSVpv("functions",0));
    PUSHs(newRV_noinc((SV*)functions));

int 
_eval_tcl(x)
	char *x; 
    PREINIT:
	int result;
    CODE:
	PDEBUGG("EVAL: %s\n",x);
	result = Tcl_Eval(interp,x);
	RETVAL = (result == TCL_OK);
    OUTPUT:
	RETVAL

void
_eval_tcl_function(PKG, FNAME...)
     char*    PKG;
     char*    FNAME;
  PREINIT:
  int i;
  char *result;
  SV* ret = NULL;
  Tcl_Obj **objv;
  char *command;
  int cmdlen;
  int len;
  PPCODE:

  PDEBUGG("function: %s:%s\n", PKG, FNAME);

  cmdlen = 0;

  for (i=1; i<items; i++) {
    result = Pl2Tcl(ST(i));
    if (result) {
      len = strlen(result);
      cmdlen += len;
    }
  }

  command = (char *)malloc( sizeof(char) * (cmdlen+2) );
  command[0] = 0x0;
  if (command == NULL ) {	
	PERROR("Out of memory\n");
	XSRETURN_EMPTY;
  }
  for (i=1; i<items; i++) {
      PDEBUGG("ARG %d: %s\n", i, Pl2Tcl(ST(i)));//Tcl_GetString(objv[i-1]));
      strcat(command, Pl2Tcl(ST(i)));//Tcl_GetString(objv[i-1]));
      strcat(command, " ");
  }

  Tcl_Eval(interp, command);
  result = Tcl_GetStringResult(interp);
  PDEBUGG("RESULT: %s\n", result);
  PDEBUGG("FUNC: return from %s\n", FNAME);
  ret = Tcl2Pl(result, PKG);

  free(command);

  if (SvROK(ret) && (SvTYPE(SvRV(ret)) == SVt_PVAV)) {
    AV* av = (AV*)SvRV(ret);
    int len = av_len(av) + 1;
    int i;
    for (i=0; i<len; i++) {
      XPUSHs(sv_2mortal(av_shift(av)));
    }
  } else {
    XPUSHs(ret);
  }
