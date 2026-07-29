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

mock_environment <- function() {
  data.frame(airtemp = 20, MAT = 293)
}

describe("inverse_input_function()", {
  it("returns one row with the documented calculated columns for a single combination", {
    out <- inverse_input_function(species = mock_species(), Food = mock_food(), rh_estimation_environment_function = mock_environment())

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 1)
    expect_true(all(c(
      "FoodMassIngested", "dryOinflux", "dryHinflux", "FreeH2Oinfood", "WaterinFood"
    ) %in% names(out)))
  })

  it("computes FoodMassIngested as EnergyExp / (Digestibility * EEE * energy density)", {
    out <- inverse_input_function(species = mock_species(), Food = mock_food(), rh_estimation_environment_function = mock_environment())

    energy_density <- 0.8 * 17300 + 0.1 * 20100 + 0.1 * 39700
    expect_equal(out$FoodMassIngested, 500 / (0.6 * 0.9 * energy_density))
  })

  it("builds one row per species combination", {
    two_species <- rbind(mock_species(), data.frame(EnergyExp = 600, TotalH2OTurnover = 120))
    out <- inverse_input_function(species = two_species, Food = mock_food(), rh_estimation_environment_function = mock_environment())
    expect_equal(nrow(out), 2)
  })
})
