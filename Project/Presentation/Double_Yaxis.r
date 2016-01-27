# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0


# Plotting the average, median, maximum, 75qt, 90qt LAI and the Forest Coverage over the years
miniY1= min(Dataset$Forest_Coverage)
maxiY1= max(Dataset$Forest_Coverage)  
maxiY2= max(Dataset$LAI_Avg, Dataset$LAI_Med, Dataset$LAI_Q75, Dataset$LAI_Q90, Dataset$LAI_Max)
miniY2= min(Dataset$LAI_Avg, Dataset$LAI_Med, Dataset$LAI_Q75, Dataset$LAI_Q90, Dataset$LAI_Max)
 

for(i in levels(factor(Dataset$Municipality)))
{
  svg(paste("Presentation/ToManyImages/", i, ".svg", sep=""))
  par(mar=c(5,4,4,5)+.1)
  plot(Forest_Coverage~ Year, data=Dataset[Dataset$Municipality==i,], type="l",col="black", main=i, ylim=c(miniY1, maxiY1), lwd=3)
  par(new=TRUE)
  plot(LAI_Avg~ Year, data=Dataset[Dataset$Municipality==i,], type="l", col="blue", xaxt="n", yaxt="n", xlab="", ylab="", ylim=c(miniY2, maxiY2))
  lines(LAI_Med~ Year, data=Dataset[Dataset$Municipality==i,], col="green")
  lines(LAI_Q75~ Year, data=Dataset[Dataset$Municipality==i,], col="yellow")
  lines(LAI_Q90~ Year, data=Dataset[Dataset$Municipality==i,], col="orange")
  lines(LAI_Max~ Year, data=Dataset[Dataset$Municipality==i,], col="red")
  axis(4)
  mtext("LAI",side=4,line=3)
  legend("topleft",col=c("black","blue", "green", "yellow", "orange", "red"),lty=1,legend=c("Forest Coverage","Mean LAI", "Median LAI", "75th percentile of LAI", "90th percentile of LAI", "Maximum LAI"))
  dev.off()
}
