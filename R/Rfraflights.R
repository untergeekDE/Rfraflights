#' Rfraflights: Access FRA flight info from www.airport-frankfurt.com
#'
#' @description This package is for reading flight plan and status
#' data from the website of Germany's FRA airport at www.frankfurt-airport.com,
#' namely from the "Arrivals" and "Departures" boards. Luckily, this data does
#' not need to be scraped but can be queried via an internal API, organized
#' around the flight schedule, and by scheduled date/time of the flights. This library
#' is a wrapper for this API.
#'
#' @section What data can you get:
#'
#' You can query either arrivals or departures. Flights are queried by the
#' scheduled flight date, and returned with status and
#' delay data. Queries can look 48 hours into the past - i.e., if a flight's scheduled
#' date is more than two days in the past, it can't be found anymore.
#'
#' FRA is not only an airport, but also a train station - the API lists a lot of
#' connecting trains as well.
#'
#' Details on the data points returned below. The library adds a timestamp, but as
#' the data contains a "lu" (Last Update) variable, this can safely be ignored.
#'
#' @section Query arrival/departure timetables with status:
#'
#' Data is queried by calling to https://www.frankfurt-airport.com/de/_jcr_content.flights.json
#' ...followed by '''/filter?''' and the query commands. (That's called a REST API,
#' right? The maintainer's a journalist, not a coder). These parameters have been observed:
#'
#' - **flighttype** - "arrivals" or "departures"
#' - **perpage**  - Number of flights returned per query; max. 50
#' - **page** - Data is paginated, i.e. returned in pages, blocks of data containing *perpage* lines. This parameter gives the number of the data block in the data.
#' - **lang** - Language of return values - must be "de-DE", presumably
#' - **time** - UTC point in time from where to look up flights (by their scheduled date/time). Formatted in in ISO8601, e.g. "2022-07-12T09:12:00.000Z"
#'
#' @section Data points returned:
#'
#' The library returns a data frame containing these values
#' - **timestamp** - the timestamp of the query created by the library itself
#' - **ac**	- Aircraft? Only thing that I can say: Trains are marked by "TRS" here. May change within flight code.
#' - **lu**	Last Update. ISO8601 local datetime,	e.g. 2022-09-21T13:05:00+0200
#' - **sched**	scheduled arrival/departure	datetime, ISO8601 local datetime. Flights are sorted in ascending order by this datetime
#' - **id** - Unique identifier, starts with flighttype "a" or "d", sched datetime, and flight code, e.g. d22020709lh1482
#' - **typ** - Only ever seems to be	“P”.
#' - **al**	- Abbreviated airline code	Two-character code	e.g. “LH”
#' - **alname**	- Airline name string,	e.g. “Lufthansa”
#' - **fnr** - Flight number	string containing airline code and flight number, e.g. “LH 1482”
#' - **reg** - Aircraft registration code/call sign?
#' - **terminal** - FRA Terminal:	"1" or "2" (Terminal 3 is just being built)
#' - **halle** Hall code:	"A","B","C",“D”,"E", "AB", "NA"
#' - **bag** _Arrivals only_ - Baggage Claim code. List of two-digit strings. Only single-value lists so far but you never know.
#' - **ausgang** _Arrivals only_ Exit code. Hall code followed by two-digit string, e.g. "A44"
#' - **schalter** _Departures only_ - check-in terminal code. Two 3-digit strings joined by a dash,	e.g. "961-968"
#' - **gate** _Departures only_ - boarding gate code. Hall code followed by two-digit string. Trains have a code starting with “T”.
#' - **esti** - updated arrival/departure datetime as ISO8601 local datetime
#' - **schedArr** _Departures only_ -	scheduled arrival time as ISO8601 local datetime
#' - **schedDep** _Arrivals only_ -	scheduled departure time as ISO8601 local datetime
#' - **duration** -	Flight duration in minutes. (equals schedArr-sched for departures / sched-schedDep for arrivals). NA for trains!
#'  - **s** - Scheduled only - seems to be TRUE if this is only an entry in the flight schedule, and FALSE if there is an actual plane/train underway. If s is TRUE, flstatus == 0 and status == NA.
#' - **flstatus** - flight status code:	0 = done, 1 = in progress, 3 = error? NB: flstatus==0 is a proxy for s==TRUE
#' - **status** _Arrival_ - status string: NA (if s==TRUE), "","im Anflug", "gelandet", "auf Position", "annulliert", "Gepäckausgabe", "Gepäckausgabe beendet"
#' - **status** _Departure_ - NA (if s==TRUE), "", "annulliert", "Aufruf", "Boarding", "geschlossen", "gestartet", "annulliert", "Zug"
#' - **iata**	- IATA airport, 3-character string, e.g. "LHR".	Destination for departures, origin for arrivals.
#' - **apname** -	Full name of IATA airport or train station string, e.g. "London Heathrow"
#' - **stops** - Number of stops. NA for trains
#' - **lang**	- language: "de"
#' - **cs** - connections? List of connecting flights
#' - **rou** - routed via - IATA location code for flights with stops, and trains
#' - **rouname** - routed via; full name string
#'
#'
#' @section API quota and data limits:
#'
#' As the API is unofficial, there is no guarantee that it will work. There is also
#' no information on data limits and quotas. Be careful not to overdo it.
#'
#' @md
#' @docType package
#' @name Rfraflights-package
#' @aliases Rfraflight
NULL

