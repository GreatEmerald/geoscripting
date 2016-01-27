# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0


# Plotting the average, median, maximum, 75qt, 90qt LAI and the Forest Coverage over the years
miniY1= min(Dataset$Forest_Coverage)
maxiY1= max(Dataset$Forest_Coverage)  
maxiY2= max(Dataset$LAI_Avg)
miniY2= min(Dataset$LAI_Avg)
 

for(i in levels(factor(Dataset$Municipality)))
{
  par(mar=c(5,4,4,5)+.1)
  plot(Forest_Coverage~ Year, data=Dataset[Dataset$Municipality==i,], type="l",col="red", main=i, ylim=c(miniY1, maxiY1))
  par(new=TRUE)
  plot(LAI_Avg~ Year, data=Dataset[Dataset$Municipality==i,], type="l", col="blue", xaxt="n", yaxt="n", xlab="", ylab="", ylim=c(miniY2, maxiY2))
  axis(4)
  mtext("LAI_ave",side=4,line=3)
  legend("topleft",col=c("red","blue"),lty=1,legend=c("Forest_Coverage","LAI_ave"))
}


