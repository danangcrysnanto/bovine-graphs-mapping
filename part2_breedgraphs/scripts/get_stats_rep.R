#!/usr/bin/env Rscript
#collect statistics from replication


library(magrittr)
library(tidyverse)
library(optparse)
library(data.table)

#option parser
option_list  <- list(make_option(c("-b","--breeds"), help="breeds", type="character",action="store"),
                     make_option(c("-m","--mode"), help="mode", type="character",action="store"),
                     make_option(c("-p","--prog"), default="vg", help="program", type="character",action="store"),
                     make_option(c("-r","--replication"), help="number of rep", type="integer",action="store"))

opt  <- parse_args(OptionParser(option_list=option_list))
breeds=opt$breeds
mode=opt$mode
prog=opt$prog
replication=opt$replication

#prefix  <- paste("bta25",graph,replication,"pan",mode,sep="_")
prefix  <- paste(breeds,replication,"003_pan",mode,sep="_")
infile <- paste0("mapping_result/",prefix,".compare.gz")
print(infile)
datcomp <- fread(infile)
colnames(datcomp)[2] <- "correct"
colnames(datcomp)[3] <- "mq"
datcomp %<>% mutate(bin=cut(mq, seq(0,60,10),include.lowest = TRUE))

datsum <- datcomp %>% group_by(bin) %>%
  summarise(mq=mean(mq),
            FP=sum(correct==0),
            total=n()) %>%
  ungroup() %>%
  mutate(TP=total-FP)

datsum %<>% arrange(-mq) %>%
  mutate(TP_sum=cumsum(TP),
         FP_sum=cumsum(FP),
         total_sum=cumsum(total),
         FPR=FP_sum*100/max(total_sum),
         TPR=TP_sum*100/max(total_sum))

datsum$mode <- mode
datsum$breeds <- breeds
datsum$prog <- prog
datsum$replication <- replication

outfile <- paste(breeds,replication,mode,prog,sep="_")
outfile <- paste0("mapping_result/",outfile,".tsv")

write.table(datsum,file=outfile,quote=FALSE,row.names = FALSE,sep="\t",col.names = TRUE)

