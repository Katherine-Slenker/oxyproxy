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

  it("errors when body_mass is left at its default of 0", {
    expect_error(species_function(water_economy_index = 0.4), "bodymass")
  })

  it("errors when water_economy_index is left at its default of 0", {
    expect_error(species_function(body_mass = 600), "Water Economy Index")
  })
})
