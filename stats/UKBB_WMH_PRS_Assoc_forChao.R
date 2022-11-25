setwd("F:/UNSW_chao/UK Biobank/R_analysis/R_chao_06/NH_Del/UKBB_WMH/All_age")

library("RNOmni")
library(asbio)

ph=read.table("UKBB_GeneticFiltered_Phenotypes_LongevityPRS.txt",header=T,stringsAsFactors=F,sep="\t")

fs=read.table("UKBB_WMH.txt",header=T,stringsAsFactors=F)

alldat=merge(ph,fs,by="IID",sort=F)

prses=grep("DelNH2019_P_5e8",names(alldat),value=T)

mris=names(alldat)[201:204]
tots=c("EstimatedTotalIntraCranialVol","eTIV")
mris=setdiff(mris,tots)


alldat$ICV=as.numeric(scale(alldat$EstimatedTotalIntraCranialVol))
al=which(alldat$ICV <= -3)
ar=which(alldat$ICV >= 3)
outliers=c(al,ar)
alldat=alldat[-outliers,]

##### additional filters  - To be discussed


alldat$zAge=as.numeric(scale(alldat$Age3))
alldat$zAge2=alldat$zAge^2
alldat$zAgexSex=alldat$zAge*alldat$SEX
alldat$zAge2xSex=alldat$zAge2*alldat$SEX

outall=NULL
for(j in 1:length(mris)) 
{
print(j) 
y=rankNorm(alldat[,mris[j]]) ### This could be done using apply function.
for(i in 1:length(prses))
{
prs=as.numeric(scale(alldat[,prses[i]])) ### This could be done using apply function.
lmout=lm(y~prs+zAge+zAge2+SEX+zAgexSex+zAge2xSex+ICV+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10,data=alldat)
out=summary(lmout)
lm0=lm(y~zAge+zAge2+SEX+zAgexSex+zAge2xSex+ICV+PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8+PC9+PC10,data=alldat)
pr2=partial.R2(lm0, lmout)
xx=c(mris[j],prses[i],out$coefficients[1:7,1],out$coefficients[1:7,2],out$coefficients[1:7,3],out$coefficients[1:7,4],pr2)
outall=rbind(outall,xx)
}
}

outall=data.frame(outall,stringsAsFactors=F)

regvars=c("mu","PRS","Age","Age2","Sex","AgexSex","Age2xSex")

nn=c("MRI_measure","PRS_ID",paste("Beta.",regvars,sep=""),paste("SE.",regvars,sep=""),paste("tvalue.",regvars,sep=""),paste("Pval.",regvars,sep=""),"R2.PRS")

names(outall)=nn
write.table(outall,file="Temp.txt",row.names=F,col.names=T,sep="\t",quote=F)
out=read.table("Temp.txt",header=T,stringsAsFactors=F)
out$pval_prs.adj=p.adjust(out$Pval.PRS,method="BH") 

write.table(out,file="UKBB_NHDel_WMH_Assoc_with_LongevityPRS.txt",row.names=F,col.names=T,sep="\t",quote=F)


