#############################################################################################################################
#      DOWNLOAD DATAFILES ( ZIP ARCHIVE) 
#  The code is commented out, as it is expected that 
#  user has downloaded the file already
#  If the file is not downloaded , uncomment the commented
#  code below. This will create a "data" folder in the
#  current working directory.
#############################################################################################################################

#  if(!file.exists("./data")){ dir.create("./data")}
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#  download.file(fileURL,destfile="./data/UCIHARDataset.zip")



#############################################################################################################################
#  Unzip the downloaded zip archive file
#  code is commented out as the step is expected to be 
#  completed already
#  Uncomment the code if the file is downloaded again
#  Please note that this step expects the archive file
#  in ./data folder , where the previous step, if run,
#  would have downloaded the file
#############################################################################################################################
# unzip("./data/UCIHARDataset.zip",exdir="./data")

# Verify download
# list.dirs("./data")




#############################################################################################################################
#  Set the working directory to the root location of extracted files from zip file
#  Code is commented out , as per the assignment users who will run this script are in this location
#  In case previous  steps of downloading and unzipping were done , after uncommenting those codes, uncomment this code
#  and run as well
#############################################################################################################################
#setwd("./data/UCI HAR Dataset")


#############################################################################################################################
#       Load common data elements viz. the feature list and activity labels
#############################################################################################################################

features<-read.table("features.txt")
activityLabels<-read.table("activity_labels.txt")
# assign proper names to activity lable table columns
names(activityLabels)<-c("activityId","activityDescription")


#############################################################################################################################
#     Load test data, assign proper heading, then add test activity and subject information to the data frame, forming 
#     a data set named "testVariables" with variable measurements, and corresponding activity and subject
#############################################################################################################################

# load test measurements
testVariables<-read.table(paste("./test","X_test.txt",sep="/"))
# verify load
head(testVariables,n=1)

# Rename the column names using the features data set, which has the list of variable name
sapply(seq(along=features$V1),function(i){names(testVariables)[i]<<-as.character(features$V2[i])})

# load activity data  for the test measurements
testActivity<-read.table(paste("./test","y_test.txt",sep="/"))
# add the activity data as a new variable to the dataframe
testVariables<-cbind(testVariables,"activityId"=testActivity[,1])
# remove the variable for test activiy as not required anymore
rm(testActivity)


# load subject data for test measurements
testSubjects<-read.table(paste("./test","subject_test.txt",sep="/"))
# add the subject data as a new variable to data frame
testVariables$subjectId<-testSubjects[,1]
# remove the variable for test subjects as not required anymore
rm(testSubjects)



#############################################################################################################################
#     Load training data, assign proper heading, then add train activity and subject information to the data frame, forming 
#     a data set named "trainVariables" with variable measurements, and corresponding activity and subject
#############################################################################################################################

# load train measurements
trainVariables<-read.table(paste("./train","X_train.txt",sep="/"))
# verify load
head(trainVariables,n=1)

# Rename the column names using the features data set, which has the list of variable name
sapply(seq(along=features$V1),function(i){names(trainVariables)[i]<<-as.character(features$V2[i])})
# load activity data  for the train  measurements
trainActivity<-read.table(paste("./train","y_train.txt",sep="/"))
# add the activity data as a new variable to the dataframe
trainVariables<-cbind(trainVariables,"activityId"=trainActivity[,1])
# remove the train activity data , as it is not used anymore
rm(trainActivity)
# load subject data for train measurements
trainSubjects<-read.table(paste("./train","subject_train.txt",sep="/"))
# add the subject data as a new variable to data frame
trainVariables$subjectId<-trainSubjects[,1]
# remove the variable for train subjects as not required anymore
rm(trainSubjects)



###############################################################################################################################
#  Combine the test and train data sets (testVariables and trainVariables, respectively) to form a single data set
#  containing both datasets
###############################################################################################################################

# for verification purposed , get the number of rows of test and train dataset, the combined data set should have
# number of rows which is the sum of these values
nrow(trainVariables)
nrow(testVariables)

# combine the datasets
combinedTestAndTrainData<-rbind(testVariables,trainVariables)
# check the number of rows to verify that it is the total of component datasets
nrow(combinedTestAndTrainData)

# have a visual verification of combined data set top rows, then summary on the activities and subjects, there should be 6 activity 
# and 30 subjects
head(combinedTestAndTrainData)
table(combinedTestAndTrainData$subjectId)
table(combinedTestAndTrainData$activityId)

# remove the test and train datasets as they are no longer needed
rm(testVariables)
rm(trainVariables)

################################################################################################################################
#  Add the activity label as the new variable to the combibed data set, combinedTestAndTrainData. 
#  The labels corresponding to id are available in the common data set "activityLabels", loaded earlier
################################################################################################################################

# merge the 2 data sets by the id column "activityId", this generates few warnings as it truncates column names of few columns
# , which are but not used, therefore ignored
combinedTestAndTrainData<-merge(combinedTestAndTrainData,activityLabels,by="activityId",all=FALSE,sort=FALSE)
# Verify the top data to see the new variable in data frame
head(combinedTestAndTrainData,n=1)
# the below summary should show that only one cell for a combination of activityid and activityDescription has a non-zero value
# , that indicates that merge was successful, because each activityId has an unique description(or label) in "activityLabels"
# dataset
table(combinedTestAndTrainData$activityId,combinedTestAndTrainData$activityDescription)

#################################################################################################################################
#    Include only the mean and stat variables , as well as the activity label and subject in the dataset
#################################################################################################################################

# In the followinng subsetting task only those columns which contains the pattern "mean()" or "stat" is included, as well as
# the "activityDescription" and "subjectId"
combinedTestAndTrainData<-combinedTestAndTrainData[,( grepl("mean()",names(combinedTestAndTrainData))|grepl("std()",names(combinedTestAndTrainData))|names(combinedTestAndTrainData) %in% c("activityDescription","subjectId"))]

# unfortunately the fields included has those with pattern "meanFreq" in the column name as well. So they are pruned out in this step
combinedTestAndTrainData<-combinedTestAndTrainData[,!(grepl("meanFreq",names(combinedTestAndTrainData)))]

##################################################################################################################################
#  Create a new dataset "averageBySubjectActivity" with averges of the variables in "combinedTestAndTrainData", which are grouped 
#  by subject and activity. The measurement columns in this dataset are named with a prefix of "Avg. " , to identify their  meaning
##################################################################################################################################

# Aggregate function gets the average (mean) values of each of the measurement column, grouped by subjectId and activityDescripton
# The activityDescription column is renamed in new data set as activityLabel
# while doing the aggregate column subsetting is done by excluding last 2 columns ( 1:(ncol(combinedTestAndTrainData)-2)), as they 
# are not measurement columns , but the id columns
averageBySubjectActivity<-aggregate(combinedTestAndTrainData[,1:(ncol(combinedTestAndTrainData)-2)],list(subjectId=combinedTestAndTrainData$subjectId,activityLabel=combinedTestAndTrainData$activityDescription),mean)

# Renamed the measurements columns with a prefix of "Avg.", please note that again columb subsetting is done to avoid the id
# columns, in this case they come at the beginning of data set
names(averageBySubjectActivity)[3:length(names(averageBySubjectActivity))]<-paste("Avg.",names(averageBySubjectActivity)[3:length(names(averageBySubjectActivity))])


################################################################################################################################
#   Sample data check to verify the new data set
#   one of the measurement from source is averaged independently and checked in the new data set for verification

# the source data vector for tBodyAcc-mean()-Z , for subject 29 and for activity WALKING_DOWNSTAIRS
xx<-combinedTestAndTrainData[(combinedTestAndTrainData$activityDescription=="WALKING_DOWNSTAIRS" & combinedTestAndTrainData$subjectId=="29"),]$"tBodyAcc-mean()-Z"
# get the mean, this should match the next step ouput
mean(xx)
# get the new data set value, which should match output of above
averageBySubjectActivity[(averageBySubjectActivity$activityLabel=="WALKING_DOWNSTAIRS" & averageBySubjectActivity$subjectId=="29"),]$"Avg. tBodyAcc-mean()-Z"





#################################################################################################################################
#   Output files to a text file, with no row names
#################################################################################################################################

write.table(averageBySubjectActivity,"SamsungWearableAverageMeanSTD.txt",row.names=FALSE)



