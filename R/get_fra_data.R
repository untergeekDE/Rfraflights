
# pacman::p_load(pacman)
# # p_load(this.path)
require(jsonlite)
require(utils)
require(lubridate)
require(dplyr)
require(stringr)
require(readr)

#' get_fra_page
#'
#' @description
#' `get_fra_page` queries one page of flight information from FRA
#'
#' @details
#' Query one page of flight information (max. 50 entries) by scheduled date and time. Query time may be up to 48 hours in the past, or in the future. Returns a data frame with one flight per line.
#'
#' @examples get_fra_page("arrivals", time=now(), page=1)
#' @examples get_fra_page("departures", time=now()+hours(24), page = 5, perpage = 10)
#'
#' @param flighttype "arrivals" or "departures"
#' @param time Point of time for querying: Returns flights with a scheduled date equal to or higher than time. Time must be given as UTC - please note that all return times are given as local times, with the time difference to UTC.
#' @param perpage Entries per page (max. 50)
#' @param page Number of the page to be queried - reading all entries with a scheduled date time from ´time´ onwards may return a potentially unlimited number of flights. They are sorted by ascending schedule datetime and paginated - i.e. with perpage=50, page=1 returns entries 1 to 50, page=2 returns 51 to 100, and so on.
#' @returns Data frame
#' @export
get_fra_page <- function(flighttype,time,
                          perpage=50,page=1) {
# Checked on 11-07-2022 - 5000 flights seem to cover approx 2 weeks.


    fraport_url <- "https://www.frankfurt-airport.com/de/_jcr_content.flights.json"
    # Alle Parameter
    query_url <- paste0(fraport_url,
                        "/filter?",
                        "perpage=",perpage,"&",
                        "lang=de-DE&",
                        "page=",page,"&",
                        "flighttype=",flighttype,"&",
                        "time=",
                        URLencode(strftime(time,format = "%Y-%m-%dT%H:%M:",tz="UTC"),
                                  reserved=T),
                        "00.000Z")
    #cat(query_url)
    cat(".")
    try(fra_json <- fromJSON(query_url,flatten = T))
    # The JSON contains a data frame in fra_json$data.
    # ISO8601 strings have to be converted to datetime objects for internal coherence
    # Converting them to datetime converts them all to UTC.
    read_df <- fra_json$data
    # read_df <- fra_json$data %>%
    #   mutate(tz = tz(lu)) %>%
    #   # These two are always present:
    #   # lu (Last Update) and sched (Scheduled flight datetime)
    #   mutate_at("lu",~as_datetime(.,tz=NULL)) %>%
    #   # Conditional: Change schedArr and schedDep if they exist
    #   mutate_at(vars(starts_with("sched")),as_datetime) %>%
    #   # Conditional: Change esti if exists
    #   mutate_at(vars(matches("esti")),as_datetime)
      return(read_df)
}

#' get_fra
#'
#' @description
#' `get_fra` queries flight information from FRA
#'
#' @details
#' Query flights, ordered by scheduled departure, starting at a point in time (up to to 48 hours in the past, or in the future), up to an end point, or a number of pages. Returns a data frame with one flight per line.
#'
#' @examples get_fra("arrivals", from=now(), pages=1)
#' @examples get_fra("departures", from=now()-hours(24), to=now()+hours(24))
#' @examples get_fra("departures", from=now(), pages=10) # gets next 500 flights
#'
#' @param flighttype "arrivals" or "departures"
#' @param from Point of time for querying: Returns flights with a scheduled date equal to or higher than time. Time must be given as UTC - please note that all return times are given as local times, with the time difference to UTC.
#' @param to Upper sched datetime limit for queried flights
#' @param perpage Entries per page (max. 50) - use only if querying by number of entries
#' @param pages Number of pages to be queried - used only if no `to` parameter is given
#' @returns Data frame - see README.md for variables
#' @export
get_fra <- function(flighttype = "arrivals",
                     from = now()-hours(48),
                     to = NA,
                     pages = 1,
                     perpage = 50) {
  if (flighttype %in% c("arrivals","departures")) {
    # Check for correct flighttype.
    # "from" can be up to 48hrs in the past; earlier dates start the query at this earliest point.
    t = from
    p = 1
    # Get first page of data
    fra_df <- get_fra_page(flighttype = flighttype,time = t,
                           perpage=perpage,page=p)
    t_max <- max(as_datetime(fra_df$sched)) # UTC
    while (ifelse(is.na(to), (p < pages),(t_max < to))) {
      # Next page number
      p <- p +1
      fra_df <- fra_df %>%
        bind_rows(get_fra_page(flighttype = flighttype,time = t,
                              perpage=perpage,page=p))
      t_max <- max(as_datetime(fra_df$sched))
    }
    # Clip to max. sched datetime
    if (!is.na(to)) { fra_df <- fra_df %>% filter(as_datetime(sched) <= to) }
    return(fra_df)
  }
}

#' get_fra_flight
#'
#' Low-level function to query one single flight via ID
#'
#' @param id e.g. "a20220712lh1284" consists of:
#' - "a"rrival or "d"eparture
#' - the scheduled date, formatted YYYYMMDD
#' - airline and flight code
#'
#' @return data frame with basically the same parameters as in the paginated data
#' @export
get_fra_flight <- function(id) {
  # Sanitize input.
  id <- tolower(id)
  if (!(str_detect(id,"^[ad]20[0-9][0-9][01][0-9][0-3][0-9][a-z]+[0-9]+"))) {
    #No valid flight number? Break.
    stop(id," is not a valid flight ID")
  }
  ts <- now()
  query_url <- paste0("https://www.frankfurt-airport.com/de/",
                    "_jcr_content.departures.suffix.json/",
                    "filter.json?",
                    "lang=de-DE&", id)
  try(fra_json <- fromJSON(query_url,flatten = T))
  return(fra_json)
}
