describe("with_column()", {
  it("adds a new column computed from the whole data frame", {
    df <- data.frame(x = c(1, 2, 3))
    out <- with_column(df, "y", function(d) d$x * 2)

    expect_equal(out$y, c(2, 4, 6))
    expect_equal(out$x, df$x)
  })

  it("overwrites an existing column of the same name", {
    df <- data.frame(x = c(1, 2), y = c(0, 0))
    out <- with_column(df, "y", function(d) d$x + 10)

    expect_equal(out$y, c(11, 12))
  })

  it("is pipeable, matching how Inputs/Outputs functions chain it", {
    df <- data.frame(x = 1:3)
    out <- df |>
      with_column("y", function(d) d$x * 2) |>
      with_column("z", function(d) d$y + 1)

    expect_equal(out$z, c(3, 5, 7))
  })
})

describe("combine_inputs()", {
  it("builds the full factorial cross of species x food x environment", {
    species <- data.frame(body_mass = c(10, 20))
    food <- data.frame(digestibility = 0.6)
    environment <- data.frame(air_temperature = c(0, 10, 20))

    out <- combine_inputs(species, food, environment)

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 2 * 1 * 3)
  })

  it("errors if any argument isn't a data frame", {
    expect_error(combine_inputs(list(a = 1), data.frame(x = 1), data.frame(x = 1)))
  })
})
