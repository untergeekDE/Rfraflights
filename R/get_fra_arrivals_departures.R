#' get_fra_arrivals_df
#'
#' @description Read arrival data into a data frame
#'
#' @details
#' Using the get_fra_data function, the FRA website is queried for scheduled arrivals, looking back the given number of hours into the past schedule, and the number of hours into the future, as by the scheduled date/time of the flight.
#'
#' @param h_back Number of hours to look back from now (max. 48; larger values are clipped). Negative values are converted.
#' @param h_forward Number of hours to look forward
#'
#' @return Data frame containing flight data, ordered by scheduled datetime (see project README for details)
#'
#' @examples get_fra_arrivals_df()
#' @examples get_fra_arrivals_df(h_back = 1, h_forward = 24)
#' @examples #NOT RUN:
#' get_fra_arrivals_df(-10,2400)
#'
#' @export
get_fra_arrivals_df <- function(h_back = 48, h_forward = 120) {
  ts <- now()
  a_df <- get_fra("arrivals",
          from = ts-hours(abs(h_back)),
          to = ts+hours(h_forward)) %>%
    # Keep timestamp of query, and write to first column.
    mutate(timestamp = ts) %>%
    relocate(timestamp)
  cat("\nArrivals: ",nrow(a_df)," flights read\n")
  return(a_df)
}

#' get_fra_departures_df
#'
#' @description Read departure data into a data frame
#'
#' @details
#' Using the get_fra_data function, the FRA website is queried for scheduled departures and their actual status, looking back the given number of hours into the past schedule, and the number of hours into the future, as by the scheduled date/time of the flight.
#'
#' @param h_back Number of hours to look back from now (max. 48; larger values are clipped). Negative values are converted.
#' @param h_forward Number of hours to look forward
#'
#' @return Data frame containing flight data, ordered by scheduled datetime (see project README for details)
#'
#' @examples get_fra_departures_df()
#' @examples get_fra_departures_df(h_back = -24, h_forward = 24)
#' @examples #NOT RUN:
#' get_departures_df(1,2400)
#'
#' @export
get_fra_departures_df <- function(h_back = 48, h_forward =120) {
  ts <- now()
  d_df <- get_fra("departures",
                           from = ts-hours(abs(h_back)),
                           to = ts+hours(h_forward)) %>%
    # Keep timestamp of query, and write to first column.
    mutate(timestamp = ts) %>%
    relocate(timestamp)
  cat("\nDepartures: ",nrow(d_df)," flights read\n")
  return(d_df)
}

#---- Function ----

#' Tupdate_fra_df
#'
#' @description Reads arrivals/departures and appends to existing data, removing duplicates
#'
#'
#'
#' @param df Data frame containing either arrival or departure data
#' @param h_back hours to look backward (max 48)
#' @param h_forward hours to look forward
#'
#' @return updated data frame with the newly read data; duplicates removed
#' @export
update_fra_df <- function(df,h_back = 48, h_forward =120) {
  is_arrivals <- substr(df$id[1],1,1) == "a"
  if (is_arrivals) {
    df_new <- get_fra_arrivals_df(h_back, h_forward)
  } else {
    df_new <- get_fra_departures_df(h_back, h_forward)
  }
  updated_df <- df %>%
    # Add any flight data that has changed.
    # Call either get_arrivals_df or get_departures_df
    # with standard parameters.
    bind_rows(df_new) %>%
    group_by(id) %>%
    # Filter all duplicates (i.e. identical ID and Last Update)
    distinct(id,lu,.keep_all = T) %>%
    arrange(sched)
  return(updated_df)
}

#' update_fra_log
#'
#' @description Reads FRA flight data and appends to .RDS and .csv files
#'
#' @details Assumes that there is a file "arrivals.RDS" (or "departures.RDS") in the current directory containing a data frame with all previously recorded data. Updates the file with any flight data that has beek changed in the meantime, keeping the original record so that you can calculate the delay and change times. Also writes a arrivals.csv (or departures.csv)
#'
#' @param path path to log files (e.g. "/path/")
#' @param flighttype "arrivals" or "departures" (or short: "a" or "d")
#'
#' @return TRUE if valid
#' @export
update_fra_log <- function(path="./fra_log/",flighttype="arrivals") {
  if (tolower(flighttype) %in% c("a","arrivals")) {
    fname_rds = paste0(path,"fra_arrivals.RDS")
    fname_csv = paste0(path,"fra_arrivals.csv")
    if (!file.exists(fname_rds)) {
      # No CSV log file yet
      get_fra_arrivals_df() %>%
        saveRDS(fname_rds)
    } else {
      arrivals_old_df <- readRDS(fname_rds)
      cat("Arrivals: Updating ",nrow(arrivals_old_df)," existing flights\n")
      arrivals_all_df <- update_fra_df(arrivals_old_df)
      cat("Arrivals: now ",nrow(arrivals_all_df)-nrow(arrivals_old_df)," new entries\n")
      cat("Arrivals from ",arrivals_all_df %>% pull(sched) %>% as_datetime(.) %>%
          min(.) %>% format_ISO8601(.usetz=T),
          " to ",arrivals_all_df %>% pull(sched) %>% as_datetime(.) %>%
          max(.) %>% format_ISO8601(.usetz=T),"\n")
      saveRDS(arrivals_all_df,fname_rds)
      write_csv2(arrivals_all_df,fname_csv)
    }
    return(TRUE)
  }
  if (tolower(flighttype) %in% c("d","departures")) {
    fname_rds = paste0(path,"fra_departures.RDS")
    fname_csv = paste0(path,"fra_departures.csv")
    if (!file.exists(fname_rds)) {
      # No CSV log file yet
      get_fra_departures_df() %>%
        saveRDS(fname_rds)
    } else {
      arrivals_old_df <- readRDS(fname_rds)
      cat("Arrivals: Updating ",nrow(arrivals_old_df)," existing flights\n")
      arrivals_all_df <- update_fra_df(arrivals_old_df)
      cat("Arrivals: now ",nrow(arrivals_all_df)-nrow(arrivals_old_df)," new entries\n")
      cat("Arrivals from ",arrivals_all_df %>% pull(sched) %>% as_datetime(.) %>%
            min(.) %>% format_ISO8601(.usetz=T),
          " to ",arrivals_all_df %>% pull(sched) %>% as_datetime(.) %>%
            max(.) %>% format_ISO8601(.usetz=T),"\n")
      saveRDS(arrivals_all_df,fname_rds)
      write_csv2(arrivals_all_df,fname_csv)
    }
    return(TRUE)
  }
  return(FALSE)
}


