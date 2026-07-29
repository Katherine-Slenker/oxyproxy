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

  it("errors when d18O_carbonate is left at its default of 0", {
    expect_error(d18O_enamel(), "d18Ocarbonate")
  })
})
