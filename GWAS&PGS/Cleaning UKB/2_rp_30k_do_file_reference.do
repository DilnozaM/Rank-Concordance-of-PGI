
set seed 543

import delimited "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\PGS ranking\Analysis\Input\ukb_hm3_snp_sqc_consent_allchr.fam", delimiter(space, collapse) clear

duplicates tag v1, gen(dup_v1)
tab dup_v1
*no duplicates 
duplicates tag v2, gen(dup_v2)
tab dup_v2
*no duplicates 

rename v2 id_ukb
merge 1:1 id_ukb using "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\PGS ranking\Analysis\Input\Input\kinship_ukb.dta"
//i want people for who we know the kinship so will exclude the non merged

/*   

    Result                           # of obs.
    -----------------------------------------
    not matched                        41,079
        from master                        10  (_merge==1)
        from using                     41,069  (_merge==2)

    matched                           446,329  (_merge==3)
    -----------------------------------------

*/

drop if _merge != 3
*(41,079 observations deleted)

* delete everybody who is related 
drop if inkinshiptable == 1
*(140,949 observations deleted)

//generate a random variable 
generate random = runiform(0,1)
sort random

gen draft = _n

//keep if draft number is less or equal than 30 000
keep if draft <= 30000

//you are left with 30000 individuals selected randomly
export delimited v1 id_ukb using "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\PGS ranking\Analysis\Input\ID_fam_ukb_reference_30k.txt", delimiter(tab) novarnames replace
