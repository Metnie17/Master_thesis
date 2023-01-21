#!/usr/bin/env bash

# Run script with selected database and output
module purge



extracted_soil_sample="/user_data/Metnie17/With_CPU_use/extraction/hmmer/seed2022/extraction/LIB-MJ050-H8/"
result_dir="/user_data/Metnie17/With_CPU_use/database/silva/"
classification_db_file="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/AutoTax_SILVA_138.1/AutoTax_SILVA_138.1_Nr99_sintax.udb"
name="LIB-MJ050-H8"

cd $result_dir


   usearch11 \
		-sintax "${extracted_soil_sample}bacteria_arcea_forward.fq" \
		-db "$classification_db_file" \
		-strand both \
		-threads 15 \
		-tabbedout "${name}_forward.sintax" \
		&> >(tee -a "${name}_forward.log")

cd $result_dir

   usearch11 \
		-sintax "${extracted_soil_sample}bacteria_arcea_reverse.fq" \
		-db "$classification_db_file" \
		-strand both \
		-threads 15 \
		-tabbedout "${name}_reverse.sintax" \
		&> >(tee -a "${name}_reverse.log")