rm -rf blib_test/lib/auto/main_Tcl_bbb_t_*
touch Tcl.xs
make DEBUG=-DMYDEBUG
perl -Mblib t/00init.t
perl -Mblib t/02bbb.t
perl -Mblib t/a1.pl
