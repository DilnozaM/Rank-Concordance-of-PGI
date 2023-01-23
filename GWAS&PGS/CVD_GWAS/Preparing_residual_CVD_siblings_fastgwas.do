clear all
capture log close
set more off

* PREPARING THE UKB PHENOTYPE FILE 
* Dilnoza Muslimova, August 2022

********************************************************************************
*** PHENOTYPE 
********************************************************************************

* Loading full phenotype data 
cd "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\"
use "Birth rank & Genes\Analysis\Input\ExtractedData.dta"


//Withdrew consent 
merge 1:1 ID using "Birth rank & Genes\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(_mergeconsent)
drop if _mergeconsent==3 // unconsented 
drop if _mergeconsent==2 // from using 
*(98 observations deleted)
drop _mergeconsent

merge 1:1 ID using "BirthControl_Pill_Genes\Analysis\Input\w41382_20210201_withdrew_consent.dta", gen(_mergeconsent1)
drop if _mergeconsent1==3 // unconsented 0 deleted
drop if _mergeconsent1==2 // from using 103 obs deleted 
drop _mergeconsent1

merge 1:1 ID using "BirthControl_Pill_Genes\Analysis\Input\w41382_20210809_withdrew_consent.dta", gen(_mergeconsent2)
drop if _mergeconsent2==3 // unconsented 29 obs deleted from master 
drop if _mergeconsent2==2 // from using 103 obs deleted 
drop _mergeconsent2

merge 1:1 ID using "BirthControl_Pill_Genes\Analysis\Input\w41382_20220222_withdrew_consent.dta", gen(_mergeconsent3)
drop if _mergeconsent3==3 // unconsented 47 deleted
drop if _mergeconsent3==2 // from using 131 deleted 
drop _mergeconsent3

count // 502,412

* CVD phenotype is constructed based on the raw data by Fleur in create_ukb_cvd_phenotype.do, can be imported from below
* gen IHD_icd = 1 if IHD_main ==1 | IHD_second ==1 | IHD9_main ==1 | IHD9_second ==1 | h_IHD_CoD ==1 | h_IHD_secCoD == 1 & h_NoInpatientData !=1
	*replace IHD_icd = 0 if IHD_icd !=1

merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Input\IHD_icd_phenotype.dta", gen(_cvd)	
keep if _cvd==3

sum IHD_icd
* Keep only relevant variables 
keep ID IHD_icd sex

* Merging with the relatedness file 
merge 1:1 ID using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\Siblings\Output\Relatedness_to_siblings_UKB.dta"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       354,972
        from master                   354,933  (_merge==1)
        from using                         39  (_merge==2)

    Matched                           147,479  (_merge==3)
    ----------------------------------------- */
	
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
keep if relationship==1 
tab relationship 

* Recoding the phenotype for the list with bad qc: see do-file do_file_select_sample_qc.do 
merge 1:1 ID using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Input\list_samples_qc_UKBB_v2.dta", generate(_merge1)

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
inspect IHD_icd
drop if _merge1==2
* (54,093 observations deleted)- those with bad qc but not present in the core Extracted Data file 
drop if IHD_icd==.
count
*39,291 remaining
keep ID IHD_icd 

* Saving the dta file 
save "GEIGHEI\projects\PGS ranking\Analysis\Output\UKB_CVD_pheno_qc_sibs.dta", replace 

********************************************************************************
*** RESIDUALIZED PHENOTYPE 
********************************************************************************
*** Start here with the split sample scores for gwas 
clear all 
use "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Input\quality_control_stata_v2.dta", clear

/* Check if the right qc file, should start with sample_0
 ID	id_ukb
3091360	sample_0
2546549	sample_1

*/

merge 1:1 ID using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Input\PGSs_PCs_Ancestry.dta", gen(_mergePC)
/*

 Result                           # of obs.
    -----------------------------------------
    not matched                        15,344
        from master                        73  (_mergePC==1)
        from using                     15,271  (_mergePC==2)

    matched                           487,325  (_mergePC==3)
    -----------------------------------------
*/

merge 1:1 ID using "GEIGHEI\projects\PGS ranking\Analysis\Output\UKB_CVD_pheno_qc_sibs.dta", gen(_mergeCVD)
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       463,378
        from master                   463,378  (_mergeCVD==1)
        from using                          0  (_mergeCVD==2)

    Matched                            39,291  (_mergeCVD==3)

*/

* Cleaning of all the values creating errors in the gcta 
keep if _mergeCVD==3
*(463,378  observations deleted)
keep if ID>0
* 0 deleted 
keep if e_PC_1!=.
*(0 observations deleted)
drop if sex==0
*(0 observations deleted)
tab batch, gen(batch_)

* Select one random member from the sib pair 
* add famid variable 
merge 1:1 ID using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\Siblings\Output\Relatedness_to_siblings_UKB.dta", gen(_merge2)

keep if _merge2==3
egen N_famid=count(famid), by(famid)
tab N_famid
drop if N_famid==1
*(237 observations deleted)
inspect IHD_icd
* 39,054 observations

set seed 543
by famid, sort: gen random = runiform(0,1)
sort famid random
by famid, sort: gen draft = _n
tab draft

reg IHD_icd i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40 if draft==1

predict cvd_resid_1 if draft==1, residuals 
inspect cvd_resid_1
drop if cvd_resid_1==.
count 
*18,965

export delimited id_ukb id_ukb using "GEIGHEI\projects\PGS ranking\Analysis\Output\UKB_list_sib.txt", delimiter(tab) replace novarnames

export delimited ID ID cvd_resid_1 using "GEIGHEI\projects\PGS ranking\Analysis\Output\UKB_cvd_resid_pheno_onesib.txt", delimiter(tab) replace novarnames

* GWAS covariates should be i.birthyear, sex, i.birthyear*sex, i.Batch, pc1-40
* qcovar file should contain all continuous variables
* covar file should contain all categorical variables with max 5 levels

