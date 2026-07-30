describe("oxy_proxy_function()", {
  it("runs the full pipeline end-to-end and returns d18Obw estimates", {
    out <- oxy_proxy_function(
      model_bodymass = 600, model_WaterEconomyIndex = 0.4,
      model_digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8,
      model_Protein_Content = 0.1, model_Fat_Content = 0.1,
      model_Free_Water_Content_Food = 0.55, model_air_temperature = 4,
      model_Relative_Humidity = 0.67, model_d18O_surfacewater = -10,
      changeConstant = FALSE, SweatingSpecies = FALSE, PlotRange = FALSE
    )

    expect_s3_class(out, "data.frame")
    expect_true(all(c("d18Obw", "d18Ophos", "d18Ocarb") %in% names(out)))
  })

  it("runs for a sweating species and yields a different result than non-sweating", {
    args <- list(
      model_bodymass = 600, model_WaterEconomyIndex = 0.4,
      model_digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8,
      model_Protein_Content = 0.1, model_Fat_Content = 0.1,
      model_Free_Water_Content_Food = 0.55, model_air_temperature = 4,
      model_Relative_Humidity = 0.67, model_d18O_surfacewater = -10,
      changeConstant = FALSE, PlotRange = FALSE
    )
    sweating <- do.call(oxy_proxy_function, c(args, SweatingSpecies = TRUE))
    non_sweating <- do.call(oxy_proxy_function, c(args, SweatingSpecies = FALSE))

    expect_true(sweating$WVSweat > 0)
    expect_equal(non_sweating$WVSweat, 0)
    expect_false(sweating$d18Obw == non_sweating$d18Obw)
  })
})
