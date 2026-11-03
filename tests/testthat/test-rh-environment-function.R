describe("rh_estimation_environment_function()", {
  it("returns one row per combination of inputs with the documented columns", {
    out <- rh_estimation_environment_function(
      air_temperature = c(10, 20),
      d18O_surface_water = c(-2, -5)
    )

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 2 * 2)
    expect_true(all(c("airtemp", "MAT", "d18Osw", "dairH2O", "dairH2OSW") %in% names(out)))
  })

  it("converts air temperature (C) to mean annual temperature (K)", {
    out <- rh_estimation_environment_function(air_temperature = 20, d18O_surface_water = -5)
    expect_equal(out$MAT, 20 + 273)
  })

  it("errors when air_temperature is omitted", {
    expect_error(rh_estimation_environment_function(d18O_surface_water = -5), "Air Temperature")
  })

  it("errors when d18O_surface_water is omitted", {
    expect_error(rh_estimation_environment_function(air_temperature = 20), "d18Osw")
  })

  it("accepts explicit zeros for air_temperature and d18O_surface_water", {
    out <- rh_estimation_environment_function(air_temperature = 0, d18O_surface_water = 0)
    expect_equal(out$airtemp, 0)
    expect_equal(out$d18Osw, 0)
  })

  it("accepts seq() inputs whose values sum to zero", {
    temps <- seq(-10, 10, by = 5)
    d18O <- seq(-8, 8, by = 4)
    expect_equal(sum(temps), 0)
    expect_equal(sum(d18O), 0)

    out <- rh_estimation_environment_function(air_temperature = temps, d18O_surface_water = d18O)
    expect_equal(nrow(out), length(temps) * length(d18O))
  })

  it("accepts negative air_temperature", {
    out <- rh_estimation_environment_function(air_temperature = -10, d18O_surface_water = -5)
    expect_equal(out$MAT, -10 + 273)
  })
})

describe("rh_estimation_environment_function() refactor guards", {
  it("lays out airtemp fastest and computes dairH2O per row", {
    air <- c(0, 10, 20)
    sw <- c(-2, -5)
    out <- rh_estimation_environment_function(air_temperature = air, d18O_surface_water = sw)

    expect_equal(out$airtemp, rep(air, times = 2))
    expect_equal(out$d18Osw, rep(sw, each = 3))
    expect_equal(out$dairH2O, out$d18Osw - 2.644 + 3206 / out$MAT - 1.534 * (10^6) / (out$MAT^2))
    expect_equal(out$dairH2OSW, out$dairH2O - out$d18Osw)
    expect_equal(names(out), c("airtemp", "MAT", "d18Osw", "dairH2O", "dairH2OSW"))
  })
})
