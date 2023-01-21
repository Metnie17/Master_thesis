#!/usr/bin/env bash
set -e

sleep 1 # Let the profiler/benchmark tool warm up

# Run script with selected database and output

export db='/user_data/tbnj/projects/Biowide_UMIs_v2/data/databases/bwa/AutoTax_SILVA_138.1_Biowide_sintax_trunc_Nr97.fa'
result_dir='/user_data/Metnie17/With_CPU_use/extraction/bwa/extraction_samples/'
forward="/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R1_fastp.fastq.gz"
reverse="/user_data/Metnie17/With_CPU_use/samples/extraction/LIB-MJ050-H8-02_R2_fastp.fastq.gz"
name="LIB-MJ050-H8"


module load BWA/2021-02-18-foss-2020b


cd $result_dir

bwa mem -t 120 $db "$forward" "$reverse" > $name'_aln_pe.sam'


module swap BWA/2021-02-18-foss-2020b SAMtools/1.14-GCC-10.2.0

  if [ -f "${name}_aligned_reads.txt" ] ; then
    echo "${name}_aligned_reads.txt already exists, skipping..."
    continue
  fi
  samtools view -uF 4 $name'_aln_pe.sam' -o $name'_aln_pe.bam'
  samtools sort $name'_aln_pe.bam' -o $name'_aln_pe_sorted.bam'
  samtools index $name'_aln_pe_sorted.bam'
  samtools view $name'_aln_pe_sorted.bam' | cut -f 1 > $name'_aligned_reads.txt'


module swap SAMtools/1.14-GCC-10.2.0 SeqKit/2.0.0


  cd $result_dir


  if [ -f "${name}_aligned_reads.fastq" ] ; then
    echo "${name}_aligned_reads.fastq already exists, skipping..."
  else
    #echo "Header file: '${name}_aligned_reads.txt', input1: '$forward', input2: '$reverse', output: '${name}_aligned_reads.fastq'"
    seqkit grep -f $name'_aligned_reads.txt' "$forward" "$reverse" > $name'_aligned_reads.fastq' &
  fi

  if [ -f "${name}_aligned_reads_R1.fastq" ] ; then
    echo "${name}_aligned_reads_R1.fastq already exists, skipping..."
  else
    seqkit grep -f $name'_aligned_reads.txt' "$forward" > $name'_aligned_reads_R1.fastq' &
  fi
wait

module unload SeqKit/2.0.0
