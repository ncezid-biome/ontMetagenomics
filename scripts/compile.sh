#!/bin/bash

#$ -S /bin/bash
#$ -N ontMetagenomics
#$ -q edlb.q
#$ -pe smp 2-16
#$ -V -cwd

set -e
set -u

dir=$1 # This is the workding directory with inbox, outbox, etc
db=$2

# Find all directories with .done files and save those directories to a bash array or string
# Look at the latest compiled subdirectory date: is it the exact same directories? If so, skip.

# Create a subdirectory $dir/compiled/date (YYYY-MM-DD-HH-MM-SS)
subdir=$dir/compiled/$(date +%F-%H-%M-%S)
mkdir -pv $subdir
# Create a file with all the directories that were compiled to make these results
ls -d $dir/outbox/* > $subdir/compiled_directories.txt

# Create a subdirectory $dir/compiled/ordinal/kraken2
# run combine_kreports.py to combine all existing kraken reports.

# kreport2krona.py to generate Krona plots


# optional steps, if you get this far, on existing set of reads
# MAGs
# serotypefinder on complete set of reads
# virulencefinder on complete set of reads
# cgMLST

# NOT optional steps
# Make a file .done in this folder to mark completion
