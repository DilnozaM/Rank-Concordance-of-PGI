
clear all
capture log close
set more off

* PREPARING THE UKB PHENOTYPE FILE 
* Dilnoza Muslimova, March 2020
* Last edited with new key and qc file (sample_0): June 16, 2020
* Updated with new EA 

********************************************************************************
*** PHENOTYPE 
********************************************************************************

* Change to the relevant paths 

* Loading full phenotype data 
use "path\Analysis\Input\ExtractedData.dta"
merge 1:1 ID using "path\Analysis\Input\w41382_20210201_withdrew_consent.dta", gen(consent)
drop if consent>1
merge 1:1 ID using "path\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(consent2)
drop if consent2>1
*merge 1:1 ID using "C:\Users\68484dmu\OneDrive - Erasmus University Rotterdam\Desktop\Projects\NHS & Genes\Data\UKB\ExtractedData.dta", gen(EA) keepusing(c_quals_*)
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

* Keep only relevant variables 
keep ID EA_new sex
* What do we do with non-europeans? also assign -8 for education?

* Merging with the relatedness file 
merge 1:1 ID using "path\Siblings\Output\Relatedness_to_siblings_UKB.dta"


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

* Replacing the phenotype data with missings for ALL siblings and their relatives (relationship>0)
drop if relationship>0 & relationship!=.
* (56,450 real changes made)

* Recoding the phenotype for the list with bad qc: see do-file do_file_select_sample_qc.do 
merge 1:1 ID using "path\Analysis\Input\list_samples_qc_UKBB_v2.dta", generate(_merge1)

/*
     Result                           # of obs.
    -----------------------------------------
    not matched                       395,766
        from master                   392,764  (_merge1==1)
        from using                      3,002  (_merge1==2)

    matched                            53,294  (_merge1==3)
    -----------------------------------------

*/

* Recoding the phenotype of bad qc indiv as -9
drop if _merge1==3
*(53,294 real changes made) not all with bad qc have info on education 

inspect EA_new
drop if _merge1==2
drop if EA_new==.
* (6,347 observations deleted)- those with bad qc but not present in the core Extracted Data file 
inspect EA_new

* family id is missing for all non-siblings
*replace famid = ID if famid ==.

keep ID EA_new 

* Saving the data in txt file 
*export delimited ID ID EA using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Output\UKB_EA_pheno_qc_nosibrels.txt", delimiter(tab) replace novarnames

* Saving the dta file 
save "path\Analysis\Output\UKB_EA_new_pheno_qc_nosibrels.dta", replace 

********************************************************************************
*** RESIDUALIZED PHENOTYPE 
********************************************************************************
*** Start here with the split sample scores for gwas 
clear all 
use "path\Analysis\Input\quality_control_stata_v2.dta", clear
*rename id_norface ID 

/* Check if the right qc file, should start with sample_0
 ID	id_ukb
3091360	sample_0
2546549	sample_1
*/

* Remove those who recently withdrew consent
merge 1:1 ID using "path\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(_mergeconsent)
drop if _mergeconsent>1
* remove 98 individuals
merge 1:1 ID using "path\Analysis\Input\w41382_20200820_withdrew_consent.dta", gen(consent2)
drop if consent2>1


merge 1:1 ID using "path\Analysis\Input\PGSs_PCs_Ancestry.dta", gen(_mergePC)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                        15,380
        from master                        73  (_mergePC==1)
        from using                     15,307  (_mergePC==2)

    matched                           487,289  (_mergePC==3)
    -----------------------------------------

*/

merge 1:1 ID using "path\Analysis\Output\UKB_EA_new_pheno_qc_nosibrels.dta", gen(_mergeEA)
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       113,250
        from master                   113,250  (_mergeEA==1)
        from using                          0  (_mergeEA==2)

    matched                           389,419  (_mergeEA==3)
    -----------------------------------------
*/

* Cleaning of all the values creating errors in the gcta 
keep if _mergeEA==3
*(113,250 observations deleted)
keep if ID>0
* 0 deleted 
keep if e_PC_1!=.
* 0 deleted
drop if sex==0
* 0 deleted
keep if EA_new!=-9
* 0 deleted
tab batch, gen(batch_)
inspect EA_new
drop if EA_new==.
*2 observations dropped
count 
*389,419

* Creating the residualized covariate file 
reg EA_new i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40
predict EA_resid_new, residuals 
inspect EA_resid_new
drop if EA_resid_new==.
* (0 observations deleted) 

export delimited ID ID EA_resid_new using "path\Analysis\Output\UKB_EA_resid_new_pheno_qc_nosibrels.txt", delimiter(tab) replace novarnames


********************************************************************************
********************** FEMALE HOLDOUT SAMPLE PHENOTYPES ************************
********************************************************************************

gen id_norface = ID
merge 1:1 id_norface using "path\Analysis\Input\complete_sample_qc_info_ukb_v2.dta", gen(_sex)
keep if _sex == 3

corr sex submittedgender inferredgender

********************************************************************************
************************* SPLIT SAMPLE PHENOTYPES ******************************
********************************************************************************

* Remove parent-child dyads 
* Pick one individual randomly from relid id to be included in the gwas 

* Merge again for relationship identifiers 
merge 1:1 ID using "path\Siblings\Output\Relatedness_to_siblings_UKB.dta", nogen
drop if EA_new==.
count 
* before the cleaning:   389,419 individs
* dropping the parent-child pairs 
tab PC
drop if PC==1 
* dropped 5,084
count 
* 384,335

* Select one cousin from the cousin cluster uniquely identified by relid 
egen N_relid=count(relid) if relid!=., by(relid)
tab N_relid if relid!=.
set seed 543
by relid, sort: gen random = runiform(0,1)
sort relid random
by relid, sort: gen draft = _n
br relid ID random draft N_relid 
tab draft if relid!=.
count if draft!=1 & relid!=.
drop if draft!=1 & relid!=.
*(44,326 observations deleted)
count 
inspect EA_new
* 340,009

reg EA_new i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40
keep if e(sample)
*(0 observations deleted)

* Split the sample randomly in two and residualize 
splitsample, generate(svar) values(0 1) rseed(543)

reg EA_new i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40 if svar==1
predict EA_resid_new_1 if svar==1, residuals 
replace EA_resid_new_1=-9 if EA_resid_new_1==.
inspect EA_resid_new_1
sum EA_resid_new_1 if EA_resid_new_1!=-9
* 170,004

reg EA_new i.YoB sex i.YoB#i.sex batch_1-batch_106 e_PC_1-e_PC_40 if svar==0
predict EA_resid_new_0 if svar==0, residuals 
replace EA_resid_new_0=-9 if EA_resid_new_0==.
inspect EA_resid_new_0
sum EA_resid_new_0 if EA_resid_new_0!=-9
* 170,005 


* Saving the data in txt file 
*export delimited ID ID EA_resid using "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\Birth rank & Genes\Analysis\Output\UKB_EA_resid_pheno_nosibrels.txt", delimiter(tab) replace novarnames

* Saving the dta file 
save "path\Analysis\Output\UKB_EA_new_resid_pheno_nosibrels_with_splitsample.dta", replace 

use "path\Analysis\Output\UKB_EA_new_resid_pheno_nosibrels_with_splitsample.dta", clear
* Saving the splitsample 
inspect EA_resid_new_0
keep if EA_resid_new_0!=-9
*(170,004 observations deleted)
count
*170,005
sum EA_resid_new_0

export delimited ID ID EA_resid_new_0 using "path\Analysis\Output\UKB_EA_new_resid_pheno_nosibrels_nopc_norel_0.txt", delimiter(tab) replace novarnames

 
use "path\Analysis\Output\UKB_EA_new_resid_pheno_nosibrels_with_splitsample.dta", clear
inspect EA_resid_new_1
keep if EA_resid_new_1!=-9
*(171,265 observations deleted)
*(196,391 observations deleted) - before the exclusion of cousins and parent child parents 
count
* 171,264
sum EA_resid_new_1
export delimited ID ID EA_resid_new_1 using "path\Analysis\Output\UKB_EA_new_resid_pheno_nosibrels_nopc_norel_1.txt", delimiter(tab) replace novarnames



* GWAS covariates should be i.birthyear, sex, i.birthyear*sex, i.Batch, pc1-40
* qcovar file should contain all continuous variables
* covar file should contain all categorical variables with max 5 levels
