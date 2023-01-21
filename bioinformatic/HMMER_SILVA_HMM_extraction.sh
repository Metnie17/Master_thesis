#!/usr/bin/env bash
set -e

hmm="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/graftm/files/"
files="/user_data/Metnie17/With_CPU_use/samples/extraction/"
result_dir="/user_data/Metnie17/With_CPU_use/extraction/hmmer/database_based/extraction/"




module purge
module load HMMER/3.3.2-foss-2020b
module load SeqKit/2.0.0

for line in "$files"/*_R1_fastp.fastq.gz; do # TODO: Filename is called "line" for some reason. Change?
  cd $result_dir
  input=$(echo ${line} | sed -r 's/R.+//')
  new_name=$(echo ${line##*/} | sed -r 's/-[^-]+$//')
  mkdir -p "${new_name}/tblout/"
  cd ${new_name}/tblout/
  echo "  - Searching forward reads for 16S and 18S fragments..."
   zcat "${input}R1_fastp.fastq.gz" | \
    awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 32 -o /dev/null --noali --tblout "bac_forward.hmmout.txt" "${hmm}bac_trunc_nr90.hmm" -) | \
          nhmmer --incE 1e-05 -E 1e-05 --cpu 32 -o /dev/null --noali --tblout "arc_forward.hmmout.txt" "${hmm}arc_trunc_nr95.hmm" -
  echo "  - Searching reverse reads for 16S and 18S fragments..."
   zcat "${input}R2_fastp.fastq.gz" | \
    awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 32 -o /dev/null --noali --tblout "bac_reverse.hmmout.txt" "${hmm}bac_trunc_nr90.hmm" -) | \
          nhmmer --incE 1e-05 -E 1e-05 --cpu 32 -o /dev/null --noali --tblout "arc_reverse.hmmout.txt" "${hmm}arc_trunc_nr95.hmm" -
cd $result_dir
  for file in "${new_name}/tblout"/*.hmmout.txt; do
    echo "Extracting IDs from $file"
    awk -F " " 'NR>2 {print $1}' "$file" | grep -vE "^#" > "$file.seqid"
  done

  cat "${new_name}/tblout/arc_forward.hmmout.txt.seqid" "${new_name}/tblout/bac_forward.hmmout.txt.seqid" > "${new_name}/bacteria_arcea_forward.seqid"
  cat "${new_name}/tblout/arc_reverse.hmmout.txt.seqid" "${new_name}/tblout/bac_reverse.hmmout.txt.seqid" > "${new_name}/bacteria_arcea_reverse.seqid"

  echo "Ensuring that IDs are unique"
  for file in "$new_name"/*.seqid; do
    sort "$file" | uniq - > "$file.uniq"
    mv "$file.uniq" "$file"
  done

  for file in "$new_name"/*_forward.seqid; do
    reverse="${file/_forward.seqid/_reverse.seqid}"
    fname_fwd="${file/.seqid/.fq}"
    fname_rev="${reverse/.seqid/.fq}"
    {
      if [ ! -f "$fname_fwd" ]; then
        echo "SeqKit $fname_fwd"
        seqkit grep -f "$file" "${input}R1_fastp.fastq.gz" -o "$fname_fwd"
        echo "SeqKit $fname_fwd DONE!"
      fi
    } &
    {
      if [ ! -f "$fname_fwd" ]; then
        echo "SeqKit $fname_rev"
        seqkit grep -f "$reverse" "${input}R2_fastp.fastq.gz" -o "$fname_rev"
        echo "SeqKit $fname_rev DONE!"
      fi
    } &
    wait
  done
done

module purge

