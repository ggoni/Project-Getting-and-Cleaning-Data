#Call Library, MUST BE INSTALLED

library(reshape)

#  read data for both test and train datasets

X_test<-read.table("UCI HAR Dataset/test/X_test.txt",stringsAsFactors=FALSE)
Y_test<-read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactors=FALSE)
subject_test<- read.table("UCI HAR Dataset/test/subject_test.txt", stringsAsFactors=FALSE)
testData<-cbind(X_test,Y_test,subject_test)

X_train<-read.table("UCI HAR Dataset/train/X_train.txt", stringsAsFactors=FALSE)
Y_train<-read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactors=FALSE)
subject_train<- read.table("UCI HAR Dataset/train/subject_train.txt", stringsAsFactors=FALSE)
trainData<-cbind(X_train,Y_train,subject_train)

#1: Merges the training and the test sets
wholeData<-rbind(testData,trainData)

features<-read.table("UCI HAR Dataset/features.txt",stringsAsFactors=FALSE)
#Extracts only the measurements on the mean and standard deviation for each measurement.

selected_features<- features[grep("mean\\(\\)|std\\(\\)",features$V2),]
selected_features<-rbind(selected_features,c("562","Activity"),c("563","Subject"))

selectedData<-subset(wholeData,select=as.numeric(selected_features$V1))

# 3 and 4: Uses descriptive activity names to name the activities in the data set,
# Appropriately labels the data set with descriptive variable names.

colnames(selectedData)<-selected_features$V2

actLabels<-read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors=FALSE)
colnames(actLabels)<-c("Activity","DescActivity")
editSelectedData<-merge(selectedData,actLabels,by="Activity",all.x=TRUE)
editSelectedData[,1]<-NULL


#create TidyData as a CSV file, write it on Working folder

meltData<-melt(editSelectedData,id=c("Subject","DescActivity"))
index<-with(meltData,order(Subject,DescActivity,variable,value))
meltDataOrdered<-meltData[index,]
rownames(meltDataOrdered)<-seq(1,nrow(meltDataOrdered),1)

write.csv(meltDataOrdered,"firstTidy.csv")

#create a Second TidyData as a CSV file, with means for each Subject and Activity. Write it on Working folder

secondTidy<-cast(meltDataOrdered,Subject + DescActivity +variable~ .,mean)
colnames(secondTidy)[4]="meanValue"
write.csv(secondTidy,"secondTidy.csv")
