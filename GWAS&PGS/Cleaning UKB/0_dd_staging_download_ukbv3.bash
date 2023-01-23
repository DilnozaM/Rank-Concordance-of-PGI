#!/bin/bash
#SBATCH -t 2-00:00:00  ## wall-clock time
#SBATCH -n 1      ## Request 1 process for the job since staging node
#SBATCH -p staging ## Node type


## The extras code for color around date command

echo "Script executed:"
date

echo

################################################################################
################################################################################


for chr in {1..22}; do(


echo "Downloading chromosome ${chr} with ukbgene..."
echo

./ukbgene imp -c${chr} -ak41382.key
wait

)
done
wait
echo

################################################################################
################################################################################

echo "Script terminated:"
date