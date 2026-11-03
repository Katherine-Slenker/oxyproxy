mock_environment <- function() {
  data.frame(WVinLungs = 5, airtemp = 20)
}

describe("input_function()", {
  it("errors if species, food, or environment is missing", {
    expect_error(input_function(food = mock_food(), environment = mock_environment()), "must be provided")
    expect_error(input_function(species = mock_species(), environment = mock_environment()), "must be provided")
    expect_error(input_function(species = mock_species(), food = mock_food()), "must be provided")
  })

  it("errors if any argument isn't a data frame", {
    expect_error(
      input_function(species = list(), food = mock_food(), environment = mock_environment()),
      "data frames"
    )
  })

  it("errors on an explicit zero-row data frame, not just a missing argument", {
    empty_species <- mock_species()[0, ]
    expect_error(
      input_function(species = empty_species, food = mock_food(), environment = mock_environment()),
      "cannot be empty"
    )
  })

  it("appends calculated columns after the inputs, in pipeline order", {
    out <- input_function(species = mock_species(), food = mock_food(), environment = mock_environment())
    expect_equal(names(out), c(
      names(mock_species()), names(mock_food()), names(mock_environment()),
      "FoodMassIngested", "dryOinflux", "dryHinflux", "FreeH2Oinfood",
      "WaterinFood", "DrinkingH2OIngested", "DrinkingWater"
    ))
  })
})
