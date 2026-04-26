#!/bin/bash
# =============================================================================
# Script: Raw Read Quality Check Using FastQC
# Project: Canine Mammary Tumor RNA-seq Analysis
# Author: Chiranjeevi Mishra | Auburn University | April 2026
#
# Description:
# This script evaluates the quality of raw FASTQ files downloaded from NCBI SRA
# using FastQC. The output includes HTML reports and zipped result folders for
# each FASTQ file.
#
# Input:
#   - Raw FASTQ files from NCBI SRA
#
# Output:
#   - FastQC quality reports saved in:
#     /scratch/${MyID}/Project/rawfile_1/RawDataQuality_2
#   - Compressed tarball of FastQC results
#
# HPC Resources:
#   - Queue: class
#   - CPUs: 1
#   - Memory: 1 GB
#   - Walltime: 04:00:00
#   - Run on: asax
# =============================================================================

# Load required modules
source /apps/profiles/modules_asax.sh.dyn
module load fastqc/0.10.1

# Define variables
MyID=aubclsf0047
DD=/scratch/${MyID}/Project/rawfile_1
WD=/scratch/${MyID}/Project/rawfile_1
RDQ=RawDataQuality_2

# Move to the directory containing raw FASTQ files
cd ${DD}

# Create output directory for FastQC results
mkdir -p ${WD}/${RDQ}

# Run FastQC on all raw FASTQ files
fastqc *.fastq --outdir=${WD}/${RDQ}

# Compress FastQC result files for transfer to local computer
cd ${WD}
tar -czvf ${RDQ}.tar.gz ${RDQ}
