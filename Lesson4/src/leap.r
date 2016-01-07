# Leap year calculator functions
# Author: Dainius Masiliunas, team Rython
# License: Apache License 2.0

# Calculates whether the year entered is a leap year or not.
is.leap = function(year)
{
    input = year

    # If characters, try coercing into a numeric
    if (is.character(year))
        year = suppressWarnings(as.numeric(year))
        
    # Sanity checks
    if (!is.numeric(year))
        stop("Error: argument of class numeric expected")
    if (is.na(year))
    {
        # If it's NA, then it might be due to the user entering NA or a failed coercion; but it could be a date
        year = try(as.numeric(strsplit(input, " ")[[1]][6]), TRUE)
        if (!is.numeric(year) || is.na(year) || class(year) == "try-error")
            stop("Error: failed to parse input argument")
    }
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
