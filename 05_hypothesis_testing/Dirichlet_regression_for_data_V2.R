library(DirichletReg)
library(reshape)
library(ggplot2)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Read data                                                               ####

data_v2 = read.csv("regression_V2 - data.csv")

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Prepare data for Dirichlet regression: defines response variable        ####

data_v2$Y = DR_data(data_v2[, 1:4])

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Fit Dirichlet regression                                                ####

fit = DirichReg(
  Y ~
    tmin_june + tmax_june + prec_june +
    population + population.density +
    bio08 + bio09 + bio10 + bio11 + bio16 + bio17 + bio18 + bio19,
  data = data_v2,
  model = "alternative",
  subset = NULL,
  weights = NULL,
  control = list(iterlim = 5000)
)

### . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..
### Display summary of results                                              ####

summary(fit)


##  ............................................................................
##  Examine predictions                                                     ####

# row 1 is ACK
n = 100
citycovs = data.frame(t(fit$X[[1]][1, ]))
newcovs = citycovs
for (i in 1:(n - 1)) {
  newcovs = rbind(newcovs, citycovs)
}

newcovs$population = seq(1000, 2000, length.out = n)
preds = data.frame(predict(fit, newcovs))
names(preds) = fit$varnames
plotdata = data.frame(preds, newcovs)

ggplotdata = melt(plotdata,
                  measure.vars = fit$varnames,
                  variable_name = "Phyllum")

g1 = ggplot(ggplotdata, aes(x = population, y = value, col = Phyllum)) +
  geom_line()
print(g1)
