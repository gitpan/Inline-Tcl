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
  );

#============================================================================
# TCL include files to look for
#============================================================================
my @py_incs = 
  (
   '/usr/local/include/',
   '/usr/include/',
  );
  
my @py_dists = 
  (
   '$ENV{HOME}/tcl8.3.2',
   '$ENV{HOME}/tcl8.3.1',
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
# Search for distribution directories
#============================================================================
my @py_dists_found;
for my $loc (@py_dists) {
    push(@py_dists_found, $loc) if -d $loc;
}
@possible = glob("$ENV{HOME}/tcl*");
for my $loc (@possible) {
    push(@py_dists_found, $loc) if -d $loc;
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

#============================================================================
# Prompt for distribution directory to use
#============================================================================
$num = 1;
my $dist = prompt(join("\n",("Found the following TCL distributions: ",
			    map {$num++ . ". $_"} @py_dists_found))."\nUse? (or enter alternative)",
		 "1") if @py_dists_found;
$dist = prompt ("Please enter the TCL distribution directory.", "")
  unless @py_dists_found;

$dist = $py_dists_found[$dist-1] if $dist =~ /^\d+$/;



#============================================================================
# Does  have Tkinter installed?
#============================================================================
#my $tkinter = prompt("Does this Python have Tkinter installed? Hint: run \"python -c 'import Tkinter'\" and watch for error messages.", "no") eq "yes";

#============================================================================
# Linker hints
#============================================================================
my %hints =
  (
   'python2.0' => ['-lpython2.0',
		   '-ldb -lutil', # seems to always be required for 2.0
		   $version < 5.6 ? "-lpthread":"",
		   $tkinter ? "-ltcl -ltk -ltix":"",
		  ],
   'python1.6' => ['-lpython1.6',
		   $tkinter ? "-ltcl -ltk -ltix":"",
		  ],
   'python1.5' => ['-lpython1.5',
		   $tkinter ? "-ltcl -ltk -ltix":"",
		  ],
  );

my $pyver;
for my $py (keys %hints) {
    $pyver ||= (($lib =~ m|$py|i) ? $py : 0);
}

#my $libs = join " ", @{$hints{$pyver}};
my $libs = join " ", "-ltcl8.4";

#============================================================================
# Write the makefile
#============================================================================
my $lib_path = substr($lib,0,rindex($lib,'/'));
my $lib = substr($lib,rindex($lib,'/lib')+4);
$lib = substr($lib,0,rindex($lib,'.'));

WriteMakefile(
	      INC => "-I$inc -I$dist/generic",
	      LIBS => "-L$lib_path $libs",
	      NAME => 'Inline::Tcl',
	      VERSION_FROM => 'Tcl.pm',
	      PREREQ_PM => {
			    Inline => 0.31,
			   },
	      clean => {FILES => 'blib_test/'},
	     );
