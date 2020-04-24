my_data <- read.delim("Michigan_Accidents_Dec19.txt")
str(my_data)
my_data = my_data[1:26]
my_data$ID = NULL
my_data$Source = NULL
my_data$Start_Time = NULL
my_data$End_Time = NULL 
my_data$End_Lat = NULL 
my_data$End_Lng = NULL 
my_data$Description = NULL 
my_data$Number = NULL 
my_data$Street = NULL 
my_data$Wind_Chill.F. = NULL 
my_data$Side = NULL 
my_data$City = NULL 
my_data$County = NULL 
my_data$State = NULL 
my_data$Zipcode = NULL 
my_data$Country = NULL 
my_data$Airport_Code = NULL 
my_data$Weather_Timestamp = NULL 
str(my_data)
my_data$Timezone = as.numeric(my_data$Timezone)
my_data = na.omit(my_data)
sum(is.na(my_data))

#test and train data
train_index <- sample(1:nrow(my_data), 0.5*nrow(my_data))#random sample
train_MI_accidents <- my_data[train_index,] #training data
test_MI_accidents <- my_data[-train_index,] #test data
#Normalize
normalize = function(x){return
  ((x)- min(x))/(max(x)-min(x))}
normalize(my_data)
#knn
library(class)
class = train_MI_accidents$Severity
knn.1 = knn(train_MI_accidents, test_MI_accidents, class)
knn.3 = knn(train_MI_accidents, test_MI_accidents, class , k = 3 )
knn.7 = knn(train_MI_accidents, test_MI_accidents, class, k = 7 )
knn.15 = knn(train_MI_accidents, test_MI_accidents, class, k = 15)
knn.43 = knn(train_MI_accidents, test_MI_accidents, class, k = 43)
knn.193 = knn(train_MI_accidents, test_MI_accidents, class, k = 193)
knn.307 = knn(train_MI_accidents, test_MI_accidents, class, k = 307)

#accuracy
library(caret)
confusionMatrix(table(knn.1 ,class))
#Accuracy for k = 1 , is  0.5167 
confusionMatrix(table(knn.3 ,class))
#Accuracy for k= 3, is 0.5195
confusionMatrix(table(knn.7 ,class))
#Accuracy for k=7 is 0.5223
confusionMatrix(table(knn.15 ,class))
#Accuracy for k=15 is 0.5257
confusionMatrix(table(knn.43 ,class))
#Accuracy for k=15 is 0.5378
confusionMatrix(table(knn.193 ,class))
#Accuracy for k=193 is 0.5625
confusionMatrix(table(knn.307 ,class))
#Accuracy for k=193 is 0.5649
#it seems we will have more accurate model if we increase k.
str(my_data)
names(my_data)

# Decision Tree Classification model
library(rpart)

Tr.mod = rpart(Severity ~ TMC+Start_Lat+Start_Lng+Distance.mi.+Timezone+Temperature.F.+ Humidity... ,
               data = train_MI_accidents ,
              method = "class")
#finding the best cut point
plotcp(Tr.mod) #the best cut point is 0.1
Tr.mod_Prune = prune( Tr.mod , cp = 0.1)

#Prediction
test_MI_accidents$Severity_prediction = predict(Tr.mod_Prune, test_MI_accidents, type = "class")
#Confusion matrix
table(test_MI_accidents$Severity_prediction,test_MI_accidents$Severity) 
#Accuracy
mean(test_MI_accidents$Severity_prediction == test_MI_accidents$Severity)
# The accuracy of this decision tree model is 77% , as it's shown in confusion matrix mostly there is misunderstanding between severity of 2 and 3 for this model.


