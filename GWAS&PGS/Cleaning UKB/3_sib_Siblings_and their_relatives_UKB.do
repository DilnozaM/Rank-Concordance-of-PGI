* IDENTIFYING RELATIONSHIPS WITH SIBLINGS IN THE UKB
* Dilnoza Muslimova, Jan 2020

clear all
capture log close

* Change to the relevant paths 

********************************************************************************
* PREPARING DATASETS 
********************************************************************************
* NOTE: All datasets are generated based on the R Code "Siblings_updated_tresholds" and then converted to .dta format 

* Opening the RL_with_relid.dta, the output file in dta form from the R code on identifying relationships
use "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\Siblings\UKB documentation\Output\RL_with_relid_UKB.dta" 

* Merging the above file with the Siblinns' file will help identify all the invididual siblings who have 2nd and 3rd degree relatives 
merge 1:1 ID using "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\Siblings\UKB documentation\Output\FS_with_famid_UKB.dta"

* Mergin in the Parent_child file 
merge 1:1 ID using "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\Siblings\UKB documentation\Output\PC_with_pcid_UKB.dta", gen(_merge1)

*Some individuals have a negative personal ID
drop if ID<0 /* Dropping 17 more individuals */

********************************************************************************
* IDENTIFICATION OF RELATEDNESS TO SIBLINGS
********************************************************************************

*2nd and 3rd degree relatives 
*Identify all siblings and their relatives (by relationshionship id we assign every other family member a status of being a relative to this sibling)
sort relid
by relid: egen sibling_relative=max(_merge) /*-merge==3 indicates that a sibling matched with a relatives file, thus has relatives*/

*Code the relatives of the siblings who are not sibling pairs themselves 
generate relationship=0
replace relationship=1 if FS==1 /*fs_fs is a sibling pair identified in the sibling R output*/
replace relationship=2 if sibling_relative==3 & FS!=1 


* Repeat the same procedure with parents
*Identify all siblings and their parents (by parent child id we assign everybody who is a parent in this family)
sort pcid
by pcid: egen parent_child=max(_merge1)

*Code the parents of the siblings or children of the siblings who are not sibling pairs themselves 
replace relationship=3 if parent_child==3 & FS!=1 

*Assign value labels to the relationship variable 
label define relationship 1 "full sibling" 2 "2nd or 3rd Relative of a sibling" 3 "Parent/child of a sibling" 0 "Not related to siblings"
label values relationship relationship
tab relationship 

********************************************************************************
* IDENTIFYING SIBLING GROUPS RELATED TO EACH OTHER: E.G. COUSINS or PARENTS
********************************************************************************
* COUSINS

* Create an indicator for related siblings
gen rel_siblings=(FS==1 & sibling_relative==3) 

* Check construction
sort relid famid
br ID relationship FS famid relid rel_siblings if rel_siblings==1
/* Makes sense in general on the first glance, different family ID, same relative ID, rel_sibling dummy shows 1,
doesn't work for siblings with no other relatives, still shows them as 2nd or 3rd related */

egen tag=tag(famid relid) /*Assigns 1 for every unique famid within relid */
egen unique_famid_in_relid=total(tag), by(relid)

* Check construction 
sort relid famid
br ID relationship FS famid relid rel_siblings tag unique_famid_in_relid if rel_siblings==1

* Recoding siblings with no relatives in the relative group 
replace rel_siblings=0 if unique_famid_in_relid==1 /*These guys are just siblings to each other*/
* There are 1,716 siblings related as 2nd or 3rd degree relatives . 
* Label for clarity'
label define rel_siblings 1 "Siblings-Cousins" 0 "Otherwise"
label values rel_siblings rel_siblings
 

* PARENTS 
* Create an indicator for parent-siblings
gen pc_siblings=(FS==1 & parent_child==3) 
* Check construction
sort pcid famid
br ID relationship FS famid pcid pc_siblings if pc_siblings==1
egen tag_pc_fs=tag(famid pcid) /* Assigns 1 for every unique famid within pcid */
egen unique_famid_in_pcid=total(tag_pc_fs), by(pcid)
replace pc_siblings=0 if unique_famid_in_pcid==1 /* These guys are just siblings to each other */
* There are 87 parents with their siblings and their children in the data, e.g. my mom and her brother and me and my sister 
label define pc_siblings 1 "Both, parents and children are in siblings" 0 "Otherwise"
label values pc_siblings pc_siblings

********************************************************************************
* CLEANING THE DATASET OF THE IRRELEVANT VARIABLES FOR FURTHER USE 
********************************************************************************

keep ID relid famid pcid relationship FS RL PC rel_siblings pc_siblings
save "Dropbox (Erasmus Universiteit Rotterdam)\GEIGHEI\projects\Siblings\Output\Relatedness_to_siblings_UKB.dta", replace 
