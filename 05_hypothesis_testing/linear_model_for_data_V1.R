library(leaps)
library(corrplot)

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
corrplot.mixed(covar,
               lower = "ellipse",
               upper = "number",
               order = "AOE")


#   ____________________________________________________________________________
#   Multiple linear regression Chao1, Shannon, Fisher, Simpson, ACE y Observed ####

#######################################################
#######    Multiple linear regression #################
#######   Chao1, Shannon, Fisher,     #################
#######   Simpson, ACE y Observed     #################
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

full.model = lm(
  Fisher ~
    population + population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

full.model = lm(
  Simpson ~
    population + population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

full.model = lm(
  ACE ~
    population + population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

full.model = lm(
  Observed ~
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
  nvmax = 3,
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
  nvmax = 3,
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

###############################################################################################

#   Multiple linear regression Simpson                                             ####

full.model = lm(
  Simpson ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Simpson ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Simpson ~
                    population + population.density,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Simpson ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Simpson ~
                   population + 
                   population.density,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Fisher                                            ####

full.model = lm(
  Fisher ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Fisher ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Fisher ~
                    population.density + prec_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Fisher ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Fisher ~
                   population.density + prec_june,
                 data = data_v1)
summary(fit.forward)
###############################################################################################

# Multiple linear regression Observed                                            ####

full.model = lm(
  Observed ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Observed ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Observed ~
                    population.density +
                    prec_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Observed ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Observed ~
                   population.density + 
                   prec_june,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression ACE                                            ####

full.model = lm(
  ACE ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  ACE ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(ACE ~
                    population.density +
                    prec_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  ACE ~
    population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 2,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(ACE ~
                   population + 
                   prec_june,
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
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Chao1 ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + population.density + 
    tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Chao1 ~
                    bio01 + bio03 + bio04 + bio05 + bio07 +
                    bio13,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Chao1 ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Chao1 ~
                   bio03 + bio11 + bio12 + year + population.density +
                   prec_june,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Shannon                                              ####

full.model = lm(
  Shannon ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Shannon ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Shannon ~
                    bio06 + bio09 + bio12 + bio13 + bio15 +
                    year,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Shannon ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Shannon ~
                   bio14 + bio19 + year + population + prec_june,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Simpson                                             ####

full.model = lm(
  Simpson ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Simpson ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Simpson ~
                    bio02 + bio05 + bio10 + bio11 + year +
                    prec_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Simpson ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Simpson ~
                   bio03 + bio05 + bio08 + year + population + 
                   population.density,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Fisher                                            ####

full.model = lm(
  Fisher ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Fisher ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Fisher ~
                    bio02 + bio03 + bio04 + bio05 + bio10 +
                    bio15,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Fisher ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Fisher ~
                   bio03 + bio11 + bio13 + population.density + tmin_june + 
                   prec_june,
                 data = data_v1)
summary(fit.forward)
###############################################################################################

# Multiple linear regression Observed                                            ####

full.model = lm(
  Observed ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Observed ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Observed ~
                    bio03 + bio09 + bio11 + bio12 + tmin_june +
                    tmax_june,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Observed ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Observed ~
                   bio12 + bio14 + bio16 + bio17 + year + 
                   prec_june,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression ACE                                            ####

full.model = lm(
  ACE ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  ACE ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(ACE ~
                    bio01 + bio03 + bio04 + bio05 + bio07 +
                    bio13,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  ACE ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + population + 
    population.density + tmin_june + tmax_june + prec_june,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(ACE ~
                   bio03 + bio11 + bio12 + year + population.density + 
                   prec_june,
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
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Chao1 ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Chao1 ~
                    bio03 + bio04 + bio07 + bio12 + bio14 +
                    bio15,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Chao1 ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Chao1 ~
                   bio02 + bio12 + bio14 + bio16 + bio17 +
                   year,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Shannon                                              ####

full.model = lm(
  Shannon ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Shannon ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Shannon ~
                    bio01 + bio02 + bio05 + bio10 + bio11 +
                    year,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Shannon ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Shannon ~
                   bio03 + bio04 + bio08 + bio18 + bio19 +
                   year,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Simpson                                             ####

full.model = lm(
  Simpson ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Simpson ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Simpson ~
                    bio04 + bio05 + bio09 + bio10 + bio11 +
                    year,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Simpson ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Simpson ~
                   bio03 + bio05 + bio08 + bio18 + bio19 + 
                   year,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression Fisher                                            ####

full.model = lm(
  Fisher ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Fisher ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Fisher ~
                    bio03 + bio04 + bio05 + bio07 + bio10 +
                    bio12,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Fisher ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Fisher ~
                   bio12 + bio14 + bio16 + bio17 + bio18 + 
                   bio19,
                 data = data_v1)
summary(fit.forward)
###############################################################################################

#   Multiple linear regression Observed                                            ####

full.model = lm(
  Observed ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  Observed ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Observed ~
                    bio02 + bio03 + bio04 + bio05 + bio10 +
                    bio15,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Observed ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Observed ~
                   bio02 + bio12 + bio14 + bio16 + bio17 + 
                   year,
                 data = data_v1)
summary(fit.forward)

###############################################################################################

#   Multiple linear regression ACE                                            ####

full.model = lm(
  ACE ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1
)
summary(full.model)

##  ............................................................................
##  Backward variable selection                                             ####

models.backward = regsubsets(
  ACE ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(ACE ~
                    bio03 + bio04 + bio07 + bio12 + bio14 +
                    bio15,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  ACE ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(ACE ~
                   bio02 + bio12 + bio14 + bio16 + bio17 + 
                   year,
                 data = data_v1)
summary(fit.forward)



