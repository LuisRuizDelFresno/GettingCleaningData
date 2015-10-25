# 1. Merges the training and the test sets to create one data set.
train <- read.table("train/X_train.txt", na.strings = "N/A") 
test <- read.table("test/X_test.txt", na.strings = "N/A")
totalDB <- rbind(train, test)			

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
features <- read.table("features.txt")
featuresNames <- features[, 2]
featuresIndexNamesWanted <- grep(".*mean.*|.*std.*", featuresNames)
totalDB <- totalDB[ , featuresIndexNamesWanted] 

# 3. Uses descriptive activity names to name the activities in the data set
activitiesTrain <- read.table("train/y_train.txt", na.strings = "N/A")
activitiesTest <- read.table("test/y_test.txt", na.strings = "N/A")
totalActivities <- rbind(activitiesTrain, activitiesTest)
activityLabels <- read.table("activity_labels.txt", na.strings = "N/A")
totalActivities$V1 <- factor(totalActivities$V1, levels = activityLabels$V1, labels = activityLabels$V2) 
totalDB <- cbind(totalActivities, totalDB)

# 4. Appropriately labels the data set with descriptive variable names. 
featuresNamesWanted <- features[featuresIndexNamesWanted, 2]
varNames <- c("activity", as.character(featuresNamesWanted))
names(totalDB)[1:80] <- varNames

# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
subjectsTrain <- read.table("train/subject_train.txt", na.strings = "N/A")
subjectsTest <- read.table("test/subject_test.txt", na.strings = "N/A")
subjects <- rbind(subjectsTrain, subjectsTest)
names(subjects) <- "subject"
totalDBSubject <- cbind(subjects, totalDB)

library(reshape)
totalDBSubject.melted <- melt(totalDBSubject, id = c("subject", "activity"))
tidyData <- cast(totalDBSubject.melted, subject + activity ~ variable, mean)

write.table(tidyData, file = "tidyData.txt", quote = FALSE)
