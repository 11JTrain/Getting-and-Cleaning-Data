
# Load Packages
library(data.table)
library(reshape2)

# Set working directory
setwd("/Users/jessechung/Documents/DataScience/Data")

# Download dataset
filename <- "Dataset.zip"
if (!file.exists(filename)) {
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, filename, method = "curl")
  unzip(filename)
}

# Load activity labels and features
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# Extract only mean and STD data
featuresW <- grep(".*mean.*|.*std.*", features[,2])
featuresW.names <- features[featuresW,2]
featuresW.names <- gsub("-mean", "Mean", featuresW.names)
featuresW.names <- gsub("-std", "Std", featuresW.names)
featuresW.names <- gsub("[-()]", "", featuresW.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresW]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresW]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Combine the datasets
combine <- rbind(train, test)
colnames(combine) <- c("Subject", "Activity", featuresW.names)

# Turn Subjects and Activities into factors
combine$Subject <- as.factor(combine$Subject)
combine$Activity <- factor(combine$Activity, levels = activity_labels[,1], labels = activity_labels[,2])

# Melt dataset
combine.melt <- melt(combine, id = c("Subject", "Activity"))
combine.mean <- dcast(combine.melt, Subject + Activity ~ variable, mean)

write.table(combine.mean, "tidy_avgs.txt", row.names = F)


