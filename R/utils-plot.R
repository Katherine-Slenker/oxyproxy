# x-axis labels for the wrapper range plots, keyed by the result column plotted
RANGE_PLOT_LABELS <- c(
  Bodymass = "Body mass (in Kg)",
  WEI = "Water Economy Index",
  Digestibility = "Digestibility",
  foodcarbcontent = "Carbohydrate content in food",
  foodproteincontent = "Protein content in food",
  foodfatcontent = "Fat content in food",
  freeH20food = "Free water content in food",
  airtemp = "Air temperature",
  Humidity = "Humidity",
  d18Osw = "d18 O surface water",
  d18Ocarbonate = "d18 O Carbonate"
)

#' Plot a wrapper's result against each argument given more than one value
#'
#' @param result Data frame returned by the wrapper
#' @param y Numeric vector for the y axis, one value per row of result
#' @param ylab Character. y-axis label
#' @param arguments Named list of the wrapper's arguments, each named after the
#'   result column it fills. Plots are drawn in list order.
#' @keywords internal
plot_varied_arguments <- function(result, y, ylab, arguments) {
  for (column in names(arguments)) {
    if (length(arguments[[column]]) > 1) {
      plot(y ~ result[[column]], xlab = RANGE_PLOT_LABELS[[column]], ylab = ylab, pch = 16)
    }
  }
}
