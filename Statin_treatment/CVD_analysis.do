clear all
set maxvar 100000

use "path\PGS ranking\Analysis\Input\PGS_ldpred_plink_EA_height_cvd.dta", clear
merge 1:1 ID using "path\UKB\Norface\UKB_smallset_CVD_inouye.dta",nogen

global controls sex i.YoB e_PC*


tab IHD_icd
tab IHD_inouye

drop if famid ==. 
drop if cvd_cardio_ukb_ld ==.

tab IHD_icd
tab IHD_inouye

pwcorr IHD_icd cvd_cardio_ukb_ld cvd_cardio_ukb_clump cvd_cardio_ld cvd_ukb_ld

/*


    IHD_icd |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     36,402       92.64       92.64
          1 |      2,894        7.36      100.00
------------+-----------------------------------
      Total |     39,296      100.00
*/

logit IHD_icd cvd_ukb_ld $controls, or
logit IHD_icd cvd_cardio_ld $controls, or
logit IHD_icd cvd_cardio_ukb_ld $controls, or


* residualize covariates out of pgs
foreach var in cvd_ukb_ld cvd_cardio_ld cvd_cardio_ukb_ld {
reg `var' $controls
predict `var'_resid, resid
}

* IHD incl angina etc.
logit IHD_icd cvd_cardio_ukb_ld_resid, or cluster(famid)
lroc

* IHD inouye, only MI
logit IHD_inouye cvd_cardio_ukb_ld_resid, or cluster(famid)
lroc

logit IHD_icd cvd_ukb_ld_resid, or cluster(famid)
lroc

logit IHD_icd cvd_cardio_ld_resid, or cluster(famid)
lroc


logit IHD_icd cvd_cardio_ukb_ld_resid, or cluster(famid)
* hit rate
estat classification
* hosmer lemeshow w/ 10 quantiles
estat gof, group(10) table


* CAD inouye
* MI
* self report https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=6150
* age MI https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=3894
 
* self report https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20002
* self report age https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=20009
* ICD 9 https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=41271 (main+secondary)
* ICD 10 https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=41270
* Death ICD10 https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=40002
* Age at death https://biobank.ndph.ox.ac.uk/showcase/field.cgi?id=40007


* PTCA


* CABG






 


/*

Logistic model for IHD_icd

              -------- True --------
Classified |         D            ~D  |      Total
-----------+--------------------------+-----------
     +     |         0             0  |          0
     -     |      2894         36402  |      39296
-----------+--------------------------+-----------
   Total   |      2894         36402  |      39296

Classified + if predicted Pr(D) >= .5
True D defined as IHD_icd != 0
--------------------------------------------------
Sensitivity                     Pr( +| D)    0.00%
Specificity                     Pr( -|~D)  100.00%
Positive predictive value       Pr( D| +)       .%
Negative predictive value       Pr(~D| -)   92.64%
--------------------------------------------------
False + rate for true ~D        Pr( +|~D)    0.00%
False - rate for true D         Pr( -| D)  100.00%
False + rate for classified +   Pr(~D| +)       .%
False - rate for classified -   Pr( D| -)    7.36%
--------------------------------------------------
Correctly classified                        92.64%
*/

* https://www.stata.com/features/overview/receiver-operating-characteristic/
* roc reg w/ 1,000 bootstrap
rocreg IHD_icd cvd_cardio_ukb_ld_resid

/*
Area under the ROC curve

   Status    : IHD_icd
   Classifier: cvd_cardio_ukb_ld_resid
------------------------------------------------------------------------------
             |    Observed               Bootstrap
         AUC |       Coef.       Bias    Std. Err.     [95% Conf. Interval]
-------------+----------------------------------------------------------------
             |    .6089764  -.0001176    .0054679     .5982595   .6196932  (N)
             |                                        .5978331   .6192108  (P)
             |                                        .5979668   .6195616 (BC)
------------------------------------------------------------------------------
*/
*

* roc curve
rocregplot

