# installing easyqc and dependencies on cartesius #
# first, easyqc and its dependency cairo were donwloaded into the tools folder,  "/path/tools/easyqc" #

cd /path/tools/easyqc

module load 2019
module load R


install.packages("Cairo_1.5-10.tar.gz")
install.packages("plotrix")
#install.packages("data.table") --> not needed, data.table already installed
install.packages("EasyQC_9.2.tar.gz")

q()

