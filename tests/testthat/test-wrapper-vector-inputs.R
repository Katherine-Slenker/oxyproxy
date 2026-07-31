# End-to-end checks that vectorized and zero-valued arguments survive the whole
# wrapper, not just the individual stage functions. The guards used to be
# sum(x) == 0, which rejected any seq() symmetric about zero and any legitimate
# zero such as 0 degrees C or 0% humidity.

bison_args <- function(...) {
  utils::modifyList(
    list(
      model_bodymass                = 612.5,
      model_WaterEconomyIndex       = 0.43,
      model_Digestibility_of_food   = 0.592,
      model_Carbohydrate_Content    = 0.82,
      model_Protein_Content         = 0.11,
      model_Fat_Content             = 0.07,
      model_Free_Water_Content_Food = 0.6,
      model_air_temperature         = 8.6,
      model_Relative_Humidity       = 0.605,
      model_d18O_surfacewater       = -9.9,
      changeConstant                = FALSE,
      sweating_species              = FALSE,
      PlotRange                     = FALSE
    ),
    list(...)
  )
}

run_bison <- function(...) suppressMessages(do.call(oxy_proxy_function, bison_args(...)))

describe("oxy_proxy_function() with vectorized inputs", {
  it("reproduces the manuscript's Step 2 example at 726 rows", {
    out <- run_bison(
      model_bodymass = 85, model_WaterEconomyIndex = seq(0.05, 0.3, 0.05),
      model_Digestibility_of_food = 0.624, model_Carbohydrate_Content = 0.72,
      model_Protein_Content = 0.15, model_Fat_Content = 0.13,
      model_Free_Water_Content_Food = 0.6, model_air_temperature = seq(0, 10, 1),
      model_Relative_Humidity = seq(0, 1, 0.1), model_d18O_surfacewater = -10
    )

    expect_equal(nrow(out), 6 * 11 * 11)
    expect_true(all(is.finite(out$d18Obw)))
  })

  it("builds a complete factorial over three vectorized environmental inputs", {
    air <- seq(-10, 10, 1)
    sw <- seq(-3, 2, 1)
    rh <- seq(0, 1, 0.1)

    out <- run_bison(
      model_air_temperature = air, model_d18O_surfacewater = sw,
      model_Relative_Humidity = rh
    )

    expect_equal(nrow(out), length(air) * length(sw) * length(rh))
    expect_setequal(unique(out$airtemp), air)
    expect_setequal(unique(out$d18Osw), sw)
    expect_setequal(unique(out$Humidity), rh)

    combos <- out[, c("airtemp", "d18Osw", "Humidity")]
    expect_equal(nrow(unique(combos)), nrow(out))
    expect_true(all(is.finite(out$d18Obw)))
  })

  it("accepts a seq() of air temperatures that sums to zero", {
    # sum(seq(-10, 10, 5)) is exactly 0, which the old guard read as "missing".
    temps <- seq(-10, 10, 5)
    expect_equal(sum(temps), 0)

    out <- run_bison(model_air_temperature = temps)
    expect_equal(nrow(out), length(temps))
    expect_setequal(unique(out$airtemp), temps)
  })

  it("accepts a seq() of surface water values that sums to zero", {
    sw <- seq(-9, 9, 3)
    expect_equal(sum(sw), 0)

    out <- run_bison(model_d18O_surfacewater = sw)
    expect_equal(nrow(out), length(sw))
    expect_setequal(unique(out$d18Osw), sw)
  })

  it("accepts zero as a legitimate air temperature and humidity", {
    expect_equal(run_bison(model_air_temperature = 0)$airtemp, 0)
    expect_equal(run_bison(model_Relative_Humidity = 0)$Humidity, 0)
  })
})

describe("sweating_species offset through the wrapper", {
  it("adds vapor loss and shifts d18Obw upward", {
    sweating <- run_bison(sweating_species = TRUE)
    non_sweating <- run_bison(sweating_species = FALSE)

    expect_gt(sweating$WVSweat, 0)
    expect_equal(non_sweating$WVSweat, 0)
    expect_gt(sweating$d18Obw, non_sweating$d18Obw)
  })

  it("keeps the documented sweat coefficients end to end", {
    out <- run_bison(sweating_species = TRUE)

    expect_equal(out$Sweating, 0.75 * out$WaterHeatLoss)
    expect_equal(out$WVSweat, 0.375 * out$WaterHeatLoss)
    expect_equal(out$WVSweat, out$Sweating / 2)
  })

  it("computes the same Sweating either way, applying it only when sweating", {
    sweating <- run_bison(sweating_species = TRUE)
    non_sweating <- run_bison(sweating_species = FALSE)

    expect_equal(sweating$Sweating, non_sweating$Sweating)
    expect_equal(sweating$WaterHeatLoss, non_sweating$WaterHeatLoss)
  })

  it("offsets d18Obw and d18Ocarb by the same amount", {
    # The carbonate conversion is a fixed additive offset from body water, so
    # any shift from sweating has to appear identically in both.
    sweating <- run_bison(sweating_species = TRUE)
    non_sweating <- run_bison(sweating_species = FALSE)

    expect_equal(
      sweating$d18Obw - non_sweating$d18Obw,
      sweating$d18Ocarb - non_sweating$d18Ocarb
    )
  })

  it("holds the coefficients across vectorized inputs, not just one row", {
    out <- run_bison(
      model_Relative_Humidity = seq(0.5, 0.8, 0.05), sweating_species = TRUE
    )

    expect_equal(nrow(out), 7)
    expect_equal(out$Sweating, 0.75 * out$WaterHeatLoss)
    expect_equal(out$WVSweat, 0.375 * out$WaterHeatLoss)
  })
})
