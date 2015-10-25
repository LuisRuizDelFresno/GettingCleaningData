1. Merges the training and the test sets to create one data set.
****************************************************************
Load and merge train and test data sets (Note: first train then test; it's important
to keep this order on preparing new columns later on)

> train <- read.table("train/X_train.txt", na.strings = "N/A") 
> test <- read.table("test/X_test.txt", na.strings = "N/A")
> totalDB <- rbind(train, test)			

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# ******************************************************************************************
# Variables names are in file "features.txt", we have to load it, and selected only those 
# variable's names that contain "mean" or "std". The result is vector of indexes, that
# will be used to select those columns (and later on their descriptive names)
features <- read.table("features.txt")
featuresNames <- features[, 2]
featuresIndexNamesWanted <- grep(".*mean.*|.*std.*", featuresNames)
totalDB <- totalDB[ , featuresIndexNamesWanted] 

# 3. Uses descriptive activity names to name the activities in the data set
# *************************************************************************
# Activity per observation is in the files "y_train.txt" and "y_test.txt".
# Loading and merging them (in the same order used before)
# File "activity_labels.txt", provides their descriptive names. 
# Loading and using them to substitute for codes.
# Adding this new variable to data set
activitiesTrain <- read.table("train/y_train.txt", na.strings = "N/A")
activitiesTest <- read.table("test/y_test.txt", na.strings = "N/A")
totalActivities <- rbind(activitiesTrain, activitiesTest)
activityLabels <- read.table("activity_labels.txt", na.strings = "N/A")
totalActivities$V1 <- factor(totalActivities$V1, levels = activityLabels$V1, labels = activityLabels$V2) 
totalDB <- cbind(totalActivities, totalDB)

# 4. Appropriately labels the data set with descriptive variable names. 
# *********************************************************************
# To prepare a vector of names to name the data set variables, 
# I first get the descriptive name of the features of interest
# Then complete the vector of names with "activity", 
# And change columns names
featuresNamesWanted <- features[featuresIndexNamesWanted, 2]
varNames <- c("activity", as.character(featuresNamesWanted))
names(totalDB)[1:80] <- varNames

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
# ***************************************************************************
# We first need to add a new column with subjects data.
# We load and merge the train and test subjects files, form a new veriable,
# label it and add as e new column to the data set.
subjectsTrain <- read.table("train/subject_train.txt", na.strings = "N/A")
subjectsTest <- read.table("test/subject_test.txt", na.strings = "N/A")
subjects <- rbind(subjectsTrain, subjectsTest)
names(subjects) <- "subject"
totalDBSubject <- cbind(subjects, totalDB)

# Now we have to calculate means specific for subject and activity.
# Following recomendations of others, we have download and installed a package "reshape" 
# http://www.statmethods.net/management/reshape.html
# http://stackoverflow.com/questions/1407449/for-each-group-summarise-means-for-all-variables-in-dataframe-ddply-split
library(reshape)
totalDBSubject.melted <- melt(totalDBSubject, id = c("subject", "activity"))
tidyData <- cast(totalDBSubject.melted, subject + activity ~ variable, mean)

# Finally we export the data set as a txt file with values separated by spaces
write.table(tidyData, file = "tidyData.txt", quote = FALSE)
