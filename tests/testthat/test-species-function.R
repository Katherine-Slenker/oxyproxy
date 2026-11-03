describe("species_function()", {
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

  it("lays out the grid with Bodymass fastest and WEI slowest", {
    out <- species_function(body_mass = c(10, 20), water_economy_index = c(0.1, 0.2, 0.3))

    expect_equal(out$Bodymass, rep(c(10, 20), times = 3))
    expect_equal(out$WEI, rep(c(0.1, 0.2, 0.3), each = 2))
    expect_equal(names(out), c(
      "Bodymass", "EnergyExp", "WEI", "TranscutaneousH2OLoss", "WVSkin", "MolesO2Air", "O2FluxLungs",
      "H2OOral", "H2ONasal", "WVNose", "TotalH2OTurnover", "UrinaryH2OLoss", "WVUrine", "Urea", "d18Oairtakenup"
    ))
  })
})
