#!/bin/bash
# =============================================================================
# Complete fastq files download steps: Cancer vs Normal (Dog Cancer Mammary Tissue)
# Author: Chiranjeevi Mishra | Auburn University | April 2026
# ALL OUTPUTS SAVED TO "group_project" FOLDER 
# =============================================================================

## 	download data from NCBI SRA using the SRAtoolkit and the SRA run IDs: https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/
## 	use FASTQC to evaluate the quality of the data: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
## Download from SRA: Input Data: NA
## 		queue: class
##		core: 1
##		time limit (HH:MM:SS): 04:00:00 
##		Memory: 4gb
##		run on asax
###############################################


########## Load Modules
source /apps/profiles/modules_asax.sh.dyn
module load sra

##########  Define variables and make directories
## Replace the numbers in the brackets with Your specific information
  ## make variable for your ASC ID so the directories are automatically made in YOUR directory
  ## These are represented in the code by [#] replace these according to the examples provided
MyID=aubclsf0047          

  ## Make variable that represent YOUR working directory(WD) in scratch, your Raw data directory (DD) and the pre or postcleaned status (CS).
DD=/scratch/${MyID}/Project/rawfile_1			## Example: DD=/scratch/${MyID}/PracticeRNAseq/RawData
 
##  make the directories in SCRATCH for holding the raw data 
## -p tells it to make any upper level directories that are not there. Notice how this will also make the WD.
mkdir -p ${DD}
## move to the Data Directory
cd ${DD}

##########  Download data files from NCBI: SRA using the Run IDs
  ### from SRA use the SRA tool kit - see NCBI website https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/
	## this downloads the SRA file and converts to fastq
	## -F 	Defline contains only original sequence name.
	## -I 	Append read id after spot id as 'accession.spot.readid' on defline.
	## --split-files splits the files into R1 and R2 (forward reads, reverse reads)

## We must run vdb-config to force creation of the default config file, otherwise we will get an error. This is a 'hack'. 

vdb-config --interactive > /dev/null 2>&1 <<EOF
q
EOF


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

##### Extra ####
## If you are downloading data from a sequencing company instead of NCBI, using wget for example, then calculate the md5sum values of all the files in the folder (./*), and read into a text file.
## then you can compare the values in this file with the ones provided by the company.
#md5sum ./* > md5sum.txt

##### Extra ####
## If you data comes with multiple R1 and R2 files per individual. You can contatenate them together using "cat" before running FASTQC
## see examples below for one file. You will probably want to use a loop to process through all the files.
#cat SRR6819014*_R1_*.fastq.gz > SRR6819014_All_R1.fastq.gz
#cat SRR6819014*_R2_*.fastq.gz > SRR6819014_All_R2.fastq.gz
