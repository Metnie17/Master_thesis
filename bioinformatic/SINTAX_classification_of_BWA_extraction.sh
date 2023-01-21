#!/usr/bin/env bash

# Run script with selected database and output
module purge



extracted_soil_sample="/user_data/Metnie17/With_CPU_use/extraction/bwa/extraction_samples/"
result_dir="/user_data/Metnie17/With_CPU_use/classification/sintax/BWA/extraction/"
classification_db_file="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/AutoTax_SILVA_138.1_Biowide/output/AutoTax_SILVA_138.1_Biowide_sintax_trunc_Nr97.udb"
name="LIB-MJ050-H8"

cd $result_dir
 usearch11 \
		-sintax "${extracted_soil_sample}/${name}_aligned_reads.fastq" \
		-db "$classification_db_file" \
		-strand both \
		-threads 120 \
		-tabbedout "$name.sintax" \
		&> >(tee -a "$name.log")
