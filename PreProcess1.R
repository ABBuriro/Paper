# This function does preprocess ".gz" files (i.e., full alcoholic EEG dataset from)
# UCI.
# The code is written specially for the paper on wavelet scattering transform
# by Dr Abdul Baseer Buriro
# email: abdul.baseer@iba-suk.edu.pk
# dated: April 20, 2021
# ----------------------------------------------------------------------
# Use the following code in the console to preprocess all the subjects file at onces.
# The code can be incorporated in the main function.
# D = list.dirs()
# for(i in 1:length(D)){
# subject = gsub("./","",D[i])
# PreProcess(subject)}
# -----------------------------------------------------------------------
PreProcess1 <- function(subject){
  #untar(paste(subject,".tar.gz"))
  reqPack <- c("tidyverse")
  new.packages <- reqPack[!(reqPack %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  sapply(reqPack, require, character.only = TRUE)
  # ------------------------------------------------------------------------
  setwd(paste("C://Users//Dr Baseer//Documents//eeg_full//",subject,sep = ""))
  Files <- list.files(pattern = ".gz")
  NF <- length(Files)
  full_data <- 0
  # -------------------------------------------------------------------
  for(i in 1:NF){
    #data = readLines(paste(subject,".rd.", trail,".gz", sep = ""))
    data = readLines(Files[i])
    cond = unlist(str_match(data[4],"S[1-2]"))
    if(!any(grepl("err",data))){
      data1 = data[-grep("#",data)]
      trail = unique(as.numeric(gsub("([0-9]+).*$", "\\1", data1)))
      patt = NULL
      patt[[1]] = "(\\d+\\.\\d+)"		  # positive float
      patt[[2]] = "(-\\d+\\.\\d+)"		# negative float
      patt = paste(patt, collapse="|", sep="")
      values = as.numeric(unlist(str_extract_all(data1,patt)))
      r <- length(values)/64          # 64 indicates the number of channel used 
      dat = data.frame(matrix(values,nrow = r,ncol = 64))
      V = all(apply(dat,2,var) > 0)   # determining if any of the column values are constant
      # the following IF is to discard ERPs that either have artefacts or constant voltages
      if(isTRUE(V) & all(abs(dat)<=60,na.rm = TRUE)){
        # ----------------------------------------------------------
        ch_names <- unique(unlist(str_match(data1,"[a-zA-Z]\\d|[a-zA-Z]\\S+|[a-zA-Z]")))
        colnames(dat) <- ch_names
        Label = rep(str_sub(subject,4,4),r)
        dat$Label <- Label
        dat$cond <- rep(cond,r)
        dat$trail <- rep(trail,r)
        full_data = rbind(full_data,dat)
      }
    }
  }
  full_data <- full_data[-1,]
  return(full_data)
  write.csv(full_data,file = paste(subject,".csv",sep=""))
}