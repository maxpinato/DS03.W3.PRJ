# Human Activity Recognition - Codebook 
You can use `source("run_analysis.R")` to produce two tiny dataset with merged information.

## har.ds - Main Dataset
har.ds contain the main dataset. Contains detailed measurement of the activity of the subjects that have carried out the experiment.

Data are structured as following:
- subject : type: int, subject of experiment
- type : type of data (training or test)
- act_id : code of activity
- act_name : name of activity
- columns from 5 to 70 contains the measurement.

## har.ds.grp - Dataset with average values
har.ds.grp is a dataset built over har.ds. Data are grouped by subject and act_name applying the average operator at all the variables.

Here the structure: 
- act_name : name of the activity
- subject : code of the subject
- columns from 3 to 68 : average of the relative variable

