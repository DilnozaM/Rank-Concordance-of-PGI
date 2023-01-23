* Converting the PGSs files to stata format
* Dilnoza Muslimova 
* July 2020
* Last updated Jan 2023

* Add your username 

if c(username)=="68484dmu" {
	cd "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\"
}
else {
	*cd "C:\Users\Hans\Dropbox (Erasmus Universiteit Rotterdam)\"
	*cd "C:\Users\Niels\Dropbox (Erasmus Universiteit Rotterdam)\"
	*cd "C:\Users\ecsmvhkv\Dropbox\"
}


*** Rule for naming the scores: phenotype_sample_method
*** All scores with prior 1
*** Double counting 
  * Scores with discovery samples including UKB have to keep only siblings for holdout 
  * Scores which exclude UKB altogether, do not need that 
  
*** Todo: Control for QC and non-consented individuals 



*** CVD PGI
{
********************************************************************************
*** Sumstats CVD1: META CARDIOGRAM + UKB nosibrels, ldpred 
********************************************************************************

clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_meta_CVD_CARDIOGRAM_UKBnosibsrels.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen cvd_cardio_ukb_ld=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_meta_CVD_CARDIOGRAM_UKBnosibsrels.dta", replace 

********************************************************************************
*** Sumstats CVD2: CARDIOGRAM, ldpred 
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_cardiogram_CVD.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen cvd_cardio_ld=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_cardiogram_CVD.dta", replace 


********************************************************************************
*** Sumstats CVD3: UKB nosibrels, ldpred 
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_ukb_CVD_UKBnosibsrels.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen cvd_ukb_ld=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_ukb_CVD_UKBnosibsrels.dta", replace 

********************************************************************************
*** Sumstats CVD4: META CARDIOGRAM + UKB nosibrels, clump
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_cvd_meta_ukb_cardiogram_clumped.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen cvd_cardio_ukb_clump=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_cvd_meta_ukb_cardiogram_clumped.dta", replace 

********************************************************************************
*** Sumstats CVD5: CARDIOGRAM, clump
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_cvd_cardiogram_clumped.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen cvd_cardio_clump=scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_cvd_cardiogram_clumped.dta", replace 

********************************************************************************
*** Sumstats CVD6: UKB nosibrels, clump
********************************************************************************

clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_CVD_UKB_clumped.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen cvd_ukb_clump=scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_CVD_UKB_clumped.dta", replace 
}


*** EA 
{

********************************************************************************
*** Sumstats EA1: NEW UKB+23andme, LDPRED
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_meta_23andme_UKB_EA_new_nosibsrel_p1.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen ea_new_23me_ukb_ld=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_meta_23andme_UKB_EA_new_nosibsrel_p1.dta", replace 

********************************************************************************
*** Sumstats EA2: 23andme LDpred 
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_EA_23andme_p1.profile", delimiter(space, collapse) varnames(1)   
* 446,339 passed QC, european, and gave consent for the data 
sum 

* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen ea_23me_ld=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_EA_23andme_p1.dta", replace 


********************************************************************************
*** Sumstats EA3: NEW UKB LDPRED 
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_UKB_EA_new_nosibsrel_p1.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen ea_new_ukb_ld=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_UKB_EA_new_nosibsrel_p1.dta", replace 


********************************************************************************
*** Sumstats EA4: NEW UKB+23andme, Clump 
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_new_meta_23andme_ukb_nosibssibrels_clumped.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen ea_new_ukb_23me_clump=(-1)*scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_new_meta_23andme_ukb_nosibssibrels_clumped.dta", replace 

********************************************************************************
*** Sumstats EA5: 23andme, Clumped
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_23andme_clumped.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 

* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen ea_23me_clump=scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_23andme_clumped.dta", replace 


********************************************************************************
*** Sumstats EA6: NEW UKB, Clump 
********************************************************************************
clear all 
import delimited "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_new_ukb_nosibssibrels_clumped.profile", delimiter(space, collapse) varnames(1)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
* Check if the dataset starts with the correct UKB id 
* br 

* Keep relevant variables 
keep iid scoresum  
gen ea_new_ukb_clump=scoresum
drop scoresum
rename iid id_ukb

save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_new_ukb_nosibssibrels_clumped.dta", replace 
}

{
********************************************************************************
*** Merge all PGS into one set & add Norface ID 
********************************************************************************
clear all

use "GEIGHEI\projects\PGS ranking\Analysis\Input\ID_Norface_ID_UKB_key.dta"

*** CVD
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_ukb_CVD_UKBnosibsrels.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_cardiogram_CVD.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_meta_CVD_CARDIOGRAM_UKBnosibsrels.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_CVD_UKB_clumped.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_cvd_cardiogram_clumped.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_cvd_meta_ukb_cardiogram_clumped.dta", nogen


*** EA
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_meta_23andme_UKB_EA_new_nosibsrel_p1.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_EA_23andme_p1.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_UKB_EA_new_nosibsrel_p1.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_new_meta_23andme_ukb_nosibssibrels_clumped.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_23andme_clumped.dta", nogen
merge 1:1 id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_plink_EA_new_ukb_nosibssibrels_clumped.dta", nogen

}

{
*** Standardize scores within the respective holdout samples 
global pgs ea_new_23me_ukb_ld     ea_23me_ld        ea_new_ukb_ld     ///
	       ea_new_ukb_23me_clump  ea_23me_clump     ea_new_ukb_clump  ///
		   cvd_cardio_ukb_ld      cvd_cardio_ld     cvd_ukb_ld        ///
		   cvd_cardio_ukb_clump   cvd_cardio_clump  cvd_ukb_clump     ///

foreach i in $pgs {
	sum `i', detail
	sca m = r(mean)
	sca sd = r(sd)
	replace `i' = (`i' - m)/sd
	}

*** Labelling the pgs, keep an eye on the holdout sample 
label var ea_new_23me_ukb_ld "standardized EA new pgs, 23andme+UKB nosibrels, ldpred"
label var ea_23me_ld "standardized EA pgs using ldpred, 23andme sumstats based and prior=1"
label var ea_new_ukb_ld "standardized EA new pgs, UKB nosibrels, ldpred"	
label var ea_new_ukb_23me_clump "standardized EA new pgs, 23andme+UKB nosibrels, clump"	 
label var ea_23me_clump "standardized clumped EA pgs using plink, 23andme sumstats based"
label var ea_new_ukb_clump "standardized EA new pgs, UKB nosibrels, clump"	

***
label var cvd_ukb_ld "standardized cvd pgs, UKB nosibrels, ldpred"
label var cvd_cardio_ld "standardized cvd pgs, CARDIOGRAM, ldpred"
label var cvd_cardio_ukb_ld "standardized cvd pgs, CARDIOGRAM+UKB nosibrels, ldpred"
label var cvd_ukb_clump "standardized cvd pgs, UKB nosibrels, clump"
label var cvd_cardio_clump "standardized cvd pgs, CARDIOGRAM, clump"
label var cvd_cardio_ukb_clump "standardized cvd pgs, CARDIOGRAM+UKB nosibrels, clump"

}

{
********************************************************************************
*** Adding Phenotypes, PCs, and Relatedness 
********************************************************************************
* Check duplicates 
duplicates tag ID, generate(dup)
br if dup>0
drop if ID<0
drop if ID==.

merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\ExtractedData.dta", gen(_mergeExtDt)
keep if _mergeExtDt==3

// Merge with PCs
merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\PGSs_PCs_Ancestry.dta", gen(_mergePC)
keep if _mergePC==3

// Merge sibling identifiers
* Need to keep only sibs and possible their relatives to test the predictive power of the score, can't apply to everyone, will overfit 
merge 1:1 ID using "GEIGHEI\projects\Siblings\Output\Relatedness_to_siblings_UKB.dta", gen(_mergeRL)

merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\w41382_20210201_withdrew_consent.dta", gen(consent)
drop if consent>1
merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(consent2)
drop if consent2>1
merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\original_EA.dta", gen(EA2)
keep if EA2==3


*** Construct EA: MAX over each wave, then replace the missings) - with distinction between -7 "None of the above" -3 "Prefer not to answer"

sum n_6138_*
forval num = 0/5 {
gen EA_new_`num' = n_6138_0_`num'
recode EA_new_`num' -7=7 -3=. 1=20 2=13 3=10 4=10 5=19 6=15 
}
egen EA_new = rowmax(EA_new*)

forval num = 0/5 {
gen EA1_new_`num' = n_6138_1_`num'
recode EA1_new_`num' -7=7 -3=. 1=20 2=13 3=10 4=10 5=19 6=15 
}
egen EA_1_new = rowmax(EA1_new*)

forval num = 0/5 {
gen EA2_new_`num' = n_6138_2_`num'
recode EA2_new_`num' -7=7 -3=. 1=20 2=13 3=10 4=10 5=19 6=15 
}
egen EA_2_new = rowmax(EA2_new*)

replace EA_new = EA_1_new if EA_new == .
replace EA_new = EA_2_new if EA_new == .
sum EA_new

/*    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
      EA_new |    481,636    14.91878    5.115882          7         20
*/


tab relationship
	
/* 
   relationship to a sibling, 0 -|
          unrelated to a sibling |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
         Not related to siblings |     91,068       61.73       61.73
                    full sibling |     41,502       28.13       89.87
2nd or 3rd Relative of a sibling |     10,208        6.92       96.79
       Parent/child of a sibling |      4,740        3.21      100.00
---------------------------------+-----------------------------------
                           Total |    147,518      100.00
*/	


merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\IHD_icd_phenotype.dta", nogen
********************************************************************************
*** Saving the complete dataset 
********************************************************************************

keep ID    EA_new IHD_icd ///
	       ea_new_23me_ukb_ld     ea_23me_ld        ea_new_ukb_ld     ///
	       ea_new_ukb_23me_clump  ea_23me_clump     ea_new_ukb_clump  ///
		   cvd_cardio_ukb_ld      cvd_cardio_ld     cvd_ukb_ld        ///
		   cvd_cardio_ukb_clump   cvd_cardio_clump  cvd_ukb_clump     ///
           YoB MoB sex e_PC_1-e_PC_40 famid relationship 
		   
save "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_plink_EA_height_cvd_bmi_dbp.dta", replace 

}

*end of do-file
