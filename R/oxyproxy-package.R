#' @keywords internal
#'
#' @details
#' oxyproxy implements the steady-state mass balance model of oxygen flux in
#' animal body water from Kohn (1996), and runs it in both directions.
#'
#' **Forward: physiology and environment to d18Obw.** Given body mass, water
#' economy index, diet composition, air temperature, relative humidity, and
#' d18O of surface water, estimate the oxygen-18 enrichment of body water,
#' enamel phosphate, and enamel carbonate. Use [OxyProxy()], or call
#' the stages individually via [Species()], [Food()],
#' [Environment()], [Inputs()], [Outputs()] and
#' [d18Obw_Estimation()].
#'
#' **Inverse: measured enamel to relative humidity.** Given a measured d18O of
#' enamel carbonate plus the same physiological and dietary parameters, recover
#' the relative humidity consistent with it. Use [RH_Estimation_OxyProxy()], or the
#' stages [RH_Estimation_d18O()], [RH_Estimation_Environment()],
#' [RH_Estimation_Inputs()] and [RH_Estimation()].
#'
#' Any argument accepts a vector, in which case the model is evaluated over
#' every combination of the supplied values.
#'
#' @examples
#' # Forward: estimate d18O body water for a herbivore
#' OxyProxy(
#'   model_bodymass = 30, model_WaterEconomyIndex = 0.25,
#'   model_Carbohydrate_Content = 0.85, model_Protein_Content = 0.1,
#'   model_Fat_Content = 0.05, model_Digestibility_of_food = 0.7,
#'   model_Free_Water_Content_Food = 0.65, model_air_temperature = 15,
#'   model_Relative_Humidity = 0.75, model_d18O_surfacewater = -3.25,
#'   PlotRange = FALSE
#' )
#'
#' # Inverse: recover relative humidity from the enamel carbonate value
#' RH_Estimation_OxyProxy(
#'   sampled_d18Ocarbonate = 26.053638,
#'   model_air_temperature = 15, model_d18O_Surfacewater = -3.25,
#'   model_Digestibility_of_food = 0.7, model_Carbohydrate_Content = 0.85,
#'   model_Protein_Content = 0.1, model_Fat_Content = 0.05,
#'   model_Free_Water_Content_Food = 0.65, model_Body_mass = 30,
#'   model_WaterEconomyIndex = 0.25, PlotRange = FALSE
#' )
"_PACKAGE"
