#install.packages("rstan")
library("rstan")
#options(mc.cores=4)

# Simulating some data
n     = 100
y     = rnorm(n,1.6,0.2)

# Running stan code
model = stan_model("Example1.stan")

fit = sampling(model,list(n=n,y=y),iter=200,chains=4)

print(fit)

params = extract(fit)


par(mfrow=c(1,2))
ts.plot(params$mu,xlab="Iterations",ylab="mu")
ts.plot(params$sigma,xlab="Iterations",ylab="sigma")

hist(params$mu,main="",xlab="mu")
hist(params$sigma,main="",xlab="sigma")

acf(params$mu, type = "correlation")
acf(params$sigma, type = "correlation")

