# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Creates a linear model and prints its summary, and (if desired) shows whether
# some covariates ought to be removed from the model, and a plot of residuals
lmValidation = function(..., printstep=FALSE, printplot=FALSE)
{
    LM = lm(...)
    print(summary(LM))
    if (printstep)
        step(LM)
    if (printplot)
        plot(LM)
    return(LM)
}

# Creates a prediction based on the model, clamps values to a given range, and
# if requested plots a histogram and/or a comparison plot between the layers
predictValidation = function(object, ..., truthlayer = "", range = c(-Inf, +Inf), plothist = FALSE, plotcomparison = FALSE)
{
    # This is mostly a wrapper function for predict()
    Prediction = predict(object, ...)
    
    # Clamp to range
    Prediction[Prediction < range[1]] = NA
    Prediction[Prediction > range[2]] = NA

    # Plot
    if (plothist)
        hist(Prediction, breaks = 200, main="Histogram of predicted values")
    if (plotcomparison)
    {
        TruthExists = try(class(object[[truthlayer]]))
        if (class(TruthExists) == "try-error")
        {
            warning("Requested a comparison plot, but could not find a layer to compare to!")
            return(Prediction)
        }
        op = par(mfrow=c(1,2))
        plot(Prediction, colNA="black", main="Predicted values")
        plot(object[[truthlayer]], colNA="black", main="Ground truth")
        par(op)
    }
    
    return(Prediction)
}
