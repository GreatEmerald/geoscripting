# Leap year calculator
# Author: Dainius Masiliunas, team Rython
# Date: 7th of January, 2016
# License: Apache License 2.0

# Source functions
source("src/leap.r")

# Usage examples / unit tests
is.leap(2016) # TRUE
is.leap(2000.8) # TRUE: assuming only the integer is wanted
is.leap(1581) # FALSE with a warning
is.leap(2002) # FALSE
is.leap('john') # Error
is.leap(TRUE) # Error
is.leap(NA) # Error
is.leap("2000") # TRUE: coercing strings to integers
is.leap("2000.8") # TRUE: coercing and only using integers
is.leap(date()) # TRUE: parsing today's date() to get the year
