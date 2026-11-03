#' Convert values of oxygen-18 enrichment found within samples of
#' the carbonate (CO3) component of animal tooth enamel to analogous values
#' representing isotopic enrichment of animal body water.
#'
#' This function converts measurements of the oxygen-18 enrichment of animal
#' enamel-carbonate to enamel-phosphate and body water.
#'
#' @param d18O_carbonate Numeric. Oxygen-18 enrichment within the carbonate (CO3)
#' component of enamel bioapatite.(per mil VPDB)
#' @return Data frame with estimated d18Oenamel-phosphate, and d18Obw values.
#'
#' @examples
#' # Example for a herbivore

#' # Calculate outputs for d18O enamel-phosphate and body water
#' herbivore_d18Oenamel <- d18O_enamel(d18O_carbonate = 26)
#'
#'
#'
#' @export
## Set d18Oenamel function
d18O_enamel <- function(d18O_carbonate = numeric(0)) {
  # FILLING DATAFRAME WITH ARGUMENTS VALUES
  # d18Ocarbonate
  if (length(d18O_carbonate) == 0) {
    stop("Enter d18Ocarbonate value")
  }
  d18Ocarbonate <- d18O_carbonate

  ## 1. d18Ophosphate and d18Obodywater calculation==============================

  # d18Ophosphate <- d18Oc - 8.5
  d18Ophosphate <- d18Ocarbonate - CARBONATE_PHOSPHATE_OFFSET

  # d18Obodywater <- d18Ophosphate + (37/4.38) - 25.9
  d18Obodywater <- d18Ophosphate + PHOSPHATE_WATER_OFFSET - PHOSPHATE_WATER_INTERCEPT

  data.frame(d18Ocarbonate, d18Ophosphate, d18Obodywater, row.names = NULL)
}
