#!/usr/bin/env bash

# Run script with selected database and output
module purge
module load Metaxa2/2.2.3-foss-2020b


files=/srv/MA/users/Metnie17/samples/test_samples/

mkdir logs
log=logs

# find files
find $files/*_R1_fastp.fastq.gz > samples.txt

while read line; do
  input=$(echo ${line} | sed -r 's/R.+//')
  new_name=$(echo ${line##*/} | sed -r 's/-[^-]+$//')
  mkdir $input
  cd $input
  metaxa2 \
  -1 $input'R1_fastp.fastq.gz' \
  -2 $input'R2_fastp.fastq.gz' \
  --reltax T \
  --cpu 60 \
  --save_raw T \
  -f p \
  -z gzip \
  &> >(tee -a ../logs/metaxa2_$input.log)
done < samples.tx
