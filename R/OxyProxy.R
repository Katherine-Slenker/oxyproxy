#' Plots estimates of oxygen-18 enrichment of animal bodywater based on
#' flux of oxygen input and outputs against variables input by user.
#'
#' This function combines the Species, Food, Environment, Inputs, and Ouputs,
#' and d18Obodywater functions to generate plots of estimates of oxygen-18
#' enrichment of animal bodywater against variables input by user.
#'
#' @param model_bodymass Numeric. Body mass in kg. Must be greater than 0.
#' @param model_WaterEconomyIndex Numeric. Water economy index (ml/kJ).
#' @param model_Digestibility_of_food Numeric. Digestible organic matter as a
#'   proportion of ingested matter, between 0 and 1.
#' @param model_Carbohydrate_Content Numeric. Proportion of carbohydrate in the
#'   diet. Carbohydrate, protein, and fat content must sum to 1.
#' @param model_Protein_Content Numeric. Proportion of protein in the diet.
#' @param model_Fat_Content Numeric. Proportion of fat in the diet.
#' @param model_Free_Water_Content_Food Numeric. Proportion of free water in food.
#' @param model_air_temperature Numeric. Air temperature in deg C. Zero and
#'   negative values are valid.
#' @param model_Relative_Humidity Numeric. Relative humidity as a proportion
#'   between 0 and 1.
#' @param model_d18O_surfacewater Numeric. d18O of local surface water
#'   (per mil VSMOW). Zero and negative values are valid.
#' @param changeConstant Logical. If TRUE, prompts for values overriding the
#'   model constants. Defaults to FALSE.
#' @param sweating_species Logical. Whether the species sweats. Defaults to FALSE.
#' @param PlotRange Logical. If TRUE, plots d18Obw against any argument given
#'   more than one value. Defaults to TRUE.
#'
#' @return Data frame of d18Obw, d18Ophos, and d18Ocarb estimates for every
#'   combination of the supplied arguments.
#'
#' @examples
#' # Single set of parameters for a herbivore
#' oxy_proxy_function(
#'   model_bodymass = 600,
#'   model_WaterEconomyIndex = 0.4,
#'   model_Digestibility_of_food = 0.6,
#'   model_Carbohydrate_Content = 0.8,
#'   model_Protein_Content = 0.1,
#'   model_Fat_Content = 0.1,
#'   model_Free_Water_Content_Food = 0.55,
#'   model_air_temperature = 4,
#'   model_Relative_Humidity = 0.67,
#'   model_d18O_surfacewater = -10,
#'   sweating_species = FALSE,
#'   PlotRange = FALSE
#' )
#'
#' @export
oxy_proxy_function <- function(model_bodymass = 0, model_WaterEconomyIndex = 0, model_Digestibility_of_food = 0,
                               model_Carbohydrate_Content = 0, model_Protein_Content= 0,
                               model_Fat_Content = 0, model_Free_Water_Content_Food = 0, model_air_temperature= 0,
                               model_Relative_Humidity = 0, model_d18O_surfacewater= 0, changeConstant = FALSE, sweating_species = FALSE, PlotRange = TRUE)
{

  ##Species
  OS <- species_function(body_mass = model_bodymass, water_economy_index = model_WaterEconomyIndex, changeConstant = changeConstant)

  ## Food
  OF <- food_function(digestibility_of_food = model_Digestibility_of_food, Carbohydrate_Content = model_Carbohydrate_Content, Protein_Content = model_Protein_Content,
                      Fat_Content = model_Fat_Content, Free_Water_Content_Food = model_Free_Water_Content_Food, changeConstant = changeConstant)

  ## Environment
  OE <- environment_function(air_temperature = model_air_temperature, relative_humidity = model_Relative_Humidity, d18O_surface_water = model_d18O_surfacewater)

  ## Oxygen Inputs
  OI <- input_function(species = OS, food = OF, environment = OE)

  ## Oxygen Outputs
  OO <- outputs_function(inputs = OI, sweating_species = sweating_species)

  ##d18O values
  d18O <- d18_obw_function(outputs = OO)

  ### Priting default plots if arguments are ranges of values (i.e. more than 1 value in any argument) ==========
  if(PlotRange == TRUE & nrow(d18O) > 1)
  {
    if(length(model_bodymass) > 1)
    {
      plot(d18O$d18Obw~d18O$Bodymass, xlab = "Body mass (in Kg)", ylab = "d18O body water", pch = 16)
    }
    if(length(model_WaterEconomyIndex) > 1)
    {
      plot(d18O$d18Obw~d18O$WEI, xlab = "Water Economy Index", ylab = "d18O body water", pch = 16)
    }
    if(length(model_Digestibility_of_food) > 1)
    {
      plot(d18O$d18Obw~d18O$Digestibility, xlab = "Digestibility", ylab = "d18O body water", pch = 16)
    }
    if(length(model_Carbohydrate_Content) > 1)
    {
      plot(d18O$d18Obw~d18O$foodcarbcontent, xlab = "Carbohydrate content in food", ylab = "d18O body water", pch = 16)
    }
    if(length(model_Protein_Content) > 1)
    {
      plot(d18O$d18Obw~d18O$foodproteincontent, xlab = "Protein content in food", ylab = "d18O body water", pch = 16)
    }
    if(length(model_Fat_Content) > 1)
    {
      plot(d18O$d18Obw~d18O$foodfatcontent, xlab = "Fat content in food", ylab = "d18O body water", pch = 16)
    }
    if(length(model_Free_Water_Content_Food) > 1)
    {
      plot(d18O$d18Obw~d18O$freeH20food, xlab = "Free water content in food", ylab = "d18O body water", pch = 16)
    }
    if(length(model_air_temperature) > 1)
    {
      plot(d18O$d18Obw~d18O$airtemp, xlab = "Air temperature", ylab = "d18O body water", pch = 16)
    }
    if(length(model_Relative_Humidity) > 1)
    {
      plot(d18O$d18Obw~d18O$Humidity, xlab = "Humidity", ylab = "d18O body water", pch = 16)
    }
    if(length(model_d18O_surfacewater) > 1)
    {
      plot(d18O$d18Obw~d18O$d18Osw, xlab = "d18 O surface water", ylab = "d18O body water", pch = 16)
    }
  }

  #Output of Oxy Proxy Function ========
  return(d18O)
}
