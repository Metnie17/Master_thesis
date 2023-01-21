#!/usr/bin/env bash

sleep 1 # Let the profiler/benchmark tool warm up

# Run script with selected database and output
module load binutils/2.28-GCCcore-6.4.0
module load GraftM/0.13.1-foss-2018a-Python-3.6.4
module load binutils/2.28-GCCcore-6.4.0


result_dir="/user_data/Metnie17/With_CPU_use/classification/graftM/Seed2022/classification/"
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
  --euk_check \
  --search_method hmmsearch \
  --assignment_method pplacer \
  --verbosity 5 \
  --output_directory $result_dir/LIB-MJ050-H8/ \
  --threads 64

module unload binutils/2.28-GCCcore-6.4.0 GraftM/0.13.1-foss-2018a-Python-3.6.4
