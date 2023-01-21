#!/bin/bash
set -e

module purge
module load Python/3.8.6-GCCcore-10.2.0

workingdir="$(pwd)"

benchmark_a_script() {
  cd "$workingdir" # Each of the scripts will usually change directory to something else. cd to current working dir to undo that.
  local name="$1"
  local script="$2"
  bash "$script" & # Run the desired script in a subprocess
  local P1=$! # Grab the pid of that subprocess
  procpath record -i .5 -d "${name}.sqlite" --stop-without-result "\$..children[?(@.stat.pid == $P1)]" & # Profile/record/benchmark the scripts subprocess, in another subprocess
  echo "$P1" > "${name}.pid"
  local P2=$! # Grab the pid of profiler subprocess
  wait $P1 $P2 # Wait for both subprocesses to terminate
  unset -v P1 P2 script # Forget the PIDs (shouldn't do anything because fields are assigned locally to this scope.)
}

# hmmer
benchmark_a_script "benchmark_hammer" "./hmmer/seed2022/extraction/run_hmmer_seed2022_extraction_hc.sh"
sleep 10

# BWA
benchmark_a_script "benchmark_bwa" "./bwa/extraction_samples/run_bwa_hc.sh"
sleep 10

# bowtie
benchmark_a_script "benchmark_bowtie" "./bowtie/extraction_samples/run_bowtie_extract_hc.sh"
sleep 10

# GraftM
benchmark_a_script "benchmark_graftm" "./graftM/seed2022/extraction_samples/run_graftM_seed2022_extraction_hc.sh"
sleep 10

# Clear all loaded modules (should only be the python module above
module purge
