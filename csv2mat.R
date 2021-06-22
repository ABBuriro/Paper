# This function selects 20 trails and then saves the data in .mat and .csv file for
# further processing
# The code is written specially for the paper on wavelet scattering transform
# by Dr Abdul Baseer Buriro
# email: abdul.baseer@iba-suk.edu.pk
# dated: April 20, 2021
# ----------------------------------------------------------------------
# Un-comment the following lines to determine the subject in both groups and 
# to exclude it.
reqPack <- c("tidyverse","R.matlab")
new.packages <- reqPack[!(reqPack %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
sapply(reqPack, require, character.only = TRUE)
#

NF <- list.files(pattern = ".csv")
A = unlist(str_extract_all(NF,'[1-9]\\d+'))
idx = matrix(rep(0,length(NF)*2),nrow = length(NF),ncol = 2)
# 
# The following code block finds a subject, who has been used both
# in control and alcoholic categories
for(i in 1:length(A)){
  idx[i,] <- grep(A[i],NF)}
#
# The following two lines determine the position/index for the above subject and
# then discarding the corresponding ERPs
idx1 = which(idx[,1]!=idx[,2])
NF = NF[-idx1]
#
for(i in 1:length(NF)){
  subject = NF[i]
  File = paste("C://Users//Documents//eeg_full//Subjectwise_data//",
               subject,sep = "")
  ndata = read.csv(File)
  n1 <- filter(ndata,cond == "S1")[1:5120, ] # 20 trails = 256*20
 #n2 <- filter(ndata,cond == "S2")[1:2560, ]
 #ndata <- bind_rows(n1,n2)
  ndata <- select(n1,c("FP1","FP2","F7","F8","F4","F3","C3",
                         "C4","P3","P4","O1","O2","T7","T8","P7","P8",
                         "Label"))
  ndata$Label <- ifelse(ndata$Label == 'a', 1, 0)
  #ndata$cond <- if_else(ndata$cond == "S1", 1, 2)
  # the following line removes ".csv" format to make generalized
  File = gsub(".csv","",File)
  writeMat(paste(File,".mat",sep = ""), ndata = as.matrix(ndata))
  write.csv(ndata,file = paste(File,'-rd.csv',sep = ""))
  rm(File,ndata,n1)
 
}