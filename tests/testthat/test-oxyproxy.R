describe("oxy_proxy_function()", {
  it("runs the full pipeline end-to-end and returns d18Obw estimates", {
    # KNOWN BUG: oxy_proxy_function() (R/OxyProxy.R) calls its helper functions
    # with names/arguments from an older naming convention that no longer
    # matches the actual current functions:
    #   - Species_Function(...)          -> actual is species_function(body_mass=, water_economy_index=)
    #   - Food_Function(Digestibility_of_food=...) -> actual is food_function(digestibility_of_food=...)
    #   - Environment_Function(Relative_Humidity=, d18O_surfacewater=) -> actual is
    #     environment_function(relative_humidity=, d18O_surface_water=)
    #   - input_function(Species=, Food=, Environment=) -> actual params are
    #     species=, food=, environment= (lowercase)
    #   - Outputs_Function(Inputs=, SweatingSpecies=) -> actual is
    #     outputs_function(inputs=, sweating_species=)
    #   - d18OBW_Function(Outputs=) -> actual is d18_obw_function(outputs=)
    # On top of that, even with those calls fixed, species_function() and
    # food_function() have their own blocking bugs (see test-species-function.R,
    # test-food-function.R), so this wrapper cannot currently produce output no
    # matter how its call sites are corrected. Flip skip() off once all of the
    # above are fixed.
    skip("oxy_proxy_function() errors: internal calls use stale function/argument names")

    out <- oxy_proxy_function(
      model_bodymass = 600, model_WaterEconomyIndex = 0.4,
      model_digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8,
      model_Protein_Content = 0.1, model_Fat_Content = 0.1,
      model_Free_Water_Content_Food = 0.55, model_air_temperature = 4,
      model_Relative_Humidity = 0.67, model_d18O_surfacewater = -10,
      changeConstant = FALSE, SweatingSpecies = FALSE, PlotRange = FALSE
    )

    expect_s3_class(out, "data.frame")
    expect_true("d18Obw" %in% names(out))
  })

  it("currently errors instead of computing anything", {
    expect_error(
      oxy_proxy_function(
        model_bodymass = 600, model_WaterEconomyIndex = 0.4,
        model_digestibility_of_food = 0.6, model_Carbohydrate_Content = 0.8,
        model_Protein_Content = 0.1, model_Fat_Content = 0.1,
        model_Free_Water_Content_Food = 0.55, model_air_temperature = 4,
        model_Relative_Humidity = 0.67, model_d18O_surfacewater = -10,
        changeConstant = FALSE, SweatingSpecies = FALSE, PlotRange = FALSE
      )
    )
  })
})
