
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

label var ea_new_23me_ukb_ld "EA PGS 23andme + UKB ldpred"
label var ea_23me_ld "EA PGS 23andme ldpred"
label var ea_new_ukb_ld "EA PGS UKB ldpred"

label var ea_new_ukb_23me_clump "EA PGS 23andme + UKB clump"
label var ea_23me_clump "EA PGS 23andme clump"
label var ea_new_ukb_clump "EA PGS UKB clump"

label var ea_new_ukb_23me_clump_gws "EA PGS 23andme + UKB clump gws"
label var ea_new_23me_clump_gws "EA PGS 23andme clump gws"
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


//NO GWS ordered by discovery sample

//ALL standard interaction
foreach y of global ea_pgs {
regress EA_new YoB `y' c.YoB#c.`y' ${PCs} if famid!=. , vce(robust)
estimates store `y'
}


coefplot    (ea_new_23me_ukb_ld, label(23andme+UKB (LDpred)))   (ea_new_ukb_23me_clump, label(23andme+UKB (C+T)))   ///
			(ea_23me_ld, label(23andme (LDpred))) (ea_23me_clump, label(23andme (C+T))) ///
			(ea_new_ukb_ld, label(UKB (LDpred)))  (ea_new_ukb_clump, label(UKB (C+T))) , ///
			keep(c.YoB#c.ea_new_23me_ukb_ld 					 	  c.YoB#c.ea_23me_ld ///
			       c.YoB#c.ea_new_ukb_ld 						      c.YoB#c.ea_new_ukb_23me_clump ///
			       c.YoB#c.ea_23me_clump						      c.YoB#c.ea_new_ukb_clump) /// ///
			vertical ///
			graphregion(color(white)) ///
			coeflabels( * = "	", noticks) ///
			ylabel(-0.02(0.01)0.01, format(%03.2f)) yline(0, lcolor(gs7)) saving(continuous)
			
coefplot    (ea_new_23me_ukb_ld, label(23andme+UKB (LDpred)))   (ea_new_ukb_23me_clump, label(23andme+UKB (C+T)))   ///
			(ea_23me_ld, label(23andme (LDpred))) (ea_23me_clump, label(23andme (C+T))) ///
			(ea_new_ukb_ld, label(UKB (LDpred)))  (ea_new_ukb_clump, label(UKB (C+T))) , ///
			keep(c.YoB#c.ea_new_23me_ukb_ld 					 	  c.YoB#c.ea_23me_ld ///
			       c.YoB#c.ea_new_ukb_ld 						      c.YoB#c.ea_new_ukb_23me_clump ///
			       c.YoB#c.ea_23me_clump						      c.YoB#c.ea_new_ukb_clump) /// ///
			vertical ///
			ytitle("Years of education") xtitle("EA PGI x YoB") ///
			graphregion(color(white)) ///
			coeflabels( * = "	") ///
			ylabel(-0.03(0.01)0.00, format(%03.2f)) yline(0, lcolor(gs7)) fysize(130) fxsize(80) saving(continuous_nolegend, replace) legend(off)	
			
			
			graph export "${graphs}\interaction_YOB_EAPGS_order_discovery_sample.png", replace
			
			
//NO GWS, quintiles


			foreach y of global ea_pgs {
			//gen quintile
			xtile `y'_qtl = `y' , nq(5)
			}
			
			foreach y of global ea_pgs {
			//regress and store
			regress EA_new YoB ib3.`y'_qtl c.YoB#ib3.`y'_qtl ${PCs} if famid!=. , vce(robust)
			test c.YoB#1.`y'_qtl = c.YoB#5.`y'_qtl
			scalar F_`y' = r(p)
			test c.YoB#4.`y'_qtl = c.YoB#5.`y'_qtl
			scalar FF`y' = r(p)
			test c.YoB#1.`y'_qtl = c.YoB#2.`y'_qtl
			scalar FS`y' = r(p)
			estimates store `y'_1
			}
			
			foreach y of global ea_pgs {
			//1st and 5th
			display F_`y'
			}
			
			foreach y of global ea_pgs {
			//4th and 5th
			display FF`y'
			}
			
			foreach y of global ea_pgs {
			//4th and 5th
			display FS`y'
			}
			
			
			coefplot    (ea_new_23me_ukb_ld_1, label(23andme+UKB (LDpred)))   (ea_new_ukb_23me_clump_1, label(23andme+UKB (C+T))) ///
						(ea_23me_ld_1, label(23andme (LDpred))) (ea_23me_clump_1, label(23andme (C+T))) ///
						(ea_new_ukb_ld_1, label(UKB (LDpred)))  (ea_new_ukb_clump_1, label(UKB (C+T))) , ///
						drop(YoB *qtl e_PC_* _cons) ///
			vertical ///
			graphregion(color(white)) ///
			coeflabels( 1.* = "1" 2.* = "2" 4.* = "4" 5.* = "5") ///
			groups(*ea_new_23me_ukb* = "	" *ea_new_ukb_23me* = "	" *ea_23me_ld* = ///
			"	" *ea_23me_clump* = "	" *ea_23me_clump* = "	" *ea_new_ukb_ld* = "	") ///
			ytitle("Years of education") xtitle("Quantiles of the EA PGI x YoB") ///
			ylabel(-0.1(0.05)0.05, format(%5.2f)) yline(0, lcolor(gs7)) saving(quintiles, replace) fysize(220) fxsize(80)
			
			graph export "${graphs}\interaction_YOB_EAPGS_order_discovery_sample_quintiles.png", replace
			
			graph combine continuous_nolegend.gph quintiles.gph, col(1) graphregion(color(white))
			graph export "${graphs}\interaction_YOB_EAPGS_merged.png", replace
			
			
			
outreg2 [${ea_pgs}] using "${tables}\interaction_YOB_EAPGS", excel see replace drop(${PCs} constant) dec(2) label

esttab  ${ea_pgs} using "${tables}\interaction_YOB_EAPGS.rtf", ///
		drop(${PCs}) stats(r2 N, fmt(%9.3f %9.0g)  labels(R-squared)) ///
		cells(b(star fmt(%9.2f))) varlabels(_cons Constant) ///
		label varwidth(9.0) modelwidth(2.0) replace

		
		
//test difference

//graph again
coefplot    (ea_new_23me_ukb_ld, label(23andme+UKB (LDpred)))   (ea_new_ukb_23me_clump, label(23andme+UKB (C+T)))   ///
			(ea_23me_ld, label(23andme (LDpred))) (ea_23me_clump, label(23andme (C+T))) ///
			(ea_new_ukb_ld, label(UKB (LDpred)))  (ea_new_ukb_clump, label(UKB (C+T))) , ///
			keep(c.YoB#c.ea_new_23me_ukb_ld 					 	  c.YoB#c.ea_23me_ld ///
			       c.YoB#c.ea_new_ukb_ld 						      c.YoB#c.ea_new_ukb_23me_clump ///
			       c.YoB#c.ea_23me_clump						      c.YoB#c.ea_new_ukb_clump) /// ///
			vertical ///
			graphregion(color(white)) ///
			coeflabels( * = "	", noticks) ///
			ylabel(-0.02(0.01)0.01, format(%03.2f)) yline(0, lcolor(gs7))


//these two are ss diferent from each other, so test needs to reject
reg3 (EA_new ea_23me_clump YoB c.YoB#c.ea_23me_clump ${PCs} if famid!=.) (EA_new ea_new_ukb_ld YoB c.YoB#c.ea_new_ukb_ld ${PCs} if famid!=.), ols
test c.YoB#c.ea_23me_clump = c.YoB#c.ea_new_ukb_ld //Prob > F =    0.0011

//these two are not ss different from each other, so test cannot reject
reg3 (EA_new ea_new_23me_ukb_ld YoB c.YoB#c.ea_new_23me_ukb_ld ${PCs} if famid!=.) (EA_new ea_new_ukb_23me_clump YoB c.YoB#c.ea_new_ukb_23me_clump ${PCs} if famid!=.), ols
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_new_ukb_23me_clump //Prob > F =    0.8799


//perfect!! now lets run everything
reg3 (EA_new ea_new_23me_ukb_ld YoB c.YoB#c.ea_new_23me_ukb_ld ${PCs} if famid!=.) (EA_new ea_new_ukb_23me_clump YoB c.YoB#c.ea_new_ukb_23me_clump ${PCs} if famid!=.) ///
	 (EA_new ea_23me_ld YoB c.YoB#c.ea_23me_ld ${PCs} if famid!=.) (EA_new ea_23me_clump YoB c.YoB#c.ea_23me_clump ${PCs} if famid!=.) ///
	 (EA_new ea_new_ukb_ld YoB c.YoB#c.ea_new_ukb_ld ${PCs} if famid!=.) (EA_new ea_new_ukb_clump YoB c.YoB#c.ea_new_ukb_clump ${PCs} if famid!=.) ///
	 , ols


//test them all together
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_new_ukb_23me_clump = c.YoB#c.ea_23me_ld = c.YoB#c.ea_23me_clump = c.YoB#c.ea_new_ukb_ld = c.YoB#c.ea_new_ukb_clump
//F-stat=3.55 p-val 0.0033
reject the null that they are all the same

//15 pairwise tests
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_new_ukb_23me_clump // 0.8799 SAME
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_23me_ld // 0.1121 SAME 
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_23me_clump // 0.0330 DIFFERENT 1 
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_new_ukb_ld // 0.2522 SAME
test c.YoB#c.ea_new_23me_ukb_ld = c.YoB#c.ea_new_ukb_clump //0.3048 SAME 
 
test c.YoB#c.ea_new_ukb_23me_clump = c.YoB#c.ea_23me_ld // 0.1516 SAME 
test c.YoB#c.ea_new_ukb_23me_clump = c.YoB#c.ea_23me_clump // 0.0481 DIFFERENT 2 
test c.YoB#c.ea_new_ukb_23me_clump = c.YoB#c.ea_new_ukb_ld // 0.1962 SAME 
test c.YoB#c.ea_new_ukb_23me_clump = c.YoB#c.ea_new_ukb_clump // 0.2406 SAME

test c.YoB#c.ea_23me_ld = c.YoB#c.ea_23me_clump // 0.5855 SAME 
test c.YoB#c.ea_23me_ld = c.YoB#c.ea_new_ukb_ld // 0.0065 DIFFERENT 3
test c.YoB#c.ea_23me_ld = c.YoB#c.ea_new_ukb_clump // 0.0093 DIFFERENT 4

test c.YoB#c.ea_23me_clump = c.YoB#c.ea_new_ukb_ld // 0.0011 DIFFERENT 5 
test c.YoB#c.ea_23me_clump = c.YoB#c.ea_new_ukb_clump // 0.0017 DIFFERENT 6

test c.YoB#c.ea_new_ukb_ld = c.YoB#c.ea_new_ukb_clump // 0.9077 SAME

*1 2
*1 3
*1 4
*1 5
*1 6

*2 3
*2 4
*2 5
*2 6

*3 4 
*3 5
*3 6

*4 5
*4 6

*5 6 


//UKB LD vs 23andme LD
reg3 (EA_new ea_new_ukb_ld YoB c.YoB#c.ea_new_ukb_ld ${PCs} if famid!=.) (EA_new ea_23me_ld YoB c.YoB#c.ea_23me_ld ${PCs} if famid!=.), ols

test c.YoB#c.ea_new_ukb_ld = c.YoB#c.ea_23me_ld //Prob > F =    0.0065


//UKB LD vs 23andme CLUMP
//test
regress EA_new ea_new_ukb_ld YoB c.YoB#c.ea_new_ukb_ld ${PCs} if famid!=.
regress EA_new ea_23me_clump YoB c.YoB#c.ea_23me_clump ${PCs} if famid!=.

reg3 (EA_new ea_new_ukb_ld YoB c.YoB#c.ea_new_ukb_ld ${PCs} if famid!=.) (EA_new ea_23me_clump YoB c.YoB#c.ea_23me_clump ${PCs} if famid!=.), ols
	  
test c.YoB#c.ea_new_ukb_ld = c.YoB#c.ea_23me_clump  //Prob > F =    0.0011


//UKB CLUMP vs 23andme LD

reg3 (EA_new ea_new_ukb_clump YoB c.YoB#c.ea_new_ukb_clump ${PCs} if famid!=.) (EA_new ea_23me_ld YoB c.YoB#c.ea_23me_ld ${PCs} if famid!=.), ols

test c.YoB#c.ea_new_ukb_clump = c.YoB#c.ea_23me_ld //Prob > F =    0.0093


//UKB CLUMP vs 23andme CLUMP


reg3 (EA_new ea_new_ukb_clump YoB c.YoB#c.ea_new_ukb_clump ${PCs} if famid!=.) (EA_new ea_23me_clump YoB c.YoB#c.ea_23me_clump ${PCs} if famid!=.), ols

test c.YoB#c.ea_new_ukb_clum = c.YoB#c.ea_23me_clump // Prob > F =    0.0017











