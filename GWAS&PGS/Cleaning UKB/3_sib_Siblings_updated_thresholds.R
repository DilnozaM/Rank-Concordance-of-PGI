#-----------------------------------------------------------------------------------------#
# Project: NORFACE
# Code that generates a file of siblings, parents, and relatives, based on the relationship file provided by UKB
# Date: 13 Jan 2020
#-----------------------------------------------------------------------------------------#
# Preliminaries
library(data.table)
library(reshape2)
setwd("//campus.eur.nl/users/home/68484dmu/Desktop/Projects/NHS & Genes/Data/Sibling & parent identifiers UKB")

outfolder <- ("//campus.eur.nl/users/home/68484dmu/Desktop/Projects/NHS & Genes/Data/Sibling & parent identifiers UKB")

# Load relatedness file from UKB
# header:
# ID1 ID2 HetHet IBS0 Kinship
d <- fread("//campus.eur.nl/users/home/68484dmu/Desktop/Projects/NHS & Genes/Data/Sibling & parent identifiers UKB/ukb41382_rel_s488302.dat")	

#-------------------------------------#
# Code various types of sibling pairs		
#-------------------------------------#

# A. MZ twins
d$MZ <- 0
d[Kinship > 0.4 & !is.na(Kinship), MZ := 1] 

# B. Full Sibs (The thresholds come from the Supplementary paper by Bycroft et al 2018).
# http://people.virginia.edu/~wc9c/KING/manual.html provides different thresholds for parent/child/sibling kinship coefficient: [0.177, 0.354]
d$FS <- 0
# The old threshold is 0.25 +/- 0.064
d[Kinship <= 0.25+0.104 & Kinship >= 0.25-0.073, FS := 1]
# Change to 0 if it is a parent-child dyad.
d[IBS0 < 0.0012, FS := 0]

# C. Parent-Child pairs 
d$PC <- 0
d[Kinship <= 0.25+0.104 & Kinship >= 0.25-0.073, PC := 1]
# Change to 0 if it is a sibling pair. 
d[IBS0 > 0.0012, PC := 0]

# D. 2nd & 3rd relatives 
d$RL <- 0
d[PC==0 & FS==0 & MZ==0, RL := 1]


# Tabulate MZ, FS, PC and RL pairs
table(d$MZ)
table(d$FS)
table(d$PC)
table(d$RL)

# Export a table of sib pairs, with relationships encoded
fwrite(d, file = paste0(outfolder,"UKB2_relpairs.txt"), sep = " ")

# Alternative to fwrite 
write.table(d, "UKB2_relpairs.txt", sep=" ")

# Create family identifiers for Full Siblings:
FS <- d[FS == 1]
FS[, fam := 0]

famid <- 1
for(i in 1:nrow(FS)) {
    if(i %% 1000 == 0) {print(i)}
    
    # Assign famid if none exists yet. If famid exists for this row, 
    # continue to next row.
    if(FS[i, fam] == 0) {
        FS[i, fam := famid]  
        fam_vector <- c(FS[i,ID1], FS[i,ID2])  
    } else {
        next
    }  

    # Search the remaining pairs, repeat until of data reached:
    pairs_remaining <- FS[-(1:i)]

    # while fam vector keeps increasing:
    stop <- 0
    while(stop == 0) {
        oldfamlength <- length(fam_vector)

        inds1 <- which(pairs_remaining[, ID1] %in% fam_vector)
        inds2 <- which(pairs_remaining[, ID2] %in% fam_vector)
        newinds <- unique(append(inds1, inds2))
        
        # Assign famid to the new inds
        FS[newinds+i, fam := famid]

        # Add new items to fam_vector
        new_pairs <- pairs_remaining[newinds]
        new_indiv <- unique(append(new_pairs[, ID1], new_pairs[, ID2]))
        fam_vector <- unique(append(fam_vector, new_indiv))
    
        # Stop loop if fam vector not increasing in size
        if(length(fam_vector) == oldfamlength) {
            stop <- 1
            famid <- famid + 1
        }
    }
}


# reshape fam file so each person gets 1 row
FS$PairNum <- rownames(FS)

ID1s <- FS[,c("ID1", "MZ","FS","PC", "RL", "fam")]
ID2s <- FS[,c("ID2", "MZ","FS","PC", "RL", "fam")]
colnames(ID1s)[colnames(ID1s) == "ID1"] <- "ID"
colnames(ID2s)[colnames(ID2s) == "ID2"] <- "ID"


# stack and remove duplicates (note, no MZ twins included)
siblist <- rbind(ID1s, ID2s)
fullsibs_withfam <- unique(siblist[FS==1])

# Write FS sibs file with fam IDs (multiple sibs per fam okay)
#fwrite(fullsibs_withfam, file = paste0(outfolder,"UKB2_FS_withfam.txt"), sep = " ")

# Alternative to fwrite 
write.table(fullsibs_withfam, "UKB2_FS_withfam.txt", sep=" ")


# Reshape such that each individual gets 1 row.
d$PairNum <- rownames(d)

ID1s <- d[,c("ID1", "MZ","FS","PC", "RL")]
ID2s <- d[,c("ID2", "MZ","FS","PC", "RL")]
colnames(ID1s)[colnames(ID1s) == "ID1"] <- "ID"
colnames(ID2s)[colnames(ID2s) == "ID2"] <- "ID"

# stack and remove duplicates
siblist <- rbind(ID1s, ID2s)

fullsibs <- unique(siblist[FS==1])
mztwins  <- unique(siblist[MZ==1])
sibsout  <- rbind(fullsibs, mztwins)

# Write list of individuals who are part of a sibling pair 
#fwrite(sibsout, file = paste0(outfolder,"UKB2_siblist.txt"), sep = " ")

#Alternative to fwrite 
write.table(sibsout, "UKB2_siblist.txt", sep=" ")


# Tabulate number of MZ twins, Full Sibs, and indivs. involved in a FS pair
table(sibsout$MZ)
table(sibsout$FS)
table(sibsout$PC)


# Create family identifiers for Parent Child relationships:
PC <- d[PC == 1]
PC[, fam := 0]

famid <- 1
for(i in 1:nrow(PC)) {
    if(i %% 1000 == 0) {print(i)}
    
    # Assign famid if none exists yet. If famid exists for this row, 
    # continue to next row.
    if(PC[i, fam] == 0) {
        PC[i, fam := famid]  
        fam_vector <- c(PC[i,ID1], PC[i,ID2])  
    } else {
        next
    }  

    # Search the remaining pairs, repeat until of data reached:
    pairs_remaining <- PC[-(1:i)]

    # while fam vector keeps increasing:
    stop <- 0
    while(stop == 0) {
        oldfamlength <- length(fam_vector)

        inds1 <- which(pairs_remaining[, ID1] %in% fam_vector)
        inds2 <- which(pairs_remaining[, ID2] %in% fam_vector)
        newinds <- unique(append(inds1, inds2))
        
        # Assign famid to the new inds
        PC[newinds+i, fam := famid]

        # Add new items to fam_vector
        new_pairs <- pairs_remaining[newinds]
        new_indiv <- unique(append(new_pairs[, ID1], new_pairs[, ID2]))
        fam_vector <- unique(append(fam_vector, new_indiv))
    
        # Stop loop if fam vector not increasing in size
        if(length(fam_vector) == oldfamlength) {
            stop <- 1
            famid <- famid + 1
        }
    }
}

# reshape fam file so each person gets 1 row
PC$PairNum <- rownames(PC)

ID1s <- PC[,c("ID1", "MZ","FS","PC", "fam")]
ID2s <- PC[,c("ID2", "MZ","FS","PC", "fam")]
colnames(ID1s)[colnames(ID1s) == "ID1"] <- "ID"
colnames(ID2s)[colnames(ID2s) == "ID2"] <- "ID"

# stack and remove duplicates (note, no MZ twins included)
parentchild <- rbind(ID1s, ID2s)
pc_withfam <- unique(parentchild[PC==1])

# Alternative to fwrite 
write.table(pc_withfam, "UKB2_PC_withfam.txt", sep=" ")

# Create family identifiers for Relatives:
RL <- d[RL == 1]
RL[, fam := 0]

relid <- 1
for(i in 1:nrow(RL)) {
    if(i %% 1000 == 0) {print(i)}
    
    # Assign relid if none exists yet. If relid exists for this row, 
    # continue to next row.
    if(RL[i, fam] == 0) {
        RL[i, fam := relid]  
        fam_vector <- c(RL[i,ID1], RL[i,ID2])  
    } else {
        next
    }  

    # Search the remaining pairs, repeat until of data reached:
    pairs_remaining <- RL[-(1:i)]

    # while fam vector keeps increasing:
    stop <- 0
    while(stop == 0) {
        oldfamlength <- length(fam_vector)

        inds1 <- which(pairs_remaining[, ID1] %in% fam_vector)
        inds2 <- which(pairs_remaining[, ID2] %in% fam_vector)
        newinds <- unique(append(inds1, inds2))
        
        # Assign relid to the new inds
        RL[newinds+i, fam := relid]

        # Add new items to fam_vector
        new_pairs <- pairs_remaining[newinds]
        new_indiv <- unique(append(new_pairs[, ID1], new_pairs[, ID2]))
        fam_vector <- unique(append(fam_vector, new_indiv))
    
        # Stop loop if fam vector not increasing in size
        if(length(fam_vector) == oldfamlength) {
            stop <- 1
            relid <- relid + 1
        }
    }
}

# reshape fam file so each person gets 1 row
RL$PairNum <- rownames(RL)

ID1s <- RL[,c("ID1", "MZ","FS","PC", "RL", "fam")]
ID2s <- RL[,c("ID2", "MZ","FS","PC", "RL", "fam")]
colnames(ID1s)[colnames(ID1s) == "ID1"] <- "ID"
colnames(ID2s)[colnames(ID2s) == "ID2"] <- "ID"

# stack and remove duplicates (note, no MZ twins included)
relative <- rbind(ID1s, ID2s)
rl_withfam <- unique(relative[RL==1])

# Alternative to fwrite 
write.table(rl_withfam, "UKB2_RL_withrlid.txt", sep=" ")

