# Herbivore Standard: the reference animal humidity_oxy_proxy() falls back to
# when an argument is left at 0.
#
# bodymass 30, WEI 0.25, carb 0.85, protein 0.1, fat 0.05, digestibility 0.7,
# free water content of food 0.65, air temp 15, d18Osw -3.25, humidity 0.75
herbivore_standard <- list(
  model_air_temperature         = 15,
  model_d18O_Surfacewater       = -3.25,
  model_Digestibility_of_food   = 0.7,
  model_Carbohydrate_Content    = 0.85,
  model_Protein_Content         = 0.1,
  model_Fat_Content             = 0.05,
  model_Free_Water_Content_Food = 0.65,
  model_Body_mass               = 30,
  model_WaterEconomyIndex       = 0.25
)

describe("Herbivore Standard", {
  it("is what humidity_oxy_proxy() substitutes for omitted arguments", {
    out <- suppressMessages(
      humidity_oxy_proxy(sampled_d18Ocarbonate = 26.053638, PlotRange = FALSE)
    )

    expect_equal(nrow(out), 1)
    expect_equal(out$Bodymass, 30)
    expect_equal(out$WEI, 0.25)
    expect_equal(out$Digestibility, 0.7)
    expect_equal(out$airtemp, 15)
    expect_equal(out$d18Osw, -3.25)
    expect_equal(out$foodcarbcontent, 0.85)
    expect_equal(out$foodproteincontent, 0.1)
    expect_equal(out$foodfatcontent, 0.05)
    expect_equal(out$freeH20food, 0.65)
  })

  it("keeps macronutrient fractions summing to 1", {
    out <- suppressMessages(
      humidity_oxy_proxy(sampled_d18Ocarbonate = 26.053638, PlotRange = FALSE)
    )
    expect_equal(
      out$foodcarbcontent + out$foodproteincontent + out$foodfatcontent, 1
    )
  })

  it("round-trips: the inverse recovers the humidity the forward model used", {
    # The standard's humidity of 0.75 is the value humidity_oxy_proxy() should
    # return when handed the enamel carbonate the forward model produces from it.
    forward <- suppressMessages(oxy_proxy_function(
      model_bodymass = 30, model_WaterEconomyIndex = 0.25,
      model_Carbohydrate_Content = 0.85, model_Protein_Content = 0.1,
      model_Fat_Content = 0.05, model_Digestibility_of_food = 0.7,
      model_Free_Water_Content_Food = 0.65, model_air_temperature = 15,
      model_d18O_surfacewater = -3.25, model_Relative_Humidity = 0.75,
      sweating_species = FALSE, PlotRange = FALSE
    ))

    inverse <- suppressMessages(do.call(
      humidity_oxy_proxy,
      c(list(sampled_d18Ocarbonate = forward$d18Ocarb, PlotRange = FALSE), herbivore_standard)
    ))

    expect_equal(inverse$Humidity, 0.75)
  })
})
