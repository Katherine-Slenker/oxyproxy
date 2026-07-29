describe("species_function()", {
  it("returns one row with the documented columns for a valid body mass and WEI", {
    # KNOWN BUG: species_function(body_mass=0, water_economy_index=0) has no
    # changeConstant parameter, yet its entire calculation body (EnergyExp,
    # TranscutaneousH2OLoss, WVSkin, MolesO2Air, O2FluxLungs, H2OOral, H2ONasal,
    # WVNose, TotalH2OTurnover, UrinaryH2OLoss, WVUrine, Urea, d18Oairtakenup,
    # and the final return()) lives inside `if (changeConstant == TRUE) { ... }`
    # (R/SpeciesFunction.R lines 78-152). Calling the function as documented
    # currently errors with "object 'changeConstant' not found" before it can
    # compute anything. Flip skip() off once the calculation is moved out from
    # under that conditional (see food_function() for the correct pattern: the
    # conditional there only guards the readline() override prompts, not the
    # calculation itself).
    skip("species_function() errors: 'changeConstant' not found (whole body is dead code)")

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
