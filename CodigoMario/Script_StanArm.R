library(ggplot2)
library(bayesplot)

theme_set(bayesplot::theme_default())
library(rstanarm)
data(wells)
wells$dist100 <- wells$dist / 100
  ggplot(wells, aes(x = dist100, y = ..density.., fill = switch == 1)) +
  geom_histogram() +
  scale_fill_manual(values = c("gray30", "skyblue"))
  t_prior <- student_t(df = 7, location = 0, scale = 2.5)
  fit1 <- stan_glm(switch ~ dist100, data = wells,
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
  ggplot(wells, aes(x = dist100, y = switch, color = switch)) +
    scale_y_continuous(breaks = c(0, 0.5, 1)) +
    jitt(x="dist100") +
    stat_function(fun = pr_switch, args = list(ests = coef(fit1)),
                  size = 2, color = "gray35")
  
  fit2 <- update(fit1, formula = switch ~ dist100 + arsenic)
  (coef_fit2 <- round(coef(fit2), 3))
  
  pr_switch2 <- function(x, y, ests) plogis(ests[1] + ests[2] * x + ests[3] * y)
  grid <- expand.grid(dist100 = seq(0, 4, length.out = 100),
                      arsenic = seq(0, 10, length.out = 100))
  grid$prob <- with(grid, pr_switch2(dist100, arsenic, coef(fit2)))
  ggplot(grid, aes(x = dist100, y = arsenic)) +
    geom_tile(aes(fill = prob)) +
    geom_point(data = wells, aes(color = factor(switch)), size = 2, alpha = 0.85) +
    scale_fill_gradient() +
    scale_color_manual("switch", values = c("white", "black"), labels = c("No", "Yes"))
  
  # Quantiles
  q_ars <- quantile(wells$dist100, seq(0, 1, 0.25))
  q_dist <- quantile(wells$arsenic, seq(0, 1, 0.25))
  base <- ggplot(wells) + xlim(c(0, NA)) +
    scale_y_continuous(breaks = c(0, 0.5, 1))
  vary_arsenic <- base + jitt(x="arsenic", y="switch", color="switch")
  vary_dist <- base + jitt(x="dist100", y="switch", color="switch")
  for (i in 1:5) {
    vary_dist <-
      vary_dist + stat_function(fun = pr_switch2, color = "gray35",
                                args = list(ests = coef(fit2), y = q_dist[i]))
    vary_arsenic <-
      vary_arsenic + stat_function(fun = pr_switch2, color = "gray35",
                                   args = list(ests = coef(fit2), x = q_ars[i]))
  }
  bayesplot_grid(vary_dist, vary_arsenic,
                 grid_args = list(ncol = 2))
  
  (loo1 <- loo(fit1))
  

  (loo2 <- loo(fit2))

  loo_compare(loo1, loo2)
  