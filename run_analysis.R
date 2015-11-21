#test.R
require(dplyr)
require(data.table)

# --------------------------------------------------
# prepareLabels
# --------------------------------------------------
# Parameters: 
#   - activityLabelsFile: full path of activity_labels.txt
# Output:
#   - A dataset with act_id and act_name column
# Description:
#   - Read file "activity_labels.txt" (as defined on the parameters)
#     and return a dataset by id/name pairs of activity.
# --------------------------------------------------
prepareLabels <- function(activityLabelsFile){
  
  labels <- read.csv2(activityLabelsFile,header = FALSE,sep="",colClasses = c("character","character"))
  names(labels) <- c("act_id","act_name")
  return(labels)
}

# --------------------------------------------------
# prepareFeatures
# --------------------------------------------------
# Parameters:
#    - featuresFile : full path of features.txt file
# Output:
#    - Object with the following properties:
#    -- getFeatures : dataset with all the features by feat_id/feat_name pairs
#    -- getClasses : a vector of classes used to read file for test and training
#    -- getFeaturesMeanStd : a dataset of feat_id/feat_name pairs, as subset of 
#           getFeatures in wich the variable name contains mean() or std()
#                     
# Description:
#    - Read the file in input and prepare tre dataset for feature, classes and
#           features containing mean() and std()
# --------------------------------------------------
prepareFeatures <- function( featuresFile ){
  
  features <- read.csv2(featuresFile,sep="",header=FALSE,colClasses = c("character","character"))
  classes <- rep("numeric",length(features$feat_id))
  names(features) <- c("feat_id","feat_name")
  idMeanStd <- as.numeric(features$feat_id[ grepl("mean\\(\\)|std\\(\\)",features$feat_name) ])
  nameMeanStd <- features$feat_name[idMeanStd]
  features.meanStd <- data.frame(idMeanStd,nameMeanStd)
  names(features.meanStd) <- c("feat_id","feat_name")
  
  getFeatures <- function(){
    return(features) 
  }
  
  getClasses <- function(){return(classes)}
  getFeaturesMeanStd <- function(){return(features.meanStd)}
  
  list(
    getFeatures = getFeatures,
    getClasses = getClasses,
    getFeaturesMeanStd = getFeaturesMeanStd 
  )
  
  
}

# --------------------------------------------------
# prepareXYds
# --------------------------------------------------
# Parameters:
#    - typeName: train or test
#    - subjFile: fullpath of subject file
#    - xFile: fullpath of xFile
#    - yFile: fullpath of yFile
#    - feat : object created by prepareFeatures(...)
#    - labels : dataset created by prepareLabels(...)
# Output:
#    - dataset with data from a type of measuremente (train or test) 
#      that merge data of subject, activity and measurements.
#    ---- Columns : 
#    ------ subject : subject of activity
#    ------ type : training or test
#    ------ act_id : id of activity
#    ------ act_name : name of activity
#    ------ column from 5 to 70: variable
# Description:
#    - dataset with data from a type of measuremente (train or test) 
#      that merge data of subject, activity and measurements.
# --------------------------------------------------
prepareXYds <- function(typeName,subjFile,xFile,yFile,feat,labels){
  
  s <- read.csv(subjFile,sep = "",header = FALSE)
  y <- read.csv2(yFile,sep = " ", header=FALSE)
  y.name <- sapply(y,function(x){return(labels$act_name[x])})
  x <- fread(xFile, 
             select = feat$getFeaturesMeanStd()$feat_id,
             colClasses = feat$getClasses())
  #setnames(x , feat$getFeaturesMeanStd()$feat_name )
  type <- rep(typeName,length(y$V1))
  ds <- data.frame(s,type,y,y.name,x)
  nameds <- c("subject","type","act_id","act_name",as.character(feat$getFeaturesMeanStd()$feat_name))
  names(ds) <- nameds
  return(ds)
  
}

# ----------------------------------------------------------------------
# APPLICATION         --------------------------------------------------
# ----------------------------------------------------------------------
har.labels <- prepareLabels("Data/activity_labels.txt")
har.feat <- prepareFeatures("Data/features.txt")
# LETTURA DEI DATA -----------------------------------------------------
har.ds <- rbind(  prepareXYds("train",
                              "Data/train/subject_train.txt",
                              "Data/train/X_train.txt",
                              "Data/train/Y_train.txt",
                              har.feat,har.labels) , 
                  prepareXYds("test",
                              "Data/test/subject_test.txt",
                              "Data/test/X_test.txt",
                              "Data/test/Y_test.txt",
                              har.feat,har.labels) )
har.ds.grp <- har.ds %>% group_by(act_name,subject) %>% summarize_each( funs(mean),c(5:70) )
remove(har.labels)
remove(har.feat)
