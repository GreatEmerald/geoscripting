# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# Working example of all the municipalities
par(mar=c(5,4,4,5)+.1)
plot(Dataset$Year, Dataset$Forest_Coverage, type="l",col="red")
par(new=TRUE)
plot(Dataset$Year, Dataset$LAI_Avg, ,type="l",col="blue",xaxt="n",yaxt="n",xlab="",ylab="")
axis(4)
mtext("LAI_ave",side=4,line=3)
legend("topleft",col=c("red","blue"),lty=1,legend=c("Forest_Coverage","LAI_ave"))


# Work in progress for each municipality
for(i in levels(statistics$Municipality))
{
  svg(paste("ToManyImages/", i, ".svg"))
  plot(Forest_Coverage_in_Percent~ Year, data=statistics[statistics$Municipality==i,], main = i, type = "l", ylim=c(0,100))
  dev.off()
}