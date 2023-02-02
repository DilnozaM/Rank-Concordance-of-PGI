library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(scales)
library(viridis)
library(ragg) # for scaling https://www.christophenicault.com/post/understand_size_dimension_ggplot2/
library(magick) #image_read
library(gridExtra)
library(grid) #textgrob
library(data.table)
library(cowplot) # isolate figure legend
library(readxl)

setwd("PGS ranking/Analysis/Output")

file.maker <- function(sheet, data ){
  
  # grab specified tab from excel file
  dciles.tab <- read_excel("PGS ranking/2. First revision to NHB/GNAMES simulation results - empirical benchmark - 01468/sim_results_rev.xls", 
                           sheet = sheet, 
                           col_names=F)
  
  # define col and row names or else flattening later doesn't work.
  colnames(dciles.tab) <- seq(1,10,1)
  rownames(dciles.tab) <- seq(1,10,1)
  
  # grab pgs names
  #pgs1.name <- colnames(pgs[,..pgs1])
  #pgs2.name <- colnames(pgs[,..pgs2])
  #
  #print(pgs1.name)
  #
  ## make sure variable name can be read from df 
  ## https://stackoverflow.com/questions/19133980/passing-a-variable-name-to-a-function-in-r
  #getvar <- function(var, df) {
  #  get(var,pgs)
  #}
  #
  #pgs.1 <- getvar(pgs1.name, "pgs")
  #pgs.2 <- getvar(pgs2.name, "pgs")
  #
  #print(head(pgs.1))
  ##print(head(pgs.2))
  
  
  # cross tab two chosen pgs (based on column number)
  #dciles.tab <- table(pgs.1, pgs.2)
  #
  #print(dciles.tab)
  #class(dciles.tab)
  
  # transform to row percentages for the two chosen pgs
  dciles.tab <- data.frame(cbind(dciles.tab, total = rowSums(dciles.tab)))
  dciles.tab <- data.frame(round((dciles.tab/dciles.tab$total)*100, 1))
  dciles.tab <- dciles.tab %>% select(!c(total))
  names(dciles.tab) <- seq(1,10,1)
  dciles.tab <- as.matrix(dciles.tab)
  
  
  # flatten into data frame so ggplot can read as x and y
  # https://stackoverflow.com/questions/27892100/distance-matrix-to-pairwise-distance-list-in-r
  
  dciles.df <- data.frame(col=colnames(dciles.tab)[col(dciles.tab)], row=rownames(dciles.tab)[row(dciles.tab)], dist=c(dciles.tab))
  
  dciles.df[,] <- apply(dciles.df[,], 2, function(x) as.numeric(as.character(x)))
  
  colnames(dciles.df) <- c("PGS1", "PGS2",  "Overlap")
  
  print(dciles.df)
  
}

# make the decile files for plotting. 
sim_1_bubble_df <- file.maker("scatter11", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_2_bubble_df <- file.maker("scatter21", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_3_bubble_df <- file.maker("scatter31", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_4_bubble_df <- file.maker("scatter41", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_5_bubble_df <- file.maker("scatter12", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_6_bubble_df <- file.maker("scatter22", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_7_bubble_df <- file.maker("scatter32", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_8_bubble_df <- file.maker("scatter42", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_9_bubble_df <- file.maker("scatter13", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_10_bubble_df <- file.maker("scatter23", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_11_bubble_df <- file.maker("scatter33", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")
sim_12_bubble_df <- file.maker("scatter43", data="PGS ranking/Analysis/Input/bubbleplot_twoPGIs.txt")







bubble.plot.maker <- function(data){
  
  
  # make sure ggplot can read the passed variable names with aes_string
  print("hello")
  
  overlap <- "Overlap"
  
  
  #colors <- brewer.pal(3, name="RdYlBu")
  
  # alpha gives transparency
  # https://stackoverflow.com/questions/10861773/remove-grid-background-color-and-top-and-right-borders-from-ggplot2 for b+w no grid
  # https://www.datanovia.com/en/blog/ggplot-colors-best-tricks-you-will-love/ color chooser
  # integrate size and color in legend https://ggplot2.tidyverse.org/reference/guides.html
  # https://stackoverflow.com/questions/10437442/place-a-border-around-points/10437545
  # modify legend spacing https://stackoverflow.com/questions/11366964/is-there-a-way-to-change-the-spacing-between-legend-items-in-ggplot2
  
  

  bubble <- ggplot(data=data,aes_string(x=data[,1], y=data[,2], size = overlap, color=overlap))+
    geom_point()+
    geom_point(alpha=0.7, aes_string(colour=overlap), shape=21, colour="grey")+
    scale_size_continuous(range = c(0, 10), breaks=seq(0, 100, by=20), #range sets size of cirlces
                          labels=c("0%","20%","40%", "60%", "80%", "100%"),
                          name="Overlap (rows)",
                          limits=c(0,100))+
    scale_colour_gradient2(low = "white",high = "red",
                           breaks=seq(0, 100, by=20),
                           limits=c(0,100),
                           labels=c("0%","20%","40%", "60%", "80%", "100%"),
                           name="Overlap (rows)")+
    guides(colour = guide_legend(byrow=T), size = guide_legend(byrow=T), shape=guide_legend(byrow=T))+
    scale_x_continuous(breaks=seq(1,10,1), limits=c(0,11))+
    scale_y_continuous(breaks=seq(1,10,1), limits=c(0,11))+
    ylab("PGI 1")+
    xlab("PGI 2")+
    theme_bw() +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.line=element_line(size=0.25, colour="black"),
          axis.ticks=element_line(size=0.25, colour="black"),
          axis.title=element_text(size=9, colour="black"),
          #axis.title.x=element_text(margin = margin(t = -1)),
          axis.text=element_text(size=8, colour="black"),
          legend.text=element_text(size=7.5, colour="black"),
          legend.title=element_text(size=8, colour="black"),
          legend.spacing.y = unit(-0.1, "cm"),
          legend.key = element_rect(color = NA, fill = NA),
          legend.key.size = unit(0.5, "cm"),
          #plot.title = element_text(size=10, hjust = 0.5),
          legend.margin=margin(0,5,0,0),
          legend.box.margin=margin(-10,-10,-10,-10))
  
  #return(bubble)
  return(bubble + theme(legend.position = "none"))
  
}

bubble.legend.maker <- function(data){
  
  
  overlap <- "Overlap"
  
  
  #colors <- brewer.pal(3, name="RdYlBu")
  
  # alpha gives transparency
  # https://stackoverflow.com/questions/10861773/remove-grid-background-color-and-top-and-right-borders-from-ggplot2 for b+w no grid
  # https://www.datanovia.com/en/blog/ggplot-colors-best-tricks-you-will-love/ color chooser
  # integrate size and color in legend https://ggplot2.tidyverse.org/reference/guides.html
  # https://stackoverflow.com/questions/10437442/place-a-border-around-points/10437545
  # modify legend spacing https://stackoverflow.com/questions/11366964/is-there-a-way-to-change-the-spacing-between-legend-items-in-ggplot2
  bubble <- ggplot(data=data,aes_string(x=data[,1], y=data[,2], size = overlap, color=overlap))+
    #ggtitle(bquote("Explained SNP-based" ~ h^2 == .(percent)))+
    geom_point()+
    geom_point(alpha=0.7, aes_string(colour=overlap), shape=21, colour="grey")+
    scale_size_continuous(range = c(0, 10), breaks=seq(0, 100, by=20), #range sets size of cirlces
                          labels=c("0%","20%","40%", "60%", "80%", "100%"),
                          name="Decile overlap (rows)",
                          limits=c(0,100))+
    scale_colour_gradient2(low = "white",high = "red",
                           breaks=seq(0, 100, by=20),
                           limits=c(0,100),
                           labels=c("0%","20%","40%", "60%", "80%", "100%"),
                           name="Decile overlap (rows)")+
    guides(colour = guide_legend(byrow=T), size = guide_legend(byrow=T), shape=guide_legend(byrow=T))+
    scale_x_continuous(breaks=seq(1,10,1), limits=c(0,11))+
    scale_y_continuous(breaks=seq(1,10,1), limits=c(0,11))+
    ylab("\"True\" PGI")+
    xlab(bquote("PGI with explained SNP-based" ~ italic(h)^2 == .(percent)))+
    theme_bw() +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.line=element_line(size=0.25, colour="black"),
          axis.ticks=element_line(size=0.25, colour="black"),
          axis.title=element_text(size=8, colour="black"),
          axis.text=element_text(size=8, colour="black"),
          legend.text=element_text(size=8, colour="black"),
          legend.title=element_text(size=10, colour="black"),
          legend.spacing.y = unit(-0.1, "cm"),
          legend.key = element_rect(color = NA, fill = NA),
          legend.key.size = unit(0.5, "cm"),
          plot.title = element_text(size=10, hjust = 0.5),
          legend.margin=margin(0,5,0,0),
          legend.box.margin=margin(-10,-10,-10,-10))
  #plot.margin = unit(c(1,1,1,1), "cm"))
  
  cowplot::get_legend(bubble)
  #return(bubble)
  return(cowplot::get_legend(bubble))
  
}



true.bubble <- grid.arrange(ncol=4,
                            nrow=3,
                            bubble.plot.maker(sim_1_bubble_df), 
                            bubble.plot.maker(sim_2_bubble_df),
                            bubble.plot.maker(sim_3_bubble_df),
                            bubble.plot.maker(sim_4_bubble_df),
                            bubble.plot.maker(sim_5_bubble_df),
                            bubble.plot.maker(sim_6_bubble_df),
                            bubble.plot.maker(sim_7_bubble_df),
                            bubble.plot.maker(sim_8_bubble_df),
                            bubble.plot.maker(sim_9_bubble_df),
                            bubble.plot.maker(sim_10_bubble_df),
                            bubble.plot.maker(sim_11_bubble_df),
                            bubble.plot.maker(sim_12_bubble_df),
                            left = textGrob(label=expression(paste(italic("r"[g])," = 1.00                               ", italic("r"[g])," = 0.95                               ", italic("r"[g])," = 0.88")), rot = 90, vjust = 1, just = "left", hjust = 0.475, gp = gpar(fontface = "bold", cex = 1)),
                            bottom = textGrob(label = expression(paste(italic("R"[PGI]^2)," / ",italic("h"[SNP]^2),"= 0.42                  ", italic("R"[PGI]^2)," / ",italic("h"[SNP]^2),"= 0.50                  ",italic("R"[PGI]^2)," / ",italic("h"[SNP]^2),"= 0.75                  ",italic("R"[PGI]^2)," / ",italic("h"[SNP]^2),"= 0.95")), vjust = 0.25, hjust = 0.475, just = "left", gp = gpar(fontface = "bold", cex = 1)))
                            


# solution for scaling https://stackoverflow.com/questions/66429500/how-to-make-raggagg-png-device-work-with-ggsave
ggsave("scaled_bubble_simulations_revision.png",
       true.bubble,
       width=1400*2.5*1.33,
       height=1150*2*1.5,
       scaling=1.75,
       device=ragg::agg_png,
       units="px"
)

ggs <- image_read("scaled_bubble_simulations.png")
print(ggs) # show rendered plot in plotting window
while (!is.null(dev.list()))  dev.off()


