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

  it("errors for sweating species instead of computing WVSweat", {
    # KNOWN BUG: outputs_function() picks the sweat calculator via
    # `ifelse(sweating_species, calculate_wv_sweating, calculate_wv_not_sweating)`
    # (R/OutputsFunction.R line 109). ifelse() is vectorized and doesn't handle
    # function-valued yes/no branches correctly; for sweating_species = TRUE it
    # returns something that fails inside with_column("WVSweat", sweat_function)
    # with "replacement has 0 rows, data has 1" rather than a real value. The
    # FALSE path happens to work because calculate_wv_not_sweating's result
    # (all zeros) survives the coercion. The fix is a plain
    # `if (sweating_species) calculate_wv_sweating else calculate_wv_not_sweating`.
    expect_error(
      outputs_function(mock_inputs(), sweating_species = TRUE),
      "replacement has 0 rows"
    )
  })

  it("computes DryFecalOutput as FoodMassIngested * (1 - Digestibility)", {
    out <- outputs_function(mock_inputs(), sweating_species = FALSE)
    expect_equal(out$DryFecalOutput, 5.2 * (1 - 0.85))
  })

  it("warns when a value that should be non-negative is negative", {
    expect_warning(outputs_function(mock_inputs(H2OOral = -1)), "Negative values")
  })
})
