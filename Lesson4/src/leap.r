# Leap year calculator functions
# Author: Dainius Masiliunas, team Rython
# License: Apache License 2.0

# Calculates whether the year entered is a leap year or not.
is.leap = function(year)
{
    # If characters, try coercing into a numeric
    if (is.character(year))
        year = as.numeric(year)
        
    # Sanity checks
    if (is.numeric(year) == FALSE)
        stop("Error: argument of class numeric expected")
    if (is.na(year))
        stop("Error: argument cannot be NA")
    if (year < 1582)
        warning(paste(year, "is out of the valid range"))
    
    # Make sure input is integer
    year = floor(year)

    if (year %% 4 > 0)
        return(FALSE)
    else if (year %% 100 > 0)
        return(TRUE)
    else if (year %% 400 > 0)
        return(FALSE)
    return(TRUE)
}
