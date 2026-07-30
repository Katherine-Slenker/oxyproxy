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

#'# Calculate outputs for d18O enamel-phosphate and body water
#' herbivore_d18Oenamel <- d18O_enamel(d18O_carbonate = 26)
#'
#'
#'
#' @export
##Set d18Oenamel function
d18O_enamel <- function(d18O_carbonate = numeric(0))
{
  ## 0. PREPPING DATAFRAME FOR OUTPUTS ===========================================
  # Width = number of variables
  # Length = number of combination of results
  DF_outputs <- matrix(data = 0, nrow = length(d18O_carbonate), ncol = 3)
  colnames(DF_outputs) <- c("d18Ocarbonate","d18Ophosphate","d18Obodywater")
  DF_outputs <- as.data.frame(DF_outputs)

  #FILLING DATAFRAME WITH ARGUMENTS VALUES
  # d18Ocarbonate
  if(length(d18O_carbonate)==0)
  {

    stop("Enter d18Ocarbonate value")
  }
  d18Oc<- d18O_carbonate
  DF_outputs$d18Ocarbonate <- d18O_carbonate

  ## 1. d18Ophosphate and d18Obodywater calculation==============================

  #d18Ophosphate <- d18Oc - 8.5
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$d18Ophosphate[i] <- DF_outputs$d18Ocarbonate[i] - 8.5}

  #d18Obodywater <- d18Ophosphate + (37/4.38) - 25.9
  for(i in 1:nrow(DF_outputs)){
    DF_outputs$d18Obodywater[i] <- DF_outputs$d18Ophosphate[i] + (37/4.38) - 25.9}



  return(DF_outputs)

}
