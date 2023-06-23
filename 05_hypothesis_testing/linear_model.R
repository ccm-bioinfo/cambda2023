library(leaps)
library(corrplot)

#   ____________________________________________________________________________
#   Read data                                                               ####

data_v1 = read.csv("regression_V1 - data.csv")

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
#   Multiple linear regression                                              ####

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
    bio15 + bio16 + bio17 + bio18 + bio19 + year + latitude,
  data = data_v1,
  nvmax = 5,
  method = "backward"
)
summary(models.backward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.backward = lm(Chao1 ~
                    bio01 + bio03 + bio04 + bio05 + bio07 +
                    bio08,
                  data = data_v1)
summary(fit.backward)

##  ............................................................................
##  Forward variable selection                                              ####

models.forward = regsubsets(
  Chao1 ~
    bio01 + bio02 + bio03 + bio04 + bio05 + bio06 + bio07 +
    bio08 + bio09 + bio10 + bio11 + bio12 + bio13 + bio14 +
    bio15 + bio16 + bio17 + bio18 + bio19 + year + latitude,
  data = data_v1,
  nvmax = 5,
  method = "forward"
)
summary(models.forward)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit best resulting model                                                ####

fit.forward = lm(Chao1 ~
                   bio02 + bio06 + bio08 + bio11 + year +
                   latitude,
                 data = data_v1)
summary(fit.forward)
