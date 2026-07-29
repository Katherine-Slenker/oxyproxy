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

  it("errors when air_temperature is left at its default of 0", {
    expect_error(rh_estimation_environment_function(d18O_surface_water = -5), "Air Temperature")
  })

  it("errors when d18O_surface_water is left at its default of 0", {
    expect_error(rh_estimation_environment_function(air_temperature = 20), "d18Osw")
  })

  it("errors on an explicit, physically valid d18O_surface_water of 0", {
    # Same missing-vs-real-zero conflict as environment_function().
    expect_error(
      rh_estimation_environment_function(air_temperature = 20, d18O_surface_water = 0),
      "d18Osw"
    )
  })

  it("accepts negative air_temperature", {
    out <- rh_estimation_environment_function(air_temperature = -10, d18O_surface_water = -5)
    expect_equal(out$MAT, -10 + 273)
  })
})
