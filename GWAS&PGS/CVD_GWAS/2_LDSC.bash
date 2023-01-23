module load 2021
module load Python/2.7.18-GCCcore-10.3.0-bare

pip install --user pandas==0.17.0
pip install --user numpy==1.16.0
pip install --user scipy
pip install --user bitarray

cd /gpfs/work4/0/geighei/projects/UKB_GWAS/CVD/OUTPUT


# Munge Data (1 Sibling)

python /gpfs/work4/0/geighei/tools/ldsc/munge_sumstats.py -h

cut -f2,3,4,5,6,7,9,10,11,13,14 CLEANED.ukb_CVD_fastgwa_mlm_onesib_resid.fastGWA > CLEANED.ukb_CVD_fastgwa_mlm_onesib_resid.fastGWA_lesscolumns

python /gpfs/work4/0/geighei/tools/ldsc/munge_sumstats.py --sumstats CLEANED.ukb_CVD_fastgwa_mlm_onesib_resid.fastGWA_lesscolumns --out CLEANED.ukb_CVD_fastgwa_mlm_onesib_resid_munged --merge-alleles /gpfs/work4/0/geighei/tools/ldsc/w_hm3.snplist

#Rename file: remove .gz part in filename (file is not gzipped for some reason)

python /gpfs/work4/0/geighei/tools/ldsc/ldsc.py --h2 CLEANED.ukb_CVD_fastgwa_mlm_onesib_resid_munged.sumstats --ref-ld-chr /gpfs/work4/0/geighei/tools/ldsc/eur_w_ld_chr/ --w-ld-chr /gpfs/work4/0/geighei/tools/ldsc/eur_w_ld_chr/ --out CVD_h2




