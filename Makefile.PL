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
   '/usr/lib/libtcl8.3.so',
   '/usr/local/lib/libtcl8.3.so',
   '/usr/tcl84/lib/libtcl8.4.so',
   '/usr/tcl83/lib/libtcl8.3.so',
   '/usr/local/lib/libtcl83.so',
   '/usr/local/lib/libtcl84.so',
  );

#============================================================================
# TCL include files to look for
#============================================================================
my @py_incs = 
  (
   '/usr/tcl84/include/',
   '/usr/tcl83/include/',
   '/usr/local/include/tcl8.3/',
   '/usr/local/include/tcl8.4/',
   '/usr/local/include/',
   '/usr/include/',
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
#    push(@py_incs_found, $loc) if -d $loc;
    push(@py_incs_found, $loc) if -f $loc."tcl.h";
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

my $libs = join " ", "-l$lib";
my $path_str = "-L$lib_path";
$path_str = ($path_str . "-R$lib_path") if $^O != "linux";

print "Platform = $^O\n";
print "Tcl include path = $inc\n";
print "Tcl library path = $lib_path\n";
print "Tcl include options = -Wall -l$lib\n";
print "Tcl link options = $path_str -l$lib\n";


#============================================================================
# Write the makefile
#============================================================================

WriteMakefile(
	      INC => "-Wall \$(DEBUG) -I$inc",
	      LIBS => "-L$lib_path -R$lib_path $libs",
	      NAME => 'Inline::Tcl',
	      VERSION_FROM => 'Tcl.pm',
	      PREREQ_PM => {
			    Inline => 0.31,
			   },
	      clean => {FILES => 'blib_test/'},
	     );
