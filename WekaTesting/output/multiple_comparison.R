rm(list = ls())
library(PMCMR)
library(scmamp)
setwd("/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/output")

metrics = c("accuracy","precision","recall","kappa","auc","time");

for (metric in metrics){
  print(paste("Analyzing: ", metric))
  
  # get data & form into matrix
  data <- read.csv(file = paste(metric,".csv", sep = ""), head = TRUE, sep = ",")
  numAlgs <- length(data)
  data <- data[2:numAlgs]
  data <- data.matrix(data)
  
  # run friedman & get p-values for Nemenyi, Holm, and Shaffer
  friedman.test(data)
  stats <- posthoc.friedman.nemenyi.test(data)
  matrix_stats <- stats[3]
  mat_st <- do.call(rbind, matrix_stats)
  mat_st[upper.tri(mat_st)] <- t(mat_st)[upper.tri(mat_st)]
  shaffer_mat <- adjustShaffer(mat_st)
  full <- matrix(unlist(stats[3]))
  nemenyi <- full[1:11]
  holm <- p.adjust(nemenyi, method = 'holm', n = length(nemenyi))
  shaf <- shaffer_mat[,1]
  pvals <- data.frame(nemenyi,holm,shaf)
  
  # write file
  write.csv(pvals, file = paste("/Users/gabriellamelki/Documents/Research/MultiInstanceLearning/WekaTesting/stats/",metric,"_pVal.csv", sep = ""))
}
