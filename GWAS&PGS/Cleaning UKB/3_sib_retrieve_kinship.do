

clear all


//load the stata data set previously created
use "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\PGS ranking\Analysis\Input\quality_control_stata_v2.dta", clear

tab inkinshiptable
//147730 in kinship

keep id_norface id_ukb id_vu inkinshiptable

save "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\PGS ranking\Analysis\Input\kinship_ukb.dta", replace
