#!/bin/bash
# =============================================================================
# Script: HISAT2 Mapping and StringTie Quantification
# Project: Canine Mammary Tumor RNA-seq Analysis
# Author: Chiranjeevi Mishra | Auburn University | April 2026
#
# Description:
# This script maps cleaned paired-end RNA-seq reads to the canFam6 reference
# genome using HISAT2. It then converts SAM files to sorted BAM files using
# Samtools and quantifies gene/transcript expression using StringTie.
# Finally, prepDE.py3 is used to generate gene and transcript count matrices.
#
# Input:
#   - Cleaned paired-end FASTQ files
#   - canFam6 reference genome FASTA file
#   - canFam6 GTF annotation file
#
# Output:
#   - SAM alignment files
#   - Sorted BAM files
#   - Mapping statistics files
#   - StringTie output folders
#   - Gene and transcript count matrices
#
# HPC Resources:
#   - Queue: class or medium
#   - CPUs: 6
#   - Memory: 12 GB
#   - Walltime: 04:00:00
#   - Run on: asax
# =============================================================================

# Load required modules
source /apps/profiles/modules_asax.sh.dyn
module load hisat2/2.2.0
module load stringtie/2.2.1
module load gcc/9.4.0
module load python/3.10.8-zimemtc
module load samtools
module load bcftools
module load gffread

# Set stack size to unlimited and echo commands to log file
ulimit -s unlimited
set -x

# Define variables
MyID=aubclsf0047
WD=/scratch/${MyID}/Project/mapping_combine
CD=/scratch/${MyID}/Project/Clean_Combine
REFD=/scratch/${MyID}/Project/canFam6
MAPD=/scratch/${MyID}/Project/mapping_combine/Map_HiSat2
COUNTSD=/scratch/${MyID}/Project/mapping_combine/Counts_StringTie
RESULTSD=/home/${MyID}/Project/mapping_combine/Counts_H_S
REF=canFam6

# Create output directories
mkdir -p ${REFD}
mkdir -p ${MAPD}
mkdir -p ${COUNTSD}
mkdir -p ${RESULTSD}

# Prepare HISAT2 reference index
cd ${REFD}

hisat2_extract_splice_sites.py ${REF}.gtf > ${REF}.ss
hisat2_extract_exons.py ${REF}.gtf > ${REF}.exon

hisat2-build --ss ${REF}.ss --exon ${REF}.exon ${REF}.fa canFam6_index

# Generate list of sample IDs from cleaned paired FASTQ files
cd ${CD}
ls *.fastq | cut -d "_" -f 1 | sort | uniq > list

# Move sample list to mapping directory
mv list ${MAPD}
cd ${MAPD}

# Map reads, process BAM files, and quantify expression
while read i
do
    hisat2 -p 6 --dta --phred33 \
    -x ${REFD}/canFam6_index \
    -1 ${CD}/${i}_1_paired.fastq \
    -2 ${CD}/${i}_2_paired.fastq \
    -S ${i}.sam

    samtools view -@ 6 -bS ${i}.sam > ${i}.bam

    samtools sort -@ 6 ${i}.bam -o ${i}_sorted.bam

    samtools flagstat ${i}_sorted.bam > ${i}_Stats.txt

    mkdir -p ${COUNTSD}/${i}

    stringtie -p 6 -e -B \
    -G ${REFD}/${REF}.gtf \
    -o ${COUNTSD}/${i}/${i}.gtf \
    -l ${i} \
    ${MAPD}/${i}_sorted.bam

done < list

# Copy mapping statistics to results directory
cp *.txt ${RESULTSD}

# Generate count matrices using prepDE.py3
cd ${COUNTSD}
cp /home/${MyID}/graze_class/prepDE.py3 .

python prepDE.py3 -i ${COUNTSD}

# Copy final count matrices to results directory
cp *.csv ${RESULTSD}
