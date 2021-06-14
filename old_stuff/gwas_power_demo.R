library("knitr")
source("~/Dropbox/cursos/laval2019/gwas-power/power_calc_functions.R")

pow = power_n_hsq(n = (1:5)*1000, qsq = (1:10)/100, pval=5E-8)
pow

pow = power_beta_het(beta = (5:10)/50, het = (1:5)/10, n = 5000, pval=5E-8)

pow = power_beta_maf(beta = (5:10)/50, maf = (1:5)/10, n = 5000, pval=5E-8)


pdf("power_heatmap.pdf",width=10,height=9) 
power_plot(pow, "n", "q-squared") 
dev.off()
