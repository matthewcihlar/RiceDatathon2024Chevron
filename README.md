# RiceDatathon2024Chevron

## Methodology

### Multiple Linear Regression

Our first idea was to use multiple linear regression, which can be found in the
top half of the datathon\_2024.R script. Our initial naive approach was to use
base our model on every numerical field. To address missing values, we used
KNN imputing. Unfortunately, the r-squared value of our initial model was 
around 0.4, indicating that a linear model might not be appropriate. 
Additionally, our RMSE value for our initial model was around 130. After 
trying to optimize the model by removing correlated fields, we managed to
obtain an RMSE value of 121.5959 (derived from the summary that R provided).

### LASSO Regression

After attempting to use multiple linear regression, we opted to try LASSO
regression which optimizes for prediction by weighting important fields
heavily and weighting unimportant fields with 0. Unfortunately, we might
have implemented LASSO regression incorrectly since we got an RMSE value
that was even higher than the "optimized" multiple linear regression model. 

### Random Forest

Our last method was to use a random forest model. Note that to address 
categorical data, we used one hot encoding. Our results from the random forest
model were better than our results from the previous two models. To test our
random forest model, we split the provided data in training and testing data 
(80/20 split). When testing our model on the testing data without imputing any
values into the testing data (removing the rows instead), we obtained an RMSE
value of 79.308367. However, when we imputed values into the testing data, we
obtained an RMSE value close to 100. This could imply that our random forest
model is unreliable. However, since our model performed on imputed or "inferred"
data, it's hard to say whether the decrease in performance is due to our model
or the generated data.

### Findings

Given that random forests are "black-box" models, it's hard to interpret our
results. However, from graphing individual explanatory variables against the
response variable (OilPeakRate), we had a few interesting findings.

When plotting "OilPeakRate" against "gross\_perforated\_length," the plot
appears to be trimodal. Specifically, there appear to be peaks when the
gross perforated length is 4000, 7000, and 10000. While this is a visual
observation, we think it could be significant in predicting the peak oil flow.

When plotting "OilPeakRate" against "number\_of\_stages," we found a somewhat
strong positive linear correlation between the two variables. Additionally,
the variables related to stages seem to be more predictive than other 
variables. For example, there seems to be a negative correlation between
average stage length and the peak oil rate. One could make the argument for
whether the relationship is linear or exponential. Additionally, there appears
to be a somewhat strong linear correlation between the average proppant per
stage and the peak oil rate. The same applies with the average frac fluid per
stage and the peak oil rate. 

We also noticed that oil wells with bin lateral lengths between 1.0 and 2.0 
(inclusive) tended to result in higher oil peak rates. Inner wells also seem
to have a higher oil peak rate compared outer wells and standalone wells. 

