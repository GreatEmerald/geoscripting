# Leap year calculator
# Author: Dainius Masiliunas, team Rython
# License: Apache License 2.0

# Source functions
source("src/leap.r")

# Usage examples / unit tests
is.leap(2000) # TRUE
is.leap(2000.8) # TRUE
is.leap(1581) # FALSE with a warning
is.leap(2002) # FALSE
is.leap('john') # Error
is.leap(TRUE) # Error
is.leap("2000") # TRUE
is.leap("2000.8") # TRUE
