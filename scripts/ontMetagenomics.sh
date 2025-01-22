#!/bin/bash

#$ -S /bin/bash
#$ -N ontMetagenomics
#$ -q edlb.q
#$ -pe smp 2-16
#$ -cwd -V

set -e
set -u
set -x

dir=$1
db=$2

which kraken2 serotypefinder virulencefinder.py

fastqFile=$(\ls $dir/*.fastq.gz)
KRAKENDB=$db/kraken2
SEROTYPEFINDERDB=$db/serotypefinder_db
VIRULENCEFINDERDB=$db/virulencefinder_db
# Number of threads is 1 unless already set by SGE as a scheduled job
NSLOTS=${NSLOTS:=1}

# Classify the reads with Kraken2
mkdir $dir/kraken2
kraken2 --db $KRAKENDB --threads $NSLOTS --output $dir/kraken2/kraken2.out --report $dir/kraken2/kraken2.report $fastqFile \
  > $dir/kraken2/stdout \
  2> $dir/kraken2/stderr

# Serotypefinder
mkdir -pv $dir/serotypefinder
serotypefinder     --infile $fastqFile --outputPath $dir/serotypefinder  --methodPath kma --databasePath $SEROTYPEFINDERDB  --extented_output \
  > $dir/serotypefinder/stdout \
  2> $dir/serotypefinder/stderr

# Virulencefinder
mkdir -pv $dir/virulencefinder
virulencefinder.py --infile $fastqFile --outputPath $dir/virulencefinder --methodPath kma --databasePath $VIRULENCEFINDERDB --extented_output \
  > $dir/virulencefinder/stdout \
  2> $dir/virulencefinder/stderr

date > $dir/.done
