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

#include "tclInt.h"
#include "tclPort.h"
#include "tclCompile.h"
#include "tclRegexp.h"

/****************************
 * SV* Tcl2Pl(Tcl_Obj *obj) 
 * 
 * Converts arbitrary Python data structures to Perl data structures
 * Note on references: does not Py_DECREF(obj).
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
 * Converts arbitrary Perl data structures to Python data structures
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
    char *cmdName, *pattern, *simplePattern;
    register Tcl_HashEntry *entryPtr;
    Tcl_HashSearch search;
    Tcl_Obj *listPtr, *elemObjPtr;
    Namespace *nsPtr;
    Namespace *globalNsPtr = (Namespace *) Tcl_GetGlobalNamespace(interp);
    Namespace *currNsPtr   = (Namespace *) Tcl_GetCurrentNamespace(interp);
    int specificNsInPattern = 0;  /* Init. to avoid compiler warning. */
    Tcl_Command cmd;
    AV* functions = newAV();
 PPCODE:
    /*
     * Get the pattern and find the "effective namespace" in which to
     * list commands.
     */
    simplePattern = NULL;
    nsPtr = currNsPtr;
    specificNsInPattern = 0;

    /*
     * Scan through the effective namespace's command table and create a
     * list with all commands that match the pattern. If a specific
     * namespace was requested in the pattern, qualify the command names
     * with the namespace name.
     */

    listPtr = Tcl_NewListObj(0, (Tcl_Obj **) NULL);
    if (nsPtr != NULL) {
        entryPtr = Tcl_FirstHashEntry(&nsPtr->cmdTable, &search);
        while (entryPtr != NULL) {
            cmdName = Tcl_GetHashKey(&nsPtr->cmdTable, entryPtr);
            if ((simplePattern == NULL)
                    || Tcl_StringMatch(cmdName, simplePattern)) {
                if (specificNsInPattern) {
                    cmd = (Tcl_Command) Tcl_GetHashValue(entryPtr);
                    elemObjPtr = Tcl_NewObj();
                    Tcl_GetCommandFullName(interp, cmd, elemObjPtr);
                } else {
                    elemObjPtr = Tcl_NewStringObj(cmdName, -1);
		    PDEBUGG("CMD: %s\n", cmdName);
		    av_push(functions, newSVpv(cmdName,0));
                }
                Tcl_ListObjAppendElement(interp, listPtr, elemObjPtr);
            }
            entryPtr = Tcl_NextHashEntry(&search);
        }
        
	/*
         * If the effective namespace isn't the global :: namespace, and a
         * specific namespace wasn't requested in the pattern, then add in
         * all global :: commands that match the simple pattern. Of course,
         * we add in only those commands that aren't hidden by a command in
         * the effective namespace.
         */

        /* if ((nsPtr != globalNsPtr) && !specificNsInPattern) {
            entryPtr = Tcl_FirstHashEntry(&globalNsPtr->cmdTable, &search);
            while (entryPtr != NULL) {
                cmdName = Tcl_GetHashKey(&globalNsPtr->cmdTable, entryPtr);
                if ((simplePattern == NULL)
                        || Tcl_StringMatch(cmdName, simplePattern)) {
                    if (Tcl_FindHashEntry(&nsPtr->cmdTable, cmdName) == NULL) {
                        Tcl_ListObjAppendElement(interp, listPtr,
                                Tcl_NewStringObj(cmdName, -1));
                    }
                }
                entryPtr = Tcl_NextHashEntry(&search);
            }
        }*/
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
