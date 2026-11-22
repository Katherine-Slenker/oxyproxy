# Minimal synthetic species/food/environment frames carrying exactly the
# columns the calculate_* helpers in R/InputsFunction.R actually read, so
# these tests exercise Inputs() in isolation from Species()/
# Food(), both of which have their own unrelated bugs (see
# test-species-function.R and test-food-function.R).
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
  data.frame(WVinLungs = 5, airtemp = 20)
}

describe("Inputs()", {
  it("errors if species, food, or environment is missing", {
    expect_error(Inputs(food = mock_food(), environment = mock_environment()), "must be provided")
    expect_error(Inputs(species = mock_species(), environment = mock_environment()), "must be provided")
    expect_error(Inputs(species = mock_species(), food = mock_food()), "must be provided")
  })

  it("errors if any argument isn't a data frame", {
    expect_error(
      Inputs(species = list(), food = mock_food(), environment = mock_environment()),
      "data frames"
    )
  })

  it("returns the documented calculated columns for a single combination", {
    out <- Inputs(species = mock_species(), food = mock_food(), environment = mock_environment())

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 1)
    expect_true(all(c(
      "FoodMassIngested", "dryOinflux", "dryHinflux",
      "FreeH2Oinfood", "WaterinFood", "DrinkingH2OIngested", "DrinkingWater"
    ) %in% names(out)))
  })

  it("computes FoodMassIngested as EnergyExp / (Digestibility * EEE * energy density)", {
    out <- Inputs(species = mock_species(), food = mock_food(), environment = mock_environment())

    energy_density <- 0.8 * 17300 + 0.1 * 20100 + 0.1 * 39700
    expect_equal(out$FoodMassIngested, 500 / (0.6 * 0.9 * energy_density))
  })

  it("errors on an explicit zero-row data frame, not just a missing argument", {
    empty_species <- mock_species()[0, ]
    expect_error(
      Inputs(species = empty_species, food = mock_food(), environment = mock_environment()),
      "cannot be empty"
    )
  })

  it("builds one row per species x food x environment combination", {
    two_species <- rbind(mock_species(), data.frame(EnergyExp = 600, TotalH2OTurnover = 120))
    out <- Inputs(species = two_species, food = mock_food(), environment = mock_environment())
    expect_equal(nrow(out), 2)
  })
})
