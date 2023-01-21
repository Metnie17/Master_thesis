#!/usr/bin/env bash
set -e

sleep 1 # Let the profiler/benchmark tool warm up

hmm="/user_data/tbnj//projects/Biowide_UMIs_v2/data/databases/graftm/packages/AutoTax_SILVA_138.1_Biowide/AutoTax_SILVA_138.1_Biowide.gpkq/"
result_dir="/user_data/Metnie17/With_CPU_use/extraction/hmmer/seed2022/extraction/"

cd $result_dir
module load HMMER/3.3.2-foss-2020b SeqKit/2.0.0

  mkdir -p "LIB-MJ050-H8/tblout/"
  cd "LIB-MJ050-H8/tblout/"
  echo "  - Searching forward reads for 16S and 18S fragments..."
  zcat "/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R1_fastp.fastq.gz" | \
    awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 40 -o /dev/null --noali --tblout "bac_forward.hmmout.txt" "${hmm}bac.hmm" -) | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 40 -o /dev/null --noali --tblout "arc_forward.hmmout.txt" "${hmm}arc.hmm" -) | \
          nhmmer --incE 1e-05 -E 1e-05 --cpu 40 -o /dev/null --noali --tblout "euk_forward.hmmout.txt" "${hmm}euk.hmm" -
  echo "  - Searching reverse reads for 16S and 18S fragments..."
  zcat "/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R2_fastp.fastq.gz" | \
    awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 40 -o /dev/null --noali --tblout "bac_reverse.hmmout.txt" "${hmm}bac.hmm" -) | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 40 -o /dev/null --noali --tblout "arc_reverse.hmmout.txt" "${hmm}arc.hmm" -) | \
          nhmmer --incE 1e-05 -E 1e-05 --cpu 40 -o /dev/null --noali --tblout "euk_reverse.hmmout.txt" "${hmm}euk.hmm" -
cd $result_dir

  for file in "LIB-MJ050-H8/tblout"/*.hmmout.txt; do
    echo "Extracting IDs from LIB-MJ050-H8"
    awk -F " " 'NR>2 {print $1}' "$file" | grep -vE "^#" > "$file.seqid"
  done

  cat "LIB-MJ050-H8/tblout/arc_forward.hmmout.txt.seqid" "LIB-MJ050-H8/tblout/bac_forward.hmmout.txt.seqid" > "LIB-MJ050-H8/bacteria_arcea_forward.seqid"
  cat "LIB-MJ050-H8/tblout/arc_reverse.hmmout.txt.seqid" "LIB-MJ050-H8/tblout/bac_reverse.hmmout.txt.seqid" > "LIB-MJ050-H8/bacteria_arcea_reverse.seqid"

  echo "Ensuring that IDs are unique"
  for file in "LIB-MJ050-H8"/*.seqid; do
    sort "$file" | uniq - > "$file.uniq"
    mv "$file.uniq" "$file"
  done

    {
        echo "SeqKit $fname_fwd"
        seqkit grep -f "LIB-MJ050-H8/bacteria_arcea_forward.seqid" "/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R1_fastp.fastq.gz" -o "LIB-MJ050-H8/bacteria_arcea_forward.fq"
        echo "SeqKit $fname_fwd DONE!"
    } &
    {
        echo "SeqKit $fname_rev"
        seqkit grep -f "LIB-MJ050-H8/bacteria_arcea_reverse.seqid" "/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R2_fastp.fastq.gz" -o "LIB-MJ050-H8/bacteria_arcea_reverse.fq"
        echo "SeqKit $fname_rev DONE!"
    } &
    wait


module unload HMMER/3.3.2-foss-2020b SeqKit/2.0.0
