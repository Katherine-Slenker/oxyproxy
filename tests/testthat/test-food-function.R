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

  it("errors when Free_Water_Content_Food is omitted", {
    expect_error(
      food_function(digestibility_of_food = 0.6, Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1),
      "Free Water Content"
    )
  })

  it("errors when digestibility_of_food is omitted", {
    expect_error(
      food_function(Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4),
      "Digestibility"
    )
  })

  it("errors when digestibility_of_food is zero or negative", {
    expect_error(
      food_function(digestibility_of_food = 0, Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4),
      "Digestibility"
    )
    expect_error(
      food_function(digestibility_of_food = -0.5, Carbohydrate_Content = 0.8, Protein_Content = 0.1, Fat_Content = 0.1, Free_Water_Content_Food = 0.4),
      "Digestibility"
    )
  })

  it("accepts a zero-fat diet (a real dietary composition)", {
    out <- food_function(
      digestibility_of_food = 0.6, Carbohydrate_Content = 0.9, Protein_Content = 0.1,
      Fat_Content = 0, Free_Water_Content_Food = 0.4
    )
    expect_equal(out$foodfatcontent, 0)
  })

  it("accepts a zero-carbohydrate diet (obligate carnivore)", {
    out <- food_function(
      digestibility_of_food = 0.85, Carbohydrate_Content = 0, Protein_Content = 0.7,
      Fat_Content = 0.3, Free_Water_Content_Food = 0.7
    )
    expect_equal(out$foodcarbcontent, 0)
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

})

describe("food_function() proportion bounds", {
  valid <- function(...) {
    utils::modifyList(
      list(
        digestibility_of_food = 0.6, Carbohydrate_Content = 0.8,
        Protein_Content = 0.1, Fat_Content = 0.1,
        Free_Water_Content_Food = 0.4, changeConstant = FALSE
      ),
      list(...)
    )
  }

  it("rejects negative macronutrient and water contents", {
    expect_error(do.call(food_function, valid(Carbohydrate_Content = -0.5)), "between 0 and 1")
    expect_error(do.call(food_function, valid(Protein_Content = -0.1)), "between 0 and 1")
    expect_error(do.call(food_function, valid(Fat_Content = -0.1)), "between 0 and 1")
    expect_error(do.call(food_function, valid(Free_Water_Content_Food = -0.5)), "between 0 and 1")
  })

  it("rejects proportions above 1", {
    expect_error(do.call(food_function, valid(Carbohydrate_Content = 1.5)), "between 0 and 1")
    expect_error(do.call(food_function, valid(Free_Water_Content_Food = 1.5)), "between 0 and 1")
    expect_error(do.call(food_function, valid(digestibility_of_food = 1.5)), "0-1")
  })

  it("still accepts zero for macronutrients and free water", {
    # A zero-fat diet and completely dry food are both physically real.
    expect_no_error(suppressMessages(do.call(food_function, valid(Fat_Content = 0))))
    expect_no_error(suppressMessages(do.call(food_function, valid(Free_Water_Content_Food = 0))))
  })
})
