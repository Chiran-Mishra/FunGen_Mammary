#!/bin/bash
# =============================================================================
# Script: Read Trimming and Post-clean Quality Assessment (Cancer Samples)
# Project: Canine Mammary Tumor RNA-seq Analysis
# Author: Chiranjeevi Mishra | Auburn University | April 2026
#
# Description:
# This script performs adapter trimming and quality filtering of paired-end
# RNA-seq reads using Trimmomatic, followed by quality assessment of the
# cleaned reads using FastQC.
#
# Input:
#   - Raw paired-end FASTQ files (R1 and R2)
#   - Adapter file (AdaptersToTrim_All.fa)
#
# Output:
#   - Trimmed paired and unpaired FASTQ files
#   - FastQC reports for cleaned reads
#   - Compressed tarball of FastQC results
#
# HPC Resources:
#   - Queue: medium
#   - CPUs: 6
#   - Memory: 12 GB
#   - Walltime: 02:00:00
#   - Run on: asax
# =============================================================================

# Load required modules
source /apps/profiles/modules_asax.sh.dyn
module load trimmomatic/0.39
module load fastqc/0.10.1

# Define variables
MyID=aubclsf0047
WD=/scratch/${MyID}/Project
DD=/scratch/${MyID}/Project/rawfile_1
CD=/scratch/${MyID}/Project/CleanData_Cancer
PCQ=PostCleanQuality_1

# Create output directories
mkdir -p ${CD}
mkdir -p ${WD}/${PCQ}

# Move to raw data directory
cd ${DD}

# Generate list of sample IDs
ls *.fastq | cut -d "_" -f 1 | sort | uniq > list

# Copy adapter file
cp /home/${MyID}/graze_class/AdaptersToTrim_All.fa .

# Run Trimmomatic + FastQC
while read i
do
    java -jar /apps/x86-64/apps/spack_0.19.1/spack/opt/spack/linux-rocky8-zen3/gcc-11.3.0/trimmomatic-0.39-iu723m2xenra563gozbob6ansjnxmnfp/bin/trimmomatic-0.39.jar \
    PE -threads 6 -phred33 \
    ${i}_1.fastq ${i}_2.fastq \
    ${CD}/${i}_1_paired.fastq ${CD}/${i}_1_unpaired.fastq \
    ${CD}/${i}_2_paired.fastq ${CD}/${i}_2_unpaired.fastq \
    ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36

    # FastQC on cleaned paired reads
    fastqc ${CD}/${i}_1_paired.fastq --outdir=${WD}/${PCQ}
    fastqc ${CD}/${i}_2_paired.fastq --outdir=${WD}/${PCQ}

done < list

# Compress FastQC results
cd ${WD}
tar -czvf ${PCQ}.tar.gz ${PCQ}
