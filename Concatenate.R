Sub = c('co2a0000365','co2a0000368','co2a0000369','co2a0000372','co2a0000375','co2a0000377',
        'co2a0000385','co2a0000392','co2a0000398','co2a0000400','co2a0000403','co2a0000404',
        'co2a0000405','co2a0000406','co2a0000407','co2a0000409','co2a0000410','co2a0000414',
        'co2a0000415','co2a0000416','co2c0000339','co2c0000340','co2c0000341','co2c0000342',
        'co2c0000344','co2c0000345','co2c0000346','co2c0000347','co2c0000348','co2c0000351',
        'co2c0000354','co2c0000356','co2c0000357','co2c0000363','co2c0000374','co2c0000383',
        'co2c0000389','co2c0000393','co2c0000397','co2c1000367')
#  'co2a0000411','co2a0000412','co2c0000337','co2c0000338'
#   total EEG records (40 subjects * 16 trails/subject)
N <- 256*16           # sampling frequency X 16 trails
reqPack <- c("tidyverse","R.matlab")
new.packages <- reqPack[!(reqPack %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
sapply(reqPack, require, character.only = TRUE)
ndata <- data.frame(matrix(rep(0,17),nrow = 1, ncol = 17))
colnames(ndata) <- c("FP1","FP2","F7","F8","F4","F3","C3","C4","P3","P4","O1","O2","T7","T8","P7","P8","Label")
for(i in 1:length(Sub)){
  #D <- readMat(paste(Sub[i],'.mat',sep = ""))
  D <- read.csv(paste(Sub[i],".csv",sep = ""))
  #data <- D$ndata[1:N,]
  ndata <- rbind(ndata,D[1:N,-1])
  rm(D)
}
ndata = ndata[-1,]