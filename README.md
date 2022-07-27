# Rfraflights package

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)

R Wrapper for the unofficial API powering the frankfurt-airport.com website: Read a number of arrivals/departures, or up to a point in time, starting at a date, acquiring actual status. Flights are sorted by sched datetime and can be queried from 48hrs in the past.

## Installation

Assuming you have the `devtools` library installed, just type: 

```
devtools::install_github("untergeekDE/Rfraflights")
library(Rfraflights)
```

## Unoffical FRA API documentation

Just query the documentation with RStudio: 

```
?RFraflights
```
will bring up a man page detailing the query parameters and return variables. 

This information was deduced from watching how the www.frankfurt-airport.com flight tables work - they query the flight data via a JSON.  

