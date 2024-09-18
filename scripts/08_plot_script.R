#Manhattan plot script for GWAMA
#Written by Joshua C Randall & Reedik Magi

for (e in commandArgs(trailingOnly=TRUE))
{
  ta = strsplit(e,"=",fixed=TRUE)
  if(!is.null(ta[[1]][2]))
  {
    assign(ta[[1]][1],ta[[1]][2])
  } else {
    assign(ta[[1]][1],TRUE)
  }
}
if(!exists("input"))
{
  input <- paste("gwama.out")
}
if(!exists("out")) {
  out <- paste(input,".3.manh.png",sep="")
}
data<-read.table(input,stringsAsFactors=FALSE,header=TRUE,na.strings = "NA")
png(out,width=6.7,height=3.385,res=300,units="in",pointsize=3)

obspval <- (data$p.value)
chr <- (data$CHR)
pos <- (data$POS)
obsmax <- trunc(max(-log10(obspval)))+2

sort.ind <- order(chr, pos)
chr <- chr[sort.ind]
pos <- pos[sort.ind]
obspval <- obspval[sort.ind]

x <- 1:23
x2<- 1:23

for (i in 1:23)
{
curchr=which(chr==i)
x[i] <- trunc((max(pos[curchr]))/100) +100000
x2[i] <- trunc((min(pos[curchr]))/100) -100000
}

x[1]=x[1]-x2[1]
x2[1]=0-x2[1]

for (i in 2:23)
{
x[i] <- x[i-1]-x2[i]+x[i]
x2[i] <- x[i-1]-x2[i]

}
locX = trunc(pos/100) + x2[chr]
locY = -log10(obspval)
col1<-"#A6CEE3"
col2<-"#1F78B4"
col3<-"#B2DF8A"
col4<-ifelse (chr%%2==0, col1, col2)
curcol <- ifelse (obspval<5e-8, col3, col4)
par(mar=c(5,5,4,2) + 0.1)
plot(locX,locY,pch=20,col=curcol,axes=F,ylab="",xlab="",bty="n",ylim=c(0,obsmax),cex=1.5)
axis(2,las=1,cex.axis=2)
for (i in 1:23)
{
labpos = (x[i] + x2[i]) / 2
mtext(i,1,at=labpos,cex=1.5,line=0)
}
mtext("Chromosome",1,at=x[22]/2,cex=1.5,line=2)
mtext("-log10 p-value", side=2, line=3, cex=2)
abline(h=-log10(5e-8), col = "red", lwd = 0.5, lty="dashed")
abline(h=-log10(1e-6), col = "blue", lwd = 0.5, lty="dashed")
dev.off()

##QQ plot (modified from Sara Pulit's qq_by_maf.R script)

plotQQ <- function(z,color,cex){
    p <- 2*pnorm(-abs(z))
    p <- sort(p)
    expected <- c(1:length(p))
   lobs <- -(log10(p))
    lexp <- -(log10(expected / (length(expected)+1)))

    # plots all points with p < 0.05
    p_sig = subset(p,p<0.05)
    points(lexp[1:length(p_sig)], lobs[1:length(p_sig)], pch=23, cex=.3, col=color, bg=color)

    # samples 5000 points from p > 0.01
    n=5001
    i <- c(length(p)- c(0,round(log(2:(n-1))/log(n)*length(p))),1)
    lobs_bottom=subset(lobs[i],lobs[i] <= 2)
    lexp_bottom=lexp[i[1:length(lobs_bottom)]]
    points(lexp_bottom, lobs_bottom, pch=23, cex=cex, col=color, bg=color)
}

## Plot 1 - by Allele 2 frequency

#pvals_lo1=subset(data,(data$AF_Allele2 > 0.20 & data$AF_Allele2 < 0.8))
#pvals_lo2=subset(data,((data$AF_Allele2 < 0.20 & data$AF_Allele2 > 0.05) | (data$AF_Allele2 > 0.8 & data$AF_Allele2 < 0.95)))
#pvals_lo3=subset(data,((data$AF_Allele2 < 0.05 & data$AF_Allele2 > 0.01) | (data$AF_Allele2 > 0.95 & data$AF_Allele2 < 0.99)))
#pvals_lo4=subset(data,((data$AF_Allele2 < 0.01 & data$AF_Allele2 > 0.001) | (data$AF_Allele2 > 0.99 & data$AF_Allele2 < 0.999)))
#pvals_lo5=subset(data,(data$AF_Allele2 < 0.001 | data$AF_Allele2 > 0.999))

z=qnorm(data$p.value/2)
#z_lo1=qnorm(pvals_lo1$p.value/2)
#z_lo2=qnorm(pvals_lo2$p.value/2)
#z_lo3=qnorm(pvals_lo3$p.value/2)
#z_lo4=qnorm(pvals_lo4$p.value/2)
#z_lo5=qnorm(pvals_lo5$p.value/2)

## calculates lambda overall and for subsets
lambda = round(median(z^2,na.rm=T)/qchisq(0.5,df=1),3)
#l1 = round(median(z_lo1^2,na.rm=T)/qchisq(0.5,df=1),3)
#l2 = round(median(z_lo2^2,na.rm=T)/qchisq(0.5,df=1),3)
#l3 = round(median(z_lo3^2,na.rm=T)/qchisq(0.5,df=1),3)
#l4 = round(median(z_lo4^2,na.rm=T)/qchisq(0.5,df=1),3)
#l5 = round(median(z_lo5^2,na.rm=T)/qchisq(0.5,df=1),3)

## Plots axes and null distribution

png(file=paste(input,"mafQQ.png",sep="."), width=8, height=8, unit="cm", pointsize=4, res=300)
plot(c(0,8), c(0,8), col="gray25", lwd=3, type="l", xlab="Expected Distribution (-log10 of P value)", ylab="Observed Distribution (-log10 of P value)", xlim=c(0,8), ylim=c(0,8), las=1, xaxs="i", yaxs="i", bty="l",main=c(substitute(paste("QQ plot: ",lambda," = ", lam),list(lam = lambda)),expression()))

## plots data

plotQQ(z,rgb(255,79,0,maxColorValue=255),0.4);
#plotQQ(z_lo5,"lightpink2",0.3);
#plotQQ(z_lo4,"purple",0.3);
#plotQQ(z_lo3,"deepskyblue1",0.3);
#plotQQ(z_lo2,"slateblue3",0.3);
#plotQQ(z_lo1,"olivedrab2",0.3);

## provides legend
legend(.25,8,legend=c("Expected (null)","Observed")
#substitute(paste("EAF > 0.20 [", lambda," = ", lam, "]"),list(lam = l1)),expression(),
#substitute(paste("0.05 < EAF < 0.20 [", lambda," = ", lam, "]"),list(lam = l2)),expression(),
#substitute(paste("0.01 < EAF < 0.05 [", lambda," = ", lam, "]"),list(lam = l3)),expression(),
#substitute(paste("0.001 < EAF < 0.01 [", lambda," = ", lam, "]"),list(lam = l4)),expression(),
#substitute(paste("EAF < 0.001 [", lambda," = ", lam, "]"),list(lam = l5)),expression()),
#pch=c((vector("numeric",6)+1)*23), cex=1.1, pt.cex=1.5, pt.bg=c("grey25",rgb(255,79,0,maxColorValue=255),"olivedrab2","slateblue3","deepskyblue1","purple","lightpink2"))

rm(z)
dev.off()