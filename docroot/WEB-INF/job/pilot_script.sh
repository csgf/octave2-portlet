#!/bin/sh
#
# Octave pilot script
#
# riccardo.bruno@ct.infn.it
#

# SGJP Testing
curl http://jessica.trigrid.it:8660/sgjp 2>/dev/null > sgjp_client.py && python sgjp_client.py 6 "${2}" "${1}" 2>.sgjp.log >.sgjp.log &

# Get the hostname
HOSTNAME=$(hostname -f)
echo "--------------------------------------------------"
echo "Octave job landed on: '"$HOSTNAME"'"
echo "--------------------------------------------------"
echo "Job execution starts on: '"$(date)"'"

echo "---[multi-infrastructure]----------"
#
# Multi-infrastructure job submission needs
# to build some environment variables
#
VO_NAME=$(voms-proxy-info -vo)
VO_VARNAME=$(echo $VO_NAME | sed s/"\."/"_"/g | sed s/"-"/"_"/g | awk '{ print toupper($1) }')
VO_SWPATH_NAME="VO_"$VO_VARNAME"_SW_DIR"
VO_SWPATH_CONTENT=$(echo $VO_SWPATH_NAME | awk '{ cmd=sprintf("echo $%s",$1); system(cmd); }')
SW_NAME=$(/bin/ls $VO_SWPATH_CONTENT | grep -i octave-3.2.4)

echo "Multi infrastructure variables:"
echo "-------------------------------"
echo "SW_NAME          : "$SW_NAME
echo "VO_NAME          : "$VO_NAME
echo "VO_VARNAME       : "$VO_VARNAME
echo "VO_SWPATH_NAME   : "$VO_SWPATH_NAME
echo "VO_SWPATH_CONTENT: "$VO_SWPATH_CONTENT
echo
export PATH=$PATH:$VO_SWPATH_CONTENT/$SW_NAME/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VO_SWPATH_CONTENT/$SW_NAME/lib/octave-3.2.4/
echo "PATH: "$PATH
echo "LD_LIBRARY_PATH: "$LD_LIBRARY_PATH
echo
echo "Software directory : '"$VO_SWPATH_CONTENT/$SW_NAME"'"
echo "------------------"
ls -ld $VO_SWPATH_CONTENT/$SW_NAME

echo "---[gnuplot]-----------------------"
GNUPLOT=$(ls -1t /usr/bin/gnuplot* 2>/dev/null | head -n 1)
if [ "${GNUPLOT}" = "" ]; then
  GNUPLOT=$VO_SWPATH_CONTENT/gnuplot-4.6.0/bin/gnuplot
  echo "WARNING: GNUPLOT not found on /usr/bin/ assuming now GNUPLOT=$GNUPLOT"
fi

GNUPLOTCHECK=$(/bin/ls -1 $GNUPLOT 2>/dev/null)
if [ "${GNUPLOTCHECK}" = "" ]; then
  echo "ERROR: Unable to locate gnuplot" >&2
  echo "Unable to execute Octave due to the missing gnuplot package"
  exit 10
fi
echo "GNUPLOT: "$GNUPLOT

echo "---[env]---------------------------"
env

##
## Octave execution body
##

# In order to avoid concurrent accesses to files, the 
# portlet uses filename prefixes like
# <timestamp>_<username>_filename
# for this reason the file must be located before to use it
INFILE=$(ls -1 | grep input_file.txt)

echo "---[WN HOME directory]----------------------------"
ls -l $HOME

echo "---[Macro file]---------------------------------"
dos2unix $INFILE 2>/dev/null
cat $INFILE
echo

echo "---[.octaverc]-----------------------------------"
cat > .octaverc <<EOF
gnuplot_binary("${GNUPLOT}");
pkg ("load", "auto");
atexit ("__finish__");
EOF
echo ".octaverc is:"
cat .octaverc
echo "---[Octave]--------------------------------------"

#
# Following statement simulates a produced job file
#
OUTFILE=octave_output.txt
echo "--------------------------------------------------"  > $OUTFILE
echo "octave job landed on: '"$HOSTNAME"'"                >> $OUTFILE
echo "infile:  '"$INFILE"'"                               >> $OUTFILE
echo "outfile: '"$OUTFILE"'"                              >> $OUTFILE
echo "--------------------------------------------------" >> $OUTFILE
echo ""                                                   >> $OUTFILE

# Starting Octave
if hash octave ; then
	octave $INFILE >> $OUTFILE
else
	/usr/local/GARUDA/apps/octave-3.2.4/bin/octave $INFILE >> $OUTFILE
fi
##
## Produce a README.txt file explaining the demo
##

# The common header first
cat > README.txt << EOF
#
# README - Octave portlet
#
# riccardo.bruno@ct.infn.it
#

This application allows Science Gateway users to submit
Octave macros into a distributed infrastructure.
Octave is a Matlab clone and many of its statements
are recognized as well; for this reason it is possible
to execute native Matlab code with Octave with minimal
changes.


If you have submitted the DEMO script, it will be
produced a small graph of the bidimentional
function: z=sqrt(x^2+y^2); sin(z)/z
The output of the application consists of:

  1) The file ${OUTFILE} containing the output stream 
     of octave application
  2) In cas of demo the  grapthic file demo_output.eps 
     will contain the produced graph 
EOF

#
# At the end of the script file it's a good practice to 
# collect all generated job files into a single tar.gz file
# the generated archive may include the input files as well
#
tar cvfz octave-Files.tar.gz $INFILE $OUTFILE *.eps README.txt

echo "---[WN Working directory]-------------------------"
ls -l $(pwd)

echo "---[end]------------------------------------------"
date

