#install.packages("rstan")
library("rstan")
#install.packages("rstanarm")
options(mc.cores=4)

# Simulating some data
NN  <- 100
II <- rpois(NN,5)
XX <- rbinom(NN,1,0.7)
YY <- (II*XX)

hist(YY)
# Running stan code
model = stan_model("Example_ZIP_Bueno.stan")

fit = sampling(model,list(N=NN,y=YY),iter=200,chains=4)

print(fit)

params = extract(fit)

par(mfrow=c(1,2))
ts.plot(params$theta,xlab="Iterations",ylab="theta")
ts.plot(params$lambda,xlab="Iterations",ylab="lambda")

acf(params$theta, type = "correlation")
acf(params$lambda, type = "correlation")



library(stats)


