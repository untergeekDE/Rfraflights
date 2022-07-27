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

#
cat(format_ISO8601(now()),"\n")
cat("Updating arrivals...\n")
update_fra_log(path="./fra_log/",flighttype = "a")
cat("Updating departures... \n")
update_fra_log(path="./fra_log/",flighttype = "d")

#
if (directory.exists("/home/jan_eggers_hr_de/")) {
  # Google-Bucket befüllen
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ./fra_log/fra_arrivals.csv gs://d.data.gcp.cloud.hr.de/arrivals.csv')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ./fra_log/fra_departures.csv gs://d.data.gcp.cloud.hr.de/departures.csv')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ./fra_log/fra_arrivals.RDS gs://d.data.gcp.cloud.hr.de/fra_arrivals.RDS')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ./fra_log/fra_departures.RDS gs://d.data.gcp.cloud.hr.de/fra_departures.RDS')

}

cat("Done. \n")
