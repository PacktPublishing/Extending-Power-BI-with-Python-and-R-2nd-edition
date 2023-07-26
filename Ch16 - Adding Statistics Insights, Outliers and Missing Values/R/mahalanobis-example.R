

library(mvtnorm)
library(robust)
library(ggplot2)

custom_plot <- function(x, is_outlier, center) {
    ggplot(data.frame(x1=x[,1], x2=x[,2], is_outlier=is_outlier), 
           aes(x=x1, y=x2, color=is_outlier)) + 
        geom_point() +
        annotate("point", x=center[1], y=center[2], color = "black", size=3)
}



# Create example data

set.seed(6897354)
x <- rnorm(200)
y <- rnorm(200) + x
y2 <- rnorm(200) + x^2
data <- data.frame(x, y)

cutoff <- 0.95

# Adding the outlier
data <- rbind(data, c(1, 4))

head(data)

ggp <- ggplot(data, aes(x, y)) +
    geom_point()

ggp 


cov.obj = covRob(data, estim="mcd", alpha=0.7)
center = cov.obj$center
cov = cov.obj$cov
distances = mahalanobis(data, center=center, cov=cov)

cut = qchisq(cutoff, ncol(data))

custom_plot(data, distances>cut, center)

pchisq(distances[distances>cut], ncol(data)) # outlier probabilities


data2 <- data.frame(x, y2)

# Adding the outlier
data2 <- rbind(data2, c(1, 9))

ggp_nl <- ggplot(data2, aes(x, y2)) +
    geom_point()

ggp_nl


cov.obj2 = covRob(data2, estim="mcd", alpha=0.7)
center2 = cov.obj2$center
cov2 = cov.obj2$cov
distances2 = mahalanobis(data2, center=center2, cov=cov2)
cut2 = qchisq(cutoff, ncol(data2))


custom_plot(data2, distances2>cut2, center2)
