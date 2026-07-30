# Minimal synthetic "inputs" frame carrying exactly the columns
# validate_inputs()/the calculate_* helpers in R/OutputsFunction.R read, per
# their own @param docs and the required_cols list in validate_inputs().
mock_inputs <- function(...) {
  defaults <- data.frame(
    FoodMassIngested = 5.2, Digestibility = 0.85, TotalH2OTurnover = 8.5,
    H2OOral = 1.2, H2ONasal = 0.8, TranscutaneousH2OLoss = 2.1, UrinaryH2OLoss = 3.2,
    Oprotein = 0.12, foodproteincontent = 0.18, EEE = 0.88, MolesO2Air = 0.42,
    dryHinflux = 0.15, dryOinflux = 0.08
  )
  overrides <- list(...)
  for (name in names(overrides)) defaults[[name]] <- overrides[[name]]
  defaults
}

describe("outputs_function()", {
  it("errors if a required column is missing", {
    incomplete <- mock_inputs()
    incomplete$EEE <- NULL
    expect_error(outputs_function(incomplete), "Missing required columns")
  })

  it("returns the original columns plus the documented calculated columns", {
    out <- outputs_function(mock_inputs(), sweating_species = FALSE)

    expect_true(all(c(
      "DryFecalOutput", "FecalH20Loss", "WVFecal", "WaterHeatLoss",
      "WVSweat", "Panting", "WVMouth", "UreaProduced", "WVCO2"
    ) %in% names(out)))
    expect_true(all(names(mock_inputs()) %in% names(out)))
  })

  it("sets WVSweat to zero for non-sweating species (the default)", {
    out <- outputs_function(mock_inputs(), sweating_species = FALSE)
    expect_equal(out$WVSweat, 0)
  })

  it("computes WVSweat as half of Sweating for sweating species", {
    out <- outputs_function(mock_inputs(), sweating_species = TRUE)
    expect_equal(out$WVSweat, out$Sweating / 2)
  })

  it("computes Sweating for both species types, but only applies it when sweating", {
    # Sweating (the water budget) is always computed; sweating_species only
    # controls whether it becomes vapor loss (WVSweat).
    sweating <- outputs_function(mock_inputs(), sweating_species = TRUE)
    non_sweating <- outputs_function(mock_inputs(), sweating_species = FALSE)

    expect_equal(sweating$Sweating, non_sweating$Sweating)
    expect_equal(non_sweating$WVSweat, 0)
  })

  it("computes Sweating as 75% of WaterHeatLoss", {
    out <- outputs_function(mock_inputs(), sweating_species = TRUE)
    expect_equal(out$Sweating, 0.75 * out$WaterHeatLoss)
  })

  it("computes DryFecalOutput as FoodMassIngested * (1 - Digestibility)", {
    out <- outputs_function(mock_inputs(), sweating_species = FALSE)
    expect_equal(out$DryFecalOutput, 5.2 * (1 - 0.85))
  })

  it("warns when a value that should be non-negative is negative", {
    expect_warning(outputs_function(mock_inputs(H2OOral = -1)), "Negative values")
  })

  it("doesn't warn for Digestibility at the boundaries of 0 or 1", {
    expect_no_warning(outputs_function(mock_inputs(Digestibility = 0)))
    expect_no_warning(outputs_function(mock_inputs(Digestibility = 1)))
  })

  it("warns when Digestibility is outside [0, 1]", {
    expect_warning(outputs_function(mock_inputs(Digestibility = 1.5)), "Digestibility")
    expect_warning(outputs_function(mock_inputs(Digestibility = -0.1)), "Digestibility")
  })

  it("errors on an explicit zero-row data frame", {
    expect_error(outputs_function(mock_inputs()[0, ]), "empty")
  })
})
