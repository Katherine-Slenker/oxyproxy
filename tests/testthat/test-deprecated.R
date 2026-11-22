test_that("legacy functions are exported", {
  exports <- getNamespaceExports("oxyproxy")

  expect_true("oxy_proxy_function" %in% exports)
  expect_true("humidity_oxy_proxy" %in% exports)
})


test_that("legacy oxygen proxy wrapper preserves results", {
  args <- list(
    model_bodymass = 600,
    model_WaterEconomyIndex = 0.4,
    model_Digestibility_of_food = 0.6,
    model_Carbohydrate_Content = 0.8,
    model_Protein_Content = 0.1,
    model_Fat_Content = 0.1,
    model_Free_Water_Content_Food = 0.55,
    model_air_temperature = 4,
    model_Relative_Humidity = 0.67,
    model_d18O_surfacewater = -10,
    changeConstant = FALSE,
    sweating_species = FALSE,
    PlotRange = FALSE
  )

  expected <- do.call(OxyProxy, args)

  expect_warning(
    actual <- do.call(oxy_proxy_function, args),
    "deprecated"
  )

  expect_equal(actual, expected)

  # Verify that legacy argument names also work.
  legacy_args <- args

  names(legacy_args)[
    names(legacy_args) == "model_Digestibility_of_food"
  ] <- "model_digestibility_of_food"

  names(legacy_args)[
    names(legacy_args) == "sweating_species"
  ] <- "SweatingSpecies"

  names(legacy_args)[
    names(legacy_args) == "model_air_temperature"
  ] <- "model_Air_temperature"

  expect_warning(
    actual_legacy <- do.call(
      oxy_proxy_function,
      legacy_args
    ),
    "deprecated"
  )

  expect_equal(actual_legacy, expected)
})


test_that("legacy humidity wrapper preserves results", {
  args <- list(
    sampled_d18Ocarbonate = 20,
    model_air_temperature = 4,
    model_d18O_Surfacewater = -8,
    model_Digestibility_of_food = 0.6,
    model_Carbohydrate_Content = 0.8,
    model_Protein_Content = 0.1,
    model_Fat_Content = 0.1,
    model_Free_Water_Content_Food = 0.5,
    model_Body_mass = 500,
    model_WaterEconomyIndex = 0.4,
    changeConstant = FALSE,
    sweating_species = FALSE,
    PlotRange = FALSE
  )

  expected <- do.call(RH_Estimation_OxyProxy, args)

  expect_warning(
    actual <- do.call(humidity_oxy_proxy, args),
    "deprecated"
  )

  expect_equal(actual, expected)

  # Verify that legacy argument names also work.
  legacy_args <- args

  names(legacy_args)[
    names(legacy_args) == "model_Digestibility_of_food"
  ] <- "model_digestibility_of_food"

  names(legacy_args)[
    names(legacy_args) == "sweating_species"
  ] <- "SweatingSpecies"

  names(legacy_args)[
    names(legacy_args) == "model_air_temperature"
  ] <- "model_Air_temperature"

  expect_warning(
    actual_legacy <- do.call(
      humidity_oxy_proxy,
      legacy_args
    ),
    "deprecated"
  )

  expect_equal(actual_legacy, expected)
})


test_that("conflicting argument names are rejected", {
  expect_error(
    translate_legacy_args(list(
      SweatingSpecies = TRUE,
      sweating_species = FALSE
    )),
    "Cannot supply both"
  )
})