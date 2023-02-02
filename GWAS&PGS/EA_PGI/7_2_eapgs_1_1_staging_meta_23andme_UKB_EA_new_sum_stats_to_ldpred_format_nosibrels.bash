#!/bin/bash
#SBATCH -t 03:00:00
#SBATCH -N 1
#Adapted from Rita Pereira 

echo "Change the sum stats to ldpred format"
echo "Script started"
echo "EA NEW"
date 

#change to the right directory
cd path/projects/UKB_LDpred/EA_new/CODE

#load python
module load 2019 
module load Python/3.6.6-foss-2018b 

#check if python works
python -h

#load other necessary packages 
pip install --user spicy
pip install --user plinkio
pip install --user h5py


#check if ldpred is working
echo "version 1.06"
python path/tools/ldpred/ldpred-1.0.6/LDpred.py coord --help


#Organize sum stats 
head path/projects/EA_METAL/OUTPUT/GWAS_ea_new_meta_23andme_UKB_UKBnosibsrels.txt

#1CHR    2POS            3rsid       4EFFECT_ALLELE   5OTHER_ALLELE    6EAF    7EAF_SE 8MIN_EAF   9MAX_EAF 10N             11Z     12P-value 13Direction     14HetISq  15HetChiSq    16HetDf 17HetPVal
#6       130840091       rs2326918       a                 g           0.8446  0.0016  0.8429     0.8462   754955.00       0.171   0.8641    +-                0.0       0.512         1       0.4744
#3       104998275       rs112634005     a                 c           0.9948  0.0000  0.9948     0.9948   389419.00       -0.366  0.7141    -?                0.0       0.000         0       1
#13      33786576        rs151222586     a                 g           0.9965  0.0000  0.9965     0.9965   389419.00       0.516   0.606     +?                0.0       0.000         0       1
#20      8411670         rs6039163       t                 c           0.5168  0.4969  0.0039     0.9983   754955.00       0.385   0.7003    +-                0.0       0.258         1       0.6115
#3       176666749       rs66941928      t                 c           0.7998  0.0033  0.7964     0.8029   754955.00       -0.850  0.3956    -+                0.0       0.730         1       0.393
#7       34606102        rs146253013     t                 c           0.5161  0.4949  0.0052     0.9956   754955.00       1.258   0.2082    ++                0.0       0.398         1       0.5282
#16      8600861         rs7190157       a                 c           0.5172  0.1397  0.3730     0.6525   754955.00       1.066   0.2865    ++                0.0       0.703         1       0.4018
#11      100009976       rs12364336      a                 g           0.8681  0.0004  0.8676     0.8685   754955.00       0.861   0.3893    ++                0.0       0.000         1       0.9851
#7       145771806       rs6977693       t                 c           0.8524  0.0028  0.8496     0.8551   754955.00       -0.707  0.4796    --                0.0       0.501         1       0.4791


## LDpred REQUIRES THE FOLLOWING FORMAT:
## chr     pos     ref     alt     reffrq  info    rs          pval    effalt
## chr1    1020428  C       T     0.85083  0.98732 rs6687776   0.0587  -0.014



#Checking which one is the reference allele 
# EFFECT_ALLLELE is the reference allele. 

# column separator is either a : or a tab 
#chr = $1
#pos = $2
#ref = EFFECT_ALLELE = $4
#alt = OTHER_ALLELE = $5
#reff freq = EAF = $6
#info = "NaN"
#rs = rsid = $3
#pval = $12
#effalt = 1*($11/sqrt($10*2*$6*(1-$6)))
awk -F" " 'BEGIN{OFS="\t"; print "chr", "pos", "ref", "alt", "reffrq", "info", "rs", "pval", "effalt"} 
                 {if(NR>1) {print "chr"$1, $2, $4, $5, $6, "NaN", $3, $12, 1*($11/sqrt($10*2*$6*(1-$6)))}}' OFS="\t" \
                  path/projects/EA_METAL/OUTPUT/GWAS_ea_new_meta_23andme_UKB_UKBnosibsrels.txt > path/projects/UKB_LDpred/EA_new/INPUT/EA_new_meta_23andme_UKB_sanssibsplusrels_fastgwa_ldpred_format.txt


#Formula for beta=z-score/sqrt(N*2*MAF*(1-MAF))

echo "head sum stats"
head path/projects/UKB_LDpred/EA_new/INPUT/EA_new_meta_23andme_UKB_sanssibsplusrels_fastgwa_ldpred_format.txt
#chr	pos	        ref	alt	reffrq	info	rs	        pval	effalt
#chr6	130840091	a	g	0.8446	NaN	rs2326918	0.8641	0.000384122
#chr3	104998275	a	c	0.9948	NaN	rs112634005	0.7141	-0.00576618
#chr13	33786576	a	g	0.9965	NaN	rs151222586	0.606	0.00990042
#chr20	8411670 	t	c	0.5168	NaN	rs6039163	0.7003	0.00062699
#chr3	176666749	t	c	0.7998	NaN	rs66941928	0.3956	-0.0017287
#chr7	34606102	t	c	0.5161	NaN	rs146253013	0.2082	0.00204862
#chr16	8600861	        a	c	0.5172	NaN	rs7190157	0.2865	0.00173608
#chr11	100009976	a	g	0.8681	NaN	rs12364336	0.3893	0.00207072
#chr7	145771806	t	c	0.8524	NaN	rs6977693	0.4796	-0.00162211

echo "tail sum stats"
tail path/projects/UKB_LDpred/EA_new/INPUT/EA_new_meta_23andme_UKB_sanssibsplusrels_fastgwa_ldpred_format.txt	  
#chr7	107988681	a	t	0.5143	NaN	rs117878361	0.1439	0.00237893
#chr15	50176748	a	g	0.9911	NaN	rs569284138	0.9739	-0.000398141
#chr5	37232736	a	c	0.5155	NaN	rs113147370	0.7278	-0.000566686
#chr10	45000528	a	g	0.9962	NaN	rs61857792	0.06529	0.0339419
#chr15	62030949	t	c	0.5079	NaN	rs2414744	0.3678	0.00146667
#chr20	33400913	t	g	0.5096	NaN	rs7262834	0.0003305	0.00584425
#chr1	84241498	t	c	0.8496	NaN	rs4140461	0.9346	0.000186684
#chr12	44074208	t	c	0.9365	NaN	rs117241566	0.8383	0.000680791
#chr6	133446510	t	c	0.5161	NaN	rs6923351	0.2697	0.00179783
#chr9	33326563	c	g	0.5120	NaN	rs35315823	0.1095	0.00260495

echo "Script finished"
date
echo
