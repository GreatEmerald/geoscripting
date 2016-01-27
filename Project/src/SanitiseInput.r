# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# A function to return the first element from the list, while fixing two pretty silly typos in GADM.
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

# Sanitised input names to remove Lithuanian characters and municipality
# abbreviations (when type="lithuanian") or duplicate data (when type="piped").
# Returns back the sanitised input.
SanitiseNames = function(names, type="piped")
{
    if(type == "piped")
        result =  sapply(strsplit(names, split="[| ]+"), FUN=TypoFix)
    else
    {
        print("Halt, who goes there?")
    }
    return(result)
}
