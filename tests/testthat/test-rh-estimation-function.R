# Minimal synthetic frames carrying exactly the columns the Humidity formula
# in R/RH_EstimationFunction.R reads.
mock_outputs <- function() {
  data.frame(
    MolesO2Air = 0.42, d18Oairtakenup = 12, WVCO2 = 0.1, WVMouth = 0.5, WVNose = 0.3,
    WVSkin = 1.5, WVSweat = 0, WVUrine = 1.6, WVFecal = 0.4, Urea = 0.2, d18Osw = -8,
    dairH2O = -10, airtemp = 20, dryOinflux = 0.08, WaterinFood = 1, TotalH2OTurnover = 100,
    FreeH2Oinfood = 0.5, dryHinflux = 0.05, dairH2OSW = 2
  )
}

mock_rh_d18O <- function() {
  data.frame(d18Obodywater = 0.05)
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
})
