#' log_fra_data
#'
#' Logs all updates to csv files in /data if called repeatedly.
#'
#'@author Jan Eggers <jan.eggers@hr.de>
#'
#'
#' Very early prototype for logging all departures and flights with their status updates.

rm(list = ls())

pacman::p_load(pacman)
p_load(this.path)
# Set default dir; load get_fra function
setwd(this.path::this.dir())
source("get_fra_data.R")

sink("../log_fra_data.log",append = TRUE)
ts <- now()
# Read 48 hours into the past, and 96 hours into the future
cat("\n",as.character(ts),"\n")

# Define column types

a_types <- cols(.default = "c",
                timestamp = "T",
                # Don't read sched etc. as datetime but keep strings,
                # as lubridate's as_datetime conversion loses timezone!x

                # sched = "T",
                # schedDep = "T",
                # esti = "T",
                # lu="T",
                duration = "i",
                s = "l",
                flstatus = "i"
                )
d_types <- cols(timestamp = "T",
                # sched = "T",
                # schedArr = "T",
                # esti = "T",
                # lu = "T",
                duration = "i",
                s = "l",
                flstatus = "i",
                )

#---- Define the function ----


# Write departures as CSV (about 600k)
# Update arrivals
if (!file.exists("../data/arrivals.RDS")) {
  # No CSV log file yet
  arrivals_df %>%
  saveRDS("../data/arrivals.RDS")
} else {
  earliest_change <- min(as_datetime(arrivals_df$sched))
  arrivals_old_df <- readRDS("../data/arrivals.RDS")
  cat("Arrivals: Updating ",nrow(arrivals_old_df)," existing flights\n")
  # Find updates
  arrivals_all_df <- arrivals_old_df %>%
    # Add any flight data that has changed
    bind_rows(arrivals_df) %>%
    group_by(id) %>%
    # Filter all duplicates (i.e. identical ID and Last Update)
    distinct(id,lu,.keep_all = T) %>%
    arrange(sched)
  cat("Arrivals: now ",nrow(arrivals_all_df)-nrow(arrivals_old_df)," new entries\n")
  cat("Arrivals from ",arrivals_all_df %>% pull(sched) %>% as_datetime(.) %>%
        min(.) %>% format_ISO8601(.usetz=T),
      " to ",arrivals_all_df %>% pull(sched) %>% as_datetime(.) %>%
        max(.) %>% format_ISO8601(.usetz=T),"\n")
  saveRDS(arrivals_all_df,"../data/arrivals.RDS")
  write_csv2(arrivals_all_df,"../data/arrivals.csv")
}

if (!file.exists("../data/departures.RDS")) {
  # No CSV log file yet
  departures_df %>%
  saveRDS("../data/departures.RDS")
} else {
  earliest_change <- min(as_datetime(departures_df$sched))
  departures_old_df <-
    readRDS("../data/departures.RDS")
  cat("Departures: Updating ",nrow(departures_old_df)," existing flights\n")
  # Find updates
  departures_all_df <- departures_old_df %>%
    # Add any flight data that has changed
    bind_rows(departures_df) %>%
    group_by(id) %>%
    # Filter all duplicates (i.e. identical ID and Last Update)
    distinct(id,lu,.keep_all = T)
  cat("Departures: now ",nrow(departures_all_df)-nrow(departures_old_df)," new entries\n")
  cat("Departures from ",departures_all_df %>% pull(sched) %>% as_datetime(.) %>%
        min(.) %>% format_ISO8601(.usetz=T),
      " to ",departures_all_df %>% pull(sched) %>% as_datetime(.) %>%
        max(.) %>% format_ISO8601(.usetz=T),"\n")
    saveRDS(departures_all_df,"../data/departures.RDS")
    write_csv2(departures_all_df,"../data/departures.csv")
}



# Stop logging
sink()

# Make a comfy table for calculating delays:
# Pivot by status

# Send all the naughty bits to the Google bucket for remote display.
#
if (directory.exists("/home/jan_eggers_hr_de/")) {
  # Google-Bucket befüllen
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../data/arrivals.csv gs://d.data.gcp.cloud.hr.de/arrivals.csv')
  system('gsutil -h "Cache-Control:no-cache, max_age=0" cp ../data/departures.csv gs://d.data.gcp.cloud.hr.de/departures.csv')
}
