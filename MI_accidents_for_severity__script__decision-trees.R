# Readable version of Rattle code. 
# Includes shallow tree with depth of 7 terminal nodes 
# Pruned maximum depth tree for comparison with 726 terminal nodes after pruning

library(rattle)   # Access the weather dataset and utilities.
library(magrittr) # Utilise %>% and %<>% pipeline operators.

# This log generally records the process of building a model. 
# However, with very little effort the log can also be used 
# to score a new dataset. The logical variable 'building' 
# is used to toggle between generating transformations, 
# when building a model and using the transformations, 
# when scoring a dataset.

building <- TRUE
scoring  <- ! building

# A pre-defined value is used to reset the random seed 
# so that results are repeatable.

crv$seed <- 42 

#=======================================================================
# Load a dataset from file.

fname         <- "file:///C:/Users/David/OneDrive/Desktop/DSA6000/DS6000/MI_accidents_for_severity_.csv" 
crs$dataset <- read.csv(fname,
			na.strings=c(".", "NA", "", "?"),
			strip.white=TRUE, encoding="UTF-8")

#=======================================================================

# CLEANUP the Dataset 

# Remove specific variables from the dataset.

crs$dataset$Temperature.F. <- NULL
crs$dataset$Weather_Condition <- NULL


#=======================================================================

# Action the user selections from the Data tab. 

# Build the train/validate/test datasets.

# nobs=71648 train=50154 validate=10747 test=10747

set.seed(crv$seed)

crs$nobs <- nrow(crs$dataset)

crs$train <- sample(crs$nobs, 0.7*crs$nobs)

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  sample(0.15*crs$nobs) ->
crs$validate

crs$nobs %>%
  seq_len() %>%
  setdiff(crs$train) %>%
  setdiff(crs$validate) ->
crs$test

# The following variable selections have been noted.

crs$input     <- c("Start_Lat", "Start_Lng", "Amenity", "Bump",
                   "Crossing", "Give_Way", "Junction", "No_Exit",
                   "Railway", "Roundabout", "Station", "Stop",
                   "Traffic_Calming", "Traffic_Signal",
                   "Sunrise_Sunset", "Month", "Hour")

crs$numeric   <- c("Start_Lat", "Start_Lng", "Month", "Hour")

crs$categoric <- c("Amenity", "Bump", "Crossing", "Give_Way",
                   "Junction", "No_Exit", "Railway", "Roundabout",
                   "Station", "Stop", "Traffic_Calming",
                   "Traffic_Signal", "Sunrise_Sunset")

crs$target    <- "Severity"
crs$risk      <- NULL
crs$ident     <- NULL
crs$ignore    <- c("Start_Time", "Street", "Side", "City", "County", "Zipcode", "Timezone", "Year", "number")
crs$weights   <- NULL

#=======================================================================

# Decision Tree 

# The 'rpart' package provides the 'rpart' function.

library(rpart, quietly=TRUE)

# Reset the random number seed to obtain the same results each time.

set.seed(crv$seed)

# Build the Decision Tree model.

crs$rpart <- rpart(Severity ~ .,
    data=crs$dataset[crs$train, c(crs$input, crs$target)],
    method="class",
    parms=list(split="information"),
    control=rpart.control(usesurrogate=0, 
        maxsurrogate=0),
    model=TRUE)

# Generate a textual view of the Decision Tree model.

print(crs$rpart)
printcp(crs$rpart)

crs$rpart$cptable[which.min(crs$rpart$cptable[,"xerror"]),"CP"]
crs$rpart$cptable[which.min(crs$rpart$cptable[,"xerror"]),"nsplit"]

plotcp(crs$rpart)

pruned_tree<- prune(crs$rpart,crs$rpart$cptable[which.min(crs$rpart$cptable[,"xerror"]),"CP"] )
fancyRpartPlot(pruned_tree, uniform=TRUE)
print(pruned_tree)

cat("\n")

# Time taken: 1.34 secs

#=======================================================================

# Plot the resulting Decision Tree. 

# We use the rpart.plot package.

fancyRpartPlot(crs$rpart, main="Decision Tree MI_accidents_for_severity_.csv $ Severity")


#pdf("Decision Tree", height=11, width=17)
par(mfrow=c(1,1), pty='m')  
fancyRpartPlot(crs$rpart, main="Decision Tree: Accident Severity", sub="", cex.main=3, cex=1.5)
#dev.off()


#=======================================================================
# The 'Hmisc' package provides the 'contents' function.

library(Hmisc, quietly=TRUE)

# Obtain a summary of the dataset.

contents(crs$dataset[crs$train, c(crs$input, crs$risk, crs$target)])
summary(crs$dataset[crs$train, c(crs$input, crs$risk, crs$target)])


#=======================================================================

# Evaluate model performance on the testing dataset. 

# Generate an Error Matrix for the Decision Tree model.

# Obtain the response from the Decision Tree model.

crs$pr <- predict(crs$rpart, newdata=crs$dataset[crs$test, c(crs$input, crs$target)],
                  type="class")

# Generate the confusion matrix showing counts.

rattle::errorMatrix(crs$dataset[crs$test, c(crs$input, crs$target)]$Severity, crs$pr, count=TRUE)

# Generate the confusion matrix showing proportions.

(per <- rattle::errorMatrix(crs$dataset[crs$test, c(crs$input, crs$target)]$Severity, crs$pr))

# Calculate the overall error percentage.

cat(100-sum(diag(per), na.rm=TRUE))

# Calculate the averaged class error percentage.

cat(mean(per[,"Error"], na.rm=TRUE))


