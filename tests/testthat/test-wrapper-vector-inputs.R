# End-to-end checks through oxy_proxy_function(). The stage functions' own tests
# cover their guards and grid layouts; these only check behavior that needs the
# whole pipeline.

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
})

describe("sweating_species offset through the wrapper", {
  it("adds vapor loss and shifts d18Obw upward", {
    sweating <- run_bison(sweating_species = TRUE)
    non_sweating <- run_bison(sweating_species = FALSE)

    expect_gt(sweating$WVSweat, 0)
    expect_equal(non_sweating$WVSweat, 0)
    expect_gt(sweating$d18Obw, non_sweating$d18Obw)
  })
})
