# Convert values of oxygen-18 enrichment found within samples of the carbonate (CO3) component of animal tooth enamel to analogous values representing isotopic enrichment of animal body water.

This function converts measurements of the oxygen-18 enrichment of
animal enamel-carbonate to enamel-phosphate and body water.

## Usage

``` r
d18O_enamel(d18O_carbonate = numeric(0))
```

## Arguments

- d18O_carbonate:

  Numeric. Oxygen-18 enrichment within the carbonate (CO3) component of
  enamel bioapatite.(per mil VPDB)

## Value

Data frame with estimated d18Oenamel-phosphate, and d18Obw values.

## Examples

``` r
# Example for a herbivore
# Calculate outputs for d18O enamel-phosphate and body water
herbivore_d18Oenamel <- d18O_enamel(d18O_carbonate = 26)


```
