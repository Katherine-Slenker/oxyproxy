#' Add column to dataframe by applying function
#'
#' Helper function for pipeline calculations
#'
#' @param df Data frame to modify
#' @param column_name Character. Name of new column to add
#' @param func Function that takes a data frame and returns calculated values
#' @return Data frame with new column added
#' @keywords internal
with_column <- function(df, column_name, func) {
  df[[column_name]] <- func(df)
  df
}

#' Stop if a data frame is missing any required columns
#'
#' The error is reported as coming from the caller, not from this helper.
#'
#' @param df Data frame to check
#' @param required_cols Character vector of column names df must contain
#' @keywords internal
check_required_columns <- function(df, required_cols) {
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(simpleError(
      paste0("Missing required columns: ", paste(missing_cols, collapse = ", ")),
      call = sys.call(-1)
    ))
  }
}

#' Create combinations dataframe from Species, Food, and Environment inputs
#'
#' @param species Data frame with species parameters
#' @param food Data frame with food composition data
#' @param environment Data frame with environmental conditions
#' @return Data frame with all input combinations
#' @keywords internal
combine_inputs <- function(species, food, environment) {
  stopifnot(is.data.frame(species), is.data.frame(food), is.data.frame(environment))

  combinations <- expand.grid(
    species_row     = seq_len(nrow(species)),
    food_row        = seq_len(nrow(food)),
    environment_row = seq_len(nrow(environment))
  )

  data.frame(
    take_rows(species, combinations$species_row),
    take_rows(food, combinations$food_row),
    take_rows(environment, combinations$environment_row),
    row.names = NULL
  )
}

#' Select rows of a data frame by index, column by column
#'
#' Same values as `df[rows, , drop = FALSE]`, but skips building unique row
#' names for repeated indices, which is most of that call's cost on large grids.
#'
#' @param df Data frame to select from
#' @param rows Integer row indices, repeats allowed
#' @return Named list of columns, for passing to [data.frame()]
#' @keywords internal
take_rows <- function(df, rows) {
  lapply(df, `[`, rows)
}

#' Cross join two data frames that share no columns
#'
#' Same result as `merge(x, y)` with no common columns (every row of `x` paired
#' with every row of `y`, `x` varying fastest), without merge()'s row-name work.
#'
#' @param x,y Data frames with no column names in common
#' @return Data frame with nrow(x) * nrow(y) rows, columns of x then y
#' @keywords internal
cross_join <- function(x, y) {
  data.frame(
    take_rows(x, rep.int(seq_len(nrow(x)), nrow(y))),
    take_rows(y, rep(seq_len(nrow(y)), each = nrow(x))),
    row.names = NULL,
    check.names = FALSE
  )
}
