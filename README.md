getcleandata
============
The R command file run_analysis.R merge data from both test and train files, provide appropriate column names, add new variables containing subject and activity label to the base data.
It extracts only the mean and std fields from base data and finally produce a tidy data with averages of these measures calculated across subject and activity
The code is commented extensively and identifies the processing logic in the script file

Since it is possible that source data files are already downloaded by the user, the command file has commented out those sections where it downloads and unzips the archive file
If the user want to run this program , including  the steps to download then
   1. Please uncomment the portion  of code which downloads, unzips the file and then changes directory. 
   2. Please note that in this scenario you will keep the command file in current working directory. The code while executing will create data folder and unzips the file underneath that
   3.You will see the final file under "<your working dir>/data/UCI HAR Dataset", named SamsungWearableAverageMeanSTD.txt
   4.Please note that this command works in windows 7 and therefore if you are downloading in different OS, you may have to change the download line.
If you already have downloaded and unzipped the archive file then
   1. Please keep the command file in the root  folder of unzipped file named "UCI HAR Dataset" and make it the working directory and execute.
   2.Output file will be created here