


// Ranking Project
// Rita Pereira
// Preliminary analysis

use "${Data}/PGS_ldpred_plink_EA_height_cvd_bmi_Rita.dta", clear
graph set window fontface default

//globals 

global ea_pgs  ea_new_23me_ukb_ld        ea_23me_ld             ea_new_ukb_ld ///
			   ea_new_ukb_23me_clump     ea_23me_clump          ea_new_ukb_clump ///
			   ea_new_ukb_23me_clump_gws ea_new_23me_clump_gws  ea_new_ukb_clump_gws 
         
				     
global PCs e_PC_1 e_PC_2 e_PC_3 e_PC_4 e_PC_5 e_PC_6 e_PC_7 e_PC_8 e_PC_9 e_PC_10 ///
		   e_PC_11 e_PC_12 e_PC_13 e_PC_14 e_PC_15 e_PC_16 e_PC_17 e_PC_18 e_PC_19 e_PC_20 ///
		   e_PC_21 e_PC_22 e_PC_23 e_PC_24 e_PC_25 e_PC_26 e_PC_27 e_PC_28 e_PC_29 e_PC_30 ///
		   e_PC_31 e_PC_32 e_PC_33 e_PC_34 e_PC_35 e_PC_36 e_PC_37 e_PC_38 e_PC_39 e_PC_40 
	
	
//labels 

label var ea_new_23me_ukb_ld "EA PGS 23&me + UKB ldpred"
label var ea_23me_ld "EA PGS 23&me ldpred"
label var ea_new_ukb_ld "EA PGS UKB ldpred"

label var ea_new_ukb_23me_clump "EA PGS 23&me + UKB clump"
label var ea_23me_clump "EA PGS 23&me clump"
label var ea_new_ukb_clump "EA PGS UKB clump"

label var ea_new_ukb_23me_clump_gws "EA PGS 23&me + UKB clump gws"
label var ea_new_23me_clump_gws "EA PGS 23&me clump gws"
label var ea_new_ukb_clump_gws "EA PGS UKB clump gws"



//standardize pgs and check their explained variance

foreach y of global ea_pgs {
rename `y' `y'_ns
egen `y' = std(`y'_ns) if famid!=.
sum `y'
regress EA_new `y' if famid!=. , vce(robust)
scalar r2_`y' = e(r2)
display  r2_`y'
}


//replace inverted PGS
replace ea_new_23me_clump_gws  = -ea_new_23me_clump_gws 
replace ea_new_ukb_clump_gws = -ea_new_ukb_clump_gws


//CLUSTERED STANDARD ERRORS

foreach y of global ea_pgs {
regress EA_new YoB `y' c.YoB#c.`y' ${PCs} if famid!=. , vce(cluster famid)
estimates store `y'
}

coefplot    (ea_new_23me_ukb_ld, label(23&me+UKB ldpred))           (ea_23me_ld, label(23&me ldpred)) ///
			(ea_new_ukb_ld, label(UKB ldpred))                      (ea_new_ukb_23me_clump, label(23&me+UKB clump)) ///
			(ea_23me_clump, label(23&me clump))                     (ea_new_ukb_clump, label(UKB clump)) ///
			(ea_new_ukb_23me_clump_gws, label(23&me+UKB clump gws)) (ea_new_23me_clump_gws, label(23&me clump gws)) ///
			(ea_new_ukb_clump_gws, label(UKB clump gws)) , 	   ///
			keep(c.YoB#c.ea_new_23me_ukb_ld 					 	  c.YoB#c.ea_23me_ld ///
			       c.YoB#c.ea_new_ukb_ld 						      c.YoB#c.ea_new_ukb_23me_clump ///
			       c.YoB#c.ea_23me_clump						      c.YoB#c.ea_new_ukb_clump ///
			       c.YoB#c.ea_new_ukb_23me_clump_gws				  c.YoB#c.ea_new_23me_clump_gws ///
			       c.YoB#c.ea_new_ukb_clump_gws) ///
			vertical ///
			title ("Year of Birth x EA PGS") ///
			graphregion(color(white)) ///
			coeflabels( * = "	", noticks) ///
			ylabel(-0.02(0.01)0.01) yline(0, lcolor(gs7))

			graph export "${graphs}\interaction_YOB_EAPGS_clustered.png", replace
			
			
//FAMILY FIXED EFFECTS + CLUSTERED STANDARD ERRORS


foreach y of global ea_pgs {
areg EA_new YoB `y' c.YoB#c.`y' ${PCs} if famid!=. , absorb(famid) vce(cluster famid)
estimates store `y'
}

coefplot    (ea_new_23me_ukb_ld, label(23&me+UKB ldpred))           (ea_23me_ld, label(23&me ldpred)) ///
			(ea_new_ukb_ld, label(UKB ldpred))                      (ea_new_ukb_23me_clump, label(23&me+UKB clump)) ///
			(ea_23me_clump, label(23&me clump))                     (ea_new_ukb_clump, label(UKB clump)) ///
			(ea_new_ukb_23me_clump_gws, label(23&me+UKB clump gws)) (ea_new_23me_clump_gws, label(23&me clump gws)) ///
			(ea_new_ukb_clump_gws, label(UKB clump gws)) , 	   ///
			keep(c.YoB#c.ea_new_23me_ukb_ld 					 	  c.YoB#c.ea_23me_ld ///
			       c.YoB#c.ea_new_ukb_ld 						      c.YoB#c.ea_new_ukb_23me_clump ///
			       c.YoB#c.ea_23me_clump						      c.YoB#c.ea_new_ukb_clump ///
			       c.YoB#c.ea_new_ukb_23me_clump_gws				  c.YoB#c.ea_new_23me_clump_gws ///
			       c.YoB#c.ea_new_ukb_clump_gws) ///
			vertical ///
			title ("Year of Birth x EA PGS") ///
			graphregion(color(white)) ///
			coeflabels( * = "	", noticks) ///
			ylabel(-0.02(0.01)0.01) yline(0, lcolor(gs7))

			graph export "${graphs}\interaction_YOB_EAPGS_clustered_FE.png", replace
	
	
////RANDOMLY HALF THE SIBLINGS
duplicates tag famid, gen(dup)
sort famid ID
br ID famid if dup==1

//randomly select one person of each family
sample 1, count by(famid)

foreach y of global ea_pgs {
regress EA_new YoB `y' c.YoB#c.`y' ${PCs} if famid!=. , vce(robust)
estimates store `y'
}

coefplot    (ea_new_23me_ukb_ld, label(23&me+UKB ldpred))           (ea_23me_ld, label(23&me ldpred)) ///
			(ea_new_ukb_ld, label(UKB ldpred))                      (ea_new_ukb_23me_clump, label(23&me+UKB clump)) ///
			(ea_23me_clump, label(23&me clump))                     (ea_new_ukb_clump, label(UKB clump)) ///
			(ea_new_ukb_23me_clump_gws, label(23&me+UKB clump gws)) (ea_new_23me_clump_gws, label(23&me clump gws)) ///
			(ea_new_ukb_clump_gws, label(UKB clump gws)) , 	   ///
			keep(c.YoB#c.ea_new_23me_ukb_ld 					 	  c.YoB#c.ea_23me_ld ///
			       c.YoB#c.ea_new_ukb_ld 						      c.YoB#c.ea_new_ukb_23me_clump ///
			       c.YoB#c.ea_23me_clump						      c.YoB#c.ea_new_ukb_clump ///
			       c.YoB#c.ea_new_ukb_23me_clump_gws				  c.YoB#c.ea_new_23me_clump_gws ///
			       c.YoB#c.ea_new_ukb_clump_gws) ///
			vertical ///
			title ("Year of Birth x EA PGS") ///
			graphregion(color(white)) ///
			coeflabels( * = "	", noticks) ///
			ylabel(-0.02(0.01)0.01) yline(0, lcolor(gs7))

			graph export "${graphs}\interaction_YOB_EAPGS_randomsibsample.png", replace
			
			
