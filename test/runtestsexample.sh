#!/bin/sh
#
# Intended to be run only on local machine.
# Run only after config.h created in a configure
# in the source directory
# Assumes env vars DWTOPSRCDIR set to the path to source.
# Assumes CFLAGS warning stuff set in env var DWCOMPILERFLAGS
# Assumes we run the script in the test directory.
# srcdir is from the environment and is, here, the 
# place of the top director itself (may be a relative
# path).

blddir=`pwd`
top_blddir=`dirname $blddir`
if [ x$DWTOPSRCDIR = "x" ]
then
  top_srcdir=$top_blddir
else
  top_srcdir=$DWTOPSRCDIR
fi
if [ $top_srcdir = ".." ]
then
  # This case hopefully eliminates relative path to test dir. 
  top_srcdir=$top_blddir
fi
# srcloc and bldloc are the executable directories.
srcloc=$top_srcdir/src/bin/dwarfexample
bldloc=$top_blddir/src/bin/dwarfexample
#localsrc is the build directory of the test
localsrc=$srcdir
if [ $localsrc = "." ]
then
  localsrc=$top_srcdir/test
fi

testbin=$top_blddir/test
testsrc=$top_srcdir/test
# So we know the build. Because of debuglink.
echo "DWARF_BIGENDIAN=$DWARF_BIGENDIAN"

echo "TOP topsrc  : $top_srcdir"
echo "TOP topbld  : $top_blddir"
echo "TOP localsrc: $localsrc"
chkres() {
r=$1
m=$2
if [ $r -ne 0 ]
then
  echo "FAIL $m.  Exit status for the test $r"
  exit 1
fi
}

if [ x"$DWARF_BIGENDIAN" = "xyes" ]
then
  echo "SKIP dwdebuglink test1, cannot work on bigendian build "
else
  echo "dwdebuglink test1"
  o=junk.debuglink1
  p="--add-debuglink-path=/exam/ple"
  p2="--add-debuglink-path=/tmp/phony"
  $bldloc/dwdebuglink $p $p2 $testsrc/dummyexecutable > $testbin/$o
  chkres $? "runtestsexample.sh running dwdebuglink test1"
  # we strip out the actual localsrc and blddir for the obvious
  # reason: We want the baseline data to be meaningful no matter
  # where one's source/build directories are.
  echo $localsrc | sed "s:[.]:\[.\]:g" >$testbin/${o}sed1
  sedv1=`head -n 1 $testbin/${o}sed1`
  sed "s:$sedv1:..src..:" <$testbin/$o  >$testbin/${o}a
  echo $blddir | sed "s:[.]:\[.\]:g" >$testbin/${o}sed2
  sedv2=`head -n 1 $testbin/${o}sed2`
  sed "s:$sedv2:..bld..:" <$testbin/${o}a  >$testbin/${o}b
  diff $testsrc/debuglink.base  $testbin/${o}b
  r=$?
  if [ $r -ne 0 ]
  then
     echo "To update dwdebuglink baseline:"
     echo "mv $testbin/${o}b $testsrc/debuglink.base"
  fi
  chkres $r "running runtestsexample.sh test1 diff against baseline"
fi
exit 0