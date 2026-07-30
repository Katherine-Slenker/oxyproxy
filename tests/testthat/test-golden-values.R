# Golden reference case supplied by the project maintainers.
#
# Inputs:  bodymass 612.5, WEI 0.43, carb 0.82, protein 0.11, fat 0.07,
#          digestibility 0.592, free water content of food 0.6, air temp 8.6,
#          d18Osw -9.9, relative humidity 0.605
# Output:  d18Obw -6.23 (published), -6.2235465687 (full precision)
golden_inputs <- function(...) {
  utils::modifyList(
    list(
      model_bodymass                = 612.5,
      model_WaterEconomyIndex       = 0.43,
      model_Carbohydrate_Content    = 0.82,
      model_Protein_Content         = 0.11,
      model_Fat_Content             = 0.07,
      model_Digestibility_of_food   = 0.592,
      model_Free_Water_Content_Food = 0.6,
      model_air_temperature         = 8.6,
      model_Relative_Humidity       = 0.605,
      model_d18O_surfacewater       = -9.9,
      sweating_species              = FALSE,
      PlotRange                     = FALSE,
      changeConstant                = FALSE
    ),
    list(...)
  )
}

describe("golden reference case", {
  it("reproduces the published d18Obw of -6.23", {
    out <- do.call(oxy_proxy_function, golden_inputs())

    expect_equal(nrow(out), 1)
    expect_equal(out$d18Obw, -6.23, tolerance = 0.01)
  })

  it("holds d18Obw exactly, so any model change surfaces as a failure", {
    out <- do.call(oxy_proxy_function, golden_inputs())
    expect_equal(out$d18Obw, -6.2235465687, tolerance = 1e-8)
  })

  it("holds the phosphate and carbonate conversions", {
    out <- do.call(oxy_proxy_function, golden_inputs())

    expect_equal(out$d18Ophos, 11.2289648468, tolerance = 1e-8)
    expect_equal(out$d18Ocarb, 19.7289648468, tolerance = 1e-8)
  })
})
