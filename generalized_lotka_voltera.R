#this script is meant to take the timeseries data from controlled infections and perform generalized lotka voltera modeling'''
#glmnet tutorial: https://drsimonj.svbtle.com/ridge-regression-with-glmnet
#library(deSolve)
#library(lattice)
#library(glmnet)
library(tidyverse)
library(broom)
library(lme4)
library(nlme)
library(lmertest)
library(relaimpo)


dc3000=read.table("/ebio/abt6_projects9/metagenomic_controlled/data/processed_reads/dc3000_infections/meta_family_corrected_per_plant.csv", header=TRUE, sep=",", row.names = 1)

#reduce to top 5 genera
dc3000_red=dc3000[names(sort(rowMeans(dc3000), decreasing=TRUE)[1:10]),]

#recode with variables
names_samps= colnames(dc3000)
dc3000_rotate=as.data.frame(t(dc3000))
dc3000_rotate$treatment=unlist(sapply(strsplit(as.character(names_samps), "\\_"), "[[", 1))
temp=unlist(sapply(strsplit(as.character(names_samps), "\\_"), "[[", 2))
dc3000_rotate$day=sapply(strsplit(temp, "\\."), "[[",1)

temp_=dc3000_rotate$day
temp_[temp_=="RI"] = 0
temp_[temp_=="RII"] = 1
temp_[temp_=="RIII"] =2
temp_[temp_=="RIV"] = 3
temp_[temp_=="RV"] = 4
temp_[temp_=="RVI"] = 6
dc3000_rotate$day=as.numeric(as.character(temp_))
dc3000_fin=dc3000_rotate[,c(rownames(dc3000_red),'treatment', 'day')]

#Show the effect of Pseudomonas growth on each of the other species
#EV_only=dc3000_fin[dc3000_fin$treatment!="avrB"& dc3000_fin$treatment!="control",]
EV_only=dc3000_fin[dc3000_fin$treatment!="control",]
models_basic <- list()
beta_pseudo=list()
dvnames=rownames(dc3000_red)
for(y in dvnames){
  y_transformed=paste(paste("log10(",y),"+0.01)")
  form=formula(paste(y_transformed, "~day+log10(Pseudomonadaceae+.01)+0"))
  print(y)
  models_basic[[y]]=lm(form, data=EV_only)
  beta_pseudo[[y]]=models_basic[[y]]$coefficients[2]
}

keep_beta=


models <- list()
dvnames=rownames(dc3000_red)
for(y in dvnames){
  y_transformed=paste(paste("log10(",y),"+0.01)")
  form=formula(paste(y_transformed, "~day*log10(Pseudomonadaceae+.01)+0"))
  print(y)
  models[[y]]=lm(form, data=EV_only)
}




summary(lm(Microbacteriaceae~treatment+Pseudomonadaceae+day, data=EV_only))
summary(lmer(Sphingobacteriaceae~day*Pseudomonadaceae+treatment, data=dc3000_fin))


#Show the effect of 



#basic model


micro=(lme(Microbacteriaceae~day+Pseudomonadaceae, random=~1|treatment, data=dc3000_fin))
anova(micro)
summary(lmer(Enterobacteriaceae~day+Pseudomonadaceae+1|treatment, data=dc3000_fin))
summary(lmer(Sphingobacteriaceae~day*Pseudomonadaceae+treatment, data=dc3000_fin))










#deltax = mu+
  
  
predpreyLV<-function(t,y,p){
  N<-y[1]
  p<-y[2]
  
}

LotVmod <- function (Time, State, Pars) {
  with(as.list(c(State, Pars)), {
    dx = x*(alpha - beta*y)
    dy = -y*(gamma - delta*x)
    return(list(c(dx, dy)))
  })
}

Pars <- c(alpha = 2, beta = .5, gamma = .2, delta = .6)
State <- c(x = 10, y = 10)
Time <- seq(0, 100, by = 1)

out <- as.data.frame(ode(func = LotVmod, y = State, parms = Pars, times = Time))

matplot(out[,-1], type = "l", xlab = "time", ylab = "population")
legend("topright", c("Cute bunnies", "Rabid foxes"), lty = c(1,2), col = c(1,2), box.lwd = 0)