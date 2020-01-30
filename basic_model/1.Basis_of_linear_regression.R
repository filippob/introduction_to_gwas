#GENERATOR MODEL
n=1000                            #ndata
x<-floor(runif(n,0,3))            #genotypes
beta<-rnorm(1,0,1.5)              #allele subst effects
mu=20                             #population mean
y<-mu+beta*x+rnorm(n,0,sd=5)      #generate data

plot(x,y)                         #plot the data

#FREQUENTIST APPROACH
#####################
#Calculate regression coeficients
SSxy<- sum( (x-mean(x))*(y-mean(y)) )
SSxx<-sum( (x-mean(x))**2 )
b1<-SSxy/SSxx                           #b=cov(x,y)/var(x)
 
print(paste("The estimated coefficient regresion is",b1))

b0<-mean(y)-b1*mean(x)                  #a=E(y)+bE(x)
print(paste("The estimated intercept is",b0))

#plot data and regression line
plot(x,y,)
abline(b0,b1,col="red")

#Calculate the t statistic and the p-value
SSE<-sum((y-(b0+b1*x))**2)
SSE
sR<-SSE/(length(y)-2)

t<-(b1-0)/sqrt(sR/SSxx)
t
#tablas para calculara probabilidad acumulada o p-valor
#http://cms.dm.uba.ar/academico/materias/1ercuat2015/probabilidades_y_estadistica_C/tabla_tstudent.pdf
#http://www.jorgegalbiati.cl/nuevo_06/tstud.pdf

A<- 1-0.9833
pvalue<-2*A
pvalue

#Use glm
summary(glm(y~x))

