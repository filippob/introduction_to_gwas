#R example 5.4 : Find the sample size needed for a t-test to detect an effect explaining 1 % of the variance with a Bayes factor 20 or more with power 0.8. Also ﬁnd the sample size needed to detect the effect with a Bayes factor 1 million with power 0.8.
#Rodercik D. Ball (Genome wide Assocition analyses book)

#Dependencies
# install.packages("../software/ldDesign_2.0-1.tar.gz", type = "source", repos = NULL)
library("ldDesign") #Install source from https://cran.r-project.org/src/contrib/Archive/ldDesign/ (v2.0-1)
library("ggplot2")
library("patchwork")


#find.n <- function(b, n.min, n.max, group.proportions= c(0.5,0.5),  alpha, n.interp=20, power=0.8){
#  log10.ns <- seq(log10(n.min), log10(n.max), length=n.interp)
#  ns <- 10^log10.ns
#  t.values <- b*sqrt(ns)
#  powers <- 1 -pf(qf(1-alpha,1,ns-1),1,ns-1,ncp=t.values^2)
#  log10.n1 <-approx(powers,log10.ns,xout=power)$y
#  n1 <- 10^log10.n1 + n1
#  }


#In this example we will use the exercise 5.4 from Rodercik D. Ball (Genome wide Assocition analyses book)
# to show the expected statistical power under a t-test hypothesis, given LD, marker and qtl frequency, 
# sample size, and variance explained by the qtl.

options(digits=3, width=65)
BayesFactor=20

#CASE 1: Common Variants --> Allele frequency = 0.5; qtl h2= 0.001; LD= 0.25, 0.20, 0.10
h2=0.001 #heritability of the marker
n1<-seq(1000,100000,1000) #sample size
qtl.freq<-0.5
marker.freq<-0.5
ppower0.25<-ld.power(B=BayesFactor, D=0.25, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.20<-ld.power(B=BayesFactor, D=0.2, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.10<-ld.power(B=BayesFactor, D=0.1, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]

df25<-data.frame(n1,ppower0.25,rep(0.25,length(n1)));names(df25)<-c("n","power","D")
df20<-data.frame(n1,ppower0.20,rep(0.20,length(n1)));names(df20)<-c("n","power","D")
df10<-data.frame(n1,ppower0.10,rep(0.10,length(n1)));names(df10)<-c("n","power","D")
df<-rbind(df25,df10,df20)

df$D<-as.factor(df$D)
plot.case1<-ggplot(df, aes(y=power, x=n, group=D)) +
  geom_line(aes(color=D))+
  geom_point(aes(color=D))+
  labs(title="Allele freq=0.5; QTL heritability = 0.001 ",x="Sample size")

##CASE 2. Common Variants --> Allele frequency = 0.5; qtl h2= 0.05; LD= 0.25, 0.20, 0.10
h2=.05 #heritability of the marker
n1<-seq(100,5000,100) #sample size
qtl.freq<-0.5
marker.freq<-0.5
ppower0.25<-ld.power(B=BayesFactor, D=0.25, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.20<-ld.power(B=BayesFactor, D=0.2, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.10<-ld.power(B=BayesFactor, D=0.1, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]

df25<-data.frame(n1,ppower0.25,rep(0.25,length(n1)));names(df25)<-c("n","power","D")
df20<-data.frame(n1,ppower0.20,rep(0.20,length(n1)));names(df20)<-c("n","power","D")
df10<-data.frame(n1,ppower0.10,rep(0.10,length(n1)));names(df10)<-c("n","power","D")
df<-rbind(df25,df10,df20)
df$D<-as.factor(df$D)
plot.case2<-ggplot(df, aes(y=power, x=n, group=D)) +
  geom_line(aes(color=D))+
  geom_point(aes(color=D))+
  labs(title="Allele freq=0.5; Marker heritability = 0.05 ",x="Sample size")

##CASE 3. Uncommon Variants --> Allele frequency = 0.05; qtl h2= 0.001; LD= 0.0475, 0.03, 0.01
h2=.001 #heritability of the marker
n1<-seq(1000,150000,1000) #sample size
qtl.freq<-0.05
marker.freq<-0.05
ppower0.0475<-ld.power(B=BayesFactor, D=0.0475, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.03<-ld.power(B=BayesFactor, D=0.03, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.02<-ld.power(B=BayesFactor, D=0.02, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower0.01<-ld.power(B=BayesFactor, D=0.01, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]

df4<-data.frame(n1,ppower0.0475,rep(0.0475,length(n1)));names(df4)<-c("n","power","D")
df3<-data.frame(n1,ppower0.03,rep(0.03,length(n1)));names(df3)<-c("n","power","D")
df1<-data.frame(n1,ppower0.02,rep(0.01,length(n1)));names(df1)<-c("n","power","D")
df<-rbind(df4,df3,df1)
df$D<-as.factor(df$D)
plot.case3<-ggplot(df, aes(y=power, x=n, group=D)) +
  geom_line(aes(color=D))+
  geom_point(aes(color=D))+
  labs(title="Allele freq=0.05; Marker heritability = 0.001 ",x="Sample size")


##Rare Variants --> Allele frequency = 0.005; qtl h2= 0.05; LD= 0.00475, 0.003, 0.001
h2=.025 #heritability of the marker
n1<-seq(1000,10000,500) #sample size
qtl.freq<-0.005
marker.freq<-0.005
ppower4<-ld.power(B=BayesFactor, D=0.00475, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower3<-ld.power(B=BayesFactor, D=0.003, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower1<-ld.power(B=BayesFactor, D=0.001, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]

df4<-data.frame(n1,ppower4,rep(0.00475,length(n1)));names(df4)<-c("n","power","D")
df3<-data.frame(n1,ppower3,rep(0.003,length(n1)));names(df3)<-c("n","power","D")
df1<-data.frame(n1,ppower1,rep(0.001,length(n1)));names(df1)<-c("n","power","D")
df<-rbind(df4,df3,df1)
df$D<-as.factor(df$D)
plot.case4<-ggplot(df, aes(y=power, x=n, group=D)) +
  geom_line(aes(color=D))+
  geom_point(aes(color=D))+
  labs(title="Allele freq=0.005; Marker heritability = 0.05 ",x="Sample size")

##Rare Variants --> Allele frequency = 0.005; qtl h2= 0.001; LD= 0.00475, 0.002, 0.001
h2=.001
n1<-seq(5000,500000,5000)
qtl.freq<-0.005
marker.freq<-0.005
ppower4<-ld.power(B=BayesFactor, D=0.00475, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower2<-ld.power(B=BayesFactor, D=0.002, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]
ppower1<-ld.power(B=BayesFactor, D=0.001, p=marker.freq, q=qtl.freq,n=n1, h= h2, phi=0)[,2]

df4<-data.frame(n1,ppower4,rep(0.00475,length(n1)));names(df4)<-c("n","power","D")
df1<-data.frame(n1,ppower1,rep(0.001,length(n1)));names(df1)<-c("n","power","D")
df2<-data.frame(n1,ppower2,rep(0.002,length(n1)));names(df2)<-c("n","power","D")
df<-rbind(df4,df2,df1)
df$D<-as.factor(df$D)
plot.case5<-ggplot(df, aes(y=power, x=n, group=D)) +
  geom_line(aes(color=D))+
  geom_point(aes(color=D))+
  labs(title="Allele freq=0.005; Marker heritability = 0.001 ",x="Sample size")


#Configure plot

(plot.case1 + plot.case2) / (plot.case3 + plot.case4 + plot.case5)

## Power calculation Tool
marker.h2=0.01
marker.p=0.5
qtl.p=0.5
sample_size=100
LD.D=0.25
Bayes.Factor=20
ld.power(B=Bayes.Factor, D=LD.D, p=marker.p, q=qtl.p,n=sample_size, h= marker.h2, phi=0)
