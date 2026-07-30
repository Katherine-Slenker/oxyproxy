describe("species_function()", {
  it("returns one row with the documented columns for a valid body mass and WEI", {
    out <- species_function(body_mass = 600, water_economy_index = 0.4)

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 1)
    expect_true(all(c(
      "Bodymass", "EnergyExp", "WEI", "TranscutaneousH2OLoss", "WVSkin",
      "MolesO2Air", "O2FluxLungs", "H2OOral", "H2ONasal", "WVNose",
      "TotalH2OTurnover", "UrinaryH2OLoss", "WVUrine", "Urea", "d18Oairtakenup"
    ) %in% names(out)))
    expect_equal(out$Bodymass, 600)
    expect_equal(out$EnergyExp, 900 * 600^0.73)
  })

  it("errors when body_mass is omitted", {
    expect_error(species_function(water_economy_index = 0.4), "bodymass")
  })

  it("errors when water_economy_index is omitted", {
    expect_error(species_function(body_mass = 600), "Water Economy Index")
  })

  it("errors when body_mass is zero or negative", {
    expect_error(species_function(body_mass = 0, water_economy_index = 0.4), "bodymass")
    expect_error(species_function(body_mass = -600, water_economy_index = 0.4), "bodymass")
  })

  it("errors when water_economy_index is zero or negative", {
    expect_error(species_function(body_mass = 600, water_economy_index = 0), "Water Economy Index")
    expect_error(species_function(body_mass = 600, water_economy_index = -0.4), "Water Economy Index")
  })

  it("accepts a seq() of body masses", {
    out <- species_function(body_mass = seq(100, 500, by = 100), water_economy_index = 0.4)
    expect_equal(nrow(out), 5)
  })

  it("returns the full factorial cross for vector inputs", {
    out <- species_function(body_mass = c(10, 20), water_economy_index = c(0.1, 0.2, 0.3))
    expect_equal(nrow(out), 2 * 3)
  })

  it("accepts a body mass at the small-but-nonzero boundary", {
    out <- species_function(body_mass = 0.001, water_economy_index = 0.4)
    expect_equal(out$Bodymass, 0.001)
    expect_false(is.nan(out$EnergyExp))
  })

  it("doesn't hang and produces NA for changeConstant = TRUE in non-interactive use", {
    # readline() returns "" non-interactively; as.numeric("") is NA.
    out <- species_function(body_mass = 600, water_economy_index = 0.4, changeConstant = TRUE)
    expect_true(is.na(out$Urea))
  })
})
