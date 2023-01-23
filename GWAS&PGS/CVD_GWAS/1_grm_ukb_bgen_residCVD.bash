#!/bin/bash
#SBATCH -t 12:00:00

echo Script started at:
date
echo

# from https://cnsgenomics.com/software/gcta/#fastGWA

# make "mbgen" file -- list of input chromosome files
cd /projects/0/geighei/projects/UKB_GWAS/CVD/INPUT

# file created with...
dos2unix UKB_relationship.txt

#Update the file here 
dos2unix UKB_IHDicd_resid_phenotype_excl_sibs_sibrels.txt


# match sp grm 

for i in {1..22}
do
echo /lustre5/0/geighei/data/UKB/imp/ukb_imp_chr${i}_v3.bgen
done > ukb_imp_allchr_v3_bgen.list

cd /projects/0/geighei/projects/UKB_GWAS/CVD/OUTPUT

# sparse GRM made with R script (script 0)
# Do fastgwa GWAS MLM!

/lustre5/0/geighei/tools/gcta_1.93.0beta/gcta64 \
	--mbgen /lustre5/0/geighei/projects/UKB_GWAS/CVD/INPUT/ukb_imp_allchr_v3_bgen.list \
	--pheno /lustre5/0/geighei/projects/UKB_GWAS/CVD/INPUT/UKB_IHDicd_resid_phenotype_excl_sibs_sibrels.txt \
	--grm-sparse /lustre5/0/geighei/projects/UKB_GWAS/CVD/OUTPUT/ukb_imp_allchr_v3_spgrm \
	--fastGWA-mlm \
	--maf 0.001 \
	--sample /lustre5/0/geighei/data/UKB/key/ukb41382_imp_chr22_v3_s487330.sample \
	--threads 23 \
	--out ukb_CVD_fastgwa_mlm_excl_sibs_sibrels_resid



echo
echo "Script finished at:"
date