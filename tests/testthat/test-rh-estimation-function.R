# Columns the Humidity formula in R/RH_EstimationFunction.R reads, with values
# captured from a real upstream run (500 kg herbivore, 4 C, d18Osw -8) so the
# resulting Humidity is physically plausible rather than arbitrary.
mock_outputs <- function() {
  data.frame(
    MolesO2Air = 181.5283, d18Oairtakenup = 14.8, WVCO2 = 167.154, WVMouth = 280.1571,
    WVNose = 36.30566, WVSkin = 45.45121, WVSweat = 0, WVUrine = 233.4469,
    WVFecal = 130.881, Urea = 0.2, d18Osw = -8, dairH2O = -19.06243, airtemp = 4,
    dryOinflux = 54.35944, WaterinFood = 218.135, TotalH2OTurnover = 1867.575,
    FreeH2Oinfood = 436.2701, dryHinflux = 134.9234, dairH2OSW = -11.06243
  )
}

mock_rh_d18O <- function() {
  # d18O_enamel(d18O_carbonate = 20)$d18Obodywater
  data.frame(d18Obodywater = -5.952511)
}

describe("rh_function()", {
  it("returns the documented calculated columns", {
    out <- rh_function(rh_estimation_d18O = mock_rh_d18O(), outputs = mock_outputs())

    expect_s3_class(out, "data.frame")
    expect_true(all(c(
      "Humidity", "WVinLungs", "WV", "d18OleafH2O", "d18Oleafcellulose",
      "dfoodO2SW", "dfoodH2Osw", "DrinkingH2OIngested", "DrinkingWater"
    ) %in% names(out)))
  })

  it("computes WV as half of WVinLungs", {
    out <- rh_function(rh_estimation_d18O = mock_rh_d18O(), outputs = mock_outputs())
    expect_equal(out$WV, out$WVinLungs / 2)
  })

  it("estimates a Humidity in the physically valid range for realistic inputs", {
    out <- rh_function(rh_estimation_d18O = mock_rh_d18O(), outputs = mock_outputs())
    expect_gt(out$Humidity, 0)
    expect_lt(out$Humidity, 1)
  })

  it("defaults printinfo to FALSE and doesn't print", {
    expect_silent(rh_function(rh_estimation_d18O = mock_rh_d18O(), outputs = mock_outputs()))
  })

  it("prints Humidity when printinfo = TRUE", {
    expect_message(
      rh_function(rh_estimation_d18O = mock_rh_d18O(), outputs = mock_outputs(), printinfo = TRUE),
      "Humidity"
    )
  })

  it("cross-joins outputs and rh_estimation_d18O when they share no columns", {
    # merge() with no shared column names does a full Cartesian product.
    two_outputs <- mock_outputs()[rep(1, 2), ]
    two_outputs$MolesO2Air <- c(0.42, 0.5)
    two_d18O <- data.frame(d18Obodywater = c(0.05, 0.06))

    out <- rh_function(rh_estimation_d18O = two_d18O, outputs = two_outputs)
    expect_equal(nrow(out), 2 * 2)
  })

  it("errors clearly when the merged result is empty instead of crashing on 1:0", {
    # BUG: the loop is `for (i in 1:nrow(DF_outputs))`. With 0 rows,
    # 1:nrow() is 1:0 == c(1, 0), so the loop tries to assign into row 1 of a
    # 0-row frame and fails with "replacement has 1 row, data has 0" instead
    # of a message that explains the actual problem.
    expect_error(
      rh_function(rh_estimation_d18O = mock_rh_d18O()[0, ], outputs = mock_outputs()),
      "cannot be empty"
    )
  })
})
