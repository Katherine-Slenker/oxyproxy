# Minimal synthetic "outputs" frame carrying exactly the columns the d18Obw
# formula in R/d18OBWFunction.R reads.
mock_outputs <- function() {
  data.frame(
    MolesO2Air = 0.42, d18Oairtakenup = 12, WV = 3, dairH2OSW = 2,
    dfoodO2SW = 10, dryOinflux = 0.08, dfoodH2Osw = 5, WaterinFood = 1,
    DrinkingWater = 2, WVCO2 = 0.1, WVMouth = 0.5, WVNose = 0.3, WVSkin = 1.5,
    WVSweat = 0, WVUrine = 1.6, WVFecal = 0.4, Urea = 0.2, d18Osw = -8
  )
}

describe("d18_obw_function()", {
  it("adds d18Obw, d18Ophos, and d18Ocarb columns", {
    out <- d18_obw_function(outputs = mock_outputs())
    expect_true(all(c("d18Obw", "d18Ophos", "d18Ocarb") %in% names(out)))
    expect_equal(nrow(out), 1)
  })

  it("derives d18Ophos and d18Ocarb from d18Obw via the documented fixed offsets", {
    out <- d18_obw_function(outputs = mock_outputs())
    expect_equal(out$d18Ophos, out$d18Obw + 25.9 - 37 / 4.38)
    expect_equal(out$d18Ocarb, out$d18Ophos + 8.5)
  })

  it("preserves the original outputs columns alongside the new ones", {
    out <- d18_obw_function(outputs = mock_outputs())
    expect_true(all(names(mock_outputs()) %in% names(out)))
  })
})
