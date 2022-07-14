#' get_fra_data
#'
#' R Wrapper for querying the JSON-API on frankfurt-airport.com
#'
#'@author Jan Eggers <jan.eggers@hr.de>
#'

#---- Query airport ----
get_arrivals_df <- function(h_back = 48, h_forward = 120) {
  a_df <- get_fra("arrivals",
          from = ts-hours(h_back),
          to = ts+hours(h_forward)) %>%
    # Keep timestamp of query, and write to first column.
    mutate(timestamp = ts) %>%
    relocate(timestamp)
  cat("\nArrivals: ",nrow(arrivals_df)," flights read\n")
  return(a_df)
}

get_departures_df <- function(h_back = 48, h_forward =120) {
  d_df <- get_fra("departures",
                           from = ts-hours(h_back),
                           to = ts+hours(h_forward)) %>%
    # Keep timestamp of query, and write to first column.
    mutate(timestamp = ts) %>%
    relocate(timestamp)
  cat("\nDepartures: ",nrow(departures_df)," flights read\n")
  return(d_df)
}

