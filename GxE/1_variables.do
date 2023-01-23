

// Ranking Project
// Rita Pereira
// Preliminary analysis

use "${Data}/PGS_ldpred_plink_EA_height_cvd_bmi.dta", clear

global ea_pgs  ea_new_23me_ukb_ld        ea_23me_ld             ea_new_ukb_ld ///
			   ea_new_ukb_23me_clump     ea_23me_clump          ea_new_ukb_clump ///
			   ea_new_ukb_23me_clump_gws ea_new_23me_clump_gws  ea_new_ukb_clump_gws 

				     
global PCs e_PC_1 e_PC_2 e_PC_3 e_PC_4 e_PC_5 e_PC_6 e_PC_7 e_PC_8 e_PC_9 e_PC_10 ///
		   e_PC_11 e_PC_12 e_PC_13 e_PC_14 e_PC_15 e_PC_16 e_PC_17 e_PC_18 e_PC_19 e_PC_20 ///
		   e_PC_21 e_PC_22 e_PC_23 e_PC_24 e_PC_25 e_PC_26 e_PC_27 e_PC_28 e_PC_29 e_PC_30 ///
		   e_PC_31 e_PC_32 e_PC_33 e_PC_34 e_PC_35 e_PC_36 e_PC_37 e_PC_38 e_PC_39 e_PC_40 

		   
//checking number of observations
sum YoB

forval x = 1934 (1) 1971 {
display `x'
count if famid!=. & YoB==`x'
}
//lets pick YoB with at least 500 siblings, 1939 to 1966

keep if YoB >=1939 & YoB <=1966
sum YoB

save "${Data}/PGS_ldpred_plink_EA_height_cvd_bmi_Rita.dta", replace
