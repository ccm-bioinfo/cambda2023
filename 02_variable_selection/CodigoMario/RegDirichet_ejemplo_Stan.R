
library("rstan")

##### Datos

#install.packages("DirichletReg")

library("DirichletReg")

Bld <- BloodSamples
head(Bld)
Bld <- na.omit(Bld) #removemos los casos no clasificados

# Graficamos 

indian_red<-rgb(205/255,92/255,92/255,1)
par(mfrow=c(1,2))
plot(1:4, Bld[1, 1:4], ylim = c(0, 0.6), type = "n", xaxt = "n", las = 1,
     xlab = "", ylab = "Proportion", main = "Disease A", xlim = c(0.6, 4.4))
abline(h = seq(0, 0.6, by = 0.1), col = "grey", lty = 2)
boxplot(Bld[Bld$Disease == "A",1:4], by=list(names(Bld)[1:4]),col=NA,border=indian_red, xaxt = "n",yaxt = "n",add=TRUE)
axis(1, at = 1:4, labels = names(Bld)[1:4], las = 2, cex.axis=.8)
matplot(t(Bld[Bld$Disease == "A",1:4]),add=TRUE,pch=19,col=rgb(.5,.5,.5,.5))
lines(apply(subset(Bld, Disease == "A")[, 1:4], MAR = 2, FUN = mean),
      type = "o", pch = 16, cex = 1.2, lwd = 2)

plot(1:4, Bld[1, 1:4], ylim = c(0, 0.6), type = "n", xaxt = "n", las = 1,
     xlab = "", ylab = "Proportion", main = "Disease B", xlim = c(0.6, 4.4))
abline(h = seq(0, 0.6, by = 0.1), col = "grey", lty = 3)
boxplot(Bld[Bld$Disease == "B",1:4], by=list(names(Bld)[1:4]),col=NA,border=indian_red,xaxt = "n",yaxt = "n",add=TRUE)
axis(1, at = 1:4, labels = names(Bld)[1:4], las = 2, cex.axis=.8)
matplot(t(Bld[Bld$Disease == "B",1:4]),add=TRUE,pch=19,col=rgb(.5,.5,.5,.5))
lines(apply(subset(Bld, Disease == "B")[, 1:4], MAR = 2, FUN = mean),
      type = "o", pch = 16, cex = 1.2, lwd = 2)



##### Definimos modelo en Stan

stan_code <- "
data {
  int<lower=1> N;     // total number of observations
  int<lower=2> ncolY; // number of categories
  int<lower=2> ncolX; // number of predictor levels
  matrix[N,ncolX] X;  // predictor design matrix
  matrix[N,ncolY] Y;  // response variable
  real sd_prior;      // Prior standard deviation
}
parameters {
  matrix[ncolY-1,ncolX] beta_raw; // coefficients (raw)
  real theta;
}
transformed parameters{
  real exptheta = exp(theta);
  matrix[ncolY,ncolX] beta;       // coefficients
  for (l in 1:ncolX) {
    beta[ncolY,l] = 0.0;
  }
  for (k in 1:(ncolY-1)) {
    for (l in 1:ncolX) {
      beta[k,l] = beta_raw[k,l];
    }
  }
}
model {
  // previa:
  theta ~ normal(0,sd_prior);
  for (k in 1:(ncolY-1)) {
    for (l in 1:ncolX) {
      beta_raw[k,l] ~ normal(0,sd_prior);
    }
  }
  // likelihood
  for (n in 1:N) {
    vector[ncolY] logits;
    for (m in 1:ncolY){
      logits[m] = X[n,] * transpose(beta[m,]);
    }
    transpose(Y[n,]) ~ dirichlet(softmax(logits) * exptheta);
  }
}
"



##### Preparamos datos

# Creamos la matrix de diseño X:
X <- as.matrix(model.matrix(lm(Albumin~Disease, data = Bld)))
X <- matrix(nrow = nrow(X), ncol = ncol(X), data = as.numeric(X))

# Definimos la variable de respuesta Y:
Bld$Smp <- DR_data(Bld[, 1:4])
Y <- Bld$Smp

# Preparamos todo en formato de lista:
Dat <- list(N = nrow(Y), ncolY = ncol(Y), ncolX = ncol(X),
            X = X, Y = Y, sd_prior = 1)


##### Realizamos la estimación

#fit1 <- stan(model_code = stan_code, data = Dat, chains = 4, iter = 2000, cores = 4,
#                 control = list(adapt_delta = 0.95, max_treedepth = 20), refresh = 100)

fit1 <- stan(model_code = stan_code, data = Dat, chains = 1, iter = 2000) 



##### Checamos resultados

#library("shinystan")

plot(fit1, pars = c("theta", "beta"))

traceplot(fit1, pars = c("theta", "beta"), inc_warmup = TRUE, nrow = 2)

traceplot(fit1, pars = c("theta", "beta"), inc_warmup = FALSE, nrow = 2)

print(fit1, probs=c(0.025, 0.975),pars = c("theta", "beta"),inc_warmup = FALSE)

sampler_params <- get_sampler_params(fit1, inc_warmup = TRUE)
summary(do.call(rbind, sampler_params), digits = 2)
#lapply(sampler_params, summary, digits = 2)

pairs(fit1, pars = c("theta", "beta", "lp__"), las = 1)

theta_draws = extract(fit1)$theta
beta_draws = extract(fit1)$beta

# Calculating posterior mean (estimator)
mean(theta_draws)
## [1] 0.2715866
apply(beta_draws[,,1],2,FUN="mean")  #beta_.,1
apply(beta_draws[,,2],2,FUN="mean")  #beta_.,2
par(mfrow=c(1,2))
matplot(beta_draws[,,1],pch=19)
matplot(beta_draws[,,2],pch=19)

# Calculating posterior intervals
quantile(theta_draws, probs=c(0.025, 0.975))
#    2.5%    97.5% 
# 3.725351 4.350544 
theta_draws_df = data.frame(list(theta=theta_draws))

library(ggplot2)
plotpostre = ggplot(theta_draws_df, aes(x=theta)) +
  geom_histogram(bins=20, color="gray")
plotpostre
 

20/500

