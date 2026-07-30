#' Plots estimated values of relative humidity converted from measurements of
#' d18Oenamel-carbonate.
#'
#' This function combines the RH_Estimation_d18O, Species, Food,
#' RH_Estimation_Environment, RH_Estimation_Inputs, and Outputs functions to
#' generate plots of estimates of relative humidity against measurements of
#' d18Oenamel-carbonate (converted to d18Obodywater) and variables input by user.
#'
#' @param sampled_d18Ocarbonate Numeric. Measured d18O of enamel carbonate
#'   (per mil VSMOW).
#' @param model_air_temperature Numeric. Air temperature in deg C. Enter 0 to
#'   have the model substitute a range of simulated values.
#' @param model_d18O_Surfacewater Numeric. d18O of local surface water
#'   (per mil VSMOW). Enter 0 to substitute simulated values.
#' @param model_Digestibility_of_food Numeric. Digestible organic matter as a
#'   proportion of ingested matter. Enter 0 to substitute simulated values.
#' @param model_Carbohydrate_Content Numeric. Proportion of carbohydrate in the diet.
#' @param model_Protein_Content Numeric. Proportion of protein in the diet.
#' @param model_Fat_Content Numeric. Proportion of fat in the diet.
#' @param model_Free_Water_Content_Food Numeric. Proportion of free water in food.
#' @param model_Body_mass Numeric. Body mass in kg.
#' @param model_WaterEconomyIndex Numeric. Water economy index (ml/kJ).
#' @param changeConstant Logical. If TRUE, prompts for values overriding the
#'   model constants. Defaults to FALSE.
#' @param sweating_species Logical. Whether the species sweats. Defaults to FALSE.
#' @param PlotRange Logical. If TRUE, plots relative humidity against any
#'   argument given more than one value. Defaults to TRUE.
#' @param printinfo Logical. If TRUE, prints the computed humidity values.
#'
#' @details
#' Any argument left at 0 is replaced with a range of simulated values. When
#' that happens the function reports which arguments were substituted, since
#' each one multiplies the number of rows in the result.
#'
#' @return Plots of estimates of relative humidity versus d18Obodywater values
#'  and user-input variables.
#'
#' @examples
#' # Estimate relative humidity from a measured enamel carbonate value
#' humidity_oxy_proxy(
#'   sampled_d18Ocarbonate = 20,
#'   model_air_temperature = 4,
#'   model_d18O_Surfacewater = -8,
#'   model_Digestibility_of_food = 0.6,
#'   model_Carbohydrate_Content = 0.8,
#'   model_Protein_Content = 0.15,
#'   model_Fat_Content = 0.05,
#'   model_Free_Water_Content_Food = 0.5,
#'   model_Body_mass = 500,
#'   model_WaterEconomyIndex = 0.4,
#'   PlotRange = FALSE
#' )
#'
#' @export
### Wrapper and final function for the "inverse function" dedicated to the computation of humidity from d18C
### This function wrap the modified (Environment, Inputs, Outputs) and base functions (Food, Species)
### as well as two originals functions dedicated to Humidity (last layer) and d180enamel (first layer) computation


humidity_oxy_proxy <- function(sampled_d18Ocarbonate = 0, model_air_temperature = 0, model_d18O_Surfacewater = 0,
                               model_Digestibility_of_food = 0, model_Carbohydrate_Content = 0, model_Protein_Content = 0,
                               model_Fat_Content = 0, model_Free_Water_Content_Food = 0, model_Body_mass = 0,
                               model_WaterEconomyIndex = 0, changeConstant = FALSE, sweating_species = FALSE, PlotRange = TRUE, printinfo = FALSE) {
  ### First layer : d180 Enamel ==================================================
  d18Result <- d18O_enamel(d18O_carbonate = sampled_d18Ocarbonate)

  #### Second layer : Species, Food and mod_environment ==========================
  message("WARNING : If you are missing information about species, food or environment and you struggle to fill the arguments values,
         oxyproxy package can try a wide range of simulated values for you. Enter 0 -zero- in the argument you want the model to inject simulated values")

  # Names of the arguments the model filled in for the caller, reported below.
  substituted <- character(0)

  # Environment function modified from the base version to exclude any calculation based on Humidity
  if (length(model_air_temperature) == 1 && model_air_temperature[1] == 0) {
    model_air_temperature <- c(-40, -30, -20, -10, 0, 10, 20, 30.40)
    substituted <- c(substituted, "model_air_temperature")
  }
  if (length(model_d18O_Surfacewater) == 1 && model_d18O_Surfacewater[1] == 0) {
    model_d18O_Surfacewater <- c(-1, -3, -5, -7, -9, -11, -13, -15, -17, -19, -21, -23, -25)
    substituted <- c(substituted, "model_d18O_Surfacewater")
  }

  OEM <- rh_estimation_environment_function(air_temperature = model_air_temperature, d18O_surface_water = model_d18O_Surfacewater)

  # Food function (unmodified from base function)
  if (length(model_Digestibility_of_food) == 1 && model_Digestibility_of_food[1] == 0) {
    model_Digestibility_of_food <- c(0.3, 0.4, 0.5, 0.6, 0.7)
    substituted <- c(substituted, "model_Digestibility_of_food")
  }
  if (length(model_Carbohydrate_Content) == 1 && model_Carbohydrate_Content[1] == 0) {
    model_Carbohydrate_Content <- c(0.7)
    substituted <- c(substituted, "model_Carbohydrate_Content")
  }
  if (length(model_Protein_Content) == 1 && model_Protein_Content[1] == 0) {
    model_Protein_Content <- c(0.2)
    substituted <- c(substituted, "model_Protein_Content")
  }
  if (length(model_Fat_Content) == 1 && model_Fat_Content[1] == 0) {
    model_Fat_Content <- c(0.1)
    substituted <- c(substituted, "model_Fat_Content")
  }
  if (length(model_Free_Water_Content_Food) == 1 && model_Free_Water_Content_Food[1] == 0) {
    model_Free_Water_Content_Food <- c(0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
    substituted <- c(substituted, "model_Free_Water_Content_Food")
  }

  OF <- food_function(
    digestibility_of_food = model_Digestibility_of_food, Carbohydrate_Content = model_Carbohydrate_Content,
    Protein_Content = model_Protein_Content, Fat_Content = model_Fat_Content, Free_Water_Content_Food = model_Free_Water_Content_Food,
    changeConstant = FALSE
  )

  # Species function (unmofidied from base function)
  if (length(model_Body_mass) == 1 && model_Body_mass[1] == 0) {
    model_Body_mass <- c(10, 50, 100, 200, 500, 1000, 1500)
    substituted <- c(substituted, "model_Body_mass")
  }
  if (length(model_WaterEconomyIndex) == 1 && model_WaterEconomyIndex[1] == 0) {
    model_WaterEconomyIndex <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6)
    substituted <- c(substituted, "model_WaterEconomyIndex")
  }

  if (length(substituted) > 0) {
    message(
      "Simulated value ranges substituted for ", length(substituted), " argument(s): ",
      paste(substituted, collapse = ", ")
    )
  }

  OS <- species_function(body_mass = model_Body_mass, water_economy_index = model_WaterEconomyIndex, changeConstant = FALSE)

  ### Third layer : Inputs fed with first layer values then Inputs results are used in Outputs function ========
  # What is going in (e.g. drinking water, food, leaf water content, etc...)
  OI <- inverse_input_function(species = OS, food = OF, environment = OEM)

  # What is going out (e.g. feces, pee, sweat, etc...)
  OOM <- outputs_function(inputs = OI, sweating_species = sweating_species)

  ### Final layer : Computation of the relative humidity =========================
  RH <- rh_function(rh_estimation_d18O = d18Result, outputs = OOM, printinfo = printinfo)

  ### Potential plots if PlotRange == TRUE =======================================
  if (isTRUE(PlotRange) && nrow(RH) > 1) {
    message("Variables with more than one values are compared to relative humidity, all plots can be redone and improved from function outputs")
    if (length(model_Body_mass) > 1) {
      plot(RH$Humidity * 100 ~ RH$Bodymass, xlab = "Body mass (in Kg)", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_WaterEconomyIndex) > 1) {
      plot(RH$Humidity * 100 ~ RH$WEI, xlab = "Water Economy Index", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_Digestibility_of_food) > 1) {
      plot(RH$Humidity * 100 ~ RH$Digestibility, xlab = "Digestibility", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_Carbohydrate_Content) > 1) {
      plot(RH$Humidity * 100 ~ RH$foodcarbcontent, xlab = "Carbohydrate content in food", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_Protein_Content) > 1) {
      plot(RH$Humidity * 100 ~ RH$foodproteincontent, xlab = "Protein content in food", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_Fat_Content) > 1) {
      plot(RH$Humidity * 100 ~ RH$foodfatcontent, xlab = "Fat content in food", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_Free_Water_Content_Food) > 1) {
      plot(RH$Humidity * 100 ~ RH$freeH20food, xlab = "Free water content in food", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_air_temperature) > 1) {
      plot(RH$Humidity * 100 ~ RH$airtemp, xlab = "Air temperature", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(model_d18O_Surfacewater) > 1) {
      plot(RH$Humidity * 100 ~ RH$d18Osw, xlab = "d18 O surface water", ylab = "Relative Humidity (%)", pch = 16)
    }
    if (length(sampled_d18Ocarbonate) > 1) {
      plot(RH$Humidity * 100 ~ RH$d18Ocarbonate, xlab = "d18 O Carbonate", ylab = "Relative Humidity (%)", pch = 16)
    }
  }

  # Return of the wrapper function, large dataset could be returned ===============
  return(RH)
}
