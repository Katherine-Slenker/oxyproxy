describe("environment_function()", {
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

  it("lays out the grid with airtemp fastest, then d18Osw, then Humidity", {
    air <- c(0, 10, 20)
    rh <- c(0.5, 0.75)
    sw <- c(-2, -5, -8, -11)
    out <- environment_function(air_temperature = air, relative_humidity = rh, d18O_surface_water = sw)

    expect_equal(out$airtemp, rep(air, times = 8))
    expect_equal(out$d18Osw, rep(rep(sw, each = 3), times = 2))
    expect_equal(out$Humidity, rep(rh, each = 12))
    expect_equal(names(out), c(
      "airtemp", "MAT", "Humidity", "WVinLungs", "WV", "d18Osw", "dairH2O",
      "dairH2OSW", "d18OleafH2O", "d18Oleafcellulose", "dfoodO2SW", "dfoodH2Osw"
    ))
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
      environment_function(air_temperature = 20, relative_humidity = 0, d18O_surface_water = -5)
    ))
    expect_no_error(suppressMessages(
      environment_function(air_temperature = 20, relative_humidity = 1, d18O_surface_water = -5)
    ))
  })

  it("still accepts negative air temperature and surface water", {
    expect_no_error(suppressMessages(
      environment_function(air_temperature = -15, relative_humidity = 0.5, d18O_surface_water = -9.9)
    ))
  })
})
