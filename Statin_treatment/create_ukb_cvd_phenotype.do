clear all
set maxvar 100000

use "path/UKB/Norface/ukb23283.dta"

merge 1:1 n_eid using "path/UKB/Norface/ukb41222.dta", nogen
merge 1:1 n_eid using "path/UKB/Norface/ukb42349.dta", nogen


	
	rename 	n_2316_*_0 h_wheezing_*
	rename 	n_2335_*_0 h_chestpain_*
	
	recode 	h_wheezing_* h_chestpain_* (-3 -1=.)
	
	* AMI, angina, stroke, hypertension (has a doctor ever told you that you have had any of the following conditions?)
	
	foreach i in AMI angina stroke hypert {
		gen 	h_`i'_0 = 0 if inlist(n_6150_0_0,-7,1,2,3,4)
		gen		h_`i'_1 = 0 if inlist(n_6150_1_0,-7,1,2,3,4)
		gen 	h_`i'_2 = 0 if inlist(n_6150_2_0,-7,1,2,3,4)
	}
	foreach i in n_6150_0_0 n_6150_0_1 n_6150_0_2 n_6150_0_3 {
		replace h_AMI_0    = 1 if `i'==1
		replace h_angina_0 = 1 if `i'==2
		replace h_stroke_0 = 1 if `i'==3
		replace h_hypert_0 = 1 if `i'==4
	}
	foreach i in n_6150_1_0 n_6150_1_1 n_6150_1_2 n_6150_1_3 {
		replace h_AMI_1    = 1 if `i'==1
		replace h_angina_1 = 1 if `i'==2
		replace h_stroke_1 = 1 if `i'==3
		replace h_hypert_1 = 1 if `i'==4
	}
	foreach i in n_6150_2_0 n_6150_2_1 n_6150_2_2 n_6150_2_3 {
		replace h_AMI_2    = 1 if `i'==1
		replace h_angina_2 = 1 if `i'==2
		replace h_stroke_2 = 1 if `i'==3
		replace h_hypert_2 = 1 if `i'==4
	}
	
	
	* data coding https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=19
	* Data-Field 41202
	* Description:	Diagnoses - main ICD10
	* Inpatient hospitalisation records
	* Codes I20-I25 are Ischemic heart diseases
	
	gen		IHD_main = 1 if inlist(s_41202_0_0, "I20","I200","I201","I208","I209","I21","I210","I211","I212")
		replace	IHD_main = 1 if inlist(s_41202_0_0, "I213","I214","I219","I21X","I22","I220","I221","I228","I229")
		replace	IHD_main = 1 if inlist(s_41202_0_0, "I23","I230","I231","I232","I233","I234","I235","I236","I238")
		replace	IHD_main = 1 if inlist(s_41202_0_0, "I24","I240","I241","I248","I249","I25","I250","I251","I252")
		replace	IHD_main = 1 if inlist(s_41202_0_0, "I253","I254","I255","I256","I258","I259")
	
	
	forval num = 1/379 {
		replace IHD_main = 1 if inlist(s_41202_0_`num', "I20","I200","I201","I208","I209","I21","I210","I211","I212")
		replace	IHD_main = 1 if inlist(s_41202_0_`num', "I213","I214","I219","I21X","I22","I220","I221","I228","I229")
		replace	IHD_main = 1 if inlist(s_41202_0_`num', "I23","I230","I231","I232","I233","I234","I235","I236","I238")
		replace	IHD_main = 1 if inlist(s_41202_0_`num', "I24","I240","I241","I248","I249","I25","I250","I251","I252")
		replace	IHD_main = 1 if inlist(s_41202_0_`num', "I253","I254","I255","I256","I258","I259")
	}
	
	tab IHD_main
	
	* data coding https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=19
	* Data-Field 41204
	* Description:	Diagnoses - secondary ICD10
	* Inpatient hospitalisation records
	* Codes I20-I25 are Ischemic heart diseases
	
	gen		IHD_second = 1 if inlist(s_41204_0_0, "I20","I200","I201","I208","I209","I21","I210","I211","I212")
		replace	IHD_second = 1 if inlist(s_41204_0_0, "I213","I214","I219","I21X","I22","I220","I221","I228","I229")
		replace	IHD_second = 1 if inlist(s_41204_0_0, "I23","I230","I231","I232","I233","I234","I235","I236","I238")
		replace	IHD_second = 1 if inlist(s_41204_0_0, "I24","I240","I241","I248","I249","I25","I250","I251","I252")
		replace	IHD_second = 1 if inlist(s_41204_0_0, "I253","I254","I255","I256","I258","I259")
	
	
		forval num = 1/379 {
			replace IHD_second = 1 if inlist(s_41204_0_`num', "I20","I200","I201","I208","I209","I21","I210","I211","I212")
			replace	IHD_second = 1 if inlist(s_41204_0_`num', "I213","I214","I219","I21X","I22","I220","I221","I228","I229")
			replace	IHD_second = 1 if inlist(s_41204_0_`num', "I23","I230","I231","I232","I233","I234","I235","I236","I238")
			replace	IHD_second = 1 if inlist(s_41204_0_`num', "I24","I240","I241","I248","I249","I25","I250","I251","I252")
			replace	IHD_second = 1 if inlist(s_41204_0_`num', "I253","I254","I255","I256","I258","I259")
		}
	
	* Some hospitals only have ICD9 codes, make sure those are included
	* Online: Data-Field 41271
	* Description:	Diagnoses - ICD9
	* 410-414 Ischemic heart disease: 4109 4119 4129 4139 4140 4141 4148 4149
	
	* Main s_41203_0_0-s_41203_0_27
	
		gen		IHD9_main = 1 if inlist(s_41203_0_0, "4109","4119","4129","4139","4140","4141","4148","4149")	
	
			forval num = 1/27 {
				replace IHD9_main = 1 if inlist(s_41203_0_`num', "4109","4119","4129","4139","4140","4141","4148","4149")

				}
	
	* Secondary s_41205_0_0-s_41205_0_29
	
			gen		IHD9_second = 1 if inlist(s_41205_0_0, "4109","4119","4129","4139","4140","4141","4148","4149")	
	
			forval num = 1/29 {
				replace IHD9_second = 1 if inlist(s_41205_0_`num', "4109","4119","4129","4139","4140","4141","4148","4149")

				}


	
		***************************************************************************
		*****		The following code is from Alice Carter 		***
		*****	      From cause of death data & inpatient records		***
		***************************************************************************
		*** Create Cause of Death Variables (ICD10), focusing on CVD
		* Primary Cause of Death
		rename  s_40001_0_0 h_CoD1
		rename  s_40001_1_0 h_CoD2
		*drop 	s_40001_2_0
		
		* Secondary Cause of Death
		foreach var of varlist s_40002* {
			rename `var' h_sec_CoD_`var'
		}	

		* Destring
		foreach var of varlist h_CoD1 h_CoD2 h_sec_CoD* {
			replace `var' = "." if `var' == ""
		}

		* Generate new CoD/AoD/DoD where each is set to missing if second instance doesn't match first 
		count if h_CoD1 != h_CoD2 & h_CoD2 != "."
		gen h_CoD = h_CoD1
		replace h_CoD = "." if h_CoD1 != h_CoD2 & h_CoD2 != "."
		drop h_CoD1 h_CoD2

		* Define dead versus alive
		generate h_death = 1 if h_CoD != "."
		replace h_death  = 0 if h_CoD == "."
		label define yesno 0 "No" 1 "Yes"
		label values h_death  yesno
		tab h_death , missing
		tab h_death , nol missing


		** MAIN/PRIMARY CoD
		* generate CHD, stroke and AMI main CoD variables
		gen 	h_STR_CoD = 0
		lab 	var h_STR_CoD "Primary CoD - Stroke"
		gen 	h_AMI_CoD = 0
		lab 	var h_AMI_CoD "Primary CoD - AMI"
		gen 	h_IHD_CoD = 0
		lab 	var h_IHD_CoD "Primary CoD - IHD"
		gen 	h_CVD_CoD = 0
		lab 	var h_CVD_CoD "Primary CoD - CVD"

		foreach cause of varlist h_CoD {
			* Capture ICD codes relating to IHD (ICDI20-I25)
			generate IHD_code_`cause' = strpos(`cause', "I20") > 0 
			replace  IHD_code_`cause' = strpos(`cause', "I21") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I22") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I23") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I24") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I25") > 0 if IHD_code_`cause' == 0

			* Capture ICD codes relating to stroke (ICDI60-69, ICDG45*)
			generate STR_code_`cause' = strpos(`cause', "I6")  > 0 
			replace  STR_code_`cause' = strpos(`cause', "G45") > 0 if STR_code_`cause' == 0

			* Capture ICD codes relating to CVD (ICDI*)
			generate CVD_code_`cause' = strpos(`cause', "I")   > 0 
			replace  CVD_code_`cause' = strpos(`cause', "G45") > 0 if CVD_code_`cause' == 0

			* Capture ICD codes relating to AMI (ICDI21* & ICDI22*)	
			generate AMI_code_`cause' = strpos(`cause', "I21") > 0 
			replace  AMI_code_`cause' = strpos(`cause', "I22") > 0 if AMI_code_`cause' == 0

			* Update case status
			replace h_STR_CoD = 1 if STR_code_`cause' == 1 
			replace h_AMI_CoD = 1 if AMI_code_`cause' == 1
			replace h_IHD_CoD = 1 if IHD_code_`cause' == 1
			replace h_CVD_CoD = 1 if CVD_code_`cause' == 1 
		}
		label values h_*_CoD yesno

		drop IHD_code_*
		drop STR_code_*
		drop CVD_code_*
		drop AMI_code_*



		** Generate a cause of death variable
		generate h_mortality_main_reason = .
		replace  h_mortality_main_reason = 0 if h_death == 1 
		replace  h_mortality_main_reason = 1 if h_CVD_CoD == 1
		replace  h_mortality_main_reason = 2 if h_IHD_CoD == 1
		replace  h_mortality_main_reason = 3 if h_STR_CoD == 1
		replace  h_mortality_main_reason = 4 if h_AMI_CoD == 1
		replace  h_mortality_main_reason = 5 if h_death == 1 & h_CoD == "."

		label define cause 0 "Non-CVD cause" 1 "Other CVD (not IHD, stroke, AMI)" 2 "Ischaemic heart disease" 3 "Stroke" 4 "AMI" 5 "Unknown cause" 
		label values h_mortality_main_reason cause

		tab h_mortality_main_reason, missing
		foreach var of varlist h_*_CoD {
			tab h_mortality_main_reason `var' , missing
		}

		** SECONDARY CoD
		* generate CHD, stroke and AMI secondary CoD variables
		gen	h_STR_secCoD = 0
		lab 	var h_STR_secCoD "Secondary CoD - Stroke"
		gen	h_AMI_secCoD = 0
		lab 	var h_AMI_secCoD "Secondary CoD - AMI"
		gen	h_IHD_secCoD = 0
		lab 	var h_IHD_secCoD "Secondary CoD - IHD"
		gen	h_CVD_secCoD = 0
		lab 	var h_CVD_secCoD "Secondary CoD - CVD"
		gen	h_secCoD_missing = .

		label values h_secCoD_missing yesno
		replace h_secCoD_missing = 1 if h_death == 1

		foreach cause of varlist h_sec_CoD_s* {
			* Capture ICD codes relating to IHD (ICDI20-I25)
			generate IHD_code_`cause' = strpos(`cause', "I20") > 0 
			replace  IHD_code_`cause' = strpos(`cause', "I21") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I22") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I23") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I24") > 0 if IHD_code_`cause' == 0
			replace  IHD_code_`cause' = strpos(`cause', "I25") > 0 if IHD_code_`cause' == 0

			* Capture ICD codes relating to stroke (ICDI60-69, ICDG45*)
			generate STR_code_`cause' = strpos(`cause', "I6") > 0 
			replace  STR_code_`cause' = strpos(`cause', "G45") > 0 if STR_code_`cause' == 0

			* Capture ICD codes relating to CVD (ICDI*)
			generate CVD_code_`cause' = strpos(`cause', "I") > 0 
			replace  CVD_code_`cause' = strpos(`cause', "G45") > 0 if CVD_code_`cause' == 0

			* Capture ICD codes relating to AMI (ICDI21*)	
			generate AMI_code_`cause' = strpos(`cause', "I21") > 0 
			replace  AMI_code_`cause' = strpos(`cause', "I22") > 0 if AMI_code_`cause' == 0

			* Update case status
			replace  h_STR_secCoD = 1 if STR_code_`cause' == 1
			replace  h_AMI_secCoD = 1 if AMI_code_`cause' == 1
			replace  h_IHD_secCoD = 1 if IHD_code_`cause' == 1
			replace  h_CVD_secCoD = 1 if CVD_code_`cause' == 1

			replace  h_secCoD_missing = 0 if `cause' != "."
			count 	 if h_death == 0 & `cause' != "."
		}
		label values h_*_secCoD yesno

		drop IHD_code_*
		drop STR_code_*
		drop CVD_code_*
		drop AMI_code_*

	
	
	
	foreach var in AMI angina {
		gen h_`var' = 1 if h_`var'_0 == 1 | h_`var'_1 == 1 | h_`var'_2 == 1 
		replace h_`var' = 0 if (h_`var'_0 == 0 | h_`var'_1 == 0 | h_`var'_2 == 0) & h_AMI !=1
	}
	
	* define zeros
	* Binary indicator for no hospital inpatient data (see email UKB 23/6/2020)
	gen 	h_NoInpatientData = cond(n_41253_0_0==. & n_41253_0_1==. & n_41253_0_2==. & n_41253_0_3==. & n_41253_0_4==.,1,0)
	label 	var h_NoInpatientData "=1 if participant has not been linked to inpatient

	
	
gen IHD =1 if IHD_main ==1 | IHD_second ==1 | IHD9_main ==1 | IHD9_second ==1 | h_AMI ==1 | h_angina == 1 | h_IHD_CoD ==1 | h_IHD_secCoD == 1 & h_NoInpatientData !=1
	replace IHD = 0 if h_NoInpatientData !=1 & IHD !=1
	replace IHD = 0 if h_AMI == 0 & h_angina == 0 & IHD ==.

	
	
****************************************************************************************
* ADD OPERATIONS (INOUYE)
* # of operations https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=136
* Operation code https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20004
* Operation age https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20011
* wave 1: 31 codes
* wave 2: 14 codes
* wave 3: 10
* data coding https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=5
* OPCS-4 K40to K46,K49,K50.1,or K75.
* 1095	coronary artery bypass grafts (cabg)
* 1070	coronary angioplasty (ptca) +/- stent
* 1523 triple heart bypass





	
****************************************************************************************
****************************************************************************************
****************************************************************************************
	
* Create GWAS phenotype based on inpatient/death records ONLY, incl. angina (Soft CAD)
* Everyone w/o inpatient data is coded as 0, as inpatient data are available for most
gen IHD_icd = 1 if IHD_main ==1 | IHD_second ==1 | IHD9_main ==1 | IHD9_second ==1 | h_IHD_CoD ==1 | h_IHD_secCoD == 1 & h_NoInpatientData !=1
	replace IHD_icd = 0 if IHD_icd !=1

tab IHD_icd

keep IHD* h_* n_eid

rename n_eid ID
save "C:/Users/Fleur/Documents/UKB/Norface/IHD_icd_phenotype.dta", replace
	
****************************************************************************************
****************************************************************************************
****************************************************************************************

use  "path/Analysis/Input/quality_control_stata_v2.dta", clear
merge 1:1 ID using "path/Analysis/Input/quality_control_stata_v2.dta", gen(_merge4)


merge 1:1 ID using "path/UKB/Norface/IHD_icd_phenotype.dta", nogen
merge 1:1 ID using "path/Siblings/Output/Relatedness_to_siblings_UKB.dta", gen(_merge3)
merge 1:1 ID using "path/Analysis/Input/PGSs_PCs_Ancestry.dta", generate(_merge2)
keep if _merge2 == 3
merge 1:1 ID using "path/Analysis/Input/list_samples_qc_UKBB_v2.dta", generate(_merge1)
drop if _merge1 == 3


* Replacing the phenotype data with missings for ALL siblings and their relatives (relationship>0)
gen missing = 0
replace missing=1 if relationship>0 & relationship!=.
replace missing=1 if IHD_icd ==. 
keep if ID>0
keep if e_PC_1!=.
drop if sex==0
drop if missing == 1


inspect IHD_icd

tab batch, gen(batch_)


reg IHD_icd i.YoB sex i.YoB#i.sex batch_* e_PC_1-e_PC_40
predict  IHD_icd_resid, residuals 
*replace IHD_icd_resid=-9 if EA==-9
drop if  IHD_icd_resid==.

export delimited ID ID IHD_icd_resid using "path/PGS Ranking/Analysis/Input/UKB_IHDicd_resid_phenotype_excl_sibs_sibrels.txt", delimiter(tab) replace novarnames









	