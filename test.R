#test.R
require(dplyr)
require(data.table)

prepareLabels <- function(activityLabelsFile){

  labels <- read.csv2(activityLabelsFile,header = FALSE,sep="",colClasses = c("character","character"))
  names(labels) <- c("act_id","act_name")
  return(labels)
}

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

# Object of type prepareFeatures
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
# INIZIO APPLICAZIONE --------------------------------------------------
# ----------------------------------------------------------------------
tst.labels <- prepareLabels("Data/activity_labels.txt")
tst.feat <- prepareFeatures("Data/features.txt")
# LETTURA DEI DATA -----------------------------------------------------
tst.ds <- rbind(  prepareXYds("train",
                            "Data/train/subject_train.txt",
                            "Data/train/X_train.txt",
                            "Data/train/Y_train.txt",
                            tst.feat,tst.labels) , 
         prepareXYds("test",
                            "Data/test/subject_test.txt",
                            "Data/test/X_test.txt",
                            "Data/test/Y_test.txt",
                            tst.feat,tst.labels) )
tst.ds.grp <- tst.ds %>% group_by(act_name,subject) %>% summarize_each( funs(mean),c(5:70) )

