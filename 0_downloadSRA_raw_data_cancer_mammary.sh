#!/bin/bash

######### FunGen Course Instructions ############
## Purpose: The purpose of this script is to 
## 	learn to use the scratch directory
## 	learn to define variables
## 	download data from NCBI SRA using the SRAtoolkit and the SRA run IDs: https://www.ncbi.nlm.nih.gov/sra/docs/sradownload/
## 	use FASTQC to evaluate the quality of the data: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
## Download from SRA: Input Data: NA
## 			Output: Downloaded read files, R1 and R2 files for each sample if paired-end data (FASTQ)
## 	After you have this script in your home directory and you have made it executable using  "chmod +x [script name]", 
## 	then run the script by using "run_script [script name]"
## 	suggested paramenters are below to submit this script.
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
MyID=aubclsf0047          ## Example: MyID=aubrmg001

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

## These samples are from Bioproject PRJNA437447. An experiment on Daphnia pulex, 5 samples on ad lib feed, 5 samples on caloric restriction diet
## https://www.ncbi.nlm.nih.gov/bioproject?LinkName=sra_bioproject&from_uid=5206312
## For class only do the 6 that you are assigned, delete the other 4 from this list

## We must run vdb-config to force creation of the default config file, otherwise we will get an error. This is a 'hack'. 

vdb-config --interactive > /dev/null 2>&1 <<EOF
q
EOF

#fastq-dump -F --split-files SRR7819731
#fastq-dump -F --split-files SRR7819736
#fastq-dump -F --split-files SRR7819741
#fastq-dump -F --split-files SRR7819742
#fastq-dump -F --split-files SRR7819752
#fastq-dump -F --split-files SRR7819755
#fastq-dump -F --split-files SRR7819756
#fastq-dump -F --split-files SRR7819758
#fastq-dump -F --split-files SRR7819760
#fastq-dump -F --split-files SRR7819765
#fastq-dump -F --split-files SRR7819768
#fastq-dump -F --split-files SRR7819780
#fastq-dump -F --split-files SRR7819787
#fastq-dump -F --split-files SRR7819790
#fastq-dump -F --split-files SRR7819796
#fastq-dump -F --split-files SRR7819797
#fastq-dump -F --split-files SRR7819801
#fastq-dump -F --split-files SRR7819803
#fastq-dump -F --split-files SRR7819807
#fastq-dump -F --split-files SRR7819812
#fastq-dump -F --split-files SRR7819813
#fastq-dump -F --split-files SRR7819830
#fastq-dump -F --split-files SRR7819831
#fastq-dump -F --split-files SRR7819834
#fastq-dump -F --split-files SRR7819836
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
#fastq-dump -F --split-files SRR7819897
#fastq-dump -F --split-files SRR7819918
#fastq-dump -F --split-files SRR7819922
#fastq-dump -F --split-files SRR7819926
#fastq-dump -F --split-files SRR7819929
#fastq-dump -F --split-files SRR7819932
#fastq-dump -F --split-files SRR7819934
#fastq-dump -F --split-files SRR7819936
#fastq-dump -F --split-files SRR7819937
#fastq-dump -F --split-files SRR7819942
#fastq-dump -F --split-files SRR7819943
#fastq-dump -F --split-files SRR7819944
#fastq-dump -F --split-files SRR7819946

##### Extra ####
## If you are downloading data from a sequencing company instead of NCBI, using wget for example, then calculate the md5sum values of all the files in the folder (./*), and read into a text file.
## then you can compare the values in this file with the ones provided by the company.
#md5sum ./* > md5sum.txt

##### Extra ####
## If you data comes with multiple R1 and R2 files per individual. You can contatenate them together using "cat" before running FASTQC
## see examples below for one file. You will probably want to use a loop to process through all the files.
#cat SRR6819014*_R1_*.fastq.gz > SRR6819014_All_R1.fastq.gz
#cat SRR6819014*_R2_*.fastq.gz > SRR6819014_All_R2.fastq.gz
