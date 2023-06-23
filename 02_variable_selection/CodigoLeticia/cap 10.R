################################################################################ 
### Chapter 10: Compositional Analysis of Microbiome Data 
### Yinglin Xia: September, 2018
### Algunas modificaciones por: Leticia Ramírez: Marzo, 2023
################################################################################

setwd("E:\\Dropbox\\Actividades_2023\\1_CIMAT\\Clases\\Genomica\\codigo")

################################################################################ 
###10.3. Exploratory Compositional Data Analysis  ----                               
################################################################################ 

## 10.3.1 Compositional Biplot 
# 1  Cargamos datos  ----

abund_table<-read.csv("VdrFecalGenusCounts.csv",row.names=1,check.names=FALSE)
abund_table_t<-t(abund_table)
abund_table_t
#abund_table_t<-abund_table_t[, 1:19]


g0<-1*(abund_table_t>0)
table(colSums(g0))  #0s son los que no tienen ningun taxa

abund_table_t<-abund_table_t[, colSums(g0)>3]  #datos con al menos dos OTUs presentes
head(abund_table_t)
dim(abund_table_t)

## 2  Reemplazamos los valores 0 usando el paquete zCompositions y su comando cmultRepl  ----
# que utliza metodos Bayesianos multiplicativos
frecuencia<-table(abund_table_t)
plot(frecuencia)

#install.packages("zCompositions")
library(zCompositions)
abund_table_r <- t(cmultRepl(abund_table_t, method="CZM", output="p-counts")) 
# "cmultRepl" expects the samples to be in rows and taxa (or OTUs) to be in columns
#  El metodo  CZM corresponde a "count zero multiplicative": Martin-Fernandez, 
#     et al.(2015) J. Bayesian-multiplicative treatment of count zeros in 
#     compositional data sets. Statistical Modelling; 15 (2): 134-158. 

abund_table_r
plot(table(abund_table_r))
min(abund_table_r)
head(sort(abund_table_r),20)


## 3 Convertir los datos a proporciones (suma 1) ----
abund_table_prop <- apply(abund_table_r, 2, function(x){x/sum(x)})
head(abund_table_prop)
colSums(abund_table_prop)  #verificamos que sumen 1


## 4 Filtrar para remover los taxa con menos de 0.1% abundancia en cualquier muestra ----
abund_table_prop_f <- abund_table_r[apply(abund_table_prop, 1, min) > 0.001,]
dim((abund_table_prop_f))
head(abund_table_prop_f)
colSums(abund_table_prop_f)


## 5 Transformar los datos con clr ----
#primero queremos reducir la base a considerar las abundancias mayores
names_add <- rownames(abund_table_prop_f)[order(apply(abund_table_prop_f, 1,
                                                      sum), decreasing=T)]
abund_table_prop_reduced <- abund_table_prop_f[names_add,]
head(abund_table_prop_reduced)

abund_clr <- t(apply(abund_table_prop_reduced, 2, 
                function(x){log(x) - mean(log(x))}))  #convert the data to the centered log-ratio
                                                      #checar la media que si es geometrica
head(abund_clr)
rowSums(abund_clr)  # las sumas de los D componente, para cada observación, sí son muy cercanas a cero.


# Graficamos los datos transformados

par(mar=c(7,4,1,1))
matplot(t(abund_clr),pch=19,t="o",xaxt = "n",xlab="",ylab="")
grid()
#axis(1,names_add, at=1:10,las=2,cex=.5)
axis(1,labels=FALSE)
text(x = 1:10,
     ## Move labels to just below bottom of chart.
     y = par("usr")[3] - 0.45,
     labels = names_add,
     xpd = NA,
     srt = 90,
     ## Adjust the labels to almost 100% right-justified.
     adj = .8,
     ## Increase label size.
     cex = 0.8)



## 6 Realizar la descomposici'on de valor singular usando prcomp() ----
abund_PCX <- prcomp(abund_clr)
abund_PCX$x
summary(abund_PCX)


## 7 Visualizar os resultados usando biplot() o coloredBiplot() ----
# The biplot is a very popular way for visualization of results from PCA, 
# as it combines both the principal component scores and the loading vectors in 
# a single biplot display.

# install.packages("compositions")
library(compositions)
# Sum the total variances
sum(abund_PCX$sdev[1:2]^2)/mvar(abund_clr)
#[1] 0.6894046

# There are 5 Vdr−/− and 3 wild type samples. To have a differentiated
# visualization of two conditions, we use different colors to label them

samples <- c(rep(1, 5),rep(2, 3))
palette=palette(c(rgb(1,0,0,0.6), rgb(0,0,1,0.6), rgb(.3,0,.3,0.6)))
palette

par(mar=c(4,3,2,0))
coloredBiplot(abund_PCX, col="black", cex=c(0.7, 0.7),xlabs.col=samples,
  arrow.len=0.05, xlab=paste("PC1_", round (sum(abund_PCX$sdev[1]^2)/mvar(abund_clr),3), sep=""),
  ylab=paste("PC2_ ", round (sum(abund_PCX$sdev[2]^2)/mvar(abund_clr),3), sep=""),
  expand=0.8,var.axes=T, scale=1, main="Biplot")

# The orientation (direction) of the vector, with respect to the principal component space, 
# in particular, its angle with the principal component axes: the more parallel to a 
# principal component axis is a vector, the more it contributes only to that PC.

# The length and direction of the arrows (taxa location) is proportional to the
# standard deviation of the taxon in the dataset. 
# Lactobacillus is highly variable genus along the same direction as samples 22 and 23, 
# which indicates that this bacterial is more abundant in WT samples than in Vdr−/− samples.

# Bacteroides and Eubacterium are very close together. They have a short link.
# The length of a link is proportional to the variance in their ratios. So the variance
# of the ratios of these two bacteria is fairly constant.

###  Compositional Scree Plot ----
# Display the proportion of the total variation in the dataset that is explained by 
# each of the components in a principle component analysis. This helps us to 
# identify how many of the components are needed to summarize the data. 

layout(matrix(c(1,2),1,2, byrow=T), widths=c(6,4), heights=c(6,4))
par(mgp=c(2,0.5,0))
screeplot(abund_PCX, type = "lines", main="Scree plot")
screeplot(abund_PCX, type = "barplot", main="Scree plot")

#The scree plot of the abundance-filtered Vdr mouse data. It shows that the majority of
#the variability is on components 1 and 2


### Compositional Cluster Dendrogram ----
# The biplot suggested that two groups could be defined with our Vdr mouse data. It
# appears that the samples were separated between the WT samples containing taxa
# of Lactobacillus, Butyricimonas, Lactococcus, and the Vdr−/− samples containing
# taxa of Alistipes, Clostridium, Eubacterium, Bacteroides, Tannerella, Prevotella,
# Akkermansia. 
# We can use a compositional cluster analysis (compositional cluster dendrogram) 
# and a compositional barplot to confirm the relationship between the sample 
# clusters and taxa abundance.

# generate the distance matrix
dist <- dist(abund_clr, method="euclidian")
hc <- hclust(dist, method="ward.D2")
hc
# plot the dendrogram
layout(1, widths=6, heights=6)
plot(hc)

# Add colors to the labels
dend <- as.dendrogram(hc)
#install.packages('dendextend')
library(dendextend)
# Assigning the labels of dendrogram object with new colors:
cols<-c("red","blue")
labels_colors(dend) <- cols[samples][order.dendrogram(dend)]
# Plotting the new dendrogram
par(mar=c(7,3,1,1))
plot(dend,cex=0.7)



### Compositional Barplot ----
#reorder the samples to match the sample orders as cluster dendrogram.
re_order <- abund_table_prop_reduced[,hc$order]
re_order

library(compositions)
re_order_acomp <- acomp(t(re_order))


layout.matrix <- matrix(c(1, 2), nrow = 1, ncol = 2)

layout(mat = layout.matrix,
       heights = c(1), # Heights of the two rows
       widths = c(2.5, 1)) # Widths of the two columns
#layout.show(2)

#par(mfrow=c(1,2))
colors <- rainbow(10)
# plot the barplot below
barplot(re_order_acomp, legend.text=F, col=colors, axisnames=F, border=NA, xpd=T)
# and the legend
plot(1,2, pch = 1, lty = 1, ylim=c(-10,10), type = "n", axes = FALSE, ann = FALSE)
legend(x="left", legend=names_add, col=colors, lwd=5,cex=.9, border=NULL,  bty="n")

#The figure shows taxa abundance distribution with the same
#sample order as that of cluster dendrogram

layout(matrix(c(1,3,2,3),2,2, byrow=T), widths=c(5,2), height=c(3,4))
par(mar=c(3,1,1,1)+0.8)
# plot the dendrogram
#plot(hc, cex=0.6)
plot(dend,cex=0.7)
# plot the barplot below
barplot(re_order_acomp, legend.text=F, col=colors, axisnames=F,
            border=NA, xpd=T)
# and the legend
plot(1,2, pch = 1, lty = 1, ylim=c(-10,10),
         type = "n", axes = FALSE, ann = FALSE)
#legend(x="center", legend=names_add, col=colors, lwd=5, cex=.6, border=NULL)
legend(x="left", legend=names_add, col=colors, lwd=5,cex=.9, border=NULL,  bty="n")








#PP












################################################################################
###10.4.Comparison between the Groups Using ALDEx2 Package ----
################################################################################

abund_table=read.csv("VdrSitesGenusCounts.csv",row.names=1,check.names=FALSE)
abund_table_t<-t(abund_table)
ncol(abund_table_t) # check the number of genera
#[1] 248
nrow(abund_table_t) # check the number of samples
#[1] 10

meta_table <- data.frame(row.names=rownames(abund_table_t),
                         t(as.data.frame(strsplit(rownames(abund_table_t),"_"))))
meta_table

# we assing a group variable
groups <- with(meta_table,ifelse(as.factor(X3)%in% c("drySt-28F"),c("VdrFecal"), c("VdrCecal")))
groups


# ALDEx2 needs the input data with taxa by samples format (row being per-taxon
# counts, column being each sample). We check to make sure the data format is
# correct.
abund_table[1:3,1:3]


#install.packages("BiocManager")
library(BiocManager)

## Run the ALDEX Modular Step-by-Step.
# 1 Generate Instances of the Centred Log-Ratio Transformed Values using aldex.clr()

#BiocManager::install("ALDEx2")
library(ALDEx2)

vdr <- aldex.clr(abund_table, groups, mc.samples=128, verbose=TRUE) 
str(vdr)

# 2 Perform the Welch’s t and Wilcoxon Rank Sum Test using aldex.ttest()
# aldex.ttest calculates the expected values of the Wilcoxon Rank Sum test and 
# Welch's t-test on the data returned by aldex.clr.

vdr_t <- aldex.ttest(vdr,  paired.test=FALSE) # calculates the expected values of 
                                              # the Wilcoxon Rank Sum test and 
                                              # Welch's t-test 
head(vdr_t)
#The aldex.ttest() function returns the values of 
# we.ep (expected p-value of Welch’s t test), 
# we.eBH (expected Benjamini-Hochberg corrected p-value of #Welch’s t test), 
# wi.ep (expected p-value of Wilcoxon rank sum test), and 
# wi.eBH (expected Benjamini-Hochberg correctedp-value of Wilcoxon rank sum test).







#PP






################################################################################
###10.5. Proportionality: Correlation Analysis for Relative Data
################################################################################


##10.5.3 Illustrating Proportionality Analysis

##10.5.3.1 Calculating Proportionality
abund_table=read.csv("VdrFecalGenusCounts.csv",row.names=1,check.names=FALSE)
head(abund_table)  
abund_table_t<-t(abund_table)

#install.packages("propr")
#https://github.com/tpq/propr
#devtools::install_github("tpq/propr")

library(propr)

# The functions phit(), perb(), and phis() return the four proportionality matrix
# wrapped within an object of the propr class:
# @counts    —a matrix storing the original “count matrix” input.
# @logratio  —a matrix storing the log-ratio transformed “count matrix”.
# @matrix    —a matrix storing the proportionality metrics.
# @pairs     —a vector indexing the proportionality of interest.

phi <- phit(abund_table_t, symmetrize = TRUE)
rho <- perb(abund_table_t, ivar = 0)
phs <- phis(abund_table_t, ivar = 0)
phi

head(phi@counts)
head(phi@logratio)
head(phi@pairs)

head(phi@matrix)
head(rho@matrix)
head(phs@matrix)

phimat<-phi@matrix


# ----- Define a function for plotting a matrix ----- #
myImagePlot <- function(x, ...){
  min <- min(x)
  max <- max(x)
  yLabels <- rownames(x)
  xLabels <- colnames(x)
  title <-c()
  # check for additional function arguments
  if( length(list(...)) ){
    Lst <- list(...)
    if( !is.null(Lst$zlim) ){
      min <- Lst$zlim[1]
      max <- Lst$zlim[2]
    }
    if( !is.null(Lst$yLabels) ){
      yLabels <- c(Lst$yLabels)
    }
    if( !is.null(Lst$xLabels) ){
      xLabels <- c(Lst$xLabels)
    }
    if( !is.null(Lst$title) ){
      title <- Lst$title
    }
  }
  # check for null values
  if( is.null(xLabels) ){
    xLabels <- c(1:ncol(x))
  }
  if( is.null(yLabels) ){
    yLabels <- c(1:nrow(x))
  }
  
  layout(matrix(data=c(1,2), nrow=1, ncol=2), widths=c(4,1), heights=c(1,1))
  
  # Red and green range from 0 to 1 while Blue ranges from 1 to 0
  ColorRamp <- rgb( seq(0,1,length=256),  # Red
                    seq(0,1,length=256),  # Green
                    seq(1,0,length=256))  # Blue
  ColorLevels <- seq(min, max, length=length(ColorRamp))
  
  # Reverse Y axis
  reverse <- nrow(x) : 1
  yLabels <- yLabels[reverse]
  x <- x[reverse,]
  
  # Data Map
  par(mar = c(3,5,2.5,2))
  image(1:length(xLabels), 1:length(yLabels), t(x), col=ColorRamp, xlab="",
        ylab="", axes=FALSE, zlim=c(min,max))
  if( !is.null(title) ){
    title(main=title)
  }
  axis(BELOW<-1, at=1:length(xLabels), labels=xLabels, cex.axis=0.7)
  axis(LEFT <-2, at=1:length(yLabels), labels=yLabels, las= HORIZONTAL<-1,
       cex.axis=0.7)
  
  # Color Scale
  par(mar = c(3,2.5,2.5,2))
  image(1, ColorLevels,
        matrix(data=ColorLevels, ncol=length(ColorLevels),nrow=1),
        col=ColorRamp,
        xlab="",ylab="",
        xaxt="n")
  
  layout(1)
}
# ----- END plot function ----- #


myImagePlot(phi@matrix)

myImagePlot(log(phi@matrix+1))
myImagePlot((rho@matrix))
myImagePlot(log(phs@matrix+1))











