describe("humidity_oxy_proxy()", {
  it("runs the full inverse pipeline end-to-end and returns Humidity estimates", {
    out <- humidity_oxy_proxy(
      sampled_d18Ocarbonate = 20, model_air_temperature = 4, model_d18O_Surfacewater = -8,
      model_Digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8, model_Protein_Content = 0.1,
      model_Fat_Content = 0.1, model_Free_Water_Content_Food = 0.5, model_Body_mass = 500,
      model_WaterEconomyIndex = 0.4, changeConstant = FALSE, sweating_species = FALSE, PlotRange = FALSE
    )

    expect_s3_class(out, "data.frame")
    expect_true("Humidity" %in% names(out))
  })

  it("runs for a sweating species and yields a different Humidity than non-sweating", {
    args <- list(
      sampled_d18Ocarbonate = 20, model_air_temperature = 4, model_d18O_Surfacewater = -8,
      model_Digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8, model_Protein_Content = 0.1,
      model_Fat_Content = 0.1, model_Free_Water_Content_Food = 0.5, model_Body_mass = 500,
      model_WaterEconomyIndex = 0.4, changeConstant = FALSE, PlotRange = FALSE
    )
    sweating <- do.call(humidity_oxy_proxy, c(args, sweating_species = TRUE))
    non_sweating <- do.call(humidity_oxy_proxy, c(args, sweating_species = FALSE))

    expect_false(sweating$Humidity == non_sweating$Humidity)
  })

  it("runs with vector inputs and PlotRange = TRUE without erroring", {
    pdf(NULL)
    on.exit(dev.off(), add = TRUE)

    out <- humidity_oxy_proxy(
      sampled_d18Ocarbonate = c(20, 22), model_air_temperature = 4, model_d18O_Surfacewater = -8,
      model_Digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8, model_Protein_Content = 0.1,
      model_Fat_Content = 0.1, model_Free_Water_Content_Food = 0.5, model_Body_mass = 500,
      model_WaterEconomyIndex = 0.4, changeConstant = FALSE, sweating_species = FALSE, PlotRange = TRUE
    )

    expect_equal(nrow(out), 2)
  })

  it("errors informatively when a model argument is NULL", {
    expect_error(
      humidity_oxy_proxy(
        sampled_d18Ocarbonate = 20, model_air_temperature = NULL, model_d18O_Surfacewater = -8,
        model_Digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8, model_Protein_Content = 0.15,
        model_Fat_Content = 0.05, model_Free_Water_Content_Food = 0.5, model_Body_mass = 500,
        model_WaterEconomyIndex = 0.4, PlotRange = FALSE
      ),
      "Air Temperature"
    )
  })

  it("treats a non-scalar PlotRange as FALSE instead of crashing", {
    expect_no_error(
      humidity_oxy_proxy(
        sampled_d18Ocarbonate = 20, model_air_temperature = c(4, 10), model_d18O_Surfacewater = -8,
        model_Digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8, model_Protein_Content = 0.1,
        model_Fat_Content = 0.1, model_Free_Water_Content_Food = 0.5, model_Body_mass = 500,
        model_WaterEconomyIndex = 0.4, changeConstant = FALSE, sweating_species = FALSE,
        PlotRange = c(TRUE, TRUE)
      )
    )
  })
})
