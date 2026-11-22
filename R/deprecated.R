# Translate previously supported argument names.
translate_legacy_args <- function(args) {
  mapping <- c(
    model_digestibility_of_food = "model_Digestibility_of_food",
    SweatingSpecies = "sweating_species",
    model_Air_temperature = "model_air_temperature"
  )

  for (old in names(mapping)) {
    new <- mapping[[old]]

    if (old %in% names(args)) {
      if (new %in% names(args)) {
        stop(
          "Cannot supply both ", old, " and ", new,
          call. = FALSE
        )
      }

      names(args)[names(args) == old] <- new
    }
  }

  args
}


#' Deprecated oxygen proxy wrapper
#'
#' Provides backward compatibility for scripts using the previous
#' oxygen proxy function name. Use OxyProxy() for new scripts.
#'
#' @param ... Arguments passed to OxyProxy().
#' @return The result returned by OxyProxy().
#' @seealso \code{\link{OxyProxy}}
#' @export
oxy_proxy_function <- function(...) {
  .Deprecated("OxyProxy")

  do.call(
    OxyProxy,
    translate_legacy_args(list(...))
  )
}


#' Deprecated relative humidity estimation wrapper
#'
#' Provides backward compatibility for scripts using the previous
#' relative humidity function name.
#' Use RH_Estimation_OxyProxy() for new scripts.
#'
#' @param ... Arguments passed to RH_Estimation_OxyProxy().
#' @return The result returned by RH_Estimation_OxyProxy().
#' @seealso \code{\link{RH_Estimation_OxyProxy}}
#' @export
humidity_oxy_proxy <- function(...) {
  .Deprecated("RH_Estimation_OxyProxy")

  do.call(
    RH_Estimation_OxyProxy,
    translate_legacy_args(list(...))
  )
}