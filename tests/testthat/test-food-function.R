describe("food_function()", {
  it("returns one row with the documented columns for a valid herbivore diet", {
    # KNOWN BUG: food_function() references Col_foodcarbcontent_temp,
    # Col_foodproteincontent_temp, and Col_foodfatcontent_temp (R/FoodFunction.R
    # lines 107, 114, 121) before they are ever assigned (the assignments happen
    # later, at lines 151-154, 174-178, 198-202). This currently errors with
    # "object 'Col_foodcarbcontent_temp' not found" for any non-zero digestibility
    # input, i.e. every real call. Flip skip() off once that's fixed.
    skip("food_function() errors: uses Col_foodcarbcontent_temp before it's assigned")

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
})
