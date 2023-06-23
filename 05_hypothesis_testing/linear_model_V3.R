#### Script for multiple Lineal Regresion (Shannon and Chao1 Index)
#### Autor: Miguel Nakamura, J. Abel Lovaco, Camila Silva, Haydeé Peruyero, Andres Arredondo
#### Description: This script was used for analisys challenge CAMDA2023



### Load the libraries
library(leaps)
library(corrplot)

### Configurar la carpeta
setwd("~/CAMDA-2023/ModelosLineales")
#   ____________________________________________________________________________
#   Read data                                                               ####

data_v1 = read.csv("regression_V1 - data.csv")
#data_v1 = read.csv("prueba.csv")
### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Simple check coordinates for which bioclim variables were extracted     ####

plot(data_v1$longitude, data_v1$latitude)
text(data_v1$longitude + 7, data_v1$latitude, data_v1$city)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Correlation analysis for alpha-biodiversity measures                    ####

covar = cor(data_v1[, c("Observed", "Chao1", "ACE", "Shannon",
                        "Simpson", "Fisher")])

#covar = cor(data_v1[, c("Chao1", "Shannon")])

corrplot.mixed(covar,
               lower = "ellipse",
               upper = "number",
               order = "AOE")


#   ____________________________________________________________________________
#   Multiple linear regression Chao1 and Shannon
#######################################################
#######    Multiple linear regression #################
#######         Chao1 y Shannon        #################
#######################################################

full.model = lm(
  Chao1 ~
    population + population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

full.model = lm(
  Shannon ~
    population + population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)


#######################################################
#######################################################
#######   ANALISIS DEMOGRAFICOS               #########
#######################################################
#######################################################
#######################################################

##  ............................................................................
#   ____________________________________________________________________________
#   Multiple linear regression Chao1                                              ####

full.model = lm(
  Chao1 ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Chao1 ~
    population + population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Chao1 ~
                    population.density + prec_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Chao1 ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Chao1 ~
                   population.density +
                   prec_june,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Shannon                                              ####

full.model = lm(
  Shannon ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Shannon ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Shannon ~
                    population + prec_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Shannon ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Shannon ~
                  population + prec_june,
                 data = data_v1)
summary(fit.forward)

#######################################################
#######################################################
#######   ANALISIS CON BIOM Y DEMOGRAFICOS    #########
#######################################################
#######################################################
#######################################################

##  ............................................................................
#   ____________________________________________________________________________
#   Multiple linear regression Chao1                                              ####

full.model = lm(
  Chao1 ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19 + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Chao1 ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19 + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Chao1 ~
                    bio10 + bio16 + bio19 + population + tmin_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Chao1 ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19 + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Chao1 ~
                   bio10 + population + population.density +
                   prec_june,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Shannon                                              ####

full.model = lm(
  Shannon ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19 + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Shannon ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19 + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Shannon ~
                    bio08 + bio18 + bio19 + population + tmax_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Shannon ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19 + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Shannon ~
                   bio10 + bio16 + population + population.density + tmax_june,
                 data = data_v1)
summary(fit.forward)



#######################################################
#######################################################
#######       BIOM (PRIMEROS ANALISIS)         #########
#######################################################
#######################################################
#######################################################
#   ____________________________________________________________________________
#   Multiple linear regression Chao1                                              ####

full.model = lm(
  Chao1 ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Chao1 ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v1,
  nvmax = 3,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Chao1 ~
                    bio16 + bio18 +
                    bio19,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Chao1 ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v1,
  nvmax = 3,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Chao1 ~
                   bio16 + bio17 + bio19,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Shannon                                              ####

full.model = lm(
  Shannon ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Shannon ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v1,
  nvmax = 3,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Shannon ~
                    bio16 + bio17 + bio18,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Shannon ~
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v1,
  nvmax = 3,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Shannon ~
                   bio09 + bio18 + bio19,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

