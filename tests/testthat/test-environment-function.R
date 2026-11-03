describe("environment_function()", {
  it("returns one row per combination of inputs with the documented columns", {
    out <- environment_function(
      air_temperature = c(10, 20),
      relative_humidity = c(0.5, 0.75),
      d18O_surface_water = c(-2, -5)
    )

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 2 * 2 * 2)
    expect_true(all(c(
      "airtemp", "MAT", "Humidity", "WVinLungs", "WV", "d18Osw", "dairH2O",
      "dairH2OSW", "d18OleafH2O", "d18Oleafcellulose", "dfoodO2SW", "dfoodH2Osw"
    ) %in% names(out)))
  })

  it("converts air temperature (C) to mean annual temperature (K)", {
    out <- environment_function(air_temperature = 20, relative_humidity = 0.5, d18O_surface_water = -5)
    expect_equal(out$MAT, 20 + 273)
  })

  it("errors when relative_humidity is omitted", {
    expect_error(
      environment_function(air_temperature = 20, d18O_surface_water = -5),
      "Relative Humidity"
    )
  })

  it("errors when d18O_surface_water is omitted", {
    expect_error(
      environment_function(air_temperature = 20, relative_humidity = 0.5),
      "d18Osw"
    )
  })

  it("accepts an explicit d18O_surface_water of 0 (a valid VSMOW value)", {
    out <- environment_function(air_temperature = 20, relative_humidity = 0.5, d18O_surface_water = 0)
    expect_equal(out$d18Osw, 0)
  })

  it("accepts an explicit air_temperature of 0 C", {
    out <- environment_function(air_temperature = 0, relative_humidity = 0.5, d18O_surface_water = -5)
    expect_equal(out$airtemp, 0)
    expect_equal(out$MAT, 273)
  })

  it("accepts seq() inputs whose values sum to zero", {
    temps <- seq(-10, 10, by = 5)
    expect_equal(sum(temps), 0) # the case the old sum()-based guard rejected

    out <- environment_function(
      air_temperature = temps, relative_humidity = 0.5, d18O_surface_water = seq(-8, 8, by = 4)
    )
    expect_equal(nrow(out), length(temps) * 1 * 5)
  })

  it("accepts relative_humidity at the upper boundary of 1", {
    out <- environment_function(air_temperature = 20, relative_humidity = 1, d18O_surface_water = -5)
    expect_equal(out$Humidity, 1)
  })

  it("accepts negative air_temperature", {
    out <- environment_function(air_temperature = -10, relative_humidity = 0.5, d18O_surface_water = -5)
    expect_equal(out$MAT, -10 + 273)
  })
})

describe("environment_function() humidity bounds", {
  it("rejects negative relative humidity", {
    expect_error(
      environment_function(air_temperature = 20, relative_humidity = -0.5, d18O_surface_water = -5),
      "between 0 and 1"
    )
  })

  it("rejects relative humidity above 1", {
    expect_error(
      environment_function(air_temperature = 20, relative_humidity = 1.5, d18O_surface_water = -5),
      "between 0 and 1"
    )
  })

  it("still accepts humidity of exactly 0 and 1", {
    # The manuscript's Step 2 example uses seq(0, 1, 0.1), so both endpoints
    # have to remain valid.
    expect_no_error(suppressMessages(
      environment_function(air_temperature = 20, relative_humidity = 0, d18O_surface_water = -5)))
    expect_no_error(suppressMessages(
      environment_function(air_temperature = 20, relative_humidity = 1, d18O_surface_water = -5)))
  })

  it("still accepts negative air temperature and surface water", {
    expect_no_error(suppressMessages(
      environment_function(air_temperature = -15, relative_humidity = 0.5, d18O_surface_water = -9.9)))
  })
})

describe("environment_function() refactor guards", {
  air <- c(0, 10, 20)
  rh <- c(0.5, 0.75)
  sw <- c(-2, -5, -8, -11)

  it("lays out the grid with airtemp fastest, then d18Osw, then Humidity", {
    out <- environment_function(air_temperature = air, relative_humidity = rh, d18O_surface_water = sw)

    expect_equal(out$airtemp, rep(air, times = 8))
    expect_equal(out$d18Osw, rep(rep(sw, each = 3), times = 2))
    expect_equal(out$Humidity, rep(rh, each = 12))
    expect_equal(names(out), c(
      "airtemp", "MAT", "Humidity", "WVinLungs", "WV", "d18Osw", "dairH2O",
      "dairH2OSW", "d18OleafH2O", "d18Oleafcellulose", "dfoodO2SW", "dfoodH2Osw"
    ))
  })

  it("computes every derived column from that row's inputs", {
    out <- environment_function(air_temperature = air, relative_humidity = rh, d18O_surface_water = sw)

    expect_equal(out$MAT, out$airtemp + 273)
    expect_equal(out$WVinLungs, out$Humidity * (10^(0.686 + 0.027 * out$airtemp)) * 12400 / (760 * 22.4))
    expect_equal(out$WV, out$WVinLungs / 2)
    expect_equal(out$dairH2O, out$d18Osw - 2.644 + 3206 / out$MAT - 1.534 * (10^6) / (out$MAT^2))
    expect_equal(out$dairH2OSW, out$dairH2O - out$d18Osw)
    expect_equal(out$d18OleafH2O, out$d18Osw + (1 - out$Humidity) * (out$d18Osw - out$dairH2O + 16))
    expect_equal(out$d18Oleafcellulose, out$d18OleafH2O + 27)
    expect_equal(out$dfoodO2SW, out$d18Oleafcellulose - out$d18Osw)
    expect_equal(out$dfoodH2Osw, (0.5 * out$d18Osw + 0.5 * out$d18OleafH2O) - out$d18Osw)
  })
})
