#!/bin/bash

#################### FunGen Course Script ####################
## Purpose:
## Trim adapters and low-quality regions from raw paired-end RNA-seq reads
## from NORMAL canine mammary gland samples using Trimmomatic.
## Then run FastQC to check quality after trimming.
##
## Project: Canine Mammary Tumor RNA-seq Analysis
## Dataset: Normal mammary tissue samples
## Input: Raw FASTQ files from raw_normal
## Output: Cleaned paired/unpaired FASTQ files and post-cleaning FastQC reports
##
## Suggested HPC resources:
## Queue: medium
## Cores: 6
## Time: 02:00:00
## Memory: 12 GB
## Run on: asax
###############################################################

# Load modules
source /apps/profiles/modules_asax.sh.dyn
module load trimmomatic/0.39
module load fastqc/0.10.1

# User ID
MyID=aubclsf0047

# Directories
WD=/scratch/${MyID}/Project
DD=/scratch/${MyID}/Project/raw_normal
CD=/scratch/${MyID}/Project/CleanData_Normal
PCQ=PostCleanQuality_Normal
adapters=AdaptersToTrim_All.fa

# Make output directories
mkdir -p ${CD}
mkdir -p ${WD}/${PCQ}

# Move to raw data directory
cd ${DD}

# Make list of sample IDs
ls | grep ".fastq" | cut -d "_" -f 1 | sort | uniq > list

# Copy adapter file
cp /home/${MyID}/graze_class/AdaptersToTrim_All.fa .

# Run Trimmomatic and FastQC
while read i
do
    java -jar /apps/x86-64/apps/spack_0.19.1/spack/opt/spack/linux-rocky8-zen3/gcc-11.3.0/trimmomatic-0.39-iu723m2xenra563gozbob6ansjnxmnfp/bin/trimmomatic-0.39.jar \
    PE -threads 6 -phred33 \
    ${i}_1.fastq ${i}_2.fastq \
    ${CD}/${i}_1_paired.fastq ${CD}/${i}_1_unpaired.fastq \
    ${CD}/${i}_2_paired.fastq ${CD}/${i}_2_unpaired.fastq \
    ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 \
    HEADCROP:10 \
    LEADING:30 \
    TRAILING:30 \
    SLIDINGWINDOW:6:30 \
    MINLEN:36

    # Run FastQC on cleaned paired reads
    fastqc ${CD}/${i}_1_paired.fastq --outdir=${WD}/${PCQ}
    fastqc ${CD}/${i}_2_paired.fastq --outdir=${WD}/${PCQ}

done < list

# Compress FastQC results
cd ${WD}/${PCQ}
tar cvzf ${PCQ}.tar.gz ${WD}/${PCQ}/*
