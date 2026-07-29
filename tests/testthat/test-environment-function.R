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
    # NOTE: unlike digestibility_of_food/d18O_surface_water (checked via
    # sum(x) == 0), the missing-argument guard here is
    # `if (length(relative_humidity) == 0)`, which never trips for the default
    # value 0 (length(0) is 1, not 0). So an omitted relative_humidity silently
    # proceeds with Humidity = 0 rather than erroring like the other two
    # required arguments do. Documenting the actual behavior here, not
    # asserting it's correct.
    out <- environment_function(air_temperature = 20, d18O_surface_water = -5)
    expect_equal(out$Humidity, 0)
  })

  it("errors when d18O_surface_water is left at its default of 0", {
    expect_error(
      environment_function(air_temperature = 20, relative_humidity = 0.5),
      "d18Osw"
    )
  })
})
