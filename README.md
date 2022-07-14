# Rfraflights package

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)


R Wrapper for the unofficial API powering the frankfurt-airport.com website: Read a number of arrivals/departures, or up to a point in time, starting at a date, acquiring actual status. Flights are sorted by sched datetime and can be queried from 48hrs in the past.



# Unoffical FRA API documentation

This information was deduced from watching how the www.frankfurt-airport.com flight tables work - they query the flight data via a JSON.  

## Query parameters

Values are queried by calling to

<https://www.frankfurt-airport.com/de/_jcr_content.flights.json>

...followed by /filter? and the query commands. (That's called a REST API, right?). These parameters have been observed:

| Name       | Parameter                                         | Observed Values/Notes |
|-----------------|--------------------------|------------------------------|
| flighttype | Incoming or outgoing?                             | "arrivals" or "departures""   |
| perpage    | Max. number of flights per page returned by query | max. 50               |
| page       | Queried page                            | Data is paginated, i.e. divided up in batches (number of flights per page is determined by perpage parameter)   |
| lang       | Language of return values                                                  | de-DE  |
| time       | query flights scheduled from | UTC in ISO8601, e.g. 2022-07-12T09:12:00.000Z |

Querying a single flight: 

https://www.frankfurt-airport.com/de/_jcr_content.departures.suffix.json/filter.json?
https://www.frankfurt-airport.com/de/_jcr_content.arrivals.suffix.json/filter.json?

with the params

| Name   | Parameter                                         | Observed Values/Notes |
|-----------------|--------------------------|------------------------------|
| lang       | Language of return values                                                  | de-DE  |
| id | Query single flight info by ID (no perpage, page, time) | ID is "a" or "d" plus sched datetime plus flightcode, e.g. "a20220712lh695" |

## Return parameters

Returns a JSON with these global parameters 

| Name | Parameter | Observed Values/Notes |
|------|-------------|--------------- |
|filter|?|Subcategory id| 
|luops|last update|local time, eg 2022-07-12T11:24:00+0200 | 
|entriesperpage| Page size | as given by "perpage" parameter, max. 50 | 
|data||df with results (see below)| 
|page|Queried result page| as given by "page" parameter| 
|type|flighttype|as given by "flighttype" parameter| 
|results|number of results| number is equal or below maxpage*perpage| 
|lusaison|earliest updated flight?|local time| 
|version|API version|1.8.2|
|maxpage|highest valid page number||

\$data is a dataframe with 27 parameters for departure, and 28 for arrival:

- *arrivals* has unique variables bag, ausgang, schedDep
- *departures* has unique variables schalter, gate, SchedArr

| Name     | Parameter                                                                                          | Values                                 | Notes                                                  |
|-----------------|----------------------|-----------------|-----------------|
| ac       | Aircraft? Trains are marked by TRS.                                                                | ...,TRS                                | Not unique for flight ids!                             |
| lu       | Last Update                                                                                        | Local datetime                         | e.g. 2022-09-21T13:05:00+0200                          |
| sched    | scheduled departure                                                                                | local datetime                         | Flights are sorted in ascending order by this datetime |
| typ      | ?                                                                                                  | "P"                                    | no other values have been observed so far              |
| al       | Airline code                                                                                       | Two-character code                     | e.g. "LH"                                              |
| alname   | Airline name                                                                                       | string                                 | e.g. "Lufthansa"                                       |
| fnr      | Flight number                                                                                      | string                                 | e.g. "LH 1482"                                         |
| reg      | Aircraft registration code/call sign?                                                              |                                        |                                                        |
| terminal | Terminal code                                                                                      | "1","2"                                | No Terminal 3 yet                                      |
| halle    | Hall code                                                                                          | "A,"B","D", "E"                        |                                                        |
| bag      | Baggage Claim code                                                                                 | List of two-digit strings                       | Arrivals only. Only single-value lists so far but you never know.                     |
| ausgang  | Exit code                                                                                          | Hall code followed by two-digit string | Arrivals only                                          |
| schalter | check-in terminal code                                                                             | two 3-digit strings joined by a dash   | e.g. 961-968 - Departures only                         |
| gate     | boarding gate code                                                                                 | Hall code followed by two-digit string | Departures only. Trains have a code starting with "T". |
| esti     | updated arrival/departure datetime                                                                 | local time                             |                                                        |
| schedArr | scheduled arrival time                                                                             | local time                             |                                                        |
| schedDep | scheduled departure time                                                                           | local time                             | Arrivals only                                          |
| duration | Flight duration in minutes                                                                         | integer                                | NA for trains!                                         |
| s        | ?                                                                                                  | FALSE                                  | some sort of status, but...                            |
| iata     | IATA airport                                                                                       | 3-character string, e.g. LHR           | Destination for departures, origin for arrivals        |
| apname   | Full name of IATA airport or train station                                                         | string                                 | iata in full                                           |
| stops    | Number of stops                                                                                    | NA, 0..                                | NA for trains                                          |
| flstatus | flight status code                                                                                 | 0, 1, 3                                | 0 = done, 1 = in progress, 3 = error?                  |
| status   | "", geschlossen", "annulliert", "Aufruf", "Boarding", "gestartet", "annulliert", "Zug""            | for departures                         |                                                        |
| status   | "", "im Anflug", "gelandet", "auf Position", "annulliert", "Gepäckausgabe", Gepäckausgabe beendet" | for arrivals                           |                                                        |
| id       | ID containing sched datetime and flight code                                                       | e.g. d22020709lh1482                   | unique ID, starts with "a" for arrivals and "d" for departures                                               |
| lang     | language                                                                                           | "de"                                   |                                                        |
| cs       | connections?                                                                                       | List of connecting flights             |                                                        |
| rou      | routing location code                                                                              | IATA code                              | mainly for trains?                                     |
| rouname  | routing location name                                                                              | IATA name                              | (mainly for trains)                                    |
