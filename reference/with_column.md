# Add column to dataframe by applying function

Helper function for pipeline calculations

## Usage

``` r
with_column(df, column_name, func)
```

## Arguments

- df:

  Data frame to modify

- column_name:

  Character. Name of new column to add

- func:

  Function that takes a data frame and returns calculated values

## Value

Data frame with new column added
