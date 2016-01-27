# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0


# Plotting the average, median, maximum, 75qt, 90qt LAI and the Forest Coverage over the years
miniY1= min(Dataset$Forest_Coverage)
maxiY1= max(Dataset$Forest_Coverage)  
maxiY2= max(Dataset$LAI_Avg, Dataset$LAI_Med, Dataset$LAI_Q75, Dataset$LAI_Q90, Dataset$LAI_Max)
miniY2= min(Dataset$LAI_Avg, Dataset$LAI_Med, Dataset$LAI_Q75, Dataset$LAI_Q90, Dataset$LAI_Max)
 
# A for loop that creates the graphical output of the statistics and the LAI
for(i in levels(factor(Dataset$Municipality)))
{
  svg(paste("output/SVG/", i, ".svg", sep=""))
  par(mar=c(5,4,4,5)+.1)
  plot(Forest_Coverage~ Year, data=Dataset[Dataset$Municipality==i,], type="l",col="black", main=i, ylab= "Forest Coverage %", ylim=c(miniY1, maxiY1), lwd=3)
  par(new=TRUE)
  plot(LAI_Avg~ Year, data=Dataset[Dataset$Municipality==i,], type="l", col="blue", xaxt="n", yaxt="n", xlab="", ylab="", ylim=c(miniY2, maxiY2))
  lines(LAI_Med~ Year, data=Dataset[Dataset$Municipality==i,], col="green")
  lines(LAI_Q75~ Year, data=Dataset[Dataset$Municipality==i,], col="gold")
  lines(LAI_Q90~ Year, data=Dataset[Dataset$Municipality==i,], col="darkorange")
  lines(LAI_Max~ Year, data=Dataset[Dataset$Municipality==i,], col="firebrick1")
  axis(4)
  mtext("LAI",side=4,line=3)
  legend("topleft",col=c("black","blue", "green", "gold", "darkorange", "firebrick1"),lty=1, lwd=c(3,1,1,1,1,1),legend=c("Forest Coverage","Mean LAI", "Median LAI", "75th percentile of LAI", "90th percentile of LAI", "Maximum LAI"))
  dev.off()
}

