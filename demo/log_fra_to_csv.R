#' log_fra_data
#'
#' Logs all updates to csv files in /data if called repeatedly.
#'
#'@author Jan Eggers <jan.eggers@hr.de>
#'
#'
#' Very early prototype for logging all departures and flights with their status updates.

rm(list = ls())

require(Rfraflights)
require(lubridate)
require(dplyr)
require(stringr)
require(pacman)

p_load(this.path)
# Set default dir; load get_fra function
setwd(this.path::this.dir())

# Write to log file in parent directory
sink("../log_fra_data.log",append = TRUE)
ts <- now()
# Read 48 hours into the past, and 96 hours into the future
cat("\n",as.character(ts),"\n")

#
if (!dir.exists("../fra_log/")) {
  dir.create("../fra_log/")
}

#
cat(format_ISO8601(now()),"\n")
cat("Updating arrivals...\n")
if (update_fra_log(path="../fra_log/",flighttype = "a")) cat("Success.\n")
cat("Updating departures... \n")
if (update_fra_log(path="../fra_log/",flighttype = "d")) cat("Success.\n")

#
if (dir.exists("/home/jan_eggers_hr_de/")) {
  # Google-Bucket befüllen
  cat("uploading fra_*.csv and fra_*.RDS to GBucket\n")

  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../fra_log/fra_arrivals.csv gs://d.data.gcp.cloud.hr.de/arrivals.csv')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../fra_log/fra_departures.csv gs://d.data.gcp.cloud.hr.de/departures.csv')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../fra_log/fra_arrivals.RDS gs://d.data.gcp.cloud.hr.de/fra_arrivals.RDS')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../fra_log/fra_departures.RDS gs://d.data.gcp.cloud.hr.de/fra_departures.RDS')

}

cat("Done. \n")
# Stop logging
sink()
