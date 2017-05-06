sourceDir <- getSrcDirectory(function(dummy) {dummy})
setwd(sourceDir)

filenames = dir()
csv_files = grep("*.csv",filenames,value = TRUE)

len = length(csv_files)

add_quarter = function(filepath)
{
    con = read.csv(filepath)
    con$quarter = quarters(as.Date(con$Date))
    write.csv(con,file = filepath)
    return(TRUE)
}

lapply(csv_files, FUN = add_quarter)