clear all
capture log close
set more off

* PREPARING THE UKB PHENOTYPE FILE 
* Dilnoza Muslimova, March 2020
* Last edited with new key and qc file (sample_0): June 16, 2020
* Updated the calculation method for EA, March 2021 

********************************************************************************
*** PHENOTYPE 
********************************************************************************

* Loading full phenotype data 
use "path\Analysis\Input\ExtractedData.dta"
merge 1:1 ID using "path\Analysis\Input\w41382_20210201_withdrew_consent.dta", gen(consent)
drop if consent>1
merge 1:1 ID using "path\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(consent2)
drop if consent2>1
merge 1:1 ID using "path\Analysis\Input\original_EA.dta", gen(EA2)
keep if EA2==3


*** NEW METHOD: MAX over each wave, then replace the missings) - with distinction between -7 "None of the above" -3 "Prefer not to answer"
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
*replace EA_new = 7 if EA_new == . *this only adds 9,000 observations, and changes the mean from 14.91 to 14.70, but doesn't make the EA cleaner*

* Keep only relevant variables 
keep ID EA_new EduYears sex
* What do we do with non-europeans? also assign -8 for education?

* Merging with the relatedness file 
merge 1:1 ID using "\Siblings\Output\Relatedness_to_siblings_UKB.dta"

/*

  Result                           # of obs.
    -----------------------------------------
    not matched                       355,010
        from master                   354,990  (_merge==1)
        from using                         20  (_merge==2)

    matched                           147,498  (_merge==3)
    -----------------------------------------

	*/
	
* Relationships 
tab relationship 

/*
 relationship to a sibling, 0 - |
          unrelated to a sibling |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
         Not related to siblings |     91,068       61.73       61.73
                    full sibling |     41,502       28.13       89.87
2nd or 3rd Relative of a sibling |     10,208        6.92       96.79
       Parent/child of a sibling |      4,740        3.21      100.00
---------------------------------+-----------------------------------
                           Total |    147,518      100.00
*/

* Keeping siblings only (relationship==1)
drop if relationship!=1 
*(461,006 observations deleted)

* Recoding the phenotype for the list with bad qc: see do-file do_file_select_sample_qc.do 
merge 1:1 ID using "path\Analysis\Input\list_samples_qc_UKBB_v2.dta", generate(_merge1)

/*

 Result                           # of obs.
    -----------------------------------------
    not matched                        93,392
        from master                    39,299  (_merge1==1)
        from using                     54,093  (_merge1==2)

    matched                             2,203  (_merge1==3)
    -----------------------------------------

*/

* Recoding the phenotype of bad qc indiv as -9
drop if _merge1==3
*(2,203 observations dropped) not all with bad qc have info on education 

inspect EA_new

drop if _merge1==2
* (54,093 observations deleted)- those with bad qc but not present in the core Extracted Data file 
inspect EA_new
drop if EA_new==.
*39,026 remaining
keep ID EA_new 

* Saving the dta file 
save "path\Analysis\Output\UKB_EA_new_pheno_qc_sibs.dta", replace 

********************************************************************************
*** RESIDUALIZED PHENOTYPE 
********************************************************************************
*** Start here with the split sample scores for gwas 
clear all 
use "path\Analysis\Input\quality_control_stata_v2.dta", clear

/* Check if the right qc file, should start with sample_0
 ID	id_ukb
3091360	sample_0
2546549	sample_1

*/
* Remove those who recently withdrew consent
merge 1:1 ID using "path\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(_mergeconsent)
drop if _mergeconsent>1
* remove 98 individuals
merge 1:1 ID using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(consent2)
drop if consent2>1

merge 1:1 ID using "path\Analysis\Input\PGSs_PCs_Ancestry.dta", gen(_mergePC)
/*

 Result                           # of obs.
    -----------------------------------------
    not matched                        15,344
        from master                        73  (_mergePC==1)
        from using                     15,271  (_mergePC==2)

    matched                           487,325  (_mergePC==3)
    -----------------------------------------
*/

merge 1:1 ID using "path\Analysis\Output\UKB_EA_new_pheno_qc_sibs.dta", gen(_mergeEA)
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       463,643
        from master                   463,643  (_mergeEA==1)
        from using                          0  (_mergeEA==2)

    matched                            39,026  (_mergeEA==3)
    -----------------------------------------
*/

* Cleaning of all the values creating errors in the gcta 
keep if _mergeEA==3
*(463,643  observations deleted)
keep if ID>0
* 0 deleted 
keep if e_PC_1!=.
*(0 observations deleted)
drop if sex==0
*(0 observations deleted)
keep if EA_new!=-9
*(0 observations deleted)
tab batch, gen(batch_)
inspect EA_new
drop if EA_new==.
*2 observations dropped

/* Creating the residualized covariate file 
reg EA i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40
predict EA_resid, residuals 
inspect EA_resid
drop if EA_resid==.
* 1 observation deleted

* Keeping the relevant variables 
inspect EA
*keep ID EA_resid


* Saving the data in txt file 
export delimited ID ID EA_resid using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Output\UKB_EA_resid_pheno_siblings.txt", delimiter(tab) replace novarnames
*/

* Select one random member from the sib pair 
* add famid variable 
merge 1:1 ID using "Siblings\Output\Relatedness_to_siblings_UKB.dta", gen(_merge2)

keep if _merge2==3
egen N_famid=count(famid), by(famid)
tab N_famid
drop if N_famid==1
*(475 observations deleted)
inspect EA_new

set seed 543
by famid, sort: gen random = runiform(0,1)
sort famid random
by famid, sort: gen draft = _n

reg EA_new i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40 if EA_new!=-9 & draft==1

predict EA__new_resid_1 if draft==1, residuals 
inspect EA__new_resid_1
drop if EA__new_resid_1==.
count 
*18,723


export delimited id_ukb id_ukb using "\Analysis\Output\UKB_list_sib.txt", delimiter(tab) replace novarnames

export delimited ID ID EA__new_resid_1 using "Analysis\Output\UKB_EA_new_resid_pheno_onesib.txt", delimiter(tab) replace novarnames

* GWAS covariates should be i.birthyear, sex, i.birthyear*sex, i.Batch, pc1-40
* qcovar file should contain all continuous variables
* covar file should contain all categorical variables with max 5 levels


********************************************************************************
*** Merging the plink IDs to the UKB IDs 
********************************************************************************

clear all 
import delimited "Analysis\Input\ukb_hm3_snp_sqc_consent_allchr.fam", delimiter(space, collapse)  
* 446,339 passed QC, european, and gave consent for the data 
sum 
rename v1 plinkID
rename v2 id_ukb
keep plinkID id_ukb
save "Analysis\Input\UKB_genetic_plinkIDs_UKBIDs.dta", replace 

clear all 
import delimited "Analysis\Output\UKB_list_sib.txt"
rename v1 id_ukb
merge 1:1 id_ukb using "Analysis\Input\UKB_genetic_plinkIDs_UKBIDs.dta", gen(_plinkID)
keep if _plinkID==3
keep plinkID id_ukb
order plinkID id_ukb
sort plinkID
export delimited plinkID id_ukb using "Analysis\Output\UKB_list_sib.txt", delimiter(tab) replace novarnames
