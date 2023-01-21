#!/usr/bin/env bash

sleep 1 # Let the profiler/benchmark tool warm up

# Run script with selected database and output
module load binutils/2.28-GCCcore-6.4.0
module load GraftM/0.13.1-foss-2018a-Python-3.6.4
module load binutils/2.28-GCCcore-6.4.0


result_dir="/user_data/Metnie17/With_CPU_use/extraction/graftM/seed2022/extraction_samples/"
package="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/graftm/packages/AutoTax_SILVA_138.1_Biowide/AutoTax_SILVA_138.1_Biowide.gpkq/"
forward="/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R1_fastp.fastq.gz"
reverse="/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R2_fastp.fastq.gz"
name="LIB-MJ050-H8"

graftM graft \
  --forward "$forward" \
  --reverse "$reverse" \
  --graftm_package $package \
  --input_sequence_type nucleotide \
  --filter_minimum 50 \
  --search_only \
  --euk_check \
  --search_method hmmsearch \
  --verbosity 5 \
  --output_directory $name \
  --threads 120 \
  --log $name.log

module unload binutils/2.28-GCCcore-6.4.0 GraftM/0.13.1-foss-2018a-Python-3.6.4
