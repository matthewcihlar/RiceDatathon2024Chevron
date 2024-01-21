library(dplyr)
library(tidyr)
library(glmnet)

df <- read.csv("~/projects/private/stat_410/training.csv")

head(df)

# Filter out non-numerical fields to start
df_mlr <- df[c("surface_x", "surface_y", "bh_x", "bh_y", "gross_perforated_length", 
               "total_proppant", "total_fluid", "true_vertical_depth", "proppant_intensity", 
               "frac_fluid_intensity", "horizontal_midpoint_x", "horizontal_midpoint_y", "horizontal_toe_x", "horizontal_toe_y",
               "OilPeakRate")]

# Change erroneous values to NA
df_mlr[is.na(df_mlr) | df_mlr == "Inf"] <- NA

# Drop NA values
df_nona <- drop_na(df_mlr)

# Split the surface plane into 4 quadrants
x_range <- max(df_nona["surface_x"]) - min(df_nona["surface_x"])
y_range <- max(df_nona["surface_y"]) - min(df_nona["surface_y"])

midpoint_x <- min(df_nona["surface_x"]) + (x_range / 2)
midpoint_y <- min(df_nona["surface_y"]) + (x_range / 2)

quad1 <- subset(df_nona, surface_x > midpoint_x & surface_y > midpoint_y)
quad2 <- subset(df_nona, surface_x < midpoint_x & surface_y > midpoint_y)
quad3 <- subset(df_nona, surface_x < midpoint_x & surface_y < midpoint_y)
quad4 <- subset(df_nona, surface_x > midpoint_x & surface_y < midpoint_y)

# Set seed for easier testing
set.seed(1)

# Divide between training and testing data (80% testing, 20% training)
quad1$rand <- runif(dim(quad1)[1], min = 0, max = 1)
quad2$rand <- runif(dim(quad2)[1], min = 0, max = 1)
quad3$rand <- runif(dim(quad3)[1], min = 0, max = 1)
quad4$rand <- runif(dim(quad4)[1], min = 0, max = 1)

quad1_training <- subset(quad1, rand < 0.8)
quad1_testing <- subset(quad1, rand > 0.8)
quad2_training <- subset(quad2, rand < 0.8)
quad2_testing <- subset(quad2, rand > 0.8)
quad3_training <- subset(quad3, rand < 0.8)
quad3_testing <- subset(quad3, rand > 0.8)
quad4_training <- subset(quad4, rand < 0.8)
quad4_testing <- subset(quad4, rand > 0.8)

training <- rbind(quad1_training, quad2_training, quad3_training, quad4_training)
testing <- rbind(quad1_testing, quad2_testing, quad3_testing, quad4_testing)

# Initialize variables for multiple linear regression model
opr <- training$OilPeakRate

sx <- training$surface_x
sy <- training$surface_y

bx <- training$bh_x
by <- training$bh_y

gpl <- training$gross_perforated_length

tp <- training$total_proppant

tf <- training$total_fluid

tvd <- training$true_vertical_depth

pi <- training$proppant_intensity

ffi <- training$frac_fluid_intensity

#ptffr <- training$proppant_to_frac_fluid_ratio

#fftpr <- training$frac_fluid_to_proppant_ratio

hmx <- training$horizontal_midpoint_x
hmy <- training$horizontal_midpoint_y

htx <- training$horizontal_toe_x
hty <- training$horizontal_toe_y

# Use the multiple linear regression model
model <- lm(opr ~ sx + sy + bx + by + gpl + tp + tf + tvd + pi + ffi + hmx + hmy + htx + hty)

# Get a summary of the linear regression model
summary(model)

new = testing[c("surface_x", "surface_y", "bh_x", "bh_y", "gross_perforated_length", 
                              "total_proppant", "total_fluid", "true_vertical_depth", "proppant_intensity", 
                              "frac_fluid_intensity", "horizontal_midpoint_x", "horizontal_midpoint_y", "horizontal_toe_x", "horizontal_toe_y")]

predict(model)

testing_opr <- testing$OilPeakRate

#rsse <- sqrt((1 / length(predictions)) * sum((predictions - testing_opr)^2))

#rsse

# The following uses LASSO regression

x <- data.matrix(training[, c("surface_x", "surface_y", "bh_x", "bh_y", "gross_perforated_length", 
                             "total_proppant", "total_fluid", "true_vertical_depth", "proppant_intensity", 
                             "frac_fluid_intensity", "proppant_to_frac_fluid_ratio", "frac_fluid_to_proppant_ratio",
                             "horizontal_midpoint_x", "horizontal_midpoint_y", "horizontal_toe_x", "horizontal_toe_y")])

y <- training$OilPeakRate

Find optimal lambda value
cv_model <- cv.glmnet(x, y, alpha = 1)

best_lambda <- cv_model$lambda.min
best_lambda

best_model <- glmnet(x, y, alpha = 1, lambda = best_lambda)
coef(best_model)

new = data.matrix(testing[, c("surface_x", "surface_y", "bh_x", "bh_y", "gross_perforated_length", 
                               "total_proppant", "total_fluid", "true_vertical_depth", "proppant_intensity", 
                               "frac_fluid_intensity", "proppant_to_frac_fluid_ratio", "frac_fluid_to_proppant_ratio",
                               "horizontal_midpoint_x", "horizontal_midpoint_y", "horizontal_toe_x", "horizontal_toe_y")])

# Use LASSO regression model for prediction
predict(best_model, s = best_lambda, newx = new)

# Use fitted model to make predictions
y_predicted <- predict(best_model, s = best_lambda, newx = x)

# Find SST and SSE
sst <- sum((y - mean(y))^2)
sse <- sum((y_predicted - y)^2)

# Find R-Squared value
rsq <- 1 - sse/sst
rsq
