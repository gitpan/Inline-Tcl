rm -rf blib_test/lib/auto/main_Tcl_bbb_t_*
make
perl -Mblib t/bbb.t
perl -Mblib t/a1.pl
