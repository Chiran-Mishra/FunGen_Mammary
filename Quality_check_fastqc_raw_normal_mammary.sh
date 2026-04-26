#!/bin/bash
# =============================================================================
# Script: Raw Read Quality Check Using FastQC
# Project: Canine Mammary Tumor RNA-seq Analysis
# Author: Chiranjeevi Mishra | Auburn University | April 2026
#
# Description:
# This script evaluates the quality of raw FASTQ files using FastQC.
# The output includes HTML reports and zipped result folders for each sample.
#
# Input:
#   - Raw FASTQ files located in:
#     /scratch/${MyID}/Project/rawfile/correct
#
# Output:
#   - FastQC quality reports saved in:
#     /scratch/${MyID}/Project/rawfile/RawDataQuality_correct
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
DD=/scratch/${MyID}/Project/rawfile/correct
WD=/scratch/${MyID}/Project/rawfile
RDQ=RawDataQuality_correct

# Move to the directory containing raw FASTQ files
cd ${DD}

# Create output directory for FastQC results
mkdir -p ${WD}/${RDQ}

# Run FastQC on all raw FASTQ files
fastqc *.fastq --outdir=${WD}/${RDQ}

# Compress FastQC results for transfer to local computer
cd ${WD}
tar -czvf ${RDQ}.tar.gz ${RDQ}
