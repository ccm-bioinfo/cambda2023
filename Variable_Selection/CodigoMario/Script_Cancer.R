# Cargamos las librerias

library(ggplot2)
library(bayesplot)
library(tidyverse)
library(readr)
library(corrplot)
library(rstanarm)
theme_set(bayesplot::theme_default())

# Cargamos los datos
cancer <- read_csv("cancer/Cancer_Data.csv") %>% 
  mutate(diagnosis=factor(diagnosis))

#Graficamos la correlacion no lineal

cancer %>% 
  mutate(diagnosis=as.integer(diagnosis)) %>% 
  .[2:32] %>% 
  cor(method = "spearman") %>% 
  corrplot()

# Corremos un modelo con una sola variable con rstanarm

ggplot(cancer, aes(x = radius_mean, y = ..density.., fill = diagnosis == "M")) +
  geom_histogram() +
  scale_fill_manual(values = c("gray30", "skyblue"))
t_prior <- student_t(df = 7, location = 0, scale = 2.5)
fit1 <- stan_glm(diagnosis ~ radius_mean, data = cancer,
                 family = binomial(link = "logit"),
                 prior = t_prior, prior_intercept = t_prior,
                 cores = 2, seed = 12345)  
round(posterior_interval(fit1, prob = 0.5), 2)

pr_switch <- function(x, ests) plogis(ests[1] + ests[2] * x)
# A function to slightly jitter the binary data
jitt <- function(...) {
  geom_point(aes_string(...), position = position_jitter(height = 0.05, width = 0.1),
             size = 2, shape = 21, stroke = 0.2)
}
ggplot(cancer, aes(x = radius_mean, y = as.integer(diagnosis)-1, color = diagnosis)) +
  scale_y_continuous(breaks = c(0, 0.5, 1)) +
  jitt(x="radius_mean") +
  stat_function(fun = pr_switch, args = list(ests = coef(fit1)),
                size = 2, color = "gray35")

# Corremos un modelo con dos variables explicativas

fit2 <- update(fit1, formula = diagnosis ~  perimeter_mean + concavity_worst)
(coef_fit2 <- round(coef(fit2), 3))
cancer[,c("perimeter_mean" ,"concavity_worst")] %>% 
  summary()

pr_switch2 <- function(x, y, ests) plogis(ests[1] + ests[2] * x + ests[3] * y )
grid <- expand.grid(perimeter_mean = seq(30, 200, length.out = 100),
                    concavity_worst = seq(0, 1.50, length.out = 100))
grid$prob <- with(grid, pr_switch2(perimeter_mean,concavity_worst, coef(fit2)))
ggplot(grid, aes(x = perimeter_mean, y = concavity_worst)) +
  geom_tile(aes(fill = prob)) +
  geom_point(data = cancer, aes(color = factor(diagnosis)), size = 2, alpha = 0.85) +
  scale_fill_gradient() +
  scale_color_manual("switch", values = c("white", "black"), labels = c("Benigno", "Maligno"))

# Quantiles
q_per <- quantile(cancer$perimeter_mean, seq(0, 1, 0.25))
q_conc <- quantile(cancer$concavity_worst, seq(0, 1, 0.25))
base <- cancer %>% 
  mutate(diagnosis=as.double(diagnosis)-1) %>% 
ggplot() + xlim(c(0, NA)) +
  scale_y_continuous(breaks = c(0, 0.5, 1))
vary_per <- base + jitt(x="perimeter_mean", y="diagnosis", color="diagnosis")
vary_conc <- base + jitt(x="concavity_worst", y="diagnosis", color="diagnosis")
for (i in 1:5) {
  vary_per <-
    vary_per + stat_function(fun = pr_switch2, color = "gray35",
                              args = list(ests = coef(fit2), y = q_conc[i]))
  vary_conc <-
    vary_conc + stat_function(fun = pr_switch2, color = "gray35",
                                 args = list(ests = coef(fit2), x = q_per[i]))
}
bayesplot_grid(vary_per, vary_conc,
               grid_args = list(ncol = 2))



