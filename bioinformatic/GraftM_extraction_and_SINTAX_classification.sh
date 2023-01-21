#!/usr/bin/env bash

sleep 1 # Let the profiler/benchmark tool warm up

# Run script with selected database and output
module load binutils/2.28-GCCcore-6.4.0
module load GraftM/0.13.1-foss-2018a-Python-3.6.4
module load binutils/2.28-GCCcore-6.4.0


result_dirG="/user_data/Metnie17/With_CPU_use/classification/sintax/benchmark/"
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
  --search_only \
  --search_method hmmsearch \
  --verbosity 5 \
  --output_directory $result_dirG/LIB-MJ050-H8/ \
  --threads 64



module unload binutils/2.28-GCCcore-6.4.0 GraftM/0.13.1-foss-2018a-Python-3.6.4



extracted_soil_sample="/user_data/Metnie17/With_CPU_use/classification/sintax/benchmark/LIB-MJ050-H8/LIB-MJ050-H8-02_R1_fastp/"
result_dirS="/user_data/Metnie17/With_CPU_use/classification/sintax/benchmark/"
classification_db_file="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/AutoTax_SILVA_138.1_Biowide/output/AutoTax_SILVA_138.1_Biowide_sintax_trunc_Nr97.udb"


cd $result_dirS
 usearch11 \
		-sintax "${extracted_soil_sample}forward/${name}-02_R1_fastp_forward_hits.fa" \
		-db "$classification_db_file" \
		-strand both \
		-threads 64 \
		-tabbedout "${name}_forward.sintax" \
		&> >(tee -a "${name}_forward_sintax.log")


cd $result_dirS
 usearch11 \
		-sintax "${extracted_soil_sample}reverse/${name}-02_R1_fastp_reverse_hits.fa" \
		-db "$classification_db_file" \
		-strand both \
		-threads 64 \
		-tabbedout "${name}_reverse.sintax" \
		&> >(tee -a "${name}_reverse_sintax.log")
