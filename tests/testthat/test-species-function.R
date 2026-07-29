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

  it("returns the full factorial cross for vector inputs", {
    out <- species_function(body_mass = c(10, 20), water_economy_index = c(0.1, 0.2, 0.3))
    expect_equal(nrow(out), 2 * 3)
  })

  it("accepts a body mass at the small-but-nonzero boundary", {
    out <- species_function(body_mass = 0.001, water_economy_index = 0.4)
    expect_equal(out$Bodymass, 0.001)
    expect_false(is.nan(out$EnergyExp))
  })

  it("silently produces NaN for negative body mass instead of erroring", {
    # NOTE: no validation rejects negative body_mass; it passes sum(x) == 0,
    # then 900 * (-600)^0.73 is NaN (fractional power of a negative number).
    out <- species_function(body_mass = -600, water_economy_index = 0.4)
    expect_true(is.nan(out$EnergyExp))
  })

  it("doesn't hang and produces NA for changeConstant = TRUE in non-interactive use", {
    # readline() returns "" non-interactively; as.numeric("") is NA.
    out <- species_function(body_mass = 600, water_economy_index = 0.4, changeConstant = TRUE)
    expect_true(is.na(out$Urea))
  })
})
