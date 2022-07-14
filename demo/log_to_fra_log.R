# Internal FN for testing: Gather data until token is erased from wd


gather_fra_data <- function() {
  fileConn<-file("delete.me")
  writeLines("Delete this file to stop the loop", fileConn)
  close(fileConn)
  arrivals_df <<- get_fra_arrivals_df()
  departures_df <<- get_fra_departures_df()
  apiWaitTill <- now()+seconds(300)
  while (file.exists("delete.me")) {

    # Query every five minutes
    if(now() < apiWaitTill) {
      Sys.sleep(1)
    } else {
      # Save new wait point
      apiWaitTill <- now()+seconds(300)
      arrivals_df <<- update_fra_df(arrivals_df)
      departures_df <<- update_fra_df(departures_df)
    }
  }
}

# ---- Main function here ----
# If you call this script as a cron job, it logs data updates to a big CSV/RDS.
#

path="./fra_log/"
if (!dir.exists(path)) { mkdir(path) }
sink(paste0(path,"get_fra_arrivals_departures.log"), append=T)
if (update_fra_log(path=path,flighttype="a") &
  update_fra_log(path,flighttype="d")) { cat("OK\n")}
# Copy to Google Bucket if on server (very special )
if (directory.exists("/home/jan_eggers_hr_de/")) {
  # Google-Bucket befüllen
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../data/arrivals.csv gs://d.data.gcp.cloud.hr.de/arrivals.csv')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../data/departures.csv gs://d.data.gcp.cloud.hr.de/departures.csv')
}

sink()

# TODO:
# - Funktionen testen
# - Logging mit log_to_fra_log.R testen
