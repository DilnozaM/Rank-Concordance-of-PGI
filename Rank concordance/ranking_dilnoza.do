cd "path"

*net install wrap, from("https://aarondwolf.github.io/wrap")
*ssc install splitvallabels
******************************* Data preparation *******************************
clear all
use "\PGS ranking\Analysis\Input\PGS_ldpred_plink_EA_height_cvd_bmi.dta"


merge 1:1 ID using "\PGS ranking\Analysis\Input\quality_control_stata_v2.dta", gen(_batch)
keep if _batch==3


merge 1:1 ID using "\PGS ranking\Analysis\Input\list_samples_qc_UKBB_v2.dta", generate(_merge1)
* Those dropped are with bad qc and non-europeans 
drop if _merge1==3
*(53,294 real changes made) not all with bad qc have info on education 

inspect EA_new
drop if _merge1==2
drop if famid==.
count 
* 39,296
merge 1:1 ID using "\PGS ranking\Analysis\Input\ExtractedData.dta", gen(_date)
keep if _date==3
count 

* Extract year from date 

gen date=date(h_date_0, "DMY")
format date %td
gen year_int=year(date)
gen age = year_int - YoB
sum age
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
         age |     39,296    57.46931    7.355664         40         71
		 */


*cd "GEIGHEI\projects\PGS ranking\Analysis\Output\"

********************************************************************************		   
******************************** ANALYSES **************************************
********************************************************************************


*****************************  FIGURE 1 - EA ***********************************

*** Final Selection of the Scores 		

global eapgi  ea_new_ukb_ld      ea_new_ukb_clump    ///
              ea_new_23me_ukb_ld ea_new_ukb_23me_clump ///
              ea_23me_ld         ea_23me_clump           
			  
spearman $eapgi			  
			 
corr $eapgi
		  
*** Standardizing 
foreach i in $eapgi {
	sum `i', detail
	sca m = r(mean)
	sca sd = r(sd)
	replace `i' = (`i' - m)/sd
	}


{
    *** Heatplot 	
corr $eapgi
matrix C = r(C)
heatplot C, color(hcl, diverging intensity(.6)) ///
            aspectratio(1) ylabel(,labsize(small)) ylabel(,angle(0)) ///
			xlabel(,labsize(small)) xlabel(,angle(90)) lower nodiagonal
}

*** Panel 1a - Decile overlap 

foreach i in $eapgi {
	xtile dec_`i' = `i', nq(10)
} 

* Correlation in decile ranks 
pwcorr 	dec*

**
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("Meta-analysis LDpred vs. meta-analysis C+T") ///
	ytitle("UKB+23andME(LDpred))", size(small)) xtitle("UKB+23andME(C+T))", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save decile_ea_ukb_23me_ld_clump.gph, replace
drop 	pop

** 
bys 	dec_ea_new_23me_ukb_ld dec_ea_23me_clump: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_23me_clump [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title(""Best" PGI vs. "Worst" PGI") ///
	ytitle("UKB+23andME(LDpred))", size(small)) xtitle("23andMe (C+T)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_bestvsworst.gph, replace
drop 	pop


**
bys 	dec_ea_new_ukb_ld dec_ea_23me_ld: gen pop = _N
twoway 	(scatter dec_ea_new_ukb_ld dec_ea_23me_ld [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title(""Sample 1" LDpred vs "Sample 2" LDpred") ///
	ytitle("UKB (LDpred)", size(small)) xtitle("23andME(LDpred)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ld_ukb_23andme.gph, replace
drop 	pop


**
bys 	dec_ea_new_ukb_clump dec_ea_23me_clump: gen pop = _N
twoway 	(scatter dec_ea_new_ukb_clump dec_ea_23me_clump [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title(""Sample 1" C+T vs "Sample 2" C+T") ///
	ytitle("UKB (C+T)", size(small)) xtitle("23andME(C+T)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ld_ukb_23andme.gph, replace
drop 	pop
		 

*** Panel 1D - Explained R2				 		 
{
*** Incremental R2
tab batch, gen(batch_)
global controls sex i.YoB i.MoB e_PC* batch_1-batch_106
foreach i in $eapgi {
	eststo M`i': reg EA_new `i' $controls, robust
} 
eststo M0: reg EA_new $controls, robust

esttab M0 M*, ///
       noomitted nobase se star(* 0.10 ** 0.05 *** 0.01) ///
       stats(r2 N, fmt(3 0)) drop(e_PC_* *.MoB *.YoB batch_* sex) se(3) b(3)
est drop _all
}


*** Overlaps in Quintiles
	
	global eapgi  ea_new_ukb_ld      ea_new_ukb_clump    ///
              ea_new_23me_ukb_ld ea_new_ukb_23me_clump ///
              ea_23me_ld         ea_23me_clump      
			  
			  
	foreach i in $eapgi {
	xtile quin_`i' = `i', nq(5)
} 

* Correlation in decile ranks 
tab quin_ea_new_23me_ukb_ld quin_ea_23me_clump
tab quin_ea_new_ukb_ld quin_ea_23me_ld

count
count if quin_ea_new_ukb_ld==1 & quin_ea_new_ukb_clump==1 & quin_ea_new_23me_ukb_ld==1 & quin_ea_new_ukb_23me_clump==1 & quin_ea_23me_ld==1 & quin_ea_23me_clump==1 
	

*** Panel 1c - Rank Switching 
order famid ea_new_23me_ukb_ld        ea_23me_ld            ea_new_ukb_ld        /// 
            ea_new_ukb_23me_clump     ea_23me_clump         ea_new_ukb_clump    
 
* start with the meta score and use random 1000 siblings for reader friendliness 
preserve 

gen nID = _n
set seed 12345
sample 1000, count		// note that there will be some siblings in this sample
gsort -ea_new_23me_ukb_ld
sum ea_new_23me_ukb_ld, d
xtile quin = ea_new_23me_ukb_ld, nq(5)
br ea_new_23me_ukb_ld quin
gen top20 = cond(quin==5,1,0)

	
egen rank1 = rank(ea_new_23me_ukb_ld)
egen rank2 = rank(ea_23me_ld)
egen rank3 = rank(ea_new_ukb_ld)
egen rank4 = rank(ea_new_ukb_23me_clump)
egen rank5 = rank(ea_23me_clump)
egen rank6 = rank(ea_new_ukb_clump)

* Quantifying misslassifications 
* Maybe rank1>=800 & rank2<=800

count if rank1>=800 
count if top20==1 & rank1>=800 & rank2>=800 & rank3>=800 & rank4>=800 & rank5>=800 & rank6>=800
count if top20==1 & rank1>=800
count if top20==1 & rank2>=800
count if top20==1 & rank3>=800
count if top20==1 & rank4>=800
count if top20==1 & rank5>=800
count if top20==1 & rank6>=800
count if rank5>=800 & rank6>=800 
count if rank1>=800 & rank2>=800 & rank3>=800 & rank4>=800 & rank5>=800 & rank6>=800
count if rank1>=800 & rank3>=800
count if rank1>=800 & rank4>=800
count if rank1>=800 & rank5>=800
count if rank1>=800 & rank6>=800

reshape long rank, i(nID) j(type)
label def type 1 "23andMe+UKB (LDpred)"    2 "23andMe (LDpred)"    3 "UKB (LDpred)" ///
               4 "23andMe+UKB (C+T)"     5 "23andMe (C+T)"     6 "UKB (C+T)" 
label val type type

*splitvallabels type, length(11)
*dis dis `r(relabel)'

count if type==1 & rank<=800
count if type==2 & rank<=800


twoway 	(line rank type if top20==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
        yline(800, lcolor(red)) ///
		ytitle("UKB+23andMe (LDpred) Rank", size(small)) ylabel(0(100)1000, angle(horizontal) labsize(small)) xtitle("") ///
		xlabel(1(1)6, labsize(small) labels angle(25) valuelabel) scheme(s1mono) ///
		legend(off) aspectratio(1)
		
* could add a threshold line 
graph export "\PGS ranking\Analysis\Output\ea_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 



{***Quantifying the missclasifications***

gsort -ea_new_ukb_ld
sum ea_new_ukb_ld, d
gen top20_ea_ukb_ld = cond(ea_new_ukb_ld>r(p80),1,0)    

gsort -ea_23me_ld
sum ea_23me_ld, d
gen top20_ea_23me_ld = cond(ea_23me_ld>r(p80),1,0)  

count if top20_ea_ukb_ld==top20_ea_23me_ld  

tab top20_ea_ukb_ld top20_ea_23me_ld  

}

*************************** Figure 2 - CVD *************************************
global cvdpgi   cvd_cardio_ukb_ld         cvd_ukb_ld             cvd_cardio_ld        ///
		        cvd_cardio_ukb_clump      cvd_ukb_clump          cvd_cardio_clump 
				
spearman $cvdpgi				
*** Standardizing 
foreach i in $cvdpgi {
	sum `i', detail
	sca m = r(mean)
	sca sd = r(sd)
	replace `i' = (`i' - m)/sd
	}
	
corr $cvdpgi

{*** Heatplot				
corr IHD_icd $cvdpgi 
matrix C = r(C)
heatplot C, novalues color(hcl, diverging intensity(.6)) ///
            aspectratio(1) ylabel(,labsize(small)) ylabel(,angle(0)) ///
			xlabel(,labsize(small)) xlabel(,angle(90)) lower nodiagonal
sum $cvdpgs 	
}
					 
*** Panel 1a - Decile Overlap  

* Create the deciles 
foreach i in $cvdpgi {
	xtile dec_`i' = `i', nq(10)
} 

pwcorr 	dec*

**
bys 	dec_cvd_cardio_ukb_ld dec_cvd_cardio_ukb_clump: gen pop = _N
twoway 	(scatter dec_cvd_cardio_ukb_ld dec_cvd_cardio_ukb_clump [w=pop], msymbol(circle_hollow) mcolor(navy)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("Meta-analysis LDpred vs. meta-analysis C+T") ///
	ytitle("UKB+CARDIoGRAM (LDpred)", size(small)) xtitle("UKB+CARDIoGRAM (C+T)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save graph1.gph, replace
drop 	pop


**
bys 	dec_cvd_cardio_ukb_ld dec_cvd_cardio_clump: gen pop = _N
twoway 	(scatter dec_cvd_cardio_ukb_ld dec_cvd_cardio_clump [w=pop], msymbol(circle_hollow) mcolor(cranberry)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title(""Best" PGI vs. "Worst" PGI") ///
	ytitle("UKB+CARDIoGRAM (LDpred)", size(small)) xtitle("CARDIoGRAM (C+T)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph2.gph, replace
drop 	pop


** 
bys 	dec_cvd_ukb_ld dec_cardio_ukb_ld: gen pop = _N
twoway 	(scatter dec_cvd_ukb_ld dec_cardio_ukb_ld [w=pop], msymbol(circle_hollow) mcolor(forest_green)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title(""Sample 1" LDpred vs "Sample 2" LDpred") ///
	ytitle("UKB (LDpred)", size(small)) xtitle("CARDIoGRAM (LDpred)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph3.gph, replace
drop 	pop

**
bys 	dec_cvd_ukb_clump dec_cardio_ukb_clump: gen pop = _N
twoway 	(scatter dec_cvd_ukb_clump dec_cardio_ukb_clump [w=pop], msymbol(circle_hollow) mcolor(teal)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title(""Sample 1" C+T vs "Sample 2" C+T") ///
	ytitle("UKB (C+T)", size(small)) xtitle("CARDIoGRAM (C+T)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph4.gph, replace
drop 	pop


*** Panel 1c - Rank Switching 
	
order famid cvd_cardio_ukb_ld        cvd_cardio_ld         cvd_ukb_ld         /// 
            cvd_cardio_ukb_clump     cvd_cardio_clump      cvd_ukb_clump    
			
* keep random 5% of sibling sample
* start with the meta score and use 1000 siblings for reader friendliness 
preserve 

gen nID = _n
set seed 12345
sample 1000, count 		// note that there will be some siblings in this sample
gsort -cvd_cardio_ukb_ld 
sum cvd_cardio_ukb_ld , d
xtile quin = cvd_cardio_ukb_ld , nq(5)
br cvd_cardio_ukb_ld  quin
gen top20 = cond(quin==5,1,0)

	
egen rank1 = rank(cvd_cardio_ukb_ld)
egen rank2 = rank(cvd_cardio_ld)
egen rank3 = rank(cvd_ukb_ld)
egen rank4 = rank(cvd_cardio_ukb_clump)
egen rank5 = rank(cvd_cardio_clump)
egen rank6 = rank(cvd_ukb_clump)

*** Quantifying misslassifications

count if top20==1 & rank1>=800 & rank2>=800 & rank3>=800 & rank4>=800 & rank5>=800 & rank6>=800
count if rank1<=800 
count if rank1>=800 & rank2<=800
count if top20==1 & rank2<=800
count if rank1>=800 & rank3<=800
count if top20==1 & rank3<=800
count if rank1>=800 & rank4<=800
count if top20==1 & rank4<=800
count if rank1>=800 & rank5<=800
count if top20==1 & rank5<=800
count if rank1>=800 & rank6<=800
count if top20==1 & rank6<=800


reshape long rank, i(nID) j(type)
label def type 1 "CARDIoGRAM+UKB (LDpred)"    2 "CARDIoGRAM (LDpred)"    3 "UKB (LDpred)" ///
               4 "CARDIoGRAM+UKB (C+T)"     5 "CARDIoGRAM (C+T)"     6 "UKB (C+T)"   
label val type type

twoway 	(line rank type if top20==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
        yline(800, lcolor(red)) ///
		ytitle("UKB+CARDIoGRAM (LDpred) rank", size(small)) ylabel(0(100)1000, angle(horizontal) labsize(small)) xtitle("") ///
		xlabel(1(1)6, labsize(small) labels angle(25) valuelabel) scheme(s1mono) ///
		legend(off) aspectratio(1)
	

/*twoway 	(line rank type if top10==0, lcolor(gs12) lwidth(vvvthin) connect(ascending)) ///
		(line rank type if top10==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
		ytitle("Rank based on PGI UKB") ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB")
*/
		
* could add a threshold line 
graph export "\PGS ranking\Analysis\Output\cvd_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 

*title("Variability in individuals' ranks with different EA PGIs") 
}

			 		 
*** Panel 1d - Incremental R2			
global cvdpgi   cvd_cardio_ukb_ld         cvd_ukb_ld             cvd_cardio_ld        ///
		        cvd_cardio_ukb_clump      cvd_ukb_clump          cvd_cardio_clump 
	
tab batch, gen(batch_)
global controls sex i.YoB i.MoB e_PC* batch_1-batch_106

*** LPM 
foreach i in $cvdpgi {
	eststo M`i': reg IHD_icd `i' $controls, robust
} 
eststo M0: reg IHD_icd $controls, robust
esttab M0 M*, ///
       noomitted nobase se star(* 0.10 ** 0.05 *** 0.01) ///
       stats(r2 N, fmt(3 0)) drop(e_PC_* *.MoB *.YoB sex) se(3) b(3)
	   est drop _all

*** LOGIT
foreach i in $cvdpgs {
	eststo M`i': logit IHD_icd `i' $controls, robust
} 
eststo M0: logit IHD_icd $controls, robust
esttab M0 M*, ///
       noomitted nobase se star(* 0.10 ** 0.05 *** 0.01) ///
       stats(r2_p N, fmt(3 0)) drop(e_PC_* *.MoB *.YoB sex) se(3) b(3)
	   est drop _all	   

