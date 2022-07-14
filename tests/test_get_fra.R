#'


source("get_fra_data.R")

testthat::test_that("Bundestags- und Landtagswahlen werden gefunden?" {
  # Punkte ausgegeben, d.h. Daten eingelesen?
  testthat::expect_output(get_fra_page("departures",time=now(),page=1),".....")
  # 10 Datenreihen zurückbekommen?
  testthat::expect_equal(nrow(get_fra("arrivals",from=now(),page=1,perpage=10),10))
  # 28 Datenspalten zurückbekommen? (departures)
  testthat::expect_equal(ncol(get_fra("departures",
                                      from=now(),
                                      to=now()+hours(48))),28)
})

#> Test erfolgreich 🎊
