# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Calculate the Root Mean Squared Error
RMSE = function(truth, prediction)
{
    return(sqrt(mean((truth-prediction)^2, na.rm=TRUE)))
}
