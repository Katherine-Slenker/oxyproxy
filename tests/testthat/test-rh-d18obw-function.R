describe("d18O_enamel()", {
  it("returns one row with the documented columns", {
    out <- d18O_enamel(d18O_carbonate = 26)

    expect_s3_class(out, "data.frame")
    expect_equal(nrow(out), 1)
    expect_true(all(c("d18Ocarbonate", "d18Ophosphate", "d18Obodywater") %in% names(out)))
  })

  it("derives d18Ophosphate and d18Obodywater via the documented fixed offsets", {
    out <- d18O_enamel(d18O_carbonate = 26)
    expect_equal(out$d18Ophosphate, 26 - 8.5)
    expect_equal(out$d18Obodywater, out$d18Ophosphate + 37 / 4.38 - 25.9)
  })

  it("errors when d18O_carbonate is omitted", {
    expect_error(d18O_enamel(), "d18Ocarbonate")
  })

  it("accepts an explicit d18O_carbonate of 0 (a valid value)", {
    out <- d18O_enamel(d18O_carbonate = 0)
    expect_equal(out$d18Ocarbonate, 0)
    expect_equal(out$d18Ophosphate, -8.5)
  })

  it("accepts a seq() whose values sum to zero", {
    vals <- seq(-8, 8, by = 4)
    expect_equal(sum(vals), 0)
    out <- d18O_enamel(d18O_carbonate = vals)
    expect_equal(nrow(out), length(vals))
  })

  it("accepts negative d18O_carbonate values (physically normal)", {
    out <- d18O_enamel(d18O_carbonate = -15)
    expect_equal(out$d18Ophosphate, -15 - 8.5)
  })

  it("handles a vector of values, one row each", {
    out <- d18O_enamel(d18O_carbonate = c(20, 26, 30))
    expect_equal(nrow(out), 3)
    expect_equal(out$d18Ocarbonate, c(20, 26, 30))
  })
})
