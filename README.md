# ONT metagenomics

This is an attempt to have a monitor for incoming ONT data.

## Scripts

* `receive.sh` monitors a working directory and performs an analysis whenever data comes in
  * `ontMetagenomics.sh` runs initial metagenomics analysis like Kraken2
  * `compile.sh` compiles initial analyses from `ontMetagenomics.sh`.

## Working directory

`receive.sh` creates a working directory with subfolders

* inbox is where reads are manually added
* log is where log files go
* outbox is where reads are moved to
* compiled is where compiled results go to from `compile.sh`.
