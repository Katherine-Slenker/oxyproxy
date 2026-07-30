# Changelog

## oxyproxy 0.1.0

First release.

If you were running the development version from GitHub, three things
changed that will break existing scripts:

- Wrapper arguments now match the manuscript:
  `model_digestibility_of_food` became `model_Digestibility_of_food`,
  `SweatingSpecies` became `sweating_species`, and
  `model_Air_temperature` became `model_air_temperature`.

- Only the 12 documented functions are exported. Internal helpers such
  as
  [`with_column()`](https://katherine-slenker.github.io/oxyproxy/reference/with_column.md),
  [`combine_inputs()`](https://katherine-slenker.github.io/oxyproxy/reference/combine_inputs.md)
  and the `calculate_*` family are no longer part of the public API.

- [`humidity_oxy_proxy()`](https://katherine-slenker.github.io/oxyproxy/reference/humidity_oxy_proxy.md)
  substitutes the Herbivore Standard reference animal for any argument
  left at 0, rather than a range of simulated values. The all-defaults
  call returns one row instead of 131,040.
