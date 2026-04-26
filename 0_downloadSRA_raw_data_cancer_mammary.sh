#!/bin/bash
# =============================================================================
# Script: Download FASTQ Files from NCBI SRA
# Project: Canine Mammary Tumor RNA-seq Analysis
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

# Download paired-end FASTQ files from NCBI SRA
fastq-dump -F --split-files SRR7819851
fastq-dump -F --split-files SRR7819863
fastq-dump -F --split-files SRR7819867
fastq-dump -F --split-files SRR7819869
fastq-dump -F --split-files SRR7819870
fastq-dump -F --split-files SRR7819871
fastq-dump -F --split-files SRR7819875
fastq-dump -F --split-files SRR7819885
fastq-dump -F --split-files SRR7819891
fastq-dump -F --split-files SRR7819893

