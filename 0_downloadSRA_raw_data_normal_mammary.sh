#!/bin/bash
# =============================================================================
# Script: Download FASTQ Files from NCBI SRA
# Project: Canine Mammary Normal RNA-seq Analysis
# Author: Chiranjeevi Mishra | Auburn University | April 2026
#
# Description:
# This script downloads paired-end RNA-seq FASTQ files for canine mammary
# tumor samples from NCBI SRA using the SRA Toolkit.
#
# Input:
#   - SRA Run IDs from BioProject PRJNA489087
#
# Output:
#   - Paired-end FASTQ files saved in:
#     /scratch/${MyID}/Project/rawfile_1
#
# HPC Resources:
#   - Queue: class
#   - CPUs: 1
#   - Memory: 4 GB
#   - Walltime: 04:00:00
#   - Run on: asax
# =============================================================================

# Load required modules
source /apps/profiles/modules_asax.sh.dyn
module load sra

# Define variables
MyID=aubclsf0047
DD=/scratch/${MyID}/Project/rawfile_1

# Create raw data directory and move into it
mkdir -p ${DD}
cd ${DD}

# Initialize SRA Toolkit configuration
vdb-config --interactive > /dev/null 2>&1 <<EOF
q
EOF

fastq-dump -F --split-files SRR7819740
fastq-dump -F --split-files SRR7819751
fastq-dump -F --split-files SRR7819759
fastq-dump -F --split-files SRR7819764
fastq-dump -F --split-files SRR7819779
fastq-dump -F --split-files SRR7819802
fastq-dump -F --split-files SRR7819811
fastq-dump -F --split-files SRR7819835
fastq-dump -F --split-files SRR7819862
fastq-dump -F --split-files SRR7819866
 



