#install.packages("rstan")
library("rstan")
#install.packages("rstanarm")
options(mc.cores=4)

# Simulating some data
NN  <- 100
rpois_V <- Vectorize(rpois,vectorize.args = c("lambda"))
XX <- rgamma(NN,3,1)
YY <- rpois_V(1,XX)
hist(YY)
plot(YY,XX)
# Running stan code
model = stan_model("Example_BN.stan")

fit = sampling(model,list(N=NN,Y=YY),iter=1600,chains=4,warmup = floor(1600/2),thin = 5)
?rstan::sampling

print(fit)

params = extract(fit)

par(mfrow=c(1,2))
ts.plot(params$alpha,xlab="Iterations",ylab="alpha")
ts.plot(params$beta,xlab="Iterations",ylab="beta")

acf(params$alpha, type = "correlation")
acf(params$beta, type = "correlation")



library(stats)
