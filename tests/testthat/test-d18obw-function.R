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
  it("errors naming the missing column", {
    incomplete <- mock_outputs()
    incomplete$MolesO2Air <- NULL
    expect_error(d18_obw_function(outputs = incomplete), "Missing required columns: MolesO2Air")
  })

  it("errors clearly on a zero-row outputs frame instead of crashing on 1:0", {
    expect_error(d18_obw_function(outputs = mock_outputs()[0, ]), "cannot be empty")
  })

  it("gives each row the same result it would get on its own", {
    rows <- mock_outputs()[rep(1, 3), ]
    rows$MolesO2Air <- c(0.42, 0.5, 0.61)
    rows$WV <- c(3, 1, 4)
    rows$WVSweat <- c(0, 0.2, 0.4)
    rows$d18Osw <- c(-8, -3, 0)

    out <- d18_obw_function(outputs = rows)
    for (i in seq_len(nrow(rows))) {
      one <- d18_obw_function(outputs = rows[i, ])
      expect_equal(out$d18Obw[i], one$d18Obw)
      expect_equal(out$d18Ophos[i], one$d18Ophos)
      expect_equal(out$d18Ocarb[i], one$d18Ocarb)
    }
  })

  it("appends d18Obw, d18Ophos, d18Ocarb after the input columns", {
    out <- d18_obw_function(outputs = mock_outputs())
    expect_equal(names(out), c(names(mock_outputs()), "d18Obw", "d18Ophos", "d18Ocarb"))
  })

  it("returns a plain data frame for a data frame subclass input", {
    outputs <- structure(mock_outputs(), class = c("custom_df", "data.frame"))
    expect_identical(class(d18_obw_function(outputs = outputs)), "data.frame")
  })
})
