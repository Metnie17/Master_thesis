#!/usr/bin/env bash
set -e

sleep 1

hmm="/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/graftm/packages/7.71.silva_v132_alpha1/7.71.silva_v132_alpha1.gpkg/"
files="/user_data/Metnie17/With_CPU_use/samples/extraction/"
result_dir="/user_data/Metnie17/With_CPU_use/extraction/hmmer/seed2015/extraction/hc/"

function getWierdFileNameFromNumber() {
  local number="$1"
  local string="$2"
  local regex="s/R1/$number/g"
  echo "$string" | sed "$regex"
}

function cutWierdFileName() {
  local name="$1"
  echo "$name" | sed -r 's/_reads.+//'
}

module load HMMER/3.3.2-foss-2020b
module load SeqKit/2.0.0

mkdir -p "$result_dir"

for line in "$files"/*R1*_reads.fastq.gz; do # TODO: Filename is called "line" for some reason. Change?
  cd $result_dir

  nm_forward="$(getWierdFileNameFromNumber "R1" "$line")"
  nm_reverse="$(getWierdFileNameFromNumber "R2" "$line")"
  export name=$(cutWierdFileName "${line##*/}")



  mkdir -p "$name/tblout/"
  cd ${name}/tblout/
  echo "  - Searching forward reads for 16S and 18S fragments..."
  zcat "$nm_forward" | \
    awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 60 -o /dev/null --noali --tblout "bac_forward.hmmout.txt" "${hmm}bacteria.hmm" -) | \
          nhmmer --incE 1e-05 -E 1e-05 --cpu 60 -o /dev/null --noali --tblout "arc_forward.hmmout.txt" "${hmm}archaea.hmm" -
  echo "  - Searching reverse reads for 16S and 18S fragments..."
  zcat "$nm_reverse" | \
    awk '{print ">" substr($0,2);getline;print;getline;getline}' - | \
    tee >(nhmmer --incE 1e-05 -E 1e-05 --cpu 60 -o /dev/null --noali --tblout "bac_reverse.hmmout.txt" "${hmm}bacteria.hmm" -) | \
          nhmmer --incE 1e-05 -E 1e-05 --cpu 60 -o /dev/null --noali --tblout "arc_reverse.hmmout.txt" "${hmm}archaea.hmm" -
cd $result_dir
  for file in "${name}/tblout"/*.hmmout.txt; do
    echo "Extracting IDs from $file"
    awk -F " " 'NR>2 {print $1}' "$file" | grep -vE "^#" > "$file.seqid"
  done

  cat "${name}/tblout/arc_forward.hmmout.txt.seqid" "${name}/tblout/bac_forward.hmmout.txt.seqid" > "${name}/bacteria_arcea_forward.seqid"
  cat "${name}/tblout/arc_reverse.hmmout.txt.seqid" "${name}/tblout/bac_reverse.hmmout.txt.seqid" > "${name}/bacteria_arcea_reverse.seqid"

  echo "Ensuring that IDs are unique"
  for file in "$name"/*.seqid; do
    sort "$file" | uniq - > "$file.uniq"
    mv "$file.uniq" "$file"
  done

  for file in "$name"/*_forward.seqid; do
    reverse="${file/_forward.seqid/_reverse.seqid}"
    fname_fwd="${file/.seqid/.fq}"
    fname_rev="${reverse/.seqid/.fq}"
    {
      if [ ! -f "$fname_fwd" ]; then
        echo "SeqKit $fname_fwd"
        seqkit grep -f "$file" "$nm_forward" -o "$fname_fwd"
        echo "SeqKit $fname_fwd DONE!"
      fi
    } &
    {
      if [ ! -f "$fname_fwd" ]; then
        echo "SeqKit $fname_rev"
        seqkit grep -f "$reverse" "$nm_reverse" -o "$fname_rev"
        echo "SeqKit $fname_rev DONE!"
      fi
    } &
    wait
  done
done

module unload HMMER/3.3.2-foss-2020b
module unload SeqKit/2.0.0
