# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# Extracts the mean of the pixels from brick within the borders (polygons).
# colname refers to the name to give the values in the returned data frame.
# years is the years that the brick contains, in a numeric vector.
# Other parameters are passed to reshape.
# The output is also saved into output/dataframes/colname.csv by default.
ExtractWithinBorders = function(brick, borders, colname, years, filename="", idvar="Municipality", overwrite=FALSE, ...)
{
    if (filename == "")
        filename = paste("output/dataframes/", colname, ".csv", sep="")
    if (!file.exists(filename) || overwrite)
    {
        print(paste("Extracting data for", colname,"and saving it. This may take a few minutes."))
        # Extract information
        Extract = extract(brick, borders, fun=mean, df=TRUE, na.rm=TRUE)
        # Make Year into a column with multiple rows rather than a lot of columns in one row
        Extract = reshape(Extract, direction="long", varying=list(names(Extract)[2:(length(years)+1)]), v.names=colname, timevar="Year", idvar=idvar, times=years, ...)
        # Save into a CSV so it doesn't have to be recalculated
        write.table(Extract, file=filename)
    }
    else
        Extract = read.table(filename)
    return(Extract)
}
