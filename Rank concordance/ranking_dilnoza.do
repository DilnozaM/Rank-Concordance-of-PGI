if c(username)=="68484dmu" {
	cd "C:\Users\68484dmu\Dropbox (Erasmus Universiteit Rotterdam)\"
}
else {
	*cd "C:\Users\Hans\Dropbox (Erasmus Universiteit Rotterdam)\"
	*cd "C:\Users\Niels\Dropbox (Erasmus Universiteit Rotterdam)\"
	*cd "C:\Users\ecsmvhkv\Dropbox\"
	*cd "C:\Users\Fleur\Dropbox\"
}

*net install wrap, from("https://aarondwolf.github.io/wrap")
*ssc install splitvallabels
******************************* Data preparation *******************************
clear all
use "GEIGHEI\projects\PGS ranking\Analysis\Input\PGS_ldpred_plink_EA_height_cvd_bmi.dta"
* standardize the scores within the same siblings sample, make sure the sample sizes are the same 
* make a correlation matrix to feed into r for the corrplot
* think of switching graphs with R2 
* look through the ideas of Hans, Niels, Stephanie 

merge 1:1 ID using "Birth rank & Genes\Analysis\Input\quality_control_stata_v2.dta", gen(_batch)
keep if _batch==3


merge 1:1 ID using "Birth rank & Genes\Analysis\Input\list_samples_qc_UKBB_v2.dta", generate(_merge1)
* Those dropped are with bad qc and non-europeans 
drop if _merge1==3
*(53,294 real changes made) not all with bad qc have info on education 

inspect EA_new
drop if _merge1==2
drop if famid==.
count 
* 39,296
merge 1:1 ID using "Birth rank & Genes\Analysis\Input\ExtractedData.dta", gen(_date)
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


***************************** EA INDICES ***************************************

*** Final Selection of the Scores 		

global eapgi  ea_new_ukb_ld      ea_new_ukb_clump    ///
              ea_new_23me_ukb_ld ea_new_ukb_23me_clump ///
              ea_23me_ld         ea_23me_clump           
			  
spearman $eapgi			  
			 
*   ea_new_ukb_clump_gws ea_new_ukb_23me_clump_gws ea_new_23me_clump_gws
			  
			  
			  

replace ea_new_ukb_clump_gws = (-1)*ea_new_ukb_clump_gws
replace ea_new_23me_clump_gws = (-1)*ea_new_23me_clump_gws	
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

{
*** Incremental R2

global controls sex i.YoB i.MoB e_PC*
foreach i in $eapgi {
	eststo M`i': reg EA_new `i' $controls, robust
} 
eststo M0: reg EA_new $controls, robust

esttab M0 M*, ///
       noomitted nobase se star(* 0.10 ** 0.05 *** 0.01) ///
       stats(r2 N, fmt(3 0)) drop(e_PC_* *.MoB *.YoB sex) se(3) b(3)
est drop _all
}

				 		 
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

{
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
	
}

{
    *** PLOTS with DECILES 

foreach i in $eapgi {
	xtile dec_`i' = `i', nq(10)
} 

* Correlation in decile ranks 
pwcorr 	dec*

/*

. pwcorr  dec*

             | dec_ea.. dec_ea.. dec_ea.. dec~e_ld dec_ea.. dec_ea.. dec_ea..
-------------+---------------------------------------------------------------
dec~w_ukb_ld |   1.0000 
dec_~b_clump |   0.8120   1.0000 
dec_ea_new.. |   0.3047   0.2941   1.0000 
dec_ea_23m~d |   0.4762   0.4077   0.2342   1.0000 
dec_ea_23m~p |   0.3892   0.3895   0.2143   0.8324   1.0000 
dec_ea_new.. |   0.1921   0.1916   0.4732   0.2603   0.2524   1.0000 
dec~e_ukb_ld |   0.7894   0.6596   0.2912   0.8397   0.7076   0.2546   1.0000 
dec_ea_new.. |   0.6843   0.7097   0.2965   0.7588   0.7677   0.2568   0.8181 
dec_ea_new.. |   0.3037   0.2855   0.6607   0.3172   0.2816   0.6885   0.3430 

             | dec_ea.. dec_ea..
-------------+------------------
dec_ea_new.. |   1.0000 
dec_ea_new.. |   0.3691   1.0000 

*/

tab dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump
**
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump [w=pop], msymbol(circle_hollow) mcolor(navy)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(a)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI CLUMP (UKB+23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save decile_ea_ukb_23me_ld_clump.gph, replace
drop 	pop


**
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump_gws: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump_gws [w=pop], msymbol(circle_hollow) mcolor(cranberry)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(b)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI CLUMP GWS (UKB+23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ukb_23me_ld_clump_gws.gph, replace
drop 	pop


** 
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_ld: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_ld [w=pop], msymbol(circle_hollow) mcolor(forest_green)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(c)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI LDPRED (UKB)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ukb_ld_meta_ld.gph, replace
drop 	pop

**
bys 	dec_ea_new_23me_ukb_ld dec_ea_23me_ld: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_23me_ld [w=pop], msymbol(circle_hollow) mcolor(teal)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(d)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI LDPRED (23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ld_meta_23andme.gph, replace
drop 	pop

**
bys 	dec_ea_new_ukb_ld dec_ea_23me_ld: gen pop = _N
twoway 	(scatter dec_ea_new_ukb_ld dec_ea_23me_ld [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(e)") ///
	ytitle("EA PGI LDPRED (UKB)", size(small)) xtitle("EA PGI LDPRED (23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ld_ukb_23andme.gph, replace
drop 	pop

graph combine decile_ea_ukb_23me_ld_clump.gph decile_ea_ukb_23me_ld_clump_gws.gph ///
              decile_ea_ukb_ld_meta_ld.gph    decile_ea_ld_meta_23andme.gph ///
			  decile_ea_ld_ukb_23andme.gph,  ///
			  scheme(s1mono)

graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_bubbles.png", ///
             as(png) name("Graph") replace 
}			 

{*** Plots with OVERLAPPING DISTRIBUTIONS 
xtile       PGI = ea_new_23me_ukb_ld, nquantiles(5)

twoway      (kdensity ea_new_ukb_23me_clump if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(black))     ///
            (kdensity ea_new_ukb_23me_clump if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(black))      ///
			(kdensity ea_new_ukb_23me_clump if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(black))  ///
			(kdensity ea_new_ukb_23me_clump if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(black))       ///
			(kdensity ea_new_ukb_23me_clump if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(black)), ///
			ytitle("Density") xtitle("EA PGI CLUMP (UKB+23&ME)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(a)")       						
            graph save density_eapgi_ukb_23me_ldpred_clump.gph, replace

twoway      (kdensity ea_new_ukb_23me_clump_gws if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(cranberry))     ///
            (kdensity ea_new_ukb_23me_clump_gws if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(cranberry))      ///
			(kdensity ea_new_ukb_23me_clump_gws if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(cranberry))  ///
			(kdensity ea_new_ukb_23me_clump_gws if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(cranberry))       ///
			(kdensity ea_new_ukb_23me_clump_gws if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(cranberry)), ///
			ytitle("Density") xtitle("EA PGI CLUMP GWS (UKB + 23&me)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(b)")						
            graph save density_eapgi_ukb_meta_ldpred_clump_gws.gph, replace
			
twoway      (kdensity ea_new_ukb_ld if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(dkorange))     ///
            (kdensity ea_new_ukb_ld if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(dkorange))      ///
			(kdensity ea_new_ukb_ld if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(dkorange))  ///
			(kdensity ea_new_ukb_ld if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(dkorange))       ///
			(kdensity ea_new_ukb_ld if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(dkorange)), ///
			ytitle("Density") xtitle("EA PGI LDPRED (UKB)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(c)")						
            graph save density_eapgi_meta_ukb_ldpred.gph, replace
			
twoway      (kdensity ea_23me_ld if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(forest_green))     ///
            (kdensity ea_23me_ld if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(forest_green))      ///
			(kdensity ea_23me_ld if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(forest_green))  ///
			(kdensity ea_23me_ld if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(forest_green))       ///
			(kdensity ea_23me_ld if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(forest_green)), ///
			ytitle("Density") xtitle("EA PGI LDPRED (23&ME)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(d)")						
            graph save density_eapgi_meta_23me_ldpred.gph, replace

* This one cannot change the reference PGI, so less comprehensive 
			
grc1leg     density_eapgi_ukb_23me_ldpred_clump.gph density_eapgi_ukb_meta_ldpred_clump_gws.gph ///
            density_eapgi_meta_ukb_ldpred.gph density_eapgi_meta_23me_ldpred.gph, ///
			scheme(s1mono) 
			  
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_density.png", ///
             as(png) name("Graph") replace			
drop      PGI
}

{*** Plots with RANKINGS
order famid ea_new_23me_ukb_ld        ea_23me_ld            ea_new_ukb_ld        /// 
            ea_new_ukb_23me_clump     ea_23me_clump         ea_new_ukb_clump    
 
* start with the meta score and use 1000 siblings for reader friendliness 
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
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 

}


{*** Plots with RANKINGS
order famid ea_new_23me_ukb_ld        ea_23me_ld            ea_new_ukb_ld        /// 
            ea_new_ukb_23me_clump     ea_23me_clump         ea_new_ukb_clump     ///
			ea_new_ukb_23me_clump_gws ea_new_23me_clump_gws ea_new_ukb_clump_gws  
 *replace ea_new_ukb_clump_gws = (-1)*ea_new_ukb_clump_gws
 *replace ea_new_23me_clump_gws = (-1)*ea_new_23me_clump_gws
 
* keep random 5% of sibling sample
* start with the meta score and use 1000 siblings for reader friendliness 
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
egen rank7 = rank(ea_new_ukb_23me_clump_gws)
egen rank8 = rank(ea_new_23me_clump_gws)
egen rank9 = rank(ea_new_ukb_clump_gws)

* Quantifying misslassifications 
* Maybe rank1>=800 & rank2<=800

count if rank1<=800 
count if rank1<=800 & rank2>=800
count if rank1<=800 & rank3>=800
count if rank1<=800 & rank4>=800
count if rank1<=800 & rank5>=800
count if rank1<=800 & rank6>=800
count if rank1<=800 & rank7>=800
count if rank1<=800 & rank8>=800
count if rank1<=800 & rank9>=800

reshape long rank, i(nID) j(type)
label def type 1 "23&me+UKB LDpred"    2 "23&me LDpred"    3 "UKB LDpred" ///
               4 "23&me+UKB Clump"     5 "23&me Clump"     6 "UKB Clump" /// 
			   7 "23&me+UKB Clump GWS" 8 "23&me Clump GWS" 9 "UKB Clump GWS"  
label val type type

count if type==1 & rank<=800
count if type==2 & rank<=800


twoway 	(line rank type if top20==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
        yline(800, lcolor(red)) ///
		ytitle("Rank based on EA PGI LDPRED (UKB+23&ME)", size(small)) ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB", size(vsmall) justification(left))

/*twoway 	(line rank type if top10==0, lcolor(gs12) lwidth(vvvthin) connect(ascending)) ///
		(line rank type if top10==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
		ytitle("Rank based on PGI UKB") ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB")
*/
		
* could add a threshold line 
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 
*title("Variability in individuals' ranks with different EA PGIs") 
}

{
*** Results with one random sibling only 
preserve 

* Keep families with at least two siblings
egen N_famid=count(famid), by(famid)
tab N_famid
drop if N_famid==1
*(233 observations deleted)

* Same seed as in other projects 
set seed 543
by famid, sort: gen random = runiform(0,1)
sort famid random
by famid, sort: gen draft = _n
sort famid draft 
br famid ID draft
keep if draft==1
count 
*  18,969
    
*** Standardizing 
foreach i in $eapgi {
	sum `i', detail
	sca m = r(mean)
	sca sd = r(sd)
	replace `i' = (`i' - m)/sd
	}
	

{	
*** PLOTS with DECILES 

foreach i in $eapgi {
	xtile dec_`i' = `i', nq(10)
} 

pwcorr 	dec*

**
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump [w=pop], msymbol(circle_hollow) mcolor(navy)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(a)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI CLUMP (UKB+23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save decile_ea_ukb_23me_ld_clump.gph, replace
drop 	pop


**
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump_gws: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_23me_clump_gws [w=pop], msymbol(circle_hollow) mcolor(cranberry)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(b)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI CLUMP GWS (UKB+23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ukb_23me_ld_clump_gws.gph, replace
drop 	pop


** 
bys 	dec_ea_new_23me_ukb_ld dec_ea_new_ukb_ld: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_new_ukb_ld [w=pop], msymbol(circle_hollow) mcolor(forest_green)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(c)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI LDPRED (UKB)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ukb_ld_meta_ld.gph, replace
drop 	pop

**
bys 	dec_ea_new_23me_ukb_ld dec_ea_23me_ld: gen pop = _N
twoway 	(scatter dec_ea_new_23me_ukb_ld dec_ea_23me_ld [w=pop], msymbol(circle_hollow) mcolor(teal)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(d)") ///
	ytitle("EA PGI LDPRED (UKB+23&ME)", size(small)) xtitle("EA PGI LDPRED (23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ld_meta_23andme.gph, replace
drop 	pop

**
bys 	dec_ea_new_ukb_ld dec_ea_23me_ld: gen pop = _N
twoway 	(scatter dec_ea_new_ukb_ld dec_ea_23me_ld [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(e)") ///
	ytitle("EA PGI LDPRED (UKB)", size(small)) xtitle("EA PGI LDPRED (23&ME)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save decile_ea_ld_ukb_23andme.gph, replace
drop 	pop

graph combine decile_ea_ukb_23me_ld_clump.gph decile_ea_ukb_23me_ld_clump_gws.gph ///
              decile_ea_ukb_ld_meta_ld.gph    decile_ea_ld_meta_23andme.gph ///
			  decile_ea_ld_ukb_23andme.gph,  ///
			  scheme(s1mono)

graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_bubbles_onesib.png", ///
             as(png) name("Graph") replace 
}			

{
    *** Plots with OVERLAPPING DISTRIBUTIONS 
xtile       PGI = ea_new_23me_ukb_ld, nquantiles(5)

twoway      (kdensity ea_new_ukb_23me_clump if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(black))     ///
            (kdensity ea_new_ukb_23me_clump if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(black))      ///
			(kdensity ea_new_ukb_23me_clump if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(black))  ///
			(kdensity ea_new_ukb_23me_clump if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(black))       ///
			(kdensity ea_new_ukb_23me_clump if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(black)), ///
			ytitle("Density") xtitle("EA PGI CLUMP (UKB+23&ME)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(a)")       						
            graph save density_eapgi_ukb_23me_ldpred_clump.gph, replace

twoway      (kdensity ea_new_ukb_23me_clump_gws if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(cranberry))     ///
            (kdensity ea_new_ukb_23me_clump_gws if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(cranberry))      ///
			(kdensity ea_new_ukb_23me_clump_gws if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(cranberry))  ///
			(kdensity ea_new_ukb_23me_clump_gws if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(cranberry))       ///
			(kdensity ea_new_ukb_23me_clump_gws if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(cranberry)), ///
			ytitle("Density") xtitle("EA PGI CLUMP GWS (UKB + 23&me)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(b)")						
            graph save density_eapgi_ukb_meta_ldpred_clump_gws.gph, replace
			
twoway      (kdensity ea_new_ukb_ld if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(dkorange))     ///
            (kdensity ea_new_ukb_ld if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(dkorange))      ///
			(kdensity ea_new_ukb_ld if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(dkorange))  ///
			(kdensity ea_new_ukb_ld if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(dkorange))       ///
			(kdensity ea_new_ukb_ld if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(dkorange)), ///
			ytitle("Density") xtitle("EA PGI LDPRED (UKB)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(c)")						
            graph save density_eapgi_meta_ukb_ldpred.gph, replace
			
twoway      (kdensity ea_23me_ld if PGI==1, legend(label(1 "Q1 - EA PGI LDpred (UKB+23&ME)")) lpattern(solid) lcolor(forest_green))     ///
            (kdensity ea_23me_ld if PGI==2, legend(label(2 "Q2 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash) lcolor(forest_green))      ///
			(kdensity ea_23me_ld if PGI==3, legend(label(3 "Q3 - EA PGI LDpred (UKB+23&ME)")) lpattern(dash_dot) lcolor(forest_green))  ///
			(kdensity ea_23me_ld if PGI==4, legend(label(4 "Q4 - EA PGI LDpred (UKB+23&ME)")) lpattern(dot) lcolor(forest_green))       ///
			(kdensity ea_23me_ld if PGI==5, legend(label(5 "Q5 - EA PGI LDpred (UKB+23&ME)")) lpattern(longdash) lcolor(forest_green)), ///
			ytitle("Density") xtitle("EA PGI LDPRED (23&ME)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(d)")						
            graph save density_eapgi_meta_23me_ldpred.gph, replace

* This one cannot change the reference PGI, so less comprehensive 
			
grc1leg     density_eapgi_ukb_23me_ldpred_clump.gph density_eapgi_ukb_meta_ldpred_clump_gws.gph ///
            density_eapgi_meta_ukb_ldpred.gph density_eapgi_meta_23me_ldpred.gph, ///
			scheme(s1mono) 
			  
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_density_onesib.png", ///
             as(png) name("Graph") replace			
drop      PGI
}
	
{
    *** Plots with RANKINGS
order famid ea_new_23me_ukb_ld        ea_23me_ld            ea_new_ukb_ld        /// 
            ea_new_ukb_23me_clump     ea_23me_clump         ea_new_ukb_clump     ///
			ea_new_ukb_23me_clump_gws ea_new_23me_clump_gws ea_new_ukb_clump_gws  
 *replace ea_new_ukb_clump_gws = (-1)*ea_new_ukb_clump_gws
 *replace ea_new_23me_clump_gws = (-1)*ea_new_23me_clump_gws
 
* keep random 5% of sibling sample
* start with the meta score and use 1000 siblings for reader friendliness 
preserve 

gen nID = _n
set seed 12345
sample 5.271 		// note that there will be some siblings in this sample
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
egen rank7 = rank(ea_new_ukb_23me_clump_gws)
egen rank8 = rank(ea_new_23me_clump_gws)
egen rank9 = rank(ea_new_ukb_clump_gws)

reshape long rank, i(nID) j(type)
label def type 1 "23&me+UKB LDpred"    2 "23&me LDpred"    3 "UKB LDpred" ///
               4 "23&me+UKB Clump"     5 "23&me Clump"     6 "UKB Clump" /// 
			   7 "23&me+UKB Clump GWS" 8 "23&me Clump GWS" 9 "UKB Clump GWS"  
label val type type

twoway 	(line rank type if top20==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
        yline(790, lcolor(red)) ///
		ytitle("Rank based on EA PGI LDPRED (UKB+23&ME)", size(small)) ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB", size(vsmall) justification(left))

/*twoway 	(line rank type if top10==0, lcolor(gs12) lwidth(vvvthin) connect(ascending)) ///
		(line rank type if top10==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
		ytitle("Rank based on PGI UKB") ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB")
*/
		
* could add a threshold line 
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\ea_statariver_onesib.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 
}	
	
restore	
}

{***Quantifying the missclasifications***

gsort -ea_new_ukb_ld
sum ea_new_ukb_ld, d
gen top20_ea_ukb_ld = cond(ea_new_ukb_ld>r(p80),1,0)    

gsort -ea_23me_ld
sum ea_23me_ld, d
gen top20_ea_23me_ld = cond(ea_23me_ld>r(p80),1,0)  

count if top20_ea_ukb_ld==top20_ea_23me_ld  

tab top20_ea_ukb_ld top20_ea_23me_ld  
	
*ea_new_ukb_ld        ea_23me_ld            ea_new_23me_ukb_ld /// 
*ea_new_ukb_clump     ea_23me_clump         ea_new_ukb_23me_clump  ///
*ea_new_ukb_clump_gws ea_new_23me_clump_gws ea_new_ukb_23me_clump_gws	
	
}

{
***************************** BMI INDICES **************************************

*** Final Selection of the Scores			  
* BMI    UKBldpred, UKBplink, UKBplinkgws,
*        giantldpred, giantplink, giantplinkgws
*        metagiantldpred, metagiantplink, metagiantgws
global bmipgi	bmi_ukb_ld         bmi_ukb_clump        bmi_ukb_clump_gws ///
                bmi_giant_ld       bmi_giant_clump      bmi_giant_clump_gws /// 
				bmi_giant_ukb_ld   bmi_giant_ukb_clump  bmi_giant_ukb_clump_gws

replace bmi_ukb_clump_gws = (-1)* bmi_ukb_clump_gws	
replace bmi_ukb_clump = (-1)*bmi_ukb_clump			

corr $bmipgi

*** Standardizing 
foreach i in $bmipgi {
	sum `i', detail
	sca m = r(mean)
	sca sd = r(sd)
	replace `i' = (`i' - m)/sd
	}


{*** Heatplot 	
corr $bmipgs
matrix C = r(C)
heatplot C, color(hcl, diverging intensity(.6)) ///
            aspectratio(1) ylabel(,labsize(small)) ylabel(,angle(0)) ///
			xlabel(,labsize(small)) xlabel(,angle(90)) lower nodiagonal
}			

{*** Incremental R2

global controls sex i.YoB i.MoB e_PC*

foreach i in $bmipgi {
	eststo M`i': reg BMI `i' $controls, robust
} 
eststo M0: reg BMI $controls, robust

esttab M0 M*, ///
       noomitted nobase se star(* 0.10 ** 0.05 *** 0.01) ///
       stats(r2 N, fmt(3 0)) drop(e_PC_* *.MoB *.YoB sex) se(3) b(3)
est drop _all
}

{*** PLOTS with DECILES 
*** plots showing substantial amount of variability in relationship between any two DECILES
* Create the deciles 


foreach i in $bmipgi {
	xtile dec_`i' = `i', nq(10)
} 

pwcorr 	dec*

**
bys 	dec_bmi_giant_ukb_ld dec_bmi_giant_ukb_clump: gen pop = _N
twoway 	(scatter dec_bmi_giant_ukb_ld dec_bmi_giant_ukb_clump [w=pop], msymbol(circle_hollow) mcolor(navy)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(a)") ///
	ytitle("BMI PGI LDPRED (UKB+GIANT)", size(small)) xtitle("BMI PGI CLUMP (UKB+GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save graph1.gph, replace
drop 	pop


**
bys 	dec_bmi_giant_ukb_ld dec_bmi_giant_ukb_clump_gws: gen pop = _N
twoway 	(scatter dec_bmi_giant_ukb_ld dec_bmi_giant_ukb_clump_gws [w=pop], msymbol(circle_hollow) mcolor(cranberry)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(b)") ///
	ytitle("BMI PGI LDPRED (UKB+GIANT)", size(small)) xtitle("BMI PGI CLUMP GWS (UKB+GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph2.gph, replace
drop 	pop


** 
bys 	dec_bmi_giant_ukb_ld dec_bmi_ukb_ld: gen pop = _N
twoway 	(scatter dec_bmi_giant_ukb_ld dec_bmi_ukb_ld [w=pop], msymbol(circle_hollow) mcolor(forest_green)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(c)") ///
	ytitle("BMI PGI LDPRED (UKB+GIANT)", size(small)) xtitle("BMI PGI LDPRED (UKB)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph3.gph, replace
drop 	pop

**
bys 	dec_bmi_giant_ukb_ld dec_bmi_giant_ld: gen pop = _N
twoway 	(scatter dec_bmi_giant_ukb_ld dec_bmi_giant_ld [w=pop], msymbol(circle_hollow) mcolor(teal)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(d)") ///
	ytitle("BMI PGI LDPRED (UKB+GIANT)", size(small)) xtitle("BMI PGI LDPRED (GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph4.gph, replace
drop 	pop

**
bys 	dec_bmi_ukb_ld dec_bmi_giant_ld: gen pop = _N
twoway 	(scatter dec_bmi_ukb_ld dec_bmi_giant_ld [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(e)") ///
	ytitle("BMI PGI LDPRED (UKB)", size(small)) xtitle("BMI PGI LDPRED (GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph5.gph, replace
drop 	pop

graph combine graph1.gph graph2.gph graph3.gph graph4.gph graph5.gph,  ///
			  scheme(s1mono) 

graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\bmi_bubbles.png", ///
             as(png) name("Graph") replace 
			
}

{*** Plots with OVERLAPPING DISTRIBUTIONS 
xtile       PGI = bmi_giant_ukb_ld, nquantiles(5)

twoway      (kdensity bmi_giant_ukb_clump if PGI==1, legend(label(1 "Q1 - BMI PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(black))     ///
            (kdensity bmi_giant_ukb_clump if PGI==2, legend(label(2 "Q2 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(black))      ///
			(kdensity bmi_giant_ukb_clump if PGI==3, legend(label(3 "Q3 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(black))  ///
			(kdensity bmi_giant_ukb_clump if PGI==4, legend(label(4 "Q4 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(black))       ///
			(kdensity bmi_giant_ukb_clump if PGI==5, legend(label(5 "Q5 - BMI PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(black)), ///
			ytitle("Density") xtitle("BMI PGI CLUMP (UKB+GIANT)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(a)")        					
            graph save graph1.gph, replace

twoway      (kdensity bmi_giant_ukb_clump_gws if PGI==1, legend(label(1 "Q1 - BMI PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(cranberry))     ///
            (kdensity bmi_giant_ukb_clump_gws if PGI==2, legend(label(2 "Q2 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(cranberry))      ///
			(kdensity bmi_giant_ukb_clump_gws if PGI==3, legend(label(3 "Q3 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(cranberry))  ///
			(kdensity bmi_giant_ukb_clump_gws if PGI==4, legend(label(4 "Q4 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(cranberry))       ///
			(kdensity bmi_giant_ukb_clump_gws if PGI==5, legend(label(5 "Q5 - BMI PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(cranberry)), ///
			ytitle("Density") xtitle("BMI PGI CLUMP GWS (UKB+GIANT)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(b)") 						
            graph save graph2.gph, replace
			
twoway      (kdensity bmi_ukb_ld if PGI==1, legend(label(1 "Q1 - BMI PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(dkorange))     ///
            (kdensity bmi_ukb_ld if PGI==2, legend(label(2 "Q2 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(dkorange))      ///
			(kdensity bmi_ukb_ld if PGI==3, legend(label(3 "Q3 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(dkorange))  ///
			(kdensity bmi_ukb_ld if PGI==4, legend(label(4 "Q4 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(dkorange))       ///
			(kdensity bmi_ukb_ld if PGI==5, legend(label(5 "Q5 - BMI PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(dkorange)), ///
			ytitle("Density") xtitle("BMI PGI LDPRED (UKB)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(c)") 						
            graph save graph3.gph, replace
			
twoway      (kdensity bmi_giant_ld if PGI==1, legend(label(1 "Q1 - BMI PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(forest_green))     ///
            (kdensity bmi_giant_ld if PGI==2, legend(label(2 "Q2 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(forest_green))      ///
			(kdensity bmi_giant_ld if PGI==3, legend(label(3 "Q3 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(forest_green))  ///
			(kdensity bmi_giant_ld if PGI==4, legend(label(4 "Q4 - BMI PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(forest_green))       ///
			(kdensity bmi_giant_ld if PGI==5, legend(label(5 "Q5 - BMI PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(forest_green)), ///
			ytitle("Density") xtitle("BMI PGI LDPRED(GIANT)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(d)") 						
            graph save graph4.gph, replace

* This one cannot change the reference PGI, so less comprehensive 
			
grc1leg     graph1.gph graph2.gph graph3.gph graph4.gph, scheme(s1mono) 
			  
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\bmi_density.png", ///
             as(png) name("Graph") replace			
drop      PGI
}

{*** Plots with RANKINGS
*gen top25 = cond(bmi_ukb_ld>r(p75),1,0)

order famid bmi_giant_ukb_ld        bmi_giant_ld         bmi_ukb_ld        /// 
            bmi_giant_ukb_clump     bmi_giant_clump      bmi_ukb_clump   

* keep random 5% of sibling sample
* start with the meta score and use 1000 siblings for reader friendliness 
preserve 

gen nID = _n
set seed 12345
sample 1000, count 		// note that there will be some siblings in this sample
gsort -bmi_giant_ukb_ld 
sum bmi_giant_ukb_ld , d
xtile quin = bmi_giant_ukb_ld , nq(5)
br bmi_giant_ukb_ld quin
gen top20 = cond(quin==5,1,0)

	
egen rank1 = rank(bmi_giant_ukb_ld)
egen rank2 = rank(bmi_giant_ld)
egen rank3 = rank(bmi_ukb_ld)
egen rank4 = rank(bmi_giant_ukb_clump)
egen rank5 = rank(bmi_giant_clump)
egen rank6 = rank(bmi_ukb_clump)

reshape long rank, i(nID) j(type)
label def type 1 "GIANT+UKB (LDpred)"    2 "GIANT (LDpred)"    3 "UKB (LDpred)" ///
               4 "GIANT+UKB (C+T)"     5 "GIANT (C+T)"     6 "UKB (C+T)"  
label val type type

twoway 	(line rank type if top20==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
        yline(800, lcolor(red)) ///
		ytitle("UKB+GIANT (LDpred) rank", size(small)) ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)6, labsize(small) labels angle(vertical) valuelabel) scheme(s1mono) ///
		legend(off) aspectratio(1)

/*twoway 	(line rank type if top10==0, lcolor(gs12) lwidth(vvvthin) connect(ascending)) ///
		(line rank type if top10==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
		ytitle("Rank based on PGI UKB") ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB")
*/
		
* could add a threshold line 
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\bmi_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 

}
}
*************************** HEIGHT INDICES *************************************
*** Final Selection of the Scores			               
* Height UKBldpred, UKBplink, UKBplinkgws,
*        giantldpred, giantplink, giantplinkgws
*        metagiantldpred, metagiantplink, metagiantgws  

global heightpgi height_ukb_ld        height_giant_ld        height_ukb_giant_ld ///  
                 height_ukb_clump     height_giant_clump     height_ukb_giant_clump /// 
                 height_ukb_clump_gws height_giant_clump_gws height_giant_ukb_clump_gws  

*** Standardizing 
foreach i in $heightpgi {
	sum `i', detail
	sca m = r(mean)
	sca sd = r(sd)
	replace `i' = (`i' - m)/sd
	}

replace height_ukb_clump_gws = (-1)*height_ukb_clump_gws	
replace height_giant_clump_gws = (-1)*height_giant_clump_gws
corr $heightpgi

{*** Heatplot 	
corr $heightpgi
matrix C = r(C)
heatplot C, color(hcl, diverging intensity(.6)) ///
            aspectratio(1) ylabel(,labsize(small)) ylabel(,angle(0)) ///
			xlabel(,labsize(small)) xlabel(,angle(90)) lower nodiagonal
}
					
{*** Incremental R2
foreach i in $heightpgi {
	eststo M`i': reg height `i' $controls, robust
} 
eststo M0: reg height $controls, robust

esttab M0 M*, ///
       noomitted nobase se star(* 0.10 ** 0.05 *** 0.01) ///
       stats(r2 N, fmt(3 0)) drop(e_PC_* *.MoB *.YoB sex) se(3) b(3)
est drop _all
}

{*** PLOTS with DECILES 
*** plots showing substantial amount of variability in relationship between any two DECILES
* Create the deciles 
foreach i in $heightpgi {
	xtile dec_`i' = `i', nq(10)
} 

pwcorr 	dec*

**
bys 	dec_height_ukb_giant_ld dec_height_ukb_giant_clump: gen pop = _N
twoway 	(scatter dec_height_ukb_giant_ld dec_height_ukb_giant_clump [w=pop], msymbol(circle_hollow) mcolor(navy)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(a)") ///
	ytitle("Height PGI LDPRED (UKB+GIANT)", size(small)) xtitle("Height PGI CLUMP (UKB+GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save graph1.gph, replace
drop 	pop


**
bys 	dec_height_ukb_giant_ld dec_height_giant_ukb_clump_gws: gen pop = _N
twoway 	(scatter dec_height_ukb_giant_ld dec_height_giant_ukb_clump_gws [w=pop], msymbol(circle_hollow) mcolor(cranberry)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(b)") ///
	ytitle("Height PGI LDPRED (UKB+GIANT)", size(small)) xtitle("Height PGI CLUMP GWS (UKB+GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph2.gph, replace
drop 	pop


** 
bys 	dec_height_ukb_giant_ld dec_height_ukb_ld: gen pop = _N
twoway 	(scatter dec_height_ukb_giant_ld dec_height_ukb_ld [w=pop], msymbol(circle_hollow) mcolor(forest_green)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(c)") ///
	ytitle("Height PGI LDPRED (UKB+GIANT)", size(small)) xtitle("Height PGI LDPRED (UKB)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph3.gph, replace
drop 	pop

**
bys 	dec_height_ukb_giant_ld dec_height_giant_ld: gen pop = _N
twoway 	(scatter dec_height_ukb_giant_ld dec_height_giant_ld [w=pop], msymbol(circle_hollow) mcolor(teal)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(d)") ///
	ytitle("Height PGI LDPRED (UKB+GIANT)", size(small)) xtitle("Height PGI LDPRED (GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph4.gph, replace
drop 	pop

**
bys 	dec_height_ukb_ld dec_height_giant_ld: gen pop = _N
twoway 	(scatter dec_height_ukb_ld dec_height_giant_ld [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(e)") ///
	ytitle("Height PGI LDPRED (UKB)", size(small)) xtitle("Height PGI LDPRED (GIANT)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph5.gph, replace
drop 	pop

graph combine graph1.gph graph2.gph graph3.gph graph4.gph graph5.gph,  ///
			  scheme(s1mono) 

graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\height_bubbles.png", ///
             as(png) name("Graph") replace 
			
}
			 
{*** Plots with OVERLAPPING DISTRIBUTIONS 
xtile       PGI = height_ukb_giant_ld, nquantiles(5)

twoway      (kdensity height_ukb_giant_clump if PGI==1, legend(label(1 "Q1 - Height PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(black))     ///
            (kdensity height_ukb_giant_clump if PGI==2, legend(label(2 "Q2 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(black))      ///
			(kdensity height_ukb_giant_clump if PGI==3, legend(label(3 "Q3 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(black))  ///
			(kdensity height_ukb_giant_clump if PGI==4, legend(label(4 "Q4 - Height PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(black))       ///
			(kdensity height_ukb_giant_clump if PGI==5, legend(label(5 "Q5 - Height PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(black)), ///
			ytitle("Density") xtitle("Height PGI CLUMP (UKB+GIANT)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(a)")        					
            graph save graph1.gph, replace

twoway      (kdensity height_giant_ukb_clump_gws if PGI==1, legend(label(1 "Q1 - Height PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(cranberry))     ///
            (kdensity height_giant_ukb_clump_gws if PGI==2, legend(label(2 "Q2 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(cranberry))      ///
			(kdensity height_giant_ukb_clump_gws if PGI==3, legend(label(3 "Q3 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(cranberry))  ///
			(kdensity height_giant_ukb_clump_gws if PGI==4, legend(label(4 "Q4 - Height PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(cranberry))       ///
			(kdensity height_giant_ukb_clump_gws if PGI==5, legend(label(5 "Q5 - Height PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(cranberry)), ///
			ytitle("Density") xtitle("Height PGI CLUMP GWS (UKB+GIANT)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(b)")						
            graph save graph2.gph, replace
			
twoway      (kdensity height_ukb_ld if PGI==1, legend(label(1 "Q1 - Height PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(dkorange))     ///
            (kdensity height_ukb_ld if PGI==2, legend(label(2 "Q2 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(dkorange))      ///
			(kdensity height_ukb_ld if PGI==3, legend(label(3 "Q3 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(dkorange))  ///
			(kdensity height_ukb_ld if PGI==4, legend(label(4 "Q4 - Height PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(dkorange))       ///
			(kdensity height_ukb_ld if PGI==5, legend(label(5 "Q5 - Height PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(dkorange)), ///
			ytitle("Density") xtitle("Height PGI LDPRED (UKB)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(c)") 						
            graph save graph3.gph, replace
			
twoway      (kdensity height_giant_ld if PGI==1, legend(label(1 "Q1 - Height PGI LDpred (UKB+GIANT)")) lpattern(solid) lcolor(forest_green))     ///
            (kdensity height_giant_ld if PGI==2, legend(label(2 "Q2 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash) lcolor(forest_green))      ///
			(kdensity height_giant_ld if PGI==3, legend(label(3 "Q3 - Height PGI LDpred (UKB+GIANT)")) lpattern(dash_dot) lcolor(forest_green))  ///
			(kdensity height_giant_ld if PGI==4, legend(label(4 "Q4 - Height PGI LDpred (UKB+GIANT)")) lpattern(dot) lcolor(forest_green))       ///
			(kdensity height_giant_ld if PGI==5, legend(label(5 "Q5 - Height PGI LDpred (UKB+GIANT)")) lpattern(longdash) lcolor(forest_green)), ///
			ytitle("Density") xtitle("Height PGI LDPRED (GIANT)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(d)")  						
            graph save graph4.gph, replace

* This one cannot change the reference PGI, so less comprehensive 
			
grc1leg     graph1.gph graph2.gph graph3.gph graph4.gph, scheme(s1mono) 
			  
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\height_density.png", ///
             as(png) name("Graph") replace			
drop      PGI
}

{*** Plots with RANKINGS		

order famid height_ukb_giant_ld        height_giant_ld         height_ukb_ld        /// 
            height_ukb_giant_clump     height_giant_clump      height_ukb_clump     

* keep random 5% of sibling sample
* start with the meta score and use 1000 siblings for reader friendliness 
preserve 

gen nID = _n
set seed 12345
sample 1000, count  // note that there will be some siblings in this sample
gsort -height_ukb_giant_ld 
sum height_ukb_giant_ld , d
xtile quin = height_ukb_giant_ld , nq(5)
br height_ukb_giant_ld quin
gen top20 = cond(quin==5,1,0)

egen rank1 = rank(height_ukb_giant_ld)
egen rank2 = rank(height_giant_ld)
egen rank3 = rank(height_ukb_ld)
egen rank4 = rank(height_ukb_giant_clump)
egen rank5 = rank(height_giant_clump)
egen rank6 = rank(height_ukb_clump)

count if rank1>=800 
count if top20==1 & rank1>=800 & rank2>=800 & rank3>=800 & rank4>=800 & rank5>=800 & rank6>=800
count if top20==1 & rank1<=800
count if top20==1 & rank2<=800
count if top20==1 & rank3<=800
count if top20==1 & rank4<=800
count if top20==1 & rank5<=800
count if top20==1 & rank6<=800


reshape long rank, i(nID) j(type)
label def type 1 "GIANT+UKB (LDpred)"    2 "GIANT (LDpred)"    3 "UKB (LDpred)" ///
               4 "GIANT+UKB (C+T)"     5 "GIANT (C+T)"     6 "UKB (C+T)" 
			
label val type type

twoway 	(line rank type if top20==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
        yline(800, lcolor(red)) ///
		ytitle("UKB+GIANT (LDpred) rank", size(small)) ylabel(0(100)1000, angle(horizontal) labsize(small)) xtitle("") ///
		xlabel(1(1)6, labsize(small) labels angle(25) valuelabel) scheme(s1mono) ///
		legend(off) aspectratio(1)
		
/*twoway 	(line rank type if top10==0, lcolor(gs12) lwidth(vvvthin) connect(ascending)) ///
		(line rank type if top10==1, lcolor(black) lwidth(vvthin) connect(ascending)), ///
		ytitle("Rank based on PGI UKB") ylabel(0(100)1000, labsize(vsmall)) xtitle("") ///
		xlabel(1(1)9, labsize(vsmall) labels angle(forty_five) valuelabel) scheme(s1mono) ///
		legend(off) note("Using a random 1000 participants of the sibling sample of the UKB")
*/
		
* could add a threshold line 
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\height_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 

}
***************************** CVD INDICES **************************************

* CVD    UKBldpred, UKBplink, UKBplinkgws,
*        cardioldpred, cardioplink, cardioplinkgws
*        metacardioldpred, metacardioplink, metacardioplinkgws 
replace cvd_cardio_clump_gws = (-1)*cvd_cardio_clump_gws
replace cvd_ukb_clump_gws = (-1)*cvd_ukb_clump_gws
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
			 		 
{*** Incremental R2			
global cvdpgi   cvd_cardio_ukb_ld         cvd_ukb_ld             cvd_cardio_ld        ///
		        cvd_cardio_ukb_clump      cvd_ukb_clump          cvd_cardio_clump 
	
global controls sex i.YoB i.MoB e_PC*
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
}
							 
{*** PLOTS with DECILES 
*** plots showing substantial amount of variability in relationship between any two DECILES
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
	title("(a)") ///
	ytitle("CVD PGI LDPRED (UKB+CARDIOGRAM)", size(small)) xtitle("CVD PGI CLUMP (UKB+CARDIOGRAM)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph save graph1.gph, replace
drop 	pop


**
bys 	dec_cvd_cardio_ukb_ld dec_cvd_ukb_cardio_clump_gws: gen pop = _N
twoway 	(scatter dec_cvd_cardio_ukb_ld dec_cvd_ukb_cardio_clump_gws [w=pop], msymbol(circle_hollow) mcolor(cranberry)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(b)") ///
	ytitle("CVD PGI LDPRED (UKB+CARDIOGRAM)", size(small)) xtitle("CVD PGI CLUMP GWS (UKB+CARDIOGRAM)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph2.gph, replace
drop 	pop


** 
bys 	dec_cvd_cardio_ukb_ld dec_cvd_ukb_ld: gen pop = _N
twoway 	(scatter dec_cvd_cardio_ukb_ld dec_cvd_ukb_ld [w=pop], msymbol(circle_hollow) mcolor(forest_green)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(c)") ///
	ytitle("CVD PGI LDPRED (UKB+CARDIOGRAM)", size(small)) xtitle("CVD PGI LDPRED (UKB)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph3.gph, replace
drop 	pop

**
bys 	dec_cvd_cardio_ukb_ld dec_cvd_cardio_ld: gen pop = _N
twoway 	(scatter dec_cvd_cardio_ukb_ld dec_cvd_cardio_ld [w=pop], msymbol(circle_hollow) mcolor(teal)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(d)") ///
	ytitle("CVD PGI LDPRED (UKB+CARDIOGRAM)", size(small)) xtitle("CVD PGI LDPRED (CARDIOGRAM)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph4.gph, replace
drop 	pop

**
bys 	dec_cvd_ukb_ld dec_cvd_cardio_ld: gen pop = _N
twoway 	(scatter dec_cvd_ukb_ld dec_cvd_cardio_ld [w=pop], msymbol(circle_hollow) mcolor(dkorange)) ///
	, ///
	legend(off) aspectratio(1) ylabel(1(1)10, labsize(small)) xlabel(1(1)10, labsize(small)) ///
	title("(e)") ///
	ytitle("CVD PGI LDPRED (UKB)", size(small)) xtitle("CVD PGI LDPRED (CARDIOGRAM)", size(small)) ///
	scheme(s1mono) plotregion(margin(large) style(none))
graph 	save graph5.gph, replace
drop 	pop

graph combine graph1.gph graph2.gph graph3.gph graph4.gph graph5.gph,  ///
			  scheme(s1mono) 

graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\cvd_bubbles.png", ///
             as(png) name("Graph") replace 
			
}			 

{*** Plots with OVERLAPPING DISTRIBUTIONS 
xtile       PGI = cvd_cardio_ukb_ld, nquantiles(5)

twoway      (kdensity cvd_cardio_ukb_clump if PGI==1, legend(label(1 "Q1 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(solid) lcolor(black))     ///
            (kdensity cvd_cardio_ukb_clump if PGI==2, legend(label(2 "Q2 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash) lcolor(black))      ///
			(kdensity cvd_cardio_ukb_clump if PGI==3, legend(label(3 "Q3 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash_dot) lcolor(black))  ///
			(kdensity cvd_cardio_ukb_clump if PGI==4, legend(label(4 "Q4 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dot) lcolor(black))       ///
			(kdensity cvd_cardio_ukb_clump if PGI==5, legend(label(5 "Q5 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(longdash) lcolor(black)), ///
			ytitle("Density") xtitle("CVD PGI CLUMP (UKB+CARDIOGRAM)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(a)")         				
            graph save graph1.gph, replace

twoway      (kdensity cvd_ukb_cardio_clump_gws if PGI==1, legend(label(1 "Q1 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(solid) lcolor(cranberry))     ///
            (kdensity cvd_ukb_cardio_clump_gws if PGI==2, legend(label(2 "Q2 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash) lcolor(cranberry))      ///
			(kdensity cvd_ukb_cardio_clump_gws if PGI==3, legend(label(3 "Q3 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash_dot) lcolor(cranberry))  ///
			(kdensity cvd_ukb_cardio_clump_gws if PGI==4, legend(label(4 "Q4 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dot) lcolor(cranberry))       ///
			(kdensity cvd_ukb_cardio_clump_gws if PGI==5, legend(label(5 "Q5 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(longdash) lcolor(cranberry)), ///
			ytitle("Density") xtitle("CVD PGI CLUMP GWS (UKB+CARDIOGRAM)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(b)")					
            graph save graph2.gph, replace
			
twoway      (kdensity cvd_ukb_ld if PGI==1, legend(label(1 "Q1 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(solid) lcolor(dkorange))     ///
            (kdensity cvd_ukb_ld if PGI==2, legend(label(2 "Q2 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash) lcolor(dkorange))      ///
			(kdensity cvd_ukb_ld if PGI==3, legend(label(3 "Q3 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash_dot) lcolor(dkorange))  ///
			(kdensity cvd_ukb_ld if PGI==4, legend(label(4 "Q4 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dot) lcolor(dkorange))       ///
			(kdensity cvd_ukb_ld if PGI==5, legend(label(5 "Q5 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(longdash) lcolor(dkorange)), ///
			ytitle("Density") xtitle("CVD PGI LDPRED (UKB)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(c)")						
            graph save graph3.gph, replace
			
twoway      (kdensity cvd_cardio_ld  if PGI==1, legend(label(1 "Q1 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(solid) lcolor(forest_green))     ///
            (kdensity cvd_cardio_ld  if PGI==2, legend(label(2 "Q2 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash) lcolor(forest_green))      ///
			(kdensity cvd_cardio_ld  if PGI==3, legend(label(3 "Q3 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dash_dot) lcolor(forest_green))  ///
			(kdensity cvd_cardio_ld  if PGI==4, legend(label(4 "Q4 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(dot) lcolor(forest_green))       ///
			(kdensity cvd_cardio_ld  if PGI==5, legend(label(5 "Q5 - CVD PGI LDpred (UKB+CARDIOGRAM)")) lpattern(longdash) lcolor(forest_green)), ///
			ytitle("Density") xtitle("CVD PGI LDPRED (CARDIOGRAM)") scheme(s1mono) xlabel(-3(1)3) legend(size(small)) title("(d)") 						
            graph save graph4.gph, replace

* This one cannot change the reference PGI, so less comprehensive 
			
grc1leg     graph1.gph graph2.gph graph3.gph graph4.gph, scheme(s1mono) 
			  
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\cvd_density.png", ///
             as(png) name("Graph") replace			
drop      PGI

}

{*** Plots with RANKINGS
	
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
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\cvd_statariver.png", ///
             as(png) name("Graph") replace	
			 
drop rank* nID top20 drop quin			

restore 

*title("Variability in individuals' ranks with different EA PGIs") 
}

{
*** Replicate Rita's GxE analysis for CVD 
global cvd_pgs	cvd_cardio_ukb_ld        cvd_cardio_ld         cvd_ukb_ld         /// 
                cvd_cardio_ukb_clump     cvd_cardio_clump      cvd_ukb_clump   
				     
global PCs      e_PC_1 e_PC_2 e_PC_3 e_PC_4 e_PC_5 e_PC_6 e_PC_7 e_PC_8 e_PC_9 e_PC_10 ///
		        e_PC_11 e_PC_12 e_PC_13 e_PC_14 e_PC_15 e_PC_16 e_PC_17 e_PC_18 e_PC_19 e_PC_20 ///
		        e_PC_21 e_PC_22 e_PC_23 e_PC_24 e_PC_25 e_PC_26 e_PC_27 e_PC_28 e_PC_29 e_PC_30 ///
		        e_PC_31 e_PC_32 e_PC_33 e_PC_34 e_PC_35 e_PC_36 e_PC_37 e_PC_38 e_PC_39 e_PC_40 

//checking number of observations
sum YoB
sum $cvd_pgs if famid!=.

forval x = 1934 (1) 1971 {
display `x'
count if famid!=. & YoB==`x'
}

//lets pick YoB with at least 500 siblings, 1939 to 1966
keep if YoB >=1939 & YoB <=1966
sum YoB			

//label new variables 
label var cvd_cardio_ukb_ld "CARDIoGRAM+UKB (LDpred)"
label var cvd_cardio_ld "CARDIoGRAM (LDpred)"
label var cvd_ukb_ld "UKB (LDpred)"
label var cvd_cardio_ukb_clump "CARDIoGRAM+UKB (C+T)" 
label var cvd_cardio_clump "CARDIoGRAM (C+T)"
label var cvd_ukb_clump "UKB (C+T)"

// Analysis 
graph set window fontface default

foreach y of global cvd_pgs {
regress IHD_icd `y' YoB c.YoB#c.`y' ${PCs} if famid!=. , vce(robust)
estimates store `y'
}

coefplot    (cvd_cardio_ukb_ld, label(CARDIoGRAM+UKB (LDpred)))  (cvd_cardio_ld, label(CARDIoGRAM (LDpred))) ///
			(cvd_ukb_ld, label(UKB (LDpred)))  (cvd_cardio_ukb_clump, label(CARDIoGRAM+UKB (C+T))) ///
			(cvd_cardio_clump, label(CARDIoGRAM (C+T))) (cvd_ukb_clump, label(UKB (C+T))), ///
			keep(c.YoB#c.cvd_cardio_ukb_ld					 	  c.YoB#c.cvd_cardio_ld ///
			       c.YoB#c.cvd_ukb_ld							  c.YoB#c.cvd_cardio_ukb_clump ///
			       c.YoB#c.cvd_cardio_clump 				      c.YoB#c.cvd_ukb_clump) ///
			vertical ///
			title ("Year of Birth x CVD PGS") ///
			graphregion(color(white)) ///
			ylabel(-0.001(0.001)0.001) yline(0, lcolor(gs7)) coeflabels( * = "	", noticks)
			
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\interaction_YOB_CVDPGS.png", replace

// Robust ses

foreach y of global cvd_pgs {
areg IHD_icd `y' YoB c.YoB#c.`y' ${PCs} if famid!=. , absorb(famid) vce(cluster famid)
estimates store `y'
}

coefplot    (cvd_cardio_ukb_ld, label(CARDIoGRAM+UKB (LDpred)))  (cvd_cardio_ld, label(CARDIoGRAM (LDpred))) ///
			(cvd_ukb_ld, label(UKB (LDpred)))  (cvd_cardio_ukb_clump, label(CARDIoGRAM+UKB (C+T))) ///
			(cvd_cardio_clump, label(CARDIoGRAM (C+T))) (cvd_ukb_clump, label(UKB (C+T))), ///
			keep(c.YoB#c.cvd_cardio_ukb_ld					 	  c.YoB#c.cvd_cardio_ld ///
			       c.YoB#c.cvd_ukb_ld							  c.YoB#c.cvd_cardio_ukb_clump ///
			       c.YoB#c.cvd_cardio_clump 				      c.YoB#c.cvd_ukb_clump) ///
			vertical ///
			title ("Year of Birth x CVD PGS") ///
			graphregion(color(white)) ///
			ylabel(-0.001(0.001)0.001) yline(0, lcolor(gs7)) coeflabels( * = "	", noticks)
			
graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\interaction_YOB_CVDPGS_robust.png", replace

//NO GWS, quintiles
			foreach y of global cvd_pgs {
			//gen quintile
			xtile `y'_qtl = `y' , nq(5)
			}
			
			foreach y of global cvd_pgs {
			//regress and store
			regress IHD_icd YoB ib3.`y'_qtl c.YoB#ib3.`y'_qtl ${PCs} if famid!=. , vce(robust)
			test c.YoB#1.`y'_qtl = c.YoB#5.`y'_qtl
			scalar F_`y' = r(p)
			test c.YoB#4.`y'_qtl = c.YoB#5.`y'_qtl
			scalar FF`y' = r(p)
			test c.YoB#1.`y'_qtl = c.YoB#2.`y'_qtl
			scalar FS`y' = r(p)
			estimates store `y'_1
			}
			
			foreach y of global cvd_pgs {
			//1st and 5th
			display F_`y'
			}
			
			foreach y of global cvd_pgs {
			//4th and 5th
			display FF`y'
			}
			
			foreach y of global cvd_pgs {
			//4th and 5th
			display FS`y'
			}
			
global cvd_pgs	cvd_cardio_ukb_ld        cvd_cardio_ld         cvd_ukb_ld         /// 
                cvd_cardio_ukb_clump     cvd_cardio_clump      cvd_ukb_clump   
			
			coefplot    (cvd_cardio_ukb_ld_1, label(CARDIoGRAM+UKB (LDpred)))   (cvd_cardio_ukb_clump_1, label(CARDIoGRAM+UKB (C+T))) ///
						(cvd_cardio_ld_1, label(CARDIoGRAM (LDpred))) (cvd_cardio_clump_1, label(CARDIoGRAM (C+T))) ///
						(cvd_ukb_ld_1, label(UKB (LDpred)))  (cvd_ukb_clump_1, label(UKB (C+T))) , ///
						drop(YoB *qtl e_PC_* _cons) ///
			vertical ///
			graphregion(color(white)) ///
			coeflabels( 1.* = "1" 2.* = "2" 4.* = "4" 5.* = "5") ///
			groups(*cvd_cardio_ukb_ld* = "	" *cvd_cardio_ukb_clump* = "	" *cvd_cardio_ld* = ///
			"	" *cvd_cardio_clump* = "	" *cvd_ukb_ld* = "	" *cvd_ukb_clump* = "	") ///
			ytitle("IHD_icd") xtitle("Quantiles of the CVD PGI x YoB") ///
			ylabel(, format(%5.3f)) yline(0, lcolor(gs7)) saving(quintiles, replace) fysize(220) fxsize(80)
			
			graph export "GEIGHEI\projects\PGS ranking\Analysis\Output\interaction_YOB_CVDPGS_order_discovery_sample_quintiles.png", replace
			
			*graph combine continuous_nolegend.gph quintiles.gph, col(1) graphregion(color(white))
			*graph export "${graphs}\interaction_YOB_EAPGS_merged.png", replace
			
			
			
outreg2 [${cvd_pgs}] using "GEIGHEI\projects\PGS ranking\Analysis\Output\interaction_YOB_CVDPGS", excel see replace drop(${PCs} constant) dec(2) label

esttab  ${cvd_pgs} using "GEIGHEI\projects\PGS ranking\Analysis\Output\interaction_YOB_CVDPGS.rtf", ///
		drop(${PCs}) stats(r2 N, fmt(%9.3f %9.0g)  labels(R-squared)) ///
		cells(b(star fmt(%9.2f))) varlabels(_cons Constant) ///
		label varwidth(9.0) modelwidth(2.0) replace

		
		
//test difference

//graph again
coefplot    (cvd_cardio_ukb_ld, label(CARDIoGRAM+UKB (LDpred)))  (cvd_cardio_ld, label(CARDIoGRAM (LDpred))) ///
			(cvd_ukb_ld, label(UKB (LDpred)))  (cvd_cardio_ukb_clump, label(CARDIoGRAM+UKB (C+T))) ///
			(cvd_cardio_clump, label(CARDIoGRAM (C+T))) (cvd_ukb_clump, label(UKB (C+T))), ///
			keep(c.YoB#c.cvd_cardio_ukb_ld					 	  c.YoB#c.cvd_cardio_ld ///
			       c.YoB#c.cvd_ukb_ld							  c.YoB#c.cvd_cardio_ukb_clump ///
			       c.YoB#c.cvd_cardio_clump 				      c.YoB#c.cvd_ukb_clump) ///
			vertical ///
			title ("Year of Birth x CVD PGS") ///
			graphregion(color(white)) ///
			ylabel(-0.001(0.001)0.001) yline(0, lcolor(gs7)) coeflabels( * = "	", noticks)

//these two are ss diferent from each other, so test needs to reject
reg3 (IHD_icd cvd_cardio_clump YoB c.YoB#c.cvd_cardio_clump ${PCs} if famid!=.) (IHD_icd cvd_ukb_ld YoB c.YoB#c.cvd_ukb_ld ${PCs} if famid!=.), ols
test c.YoB#c.cvd_cardio_clump = c.YoB#c.cvd_ukb_ld //Prob > F =   

//these two are not ss different from each other, so test cannot reject
reg3 (IHD_icd cvd_cardio_ukb_ld YoB c.YoB#c.cvd_cardio_ukb_ld ${PCs} if famid!=.) (IHD_icd cvd_cardio_ukb_clump YoB c.YoB#c.cvd_cardio_ukb_clump ${PCs} if famid!=.), ols
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_cardio_ukb_clump //Prob > F =    


//perfect!! now lets run everything
reg3 (IHD_icd cvd_cardio_ukb_ld YoB c.YoB#c.cvd_cardio_ukb_ld ${PCs} if famid!=.) (IHD_icd cvd_cardio_ukb_clump YoB c.YoB#c.cvd_cardio_ukb_clump ${PCs} if famid!=.) ///
	 (IHD_icd cvd_cardio_ld YoB c.YoB#c.cvd_cardio_ld ${PCs} if famid!=.) (IHD_icd cvd_cardio_clump YoB c.YoB#c.cvd_cardio_clump ${PCs} if famid!=.) ///
	 (IHD_icd cvd_ukb_ld YoB c.YoB#c.cvd_ukb_ld ${PCs} if famid!=.) (IHD_icd cvd_ukb_clump YoB c.YoB#c.cvd_ukb_clump ${PCs} if famid!=.) ///
	 , ols


//test them all together
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_cardio_ukb_clump = c.YoB#c.cvd_cardio_ld = c.YoB#c.cvd_cardio_clump = c.YoB#c.cvd_ukb_ld = c.YoB#c.cvd_ukb_clump
//F-stat=3.55 p-val 0.0033
* reject the null that they are all the same

//15 pairwise tests
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_cardio_ukb_clump // 0.8799 SAME
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_cardio_ld // 0.1121 SAME 
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_cardio_clump // 0.0330 DIFFERENT 1 
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_ukb_ld // 0.2522 SAME
test c.YoB#c.cvd_cardio_ukb_ld = c.YoB#c.cvd_ukb_clump //0.3048 SAME 
 
test c.YoB#c.cvd_cardio_ukb_clump = c.YoB#c.cvd_cardio_ld  // 0.1516 SAME 
test c.YoB#c.cvd_cardio_ukb_clump = c.YoB#c.cvd_cardio_clump // 0.0481 DIFFERENT 2 
test c.YoB#c.cvd_cardio_ukb_clump = c.YoB#c.cvd_ukb_ld // 0.1962 SAME 
test c.YoB#c.cvd_cardio_ukb_clump = c.YoB#c.cvd_ukb_clump// 0.2406 SAME

test c.YoB#c.cvd_cardio_ld = c.YoB#c.cvd_cardio_clump // 0.5855 SAME 
test c.YoB#c.cvd_cardio_ld = c.YoB#c.cvd_ukb_ld // 0.0065 DIFFERENT 3
test c.YoB#c.cvd_cardio_ld = c.YoB#c.cvd_ukb_clump // 0.0093 DIFFERENT 4

test c.YoB#c.cvd_cardio_clump = c.YoB#c.cvd_ukb_ld // 0.0011 DIFFERENT 5 
test c.YoB#c.cvd_cardio_clump = c.YoB#c.cvd_ukb_clump // 0.0017 DIFFERENT 6

test c.YoB#c.cvd_ukb_ld = c.YoB#c.cvd_ukb_clump // 0.9077 SAME

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


//UKB LD vs CARDIoGRAM LD
reg3 (IHD_icd cvd_ukb_ld YoB c.YoB#c.cvd_ukb_ld ${PCs} if famid!=.) (IHD_icd cvd_cardio_ld YoB c.YoB#c.cvd_cardio_ld ${PCs} if famid!=.), ols
test c.YoB#c.cvd_ukb_ld = c.YoB#c.cvd_cardio_ld //Prob > F =    


//UKB LD vs 23andme CLUMP
//test
regress IHD_icd cvd_ukb_ld YoB c.YoB#c.cvd_ukb_ld ${PCs} if famid!=.
regress IHD_icd cvd_cardio_clump YoB c.YoB#c.cvd_cardio_clump ${PCs} if famid!=.

reg3 (IHD_icd cvd_ukb_ld YoB c.YoB#c.cvd_ukb_ld ${PCs} if famid!=.) (IHD_icd cvd_cardio_clump YoB c.YoB#c.cvd_cardio_clump ${PCs} if famid!=.), ols
	  
test c.YoB#c.cvd_ukb_ld = c.YoB#c.cvd_cardio_clump  //Prob > F =    


//UKB CLUMP vs CARDIoGRAM LD

reg3 (IHD_icd cvd_ukb_clump YoB c.YoB#c.cvd_ukb_clump ${PCs} if famid!=.) (IHD_icd cvd_cardio_ld YoB c.YoB#c.cvd_cardio_ld ${PCs} if famid!=.), ols

test c.YoB#c.cvd_ukb_clump = c.YoB#c.cvd_cardio_ld //Prob > F =    


//UKB CLUMP vs CARDIoGRAM CLUMP

reg3 (IHD_icd cvd_ukb_clump YoB c.YoB#c.cvd_ukb_clump ${PCs} if famid!=.) (IHD_icd cvd_cardio_clump YoB c.YoB#c.cvd_cardio_clump ${PCs} if famid!=.), ols

test c.YoB#c.ukb_ukb_clump = c.YoB#c.cvd_cardio_clump // Prob > F =    
	   
}