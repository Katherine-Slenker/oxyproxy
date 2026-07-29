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

  it("silently defaults relative_humidity to 0 instead of erroring", {
    # BUG: the missing-argument guard is `length(relative_humidity) == 0`,
    # which never trips for the default value 0 (length(0) is 1). Unlike
    # digestibility_of_food/d18O_surface_water, an omitted relative_humidity
    # doesn't error.
    out <- environment_function(air_temperature = 20, d18O_surface_water = -5)
    expect_equal(out$Humidity, 0)
  })

  it("errors when d18O_surface_water is left at its default of 0", {
    expect_error(
      environment_function(air_temperature = 20, relative_humidity = 0.5),
      "d18Osw"
    )
  })

  it("errors on an explicit, physically valid d18O_surface_water of 0", {
    # BUG: 0 permil is a legitimate VSMOW-relative isotope value, but the
    # missing-argument guard is `sum(d18O_surface_water) == 0`, so a real 0
    # is indistinguishable from an omitted argument.
    expect_error(
      environment_function(air_temperature = 20, relative_humidity = 0.5, d18O_surface_water = 0),
      "d18Osw"
    )
  })

  it("accepts relative_humidity at the upper boundary of 1", {
    out <- environment_function(air_temperature = 20, relative_humidity = 1, d18O_surface_water = -5)
    expect_equal(out$Humidity, 1)
  })

  it("silently accepts relative_humidity outside [0, 1] instead of erroring", {
    out <- environment_function(air_temperature = 20, relative_humidity = 1.5, d18O_surface_water = -5)
    expect_equal(out$Humidity, 1.5)
  })

  it("accepts negative air_temperature", {
    out <- environment_function(air_temperature = -10, relative_humidity = 0.5, d18O_surface_water = -5)
    expect_equal(out$MAT, -10 + 273)
  })
})
