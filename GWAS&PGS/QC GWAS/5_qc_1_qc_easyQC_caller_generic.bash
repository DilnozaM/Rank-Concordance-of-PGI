#!/bin/bash
#SBATCH -t 01:00:00
#SBATCH -p short
###########################################################################
echo "Script started:"
date
echo
###########################################################################
# define positional parameters ############################################
###########################################################################

cohort=$1 # eg AS264
pheno=$2 # eg CARB
file=$3 # file name (just the file name, not a full path)
standdev=$4
corrfac=1.4 # set corrfac to fixed value

path=/projects/0/geighei/projects
input=/lustre5/0/geighei/projects/UKB_QC/INPUT/${file}
NOW=$(date +"%m%d%Y")



echo
echo "1st pos par ${1} (cohort)"
echo "2nd pos par ${2} (phenotype)"
echo "3rd pos par ${3} (input file name)"
echo "4th pos par ${4} (standard deviation ${pheno})"


echo "full path to input file is ${input}/"
echo


echo "is input correctly specified?"
# http://www.dreamsyssoft.com/unix-shell-scripting/ifelse-tutorial.php #
if [ -s ${input} ]
	then
	echo "all good: input file exists, continue running"
	else
	echo "!!!!!!! WARNING: INPUT FILE DOES NOT EXIST / HAS BROKEN PATH !!!!!!!!"
	echo "terminate script"
	exit
fi

echo
echo
echo
###########################################################################
# Create cohort-specific EasyQC script         ############################
###########################################################################
echo
cd ${path}/UKB_QC/OUTPUT/

module load 2019
module load R
echo
echo "first modify easyqc script for ${cohort}, input file ${input}, pheno ${pheno}"

cohortpheno=${cohort}_${pheno}
outputpath="/projects/0/geighei/projects/UKB_QC/OUTPUT/${cohort}/${pheno}"

#integrate standdev from R file (future)
#standdev=$(cat /lustre5/0/geighei/projects/UKB_QC/INPUT/${cohort}_${pheno}_standdev.txt )


echo "create output directories (if necessary)"
if [ -d ${outputpath} ]
then
	echo "output directory ${outputpath} already exists"
	echo
else
	echo "make umbrella directory ${outputpath}"
	mkdir /projects/0/geighei/projects/UKB_QC/OUTPUT/${cohort}/${pheno}
	echo
fi



awk -v var="$input" '{gsub ("FILEINHERE", var ); print}' ${path}/UKB_QC/CODE/2_qc_easyqc_${cohort}.ecf | awk -v var="$cohort" '{gsub ("COHORT", var ); print}' | \
awk -v var="$pheno" '{gsub ("PHENO",var ); print }' | awk -v var="$outputpath" '{gsub ("OUTPATH",var ); print }' | \
awk -v var="$corrfac" '{gsub ("CORRFAC",var ); print }' | \
awk -v var="$standdev" '{gsub ("STANDDEV",var ); print }' \
> ${path}/UKB_QC/CODE/3_qc_easyqc_${cohort}_${pheno}_${NOW}.ecf

echo
easyqcscript=${path}/UKB_QC/CODE/3_qc_easyqc_${cohort}_${pheno}_${NOW}.ecf
echo "created easyqcscript ${easyqcscript}"
echo
###########################################################################
# Call easyqc script           ############################################
###########################################################################
echo "start R (easyQC)"
xvfb-run R --no-save --slave --args ${path}/UKB_QC/OUTPUT/${cohort} ${easyqcscript} << EOF
argv = commandArgs(trailingOnly=TRUE)
argv
working.dir <- argv[1]
working.dir
setwd(file.path(working.dir))
print("getwd")
getwd()
print("")
easyqcscript <- argv[2]
library(EasyQC)
EasyQC(easyqcscript)
EOF
echo
echo
echo "performed QC for ${cohort}"
echo "Script finished:"
date

