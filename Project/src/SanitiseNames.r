# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# A function to return the first element from the list,
# while fixing several pretty silly typos in GADM.
TypoFix = function(words)
{
    if(words[1] == "Kedinai")
        return("Kedainiai")
    if(words[1] == "Mazeikai")
        return("Mazeikiai")
    if(words[1] == "Raseinai")
        return("Raseiniai")
    return(words[1])
}

# Returns a pretty list of municipality names extracted from GADM's VARNAME_2
# by splitting off at the pipe character and returning the first part of the string.
SanitiseNames = function(names)
{
    return(sapply(strsplit(names, split="[| ]+"), FUN=TypoFix))
}
