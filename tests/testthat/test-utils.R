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
})

describe("combine_inputs()", {
  it("builds the full factorial cross of species x food x environment", {
    # Multi-column, matching real species_function()/food_function()/
    # environment_function() output (see next test for single-column inputs).
    species <- data.frame(body_mass = c(10, 20), foo = 1)
    food <- data.frame(digestibility = 0.6, bar = 1)
    environment <- data.frame(air_temperature = c(0, 10, 20), baz = 1)

    out <- combine_inputs(species, food, environment)

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 2 * 1 * 3)
    expect_true(all(c("body_mass", "digestibility", "air_temperature") %in% names(out)))
  })

  it("preserves column names when an input has exactly one column", {
    # Regression check: `df[rows, ]` without drop = FALSE collapses a
    # single-column data frame to a bare vector, which would otherwise get
    # named from the deparsed subsetting expression instead of kept as-is.
    species <- data.frame(body_mass = c(10, 20))
    food <- data.frame(digestibility = 0.6)
    environment <- data.frame(air_temperature = c(0, 10, 20))

    out <- combine_inputs(species, food, environment)

    expect_true(all(c("body_mass", "digestibility", "air_temperature") %in% names(out)))
  })

  it("errors if any argument isn't a data frame", {
    expect_error(combine_inputs(list(a = 1), data.frame(x = 1), data.frame(x = 1)))
  })

  it("selects whole rows of matrix columns", {
    species <- data.frame(id = 1:2)
    species$m <- matrix(1:4, nrow = 2)
    out <- combine_inputs(species, data.frame(digestibility = c(0.6, 0.7)), data.frame(air_temperature = 0))

    expect_equal(out$m, matrix(c(1, 2, 1, 2, 3, 4, 3, 4), nrow = 4))
  })

  it("varies the inputs in the requested order, keeping columns species, food, environment", {
    out <- combine_inputs(
      data.frame(s = 1:2), data.frame(f = 1:2), data.frame(e = 1:2),
      order = c("species", "environment", "food")
    )

    expect_equal(names(out), c("s", "f", "e"))
    expect_equal(out$s, rep(1:2, times = 4))
    expect_equal(out$e, rep(rep(1:2, each = 2), times = 2))
    expect_equal(out$f, rep(1:2, each = 4))
  })
})
