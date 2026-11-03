# Model constants shared by more than one file. Constants used by a single
# file stay next to the code that uses them.

# Moles of water per kg, used by calculate_free_water_in_food() and
# calculate_fecal_water_loss()
MOLES_WATER_PER_KG <- 55.56

# Enamel conversion constants. d18_obw_function() applies them forward and
# d18O_enamel() in reverse.
# d18Ophosphate = d18Obw + 25.9 - 37 / 4.38
PHOSPHATE_WATER_INTERCEPT <- 25.9
PHOSPHATE_WATER_OFFSET <- 37 / 4.38
# d18Ocarbonate = d18Ophosphate + 8.5
CARBONATE_PHOSPHATE_OFFSET <- 8.5
