#### 30 September 2021 ####
#### venn diagram ####
#### fleur meddens ####

library(data.table)
library(VennDiagram)
library(ggVennDiagram)
library(dplyr)
#install.packages("BiocManager")
#BiocManager::install("limma")
library(limma)
library(ggplot2)
library(scales) # for muted color functionality in ggplot
library(ggraph) # for edge colors
library(RColorBrewer)

setwd("C:/Users/Fleur/Dropbox/GEIGHEI/projects/PGS ranking/Analysis/Output/")
# tryout
x <- list(A=1:5,B=2:7,C=3:6,D=4:9)
ggVennDiagram(x)


# https://www.datanovia.com/en/blog/venn-diagram-with-r-or-rstudio-a-million-ways/
# https://www.frontiersin.org/articles/10.3389/fgene.2021.706907/full
# https://cran.r-project.org/web/packages/ggVennDiagram/ggVennDiagram.pdf
# https://stats.idre.ucla.edu/r/faq/how-can-i-generate-a-venn-diagram-in-r/
# https://www.datanovia.com/en/blog/beautiful-ggplot-venn-diagram-with-r/
# https://cran.rstudio.com/web/packages/ggVennDiagram/vignettes/fully-customed.html
# https://stackoverflow.com/questions/68875752/how-to-edit-ggvenndiagram-intersection-fill-region 
# https://cran.rstudio.com/web/packages/ggVennDiagram/vignettes/using-ggVennDiagram.html
# https://github.com/gaospecial/ggVennDiagram

# setting the legend with percentages and good title
# https://r-charts.com/part-whole/ggvenndiagram/#legend
# https://stackoverflow.com/questions/29213881/get-ggplot2-legend-to-display-percentage-sign-in-r
# https://stackoverflow.com/questions/58939933/how-to-show-the-count-in-legend-as-percent-in-geom-hex-plot
# https://thomasadventure.blog/posts/ggplot2-percentage-scale/
# https://stackoverflow.com/questions/14622421/how-to-change-legend-title-in-ggplot

vennPlot <- function(data, fileName, cuts){

#data <- fread("C:/Users/Fleur/Documents/UKB/Norface/UKB_cvd_quintiles_top.txt")
data <- fread(data, na.strings="NA")

labels <- c("UKB       \n(LDpred)       ", 
            "UKB+CARDIoGRAM (LDpred)",  
            "    CARDIoGRAM \n          (LDpred)",  
            "\n CARDIoGRAM (C+T)",
            "UKB (C+T)")


## easy setup
venndata <-  data %>% select(!c(ID))

# number below should not be manual!
#nvenn <- 4274
nvenn <- length(data$ID)
# label_percent_digit = 1
venn <- ggVennDiagram(venndata, label_alpha = 0,  category.names = labels, edge_size = 0.5, label_size = 2.8 )+
                        scale_fill_gradient2( low = muted("coral"),high = "red", 
                        labels = function(x) scales::percent(x/nvenn, accuracy=0.1),
                        breaks = cuts * nvenn,
                        name="percentage overlap")+
                        scale_colour_manual(values = c(rep("black", 5)))+
                        scale_x_continuous(expand = expansion(mult = 0.2))
  
  #scale_fill_distiller(palette = "YlOrRd", direction=1)#+
  #scale_y_continuous(expand = expansion(mult = 0.1))

ggsave(paste0("C:/Users/Fleur/Dropbox/GEIGHEI/projects/PGS ranking/Analysis/Output/venn", fileName), 
       dpi=300,
       limitsize = F, units = "px", height=2000, width = 2000)
                       
return(venn)
#dev.off()


}

# quintiles
vennPlot("C:/Users/Fleur/Documents/UKB/Norface/UKB_cvd_quintiles_top_mi_incl.txt", "_cvd_quint_mi_incl.jpeg", c(0, 0.025, 0.05, 0.075, 0.1, 0.125))

# deciles
vennPlot("C:/Users/Fleur/Documents/UKB/Norface/UKB_cvd_deciles_top_mi_incl.txt", "_cvd_dec_mi_incl.jpeg", cuts)

# top 5%
vennPlot("C:/Users/Fleur/Documents/UKB/Norface/UKB_cvd_fives_top_mi_incl.txt", "_cvd_five_mi_incl.jpeg", cuts)


# histogram

### hist
qbinx <- c(5757,1604, 1098, 912, 408, 252)
qbiny <- c(0,1,2,3,4,5)

colors <- brewer.pal(6, "YlOrRd")

jpeg(paste0("C:/Users/Fleur/Dropbox/GEIGHEI/projects/PGS ranking/Analysis/Output/barplot", fileName), 
     width=2500, 
     height=2000, 
     res=400, 
     quality=100)

plot <- barplot(qbinx,
                names.arg = qbiny,
                ylim=c(0,6000),
                cex.axis =1,
                cex = 0.6,
                cex.lab = 1,
                beside =T,
                font.main = 1.5,
                xpd = FALSE,
                col = c("#ffefe9", "#ffccbb", "#ff9374", "#ff714f",  "#ff331a", "#B60a0a"),
                xlab="",
                ylab="Individuals",
                xaxt='n',
                main=" ",
                cex.main=2,
                las=1)

axis(1, at=plot, c(0:5), cex.axis=1)
title(xlab ="Number of PGIs the individual ranks \nin top quintile for", mgp = c(3, 0, 0))
#text(x=1, y= 0.6, cex=2, expression(paste(italic(R)^2) ~  "= 8.3%",sep=" "))












venndata <- Venn(data %>% select(!c(ID)))
venndata <- process_data(venndata)
#venndata <- vennCounts(venndata)
#class(venndata) <- "matrix"
  

## fullly custom
           
ggplot()+
  # change mapping of color filling
  geom_sf(aes(fill=count), data = venn_region(venndata), show.legend = FALSE) +
  scale_fill_gradient2(low=muted("coral"),high = "red")+
  # adjust edge size and color
  geom_sf(color="grey", size = 1, data = venn_setedge(venndata), show.legend = FALSE) +  
  # show set label in bold
  geom_sf_text(aes(label = labels), fontface = "bold", data = venn_setlabel(venndata)) +  
  # add a alternative region name
  geom_sf_label(aes(label = count), data = venn_region(venndata), alpha = 0) +  
  theme_void()
