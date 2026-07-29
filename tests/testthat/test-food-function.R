describe("food_function()", {
  it("returns one row with the documented columns for a valid herbivore diet", {
    out <- food_function(
      digestibility_of_food = 0.6,
      Carbohydrate_Content = 0.8,
      Protein_Content = 0.1,
      Fat_Content = 0.1,
      Free_Water_Content_Food = 0.4
    )

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 1)
    expect_true(all(c(
      "Digestibility", "EEE", "foodcarbenergy", "foodcarbcontent", "Ocarb", "Hcarb",
      "foodproteinenergy", "Oprotein", "Hprotein", "foodfatenergy", "Ofat", "Hfat",
      "foodproteincontent", "foodfatcontent", "freeH20food"
    ) %in% names(out)))
    expect_equal(out$EEE, 0.9)
  })

  it("errors when Free_Water_Content_Food is left at its default of 0", {
    expect_error(
      food_function(digestibility_of_food = 0.6, Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1),
      "Free Water Content"
    )
  })

  it("errors when digestibility_of_food is left at its default of 0", {
    expect_error(
      food_function(Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4),
      "Digestibility"
    )
  })

  it("returns the full factorial cross for vector inputs", {
    out <- food_function(
      digestibility_of_food = c(0.5, 0.6), Carbohydrate_Content = c(0.7, 0.8),
      Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4
    )
    expect_equal(nrow(out), 2 * 2)
  })

  it("accepts digestibility at the upper boundary of 1", {
    out <- food_function(digestibility_of_food = 1, Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4)
    expect_equal(out$Digestibility, 1)
  })

  it("doesn't enforce that Carbohydrate/Protein/Fat content sum to 1", {
    # Only a caution message is printed; nothing rejects macronutrients
    # that don't sum to 1.
    out <- food_function(digestibility_of_food = 0.6, Carbohydrate_Content = 0.9, Protein_Content = 0.9, Fat_Content = 0.9, Free_Water_Content_Food = 0.4)
    expect_equal(out$EEE, 0.9)
  })

  it("silently accepts a negative Fat_Content instead of erroring", {
    out <- food_function(digestibility_of_food = 0.6, Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = -0.1, Free_Water_Content_Food = 0.4)
    expect_equal(out$foodfatcontent, -0.1)
  })
})
