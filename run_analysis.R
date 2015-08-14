
if (!require("data.table")) {
        install.packages("data.table")
}

if (!require("reshape2")) {
        install.packages("reshape2")
}

require("data.table")
require("reshape2")

# 3: labels
labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# 2: Extract only the measurements on the mean and standard deviation for each measurement.
extractedFeatures <- grepl("mean|std", features)

# 1: Load and process X_test & y_test data.
XTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(XTest) = features

# 2: Extract only the measurements on the mean and standard deviation for each measurement.
XTest = XTest[,extractedFeatures]

# 3: Load activity labels
yTest[,2] = labels[yTest[,1]]
names(yTest) = c("Activity_ID", "Activity_Label")
names(subjectTest) = "subject"

# 1: Bind data
testData <- cbind(as.data.table(subjectTest), yTest, XTest)

# 1: Load and process X_train & y_train data.
XTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")

subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(XTrain) = features

# 2: Extract only the measurements on the mean and standard deviation for each measurement.
XTrain = XTrain[,extractedFeatures]

# 1: Load activity data
yTrain[,2] = labels[yTrain[,1]]
names(yTrain) = c("Activity_ID", "Activity_Label")
names(subjectTrain) = "subject"

# Bind data
trainData <- cbind(as.data.table(subjectTrain), yTrain, XTrain)

# 1: Merge test and train data
data = rbind(testData, trainData)

idLabels   = c("subject", "Activity_ID", "Activity_Label")
dataLabels = setdiff(colnames(data), idLabels)
meltData      = melt(data, id = idLabels, measure.vars = dataLabels)

# 2: Apply mean function to dataset using dcast function
tidyData   = dcast(meltData, subject + Activity_Label ~ variable, mean)

write.table(tidyData, file = "./tidy_data.txt", row.names = FALSE)