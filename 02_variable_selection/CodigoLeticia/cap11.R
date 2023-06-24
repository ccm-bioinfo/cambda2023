################################################################################ 
###Chapter 11: Modeling Over-dispersed Microbiome Data 
###Yinglin Xia: September, 2018 
### Algunas modificaciones por: Leticia Ramírez: Marzo, 2023
################################################################################ 

################################################################################ 
###11.2. NB Model in edgeR                                                      
################################################################################ 

# Step 1: Load Datasets and Setting Up the Count Matrix ########################
# We use the left-side throat data from the GUniFrac package, we first install the
# package and load datasets.

#install.packages("GUniFrac")
library(GUniFrac)
data(throat.otu.tab)
dim(throat.otu.tab)
colnames(throat.otu.tab)
rownames(throat.otu.tab)
head(throat.otu.tab)
matplot(t(throat.otu.tab),t="o",pch=20)

counts<-t(throat.otu.tab)
head(counts)


# Step 2: Build the edgeR Object                        ########################
# BiocManager::install("edgeR")
library(edgeR)

data(throat.meta)
group <- throat.meta$SmokingStatus
table(group)
dim(counts)
y <- DGEList(counts=counts,group=group) #build the edgeR object
str(y)
#y@.Data

names(y)
y$counts
y$sample
sum(y$all.zeros) # How many genes have 0 counts across all samples


# Step 3: Filter the Data                               ########################
# Typically, several thousand genes or taxa are expressed or abundant in all samples
# in a DNA/RNA-Seq experiment. Too low count reads suggest something wrong
# with samples or the sequencing.
# To effectively detect truly differentially expressed
# genes or abundant taxa and conduct downstream analysis, it usually removes very
# low expressed genes or abundant taxa in the any of experimental conditions in the
# early stage, before processing the normalization and differential abundance testing

# CPM filter used in the edgeR actually is a generalized version of the
# maximum-based filter. It is based on counts per million (CPM), calculated as the
# raw counts divided by the library sizes and multiplied by one million. 

dim(y)
y_full <- y # keep the old one in case we mess up
apply(y$counts, 2, sum) # total OTU counts per sample
keep <- rowSums(cpm(y)>100) >= 2
table(keep)
y <- y[keep,]
dim(y)

y$samples$lib.size <- colSums(y$counts)
y$samples

# Step 4: Normalize the Data                            ########################
# Normalization is often used to ensure that parameters are comparable because
# different libraries are sequenced to different depths. 

y <- calcNormFactors(y)
# calcNormFactors(object, method = c("TMM","TMMwsp","RLE","upperquartile","none"),
# refColumn = NULL, logratioTrim = .3, sumTrim = 0.05, doWeighting = TRUE,
# Acutoff = -1e10, p = 0.75, ...)

names(y)
y$samples
matplot(y$samples$norm.factors,t="o",pch=20)

# The effective library size is the product of the original library size and the scaling
# factor. In all downsteam analyses, the effective library size replaces the original
# library size.

# effective library sizes
y$samples$lib.size*y$samples$norm.factors

plot(y$samples$lib.size,t="o",pch=19,ylim=c(300,3800))
lines(y$samples$lib.size*y$samples$norm.factors,t="o",pch=19,col="red")

# Step 5: Explore the Data by Multi-dimensional Scaling (MDS) Plot  ############
# An MDS plot measures the similarity of the samples and projects this measure into
# 2-dimensions.
# In the plot, the samples, which are similar, are near to each other while samples
# that are dissimilar are far from each other. The following R codes create the MDS
# plot

plotMDS(y, method="bcv", main = "MDS Plot for throat Count Data",
        col=as.numeric(y$samples$group), cex=0.5, labels = colnames(y$counts))

# This function uses multidimensional scaling (MDS) to produce a principal coordinate 
# (PCoA) or principal component (PCA) plot showing the relationships between the 
# expression profiles represented by the columns of x. 


legend("topright", as.character(unique(y$samples$group)), col=1:2, cex=0.8, pch=16)


# Step 6: Estimate the Dispersions                      ########################

# The first major step in the analyses of RNA-seq differential expression and
# microbiome abundance count data using the NB model is to estimate the dispersion
# parameter for each gene or taxon (OTU). 

# The dispersion measures the biological variability of within-group variability, 
# i.e., variability between replicates (or called
# inter-library variation) for that gene (taxon, OTU). For strongly abundant genes, the
# dispersion can be understood as a squared coefficient of variation: that is, a 
# dispersion value of 0.01 indicates that the gene’s expression tends to differ usually by
# 10% between samples of the same treatment group. Typically, the shape
# of the dispersion fit is an exponentially decaying curve. We fit a model in edgeR to
# estimate the dispersions as below:

## Estimate the common dispersion  ##
# The common dispersion measure will give an idea of overall variability across
# the genome for the dataset. 
# estimateCommonDisp maximizes the negative binomial conditional common likelihood 
# to estimate a common dispersion value across all genes.
# Implements the conditional maximum likelihood (CML) method proposed by Robinson 
# and Smyth (2008) for estimating a common dispersion parameter.

y1 <- estimateCommonDisp(y, verbose=T) 
names(y1)

# BCV stands for Biological Coefficient of Variation. It is the square root of dispersion.
# CPM stands for counts per million mapped reads

## Estimate the tag-wise dispersion ##
# In this scenario, each gene will get its own unique dispersion estimate. 
# But the common dispersion is still used in the calculation.

y1 <- estimateTagwiseDisp(y1)
names(y1)
y1$common.dispersion

head(y1$tagwise.dispersion)
par(mar=c(4,4,4,1))
plotBCV(y1)

# The black dots represent the BCV if it were calculated individually for each tagwise
# the red line represent the BCV of the samples if a common dispersion values, over
# all genes, were used


## Fit a generalized linear model to estimate the genewise dispersion. ##

# We can also fit a generalized linear model (GLM) using edgeR to estimate the
# genewise dispersion. Before fitting GLMs, we need to define the design matrix. In
# this case, the design matrix is created as:

design <- model.matrix(~group)
rownames(design) <- colnames(y)
design


# Now we can estimate the genewise dispersion over all genes /OTUs, allowing
# for a possible abundance trend. The estimation is also robust against potential
# outlier genes/OTUs.

library(statmod)
y2 <- estimateDisp(y, design, robust=TRUE) # Maximizes the negative binomial 
                                           # likelihood to give the estimate of the 
                                           # common, trended and tagwise dispersions 
                                           # across all tags.
y2$common.dispersion

plotBCV(y2)
# The blue line is the trend of this data. 
# The plot shows that the trended dispersion decreases with expression level.


# Step 7: Test the Differential Abundance               ########################

# Once NB models are fitted and dispersion estimates are obtained for each gene, we
# can test the differentially expressed (abundant) genes (OTUs) between conditions
# either using the function exactTest () or GLM approach.


## The exactTest() Approach ##
# The classic edgeR approach uses the function exactTest() to make the pairwise
# comparisons between the groups. The output of exactTest() is a list of elements, one
# of which is a table of the results.

# The null hypothesis of this example study is that there is no effect of the smoking
# on the OTUs. The codes below find differential abundance of the OTUs in Smoker
# versus NonSmoker.


et <- exactTest(y1,pair = c( "NonSmoker", "Smoker" ))

names(et)
plot(et$table$PValue)
abline(h=0.01,col="red")
#plot(sort(et$table$PValue))

topTags(et)

alfa<-0.01  #For example
significant<-(et$table$PValue<alfa)
table(significant)

#Then we have 21 OTUs that are significantly different between the two groups

all(row.names(et$table)==row.names(y2$counts))

significant<-which(et$table$PValue<alfa)

x11()
par(mfrow=c(5,5),mar=c(2,1,0,0))
for(i in significant){
 boxplot(y2$counts[i,]~y2$samples$group, col=rgb(0,.7,.7,.5))
}

par(mfrow=c(1,1),mar=c(5,5,3,0))
boxplot(y2$counts[significant[3],]~y2$samples$group, col=rgb(0,.7,.7,.5))
boxplot(y2$counts[significant[3],]~y2$samples$group, col=rgb(0,.7,.7,.5),ylim=c(0,0.01))

#plot(rep(0,32),y2$counts[significant[3],y2$samples$group=="NonSmoker"])

table(y2$samples$group,y2$counts[significant[3],])



# Step 8: Interpret the Results of Differential Expression Analysis with 
# Diagnostic Plots                                      ########################

# Once the data have been processed and the dispersion estimates are moderated, we can
# use diagnostic plots to help interpreting the results of differential abundance analysis






     