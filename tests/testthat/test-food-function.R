describe("food_function()", {
  it("returns one row with the documented columns for a valid herbivore diet", {
    # BUG: Col_foodcarbcontent_temp/Col_foodproteincontent_temp/
    # Col_foodfatcontent_temp (R/FoodFunction.R) are used before they're
    # assigned, so any non-zero digestibility input errors.
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
