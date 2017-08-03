# Set directory
setwd("C:/Users/Andrew/Google Drive/Work/Turo")
dir()

# Stating all required packages
library(ranger)
library(caret)
library(doParallel)

# Import the data
mydata = read.table("res_model.txt", header = T)
mydata$diff_price = abs(mydata$recommended_price - mydata$actual_price)
fix(mydata)

# Response roungly follows an exponential distribution
hist(mydata$restot, main = "Histogram of Total Reservations", 
     xlab = "Total Reservations")

# Allows for parallel computing
cl = makeCluster(detectCores())
registerDoParallel(cl)
set.seed(1)

# Random Forest for predicting restot
control1 = trainControl(
  method = "cv", 
  number = 5, 
  allowParallel = T) 
  # preProcOptions = (thresh = 0.95))

grid1 = expand.grid(mtry = seq(1, 10))

model1 = train(restot~., 
               data = mydata, 
               trControl = control1, 
               method = "ranger", 
               tuneGrid = grid1, 
               importance = "impurity")
model1
varImp(model1)

# Variable importances with price differential
var1 = c("diff_price", "actual_price", "recommended_price", "description", "num_images", "street_parked", "technology")
imp1 = c(100, 62.2787, 46.4881, 45.9638, 26.9315, 0.5466, 0)
varimps1 = as.data.frame(cbind(var1, imp1))
fix(varimps1)
write.table(varimps1, file = "varimp1.csv", sep = ",")

# Variable importances without price differential
var2 = c("actual_price", "recommended_price", "description", "num_images", "street_parked", "technology")
imp2 = c(100, 73.896, 50.894, 23.709, 0.916, 0)
varimps2 = as.data.frame(cbind(var2, imp2))
fix(varimps2)
write.table(varimps2, file = "varimp2.csv", sep = ",")