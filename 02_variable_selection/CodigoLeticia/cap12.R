################################################################################ 
### Chapter 12: Modeling Zero-Inflated Microbiome Data
### Yinglin Xia: September, 2018 
### Algunas modificaciones por: Leticia Ramírez: Marzo, 2023
################################################################################ 
setwd("E:\\Dropbox\\Actividades_2023\\1_CIMAT\\Clases\\Genomica\\codigo")

# Step 1: Load Abundance Data and Prepare Analysis Dataset######################
# Load abundance data and check first few lines:
abund_table=read.csv("allTD_long.csv",header=TRUE)
head(abund_table)
tail(abund_table)

library(dplyr)
abund_table_28 <- filter(abund_table, Ind == 28)
head(abund_table_28)
 
#The following R codes create the group variable “x”, and define it as a factor:
abund_table_28$x <- with(abund_table_28,ifelse(as.factor(DX)%in% "0",0, 1))
head(abund_table_28)
table(abund_table_28$x,abund_table_28$DX)

names(abund_table_28)
abund_table_28$fx <- factor(abund_table_28$x)
names(abund_table_28)
# Removing missing values is not really necessary, but it makes model validation
# easier.
I <- is.na(abund_table_28$Y)|is.na(abund_table_28$fx)|is.na(abund_table_28$nReads)
if(length(I)>0){
    abund_table_28a <- abund_table_28[!I,]
  }else{
    abund_table_28a <- abund_table_28
    }

# Step 2: Check Outcome Distribution and Zeros            ######################

par(mfrow = c(2,1))
plot(table(abund_table_28a$Y),ylab = "Frequencies",main = "Lactobacillus.vaginalis", 
     xlab = "Observed read values")
plot(sort(abund_table_28a$Y),ylab = "Frequencies",main = "Lactobacillus.vaginalis", 
     xlab = "Observed read values")

summary(abund_table_28a$Y)


# Step 3: Create the Offset                               ######################
# The total count read is used to create the offset. The offset will be adjusted 
# as a covariate in the model later to ensure microbiome response is relative 
# abundance instead of count data. 

# This step is critical for fitting linear mixed effects models in microbiome study
summary(abund_table_28a$nReads)

abund_table_28a$Offset <- log(abund_table_28a$nReads)
head(abund_table_28a$Offset)


# Step 4: Create a Formula for Fitting ZIP and ZINB       ######################
f28 <- formula(Y ~ fx + offset(Offset)|1)




# Regresar a presentación




# Step 4.5: Check the overfiting and see which model to fit         ############
summary(abund_table_28a$Y)
var(abund_table_28a$Y)

library(MASS)
fit.nb1 <- glm.nb(Y ~ fx,data=abund_table_28a)
summary(fit.nb1)

fit.nb2 <- glm.nb(Y ~ fx+offset(Offset),data=abund_table_28a)
summary(fit.nb2)


# Step 5: Fit ZIP and ZINB                                ######################
# Now let's build up our model. We are going to use the variables child and camper 
# to model the count in the part of negative binomial model and the variable 
# persons in the logit part of the model. We use the pscl to run a zero-inflated 
# negative binomial regression. We begin by estimating the model with the variables 
# of interest.

#install.packages("pscl")
library(pscl)
# ZI Poisson:
ZIP28 <- zeroinfl(formula = f28, dist = "poisson", link = "logit", 
                  data = abund_table_28a)

#The link = logit option specifies the logistic link for the structural
#zeros versus the non-structural zeros (the sampling zeros plus the positive counts).


# A binomial distribution is always used to model the distinction. The offset term 
# (the log of the total number of reads in a given sample) is used here to allow 
# for a comparison in the relative abundance (and not absolute counts) between groups.
summary(ZIP28)



hist(ZIP28$fitted.values,breaks=seq(0,120,by=10))
hist(abund_table_28a$Y)
qqplot(ZIP28$fitted.values,abund_table_28a$Y)
plot(ZIP28$residuals)
hist(ZIP28$residuals)
     


# ZI Negative Binomial:
ZINB28 <- zeroinfl(formula = f28, dist = "negbin", link = "logit", data = abund_table_28a)
summary(ZINB28)

hist(ZINB28$fitted.values,breaks=seq(0,120,by=10))
hist(abund_table_28a$Y)
qqplot(ZINB28$fitted.values,abund_table_28a$Y)
plot(ZINB28$residuals)
hist(ZINB28$residuals)

hist(ZIP28$residuals,col=rgb(1,0,1,.5),add=TRUE)  #contrastar con el anterior
plot(ZIP28$residuals, ZINB28$residuals)
abline(0,1,col="blue")

ZINB28_2 <- zeroinfl(formula = Y ~ fx + offset(Offset), dist = "negbin", link = "logit", data = abund_table_28a)
summary(ZINB28_2)

plot(ZIP28$residuals, ZINB28_2$residuals)
abline(0,1,col="blue")
plot(ZINB28$residuals, ZINB28_2$residuals)
abline(0,1,col="blue")


AIC(ZIP28,ZINB28,ZINB28_2)



# Zero Hurdle Poisson and Negative Binomial ####################################

ZHP28 <- hurdle(formula =Y ~ fx+offset(Offset), dist= "poisson", data = abund_table_28a)
summary(ZHP28)


ZHNB28 <- hurdle(formula = Y ~ fx+offset(Offset), dist= "negbin", data = abund_table_28a)
summary(ZHNB28)


# Comparing Zero-Inflated ans Zero-Hurdle Models
# Likelihood Ratio Test
# In general, nested models are compared using likelihood or score test, while
# non-nested models are evaluated using AIC 
# For the models considered, ZIP is nested within ZINB, ZHP nested within ZHNB. 

library(lmtest)
lrtest(ZIP28,ZINB28)


lrtest(ZHP28,ZHNB28)


