# oxyproxy 0.1.0

First release.

## Backward compatibility

* Restored `oxy_proxy_function()` and `humidity_oxy_proxy()`
  as deprecated compatibility wrappers for `OxyProxy()`
  and `RH_Estimation_OxyProxy()`, respectively.

* Legacy wrappers support previously used argument names
  and forward calls to the current implementations.

## Changes from the development version

* Wrapper arguments now match the manuscript:
  `model_digestibility_of_food` became
  `model_Digestibility_of_food`, `SweatingSpecies` became
  `sweating_species`, and `model_Air_temperature` became
  `model_air_temperature`.

* The 12 primary documented functions and two deprecated
  compatibility wrappers are exported. Internal helpers such as
  `with_column()`, `combine_inputs()` and the `calculate_*`
  family are no longer part of the public API.

* `RH_Estimation_OxyProxy()` substitutes the Herbivore Standard
  reference animal for any argument left at 0, rather than a
  range of simulated values. The all-defaults call returns
  one row instead of 131,040.