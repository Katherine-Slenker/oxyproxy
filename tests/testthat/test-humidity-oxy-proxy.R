humidity_args <- function(...) {
  utils::modifyList(
    list(
      sampled_d18Ocarbonate         = 20,
      model_air_temperature         = 4,
      model_d18O_Surfacewater       = -8,
      model_Digestibility_of_food   = 0.6,
      model_Carbohydrate_Content    = 0.8,
      model_Protein_Content         = 0.1,
      model_Fat_Content             = 0.1,
      model_Free_Water_Content_Food = 0.5,
      model_Body_mass               = 500,
      model_WaterEconomyIndex       = 0.4,
      PlotRange                     = FALSE
    ),
    list(...)
  )
}

run_humidity <- function(...) do.call(humidity_oxy_proxy, humidity_args(...))

describe("humidity_oxy_proxy()", {
  it("reports which arguments had Herbivore Standard values substituted", {
    expect_message(
      run_humidity(model_Carbohydrate_Content = 0),
      "model_Carbohydrate_Content"
    )
  })

  it("names every substituted argument, not just the first", {
    expect_message(
      run_humidity(model_Carbohydrate_Content = 0, model_Protein_Content = 0),
      "model_Carbohydrate_Content.*model_Protein_Content"
    )
  })

  it("reports nothing when every argument is supplied", {
    expect_no_message(
      run_humidity(),
      message = "model_"
    )
  })

  it("runs for a sweating species and yields a different Humidity than non-sweating", {
    sweating <- run_humidity(sweating_species = TRUE)
    non_sweating <- run_humidity(sweating_species = FALSE)

    expect_false(sweating$Humidity == non_sweating$Humidity)
  })

  it("runs with vector inputs and PlotRange = TRUE without erroring", {
    pdf(NULL)
    on.exit(dev.off(), add = TRUE)

    out <- run_humidity(sampled_d18Ocarbonate = c(20, 22), PlotRange = TRUE)

    expect_equal(nrow(out), 2)
  })

  it("errors informatively when a model argument is NULL", {
    # Set with [<- because modifyList() would drop a NULL instead of passing it
    args <- humidity_args()
    args["model_air_temperature"] <- list(NULL)
    expect_error(do.call(humidity_oxy_proxy, args), "Air Temperature")
  })

  it("treats a non-scalar PlotRange as FALSE instead of crashing", {
    expect_no_error(run_humidity(model_air_temperature = c(4, 10), PlotRange = c(TRUE, TRUE)))
  })
})
