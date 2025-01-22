#!/bin/bash

# This script monitors the inbox and if it finds reads,
# it will start the analysis pipeline

set -e
set -u

# Usage if there are no arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 workdirectory"
    echo "  workdirectory/inbox is where reads are monitored. Do not mv into here; only cp. These reads in inbox might get deleted."
    exit 0
fi

# Set up the directory structure
workdirectory=$1
INBOX=$workdirectory/inbox         # where fastq files land. NOTE: cp into here. Do not mv.
OUTBOX=$workdirectory/outbox       # where fastq files are moved and analyzed
COMPILED=$workdirectory/compiled   # where compiled results are stored
LOG=$workdirectory/log             # qsub logs
mkdir -pv $INBOX $OUTBOX $COMPILED $LOG

# Note where this script is located
thisDir=$(dirname $0)
        
function logmsg {
    echo "$(date) $1" >&2
}

logmsg "Monitoring $INBOX for ONT fastq.gz files"

reads_done="";
while [ 1 ]; do
    reads=$(\ls $INBOX/*.fastq.gz 2>/dev/null | head -n 1)
    if [ "$reads" ]; then
        # Start the analysis pipeline
        logmsg "Starting analysis pipeline with $reads ..."
        
        # Move the reads to the outbox
        sourceDir=$OUTBOX/$(basename $reads .fastq.gz)
        mkdir -pv $sourceDir
        mv -v $INBOX/*.fastq.gz $sourceDir/ >&2
        # Do all the analysis in the same directory as the reads
        qsub -pe smp 1-16 -o $LOG -j y -N ontMetagenomics $thisDir/ontMetagenomics.sh $sourceDir $(realpath ./db) >&2
    else 
        logmsg "No reads found in $INBOX. Sleeping."
    fi

    # Make a running list of all the directories that have been analyzed
    reads_done_now=$(ls -d $OUTBOX/*/.done 2>/dev/null || true)

    if [ "$reads_done_now" != "$reads_done" ]; then
        compile
        reads_done=$reads_done_now
        
        # Compile results with another script and another qsub invocation
        # Krona plots from Kraken2:
        #  Find all available and finished reports and combine them with kraken tools
        #  Use kraken tools to import results into krona
        # Assemble MAGs
        #  Use all available reads with .done files to assemble MAGs
        # cgMLST
    fi

    # Sleep for a minute
    for i in $(seq 1 10); do
        echo -ne . >&2
        sleep 1
    done
    echo >&2
done
