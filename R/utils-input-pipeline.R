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
#' @param order Character. The three inputs from fastest- to slowest-varying.
#'   Columns are always returned species, then food, then environment.
#' @param check.names Passed to [data.frame()]
#' @return Data frame with all input combinations
#' @keywords internal
combine_inputs <- function(species, food, environment,
                           order = c("species", "food", "environment"), check.names = TRUE) {
  stopifnot(is.data.frame(species), is.data.frame(food), is.data.frame(environment))

  frames <- list(species = species, food = food, environment = environment)
  stopifnot(setequal(order, names(frames)), length(order) == 3)
  combinations <- expand.grid(lapply(frames[order], function(frame) seq_len(nrow(frame))))

  data.frame(
    take_rows(species, combinations$species),
    take_rows(food, combinations$food),
    take_rows(environment, combinations$environment),
    row.names = NULL,
    check.names = check.names
  )
}

#' Select rows of a data frame by index, column by column
#'
#' Same values as `df[rows, , drop = FALSE]`, but skips building unique row
#' names for repeated indices, which is most of that call's cost on large grids.
#'
#' @param df Data frame to select from
#' @param rows Integer row indices, repeats allowed
#' @return Data frame with default row names
#' @keywords internal
take_rows <- function(df, rows) {
  # Matrix and data-frame columns need whole rows, not single elements
  columns <- lapply(df, function(column) {
    if (is.null(dim(column))) column[rows] else column[rows, , drop = FALSE]
  })
  structure(columns, names = names(df), row.names = .set_row_names(length(rows)), class = "data.frame")
}

#' Merge two data frames, with a fast path for cross joins
#'
#' Same result as `merge(x, y)`. When both are data frames with no column names
#' in common, merge() is a plain cross join (every row of `x` paired with every
#' row of `y`, `x` varying fastest), which this builds directly instead of
#' paying for merge()'s row-name work. Anything else goes to merge().
#'
#' @param x,y Data frames, or anything merge() accepts
#' @return Data frame, as from merge()
#' @keywords internal
fast_merge <- function(x, y) {
  if (!is.data.frame(x) || !is.data.frame(y) || length(intersect(names(x), names(y))) > 0) {
    return(merge(x, y))
  }
  data.frame(
    take_rows(x, rep.int(seq_len(nrow(x)), nrow(y))),
    take_rows(y, rep(seq_len(nrow(y)), each = nrow(x))),
    row.names = NULL,
    check.names = FALSE
  )
}
