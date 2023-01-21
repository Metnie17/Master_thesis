#!/usr/bin/env bash

# Run script with selected database and output
module purge



extracted_soil_sample="/user_data/Metnie17/With_CPU_use/extraction/graftM/seed2022/extraction_samples/LIB-MJ050-H8/LIB-MJ050-H8-02_R1_fastp/"
result_dir="/user_data/Metnie17/With_CPU_use/classification/sintax/graftM/extraction/"
classification_db_file="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/AutoTax_SILVA_138.1_Biowide/output/AutoTax_SILVA_138.1_Biowide_sintax_trunc_Nr97.udb"
name="LIB-MJ050-H8"

cd $result_dir
 usearch11 \
		-sintax "${extracted_soil_sample}forward/${name}-02_R1_fastp_forward_hits.fa" \
		-db "$classification_db_file" \
		-strand both \
		-threads 120 \
		-tabbedout "${name}_forward.sintax" \
		&> >(tee -a "${name}_forward.log")




cd $result_dir
 usearch11 \
		-sintax "${extracted_soil_sample}reverse/${name}-02_R1_fastp_reverse_hits.fa" \
		-db "$classification_db_file" \
		-strand both \
		-threads 120 \
		-tabbedout "${name}_reverse.sintax" \
		&> >(tee -a "${name}_reverse.log")
