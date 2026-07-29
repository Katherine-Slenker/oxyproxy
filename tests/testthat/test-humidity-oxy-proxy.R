describe("humidity_oxy_proxy()", {
  it("runs the full inverse pipeline end-to-end and returns Humidity estimates", {
    out <- humidity_oxy_proxy(
      sampled_d18Ocarbonate = 20, model_Air_temperature = 4, model_d18O_Surfacewater = -8,
      model_Digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8, model_Protein_Content = 0.1,
      model_Fat_Content = 0.1, model_Free_Water_Content_Food = 0.5, model_Body_mass = 500,
      model_WaterEconomyIndex = 0.4, changeConstant = FALSE, SweatingSpecies = FALSE, PlotRange = FALSE
    )

    expect_s3_class(out, "data.frame")
    expect_true("Humidity" %in% names(out))
  })
})
