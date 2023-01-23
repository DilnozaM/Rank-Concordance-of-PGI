import numpy as np
from gnames import gnames
# GNAMES (Genetic-Nurture and Assortative-Mating-Effects Simulator) script (https://github.com/devlaming/gnames)
# Script adapted from https://github.com/devlaming/gnames/tree/main/simulations (design 8)
# Benchmark simulations NHB paper: Imperfect genetic correlation between discovery sample 1 and discovery sample 2 and perfect genetic correlation between discovery sample 2 and hold-out sample

vNGWAS=np.array((4843,6812,20436,129428))
iNPRED=10000
iM=1000
dHsqY=0.1468
dPropGN=0
dRhoAM=0
dCorrYAM=1
vRhoG=np.array((0.88,0.95,1.00))
bY2GWAS1=True
bY2Out=False
iC=2
iT=1
dGWASMAF=0.01
iSETTINGS=len(vRhoG)
iSETTINGS2=len(vNGWAS)
#RUN NUMBER
vR=np.array(range(1,11))
iRUN=len(vR)
for iRun in range(iRUN):
	for iSetting in range(iSETTINGS):
		for iSetting2 in range(iSETTINGS2):
			iR=int(vR[iRun])
			#bits 1-4: for setting numbers between 0 and 15 (=2**(4-0)-1)
			#bits 5-8: for setting2 numbers between 0 and 15 (=2**(8-4)-1)
			#bits 9-.: for run numbers between 0 and 16777215 (=2**(32-8)-1)
			iThisSeed=(2**0)*iSetting+(2**4)*iSetting2+(2**8)*iR
			iNGWAS=int(vNGWAS[iSetting2])
			dRhoG=vRhoG[iSetting]
			iN=(2*iC*iNGWAS)+iNPRED
			sName='NHB2_0.1468'+'.NGWASPOOLED.'+str(2*iNGWAS)+'.RHO_G.'+'{:.2f}'.format(dRhoG)+'.RUN.'+str(iR)
			simulator=gnames(iN,iM,iC,dHsqY,dPropGN,dCorrYAM,dRhoAM,dRhoG,iSeed=iThisSeed)
			simulator.Simulate(iT)
			simulator.MakeThreePGIs(sName,iNGWAS,iNPRED,dGWASMAF,bY2GWAS1,bY2Out)
