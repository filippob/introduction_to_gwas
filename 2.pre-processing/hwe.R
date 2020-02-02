library("genetics")

##################
## example data ##
##################

#allele frequencies
p <- 0.7625 ##frequency of major allele
q <- (1-p)  ##frequency of minor allele

#n. of genotypes (observed)
nAA <- 26
nAB <- 9
nBB <- 5

#n. of alleles
nA <- 2*nAA+nAB
nB <- 2*nBB+nAB

nA/sum(nA,nB) # p
nB/sum(nA,nB) # q

#sample size
N <- sum(nAA,nAB,nBB)

#expected genotypes
eAA <- (p^2)*N
eAB <- (2*p*q)*N
eBB <- (q^2)*N

#genotype object (library "genetics")
g1 <- genotype(c(rep("A/A",nAA),rep("A/B",nAB),rep("B/B",nBB)))

##########################
## TEST for HW equilibrium
##########################
## Chi-square
## 
chi <- function(obs,exp) ((obs-exp)^2)/(exp)

chi_stat <- chi(obs = nAA, exp = eAA) + chi(obs = nAB, exp = eAB) + chi(obs = nBB, exp = eBB)
pval <- 1-pchisq(chi_stat, df=1)
pval

HWE.chisq(g1) #library "genetics"

## Fsher
(2^nAB)*((factorial(N)/(cumprod(factorial(c(nAA,nAB,nBB)))[[3]]))/(factorial(2*N)/(factorial(2*N-nA)*factorial(nA))))

HWE.exact(g1)
