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
#'   substitute the Herbivore Standard value.
#' @param model_d18O_Surfacewater Numeric. d18O of local surface water
#'   (per mil VSMOW). Enter 0 to substitute the Herbivore Standard value.
#' @param model_Digestibility_of_food Numeric. Digestible organic matter as a
#'   proportion of ingested matter, greater than 0 and at most 1. Enter 0 to
#'   substitute the Herbivore Standard value.
#' @param model_Carbohydrate_Content Numeric. Proportion of carbohydrate in the
#'   diet, between 0 and 1.
#' @param model_Protein_Content Numeric. Proportion of protein in the diet,
#'   between 0 and 1.
#' @param model_Fat_Content Numeric. Proportion of fat in the diet, between
#'   0 and 1.
#' @param model_Free_Water_Content_Food Numeric. Proportion of free water in
#'   food, between 0 and 1.
#' @param model_Body_mass Numeric. Body mass in kg. Must be greater than 0.
#' @param model_WaterEconomyIndex Numeric. Water economy index (ml/kJ). Must be
#'   greater than 0; values between 0.05 and 0.6 are typical.
#' @param changeConstant Logical. If TRUE, prompts for values overriding the
#'   model constants. Defaults to FALSE.
#' @param sweating_species Logical. Whether the species sweats. Defaults to FALSE.
#' @param PlotRange Logical. If TRUE, plots relative humidity against any
#'   argument given more than one value. Defaults to TRUE.
#' @param printinfo Logical. If TRUE, prints the computed humidity values.
#'
#' @details
#' Any argument left at 0 is replaced with the corresponding Herbivore Standard
#' value, a self-consistent reference animal: body mass 30 kg, WEI 0.25,
#' carbohydrate 0.85, protein 0.1, fat 0.05, digestibility 0.7, free water
#' content of food 0.65, air temperature 15 deg C, d18Osw -3.25 per mil. The
#' function reports which arguments it substituted.
#'
#' The standard also fixes a relative humidity of 0.75. Running
#' [oxy_proxy_function()] on the same parameters and feeding the resulting
#' d18Ocarb back through this function recovers that value.
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

humidity_oxy_proxy <- function(sampled_d18Ocarbonate = 0, model_air_temperature = 0, model_d18O_Surfacewater = 0,
                               model_Digestibility_of_food = 0, model_Carbohydrate_Content = 0, model_Protein_Content = 0,
                               model_Fat_Content = 0, model_Free_Water_Content_Food = 0, model_Body_mass = 0,
                               model_WaterEconomyIndex = 0, changeConstant = FALSE, sweating_species = FALSE, PlotRange = TRUE, printinfo = FALSE) {
  d18Result <- d18O_enamel(d18O_carbonate = sampled_d18Ocarbonate)

  message("NOTE : If you are missing information about species, food or environment, enter 0 -zero- for that argument
         and oxyproxy will substitute the corresponding Herbivore Standard value.")

  substituted <- character(0)

  # Environment function modified from the base version to exclude any calculation based on Humidity
  if (length(model_air_temperature) == 1 && model_air_temperature[1] == 0) {
    model_air_temperature <- 15
    substituted <- c(substituted, "model_air_temperature")
  }
  if (length(model_d18O_Surfacewater) == 1 && model_d18O_Surfacewater[1] == 0) {
    model_d18O_Surfacewater <- -3.25
    substituted <- c(substituted, "model_d18O_Surfacewater")
  }

  OEM <- rh_estimation_environment_function(air_temperature = model_air_temperature, d18O_surface_water = model_d18O_Surfacewater)

  if (length(model_Digestibility_of_food) == 1 && model_Digestibility_of_food[1] == 0) {
    model_Digestibility_of_food <- 0.7
    substituted <- c(substituted, "model_Digestibility_of_food")
  }
  if (length(model_Carbohydrate_Content) == 1 && model_Carbohydrate_Content[1] == 0) {
    model_Carbohydrate_Content <- 0.85
    substituted <- c(substituted, "model_Carbohydrate_Content")
  }
  if (length(model_Protein_Content) == 1 && model_Protein_Content[1] == 0) {
    model_Protein_Content <- 0.1
    substituted <- c(substituted, "model_Protein_Content")
  }
  if (length(model_Fat_Content) == 1 && model_Fat_Content[1] == 0) {
    model_Fat_Content <- 0.05
    substituted <- c(substituted, "model_Fat_Content")
  }
  if (length(model_Free_Water_Content_Food) == 1 && model_Free_Water_Content_Food[1] == 0) {
    model_Free_Water_Content_Food <- 0.65
    substituted <- c(substituted, "model_Free_Water_Content_Food")
  }

  OF <- food_function(
    digestibility_of_food = model_Digestibility_of_food, Carbohydrate_Content = model_Carbohydrate_Content,
    Protein_Content = model_Protein_Content, Fat_Content = model_Fat_Content, Free_Water_Content_Food = model_Free_Water_Content_Food,
    changeConstant = FALSE
  )

  if (length(model_Body_mass) == 1 && model_Body_mass[1] == 0) {
    model_Body_mass <- 30
    substituted <- c(substituted, "model_Body_mass")
  }
  if (length(model_WaterEconomyIndex) == 1 && model_WaterEconomyIndex[1] == 0) {
    model_WaterEconomyIndex <- 0.25
    substituted <- c(substituted, "model_WaterEconomyIndex")
  }

  if (length(substituted) > 0) {
    message(
      "Herbivore Standard values substituted for ", length(substituted), " argument(s): ",
      paste(substituted, collapse = ", ")
    )
  }

  OS <- species_function(body_mass = model_Body_mass, water_economy_index = model_WaterEconomyIndex, changeConstant = FALSE)

  OI <- inverse_input_function(species = OS, food = OF, environment = OEM)

  OOM <- outputs_function(inputs = OI, sweating_species = sweating_species)

  RH <- rh_function(rh_estimation_d18O = d18Result, outputs = OOM, printinfo = printinfo)

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

  return(RH)
}
