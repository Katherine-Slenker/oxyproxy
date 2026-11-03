# Minimal synthetic species and food frames carrying exactly the columns the
# calculate_* helpers in R/InputsFunction.R read, so input_function() and
# inverse_input_function() are tested in isolation from species_function() and
# food_function(). Each test file defines its own mock_environment().
mock_species <- function() {
  data.frame(EnergyExp = 500, TotalH2OTurnover = 100)
}

mock_food <- function() {
  data.frame(
    Digestibility = 0.6, EEE = 0.9,
    foodcarbcontent = 0.8, foodcarbenergy = 17300, Ocarb = 15.4, Hcarb = 30.9,
    foodproteincontent = 0.1, foodproteinenergy = 20100, Oprotein = 3, Hprotein = 11,
    foodfatcontent = 0.1, foodfatenergy = 39700, Ofat = 2, Hfat = 60,
    freeH20food = 0.4
  )
}

# Golden reference case supplied by the project maintainers, as
# oxy_proxy_function() arguments. See test-golden-values.R for its outputs.
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
