use ExtUtils::MakeMaker;

#============================================================================
# What perl are we running?
#============================================================================
use Config;
$version = $Config{version};
#my $version = $];
#print $version,"\n";

#============================================================================
# TCL libraries to look for
#============================================================================
my @py_libs = 
  (
   '/usr/local/lib/libtcl8.4.so',
   '/usr/local/lib/libtcl8.4.a',
   '/usr/lib/libtcl8.3.a',
   '/usr/lib/libtcl8.3.so',
   '/usr/local/lib/libtcl8.3.a',
   '/usr/local/lib/libtcl8.3.so',
   '/usr/tcl84/lib/libtcl8.4.so',
  );

#============================================================================
# TCL include files to look for
#============================================================================
my @py_incs = 
  (
   '/usr/local/include/',
   '/usr/include/',
   '/usr/tcl84/include',
  );
  
#============================================================================
# Search for libraries
#============================================================================
my @py_libs_found;
for my $loc (@py_libs) {
    push(@py_libs_found, $loc) if -f $loc;
}

#============================================================================
# Search for include directories
#============================================================================
my @py_incs_found;
for my $loc (@py_incs) {
    push(@py_incs_found, $loc) if -d $loc;
}

#============================================================================
# Prompt for library to use
#============================================================================
my $num = 1;
my $lib = prompt(join("\n",("Found these TCL libraries: ",
			    map {$num++ . ". $_"} @py_libs_found))."\nUse? (or enter alternative)",
		 "1") if @py_libs_found;
$lib = prompt ("Please enter the TCL library.", "")
  unless @py_libs_found;

$lib = $py_libs_found[$lib-1] if $lib =~ /^\d+$/;

#============================================================================
# Prompt for include directory to use
#============================================================================
$num = 1;
my $inc = prompt(join("\n",("Found these TCL include dirs: ",
			    map {$num++ . ". $_"} @py_incs_found))."\nUse? (or enter alternative)",
		 "1") if @py_incs_found;
$inc = prompt ("Please enter the TCL include directory.", "")
  unless @py_incs_found;

$inc = $py_incs_found[$inc-1] if $inc =~ /^\d+$/;


my $lib_path = substr($lib,0,rindex($lib,'/'));
my $lib = substr($lib,rindex($lib,'/lib')+4);
$lib = substr($lib,0,rindex($lib,'.'));


#============================================================================
# Linker hints
#============================================================================

print "Tcl include path =  $inc\n";
print "Tcl library path =  $lib_path\n";
print "Tcl link options =  -l$lib\n";

my $libs = join " ", "-l$lib";

#============================================================================
# Write the makefile
#============================================================================

WriteMakefile(
	      INC => "-I$inc",
	      LIBS => "-L$lib_path $libs",
	      NAME => 'Inline::Tcl',
	      VERSION_FROM => 'Tcl.pm',
	      PREREQ_PM => {
			    Inline => 0.31,
			   },
	      clean => {FILES => 'blib_test/'},
	     );
