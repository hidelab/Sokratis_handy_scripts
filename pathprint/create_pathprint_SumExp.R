# Script to create a SummarizedExperiment object from a fingerprint and a 
# metadata matrix. This object is used by the pathprint package. Needs matrices
# in the same folder

# Set the working directory to where this script is
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(SummarizedExperiment)

# Load the 2 matrices we want to summarize as well as two that are already in 
# the correct form
load("GEO.fingerprint.matrix.rda")
load("GEO.metadata.matrix.rda")

load("RNA.fingerprint.matrix.rda")
load("RNA.metadata.matrix.rda")

# Get the SummarizedExperiment parameters ready
colData <- GEO.metadata.matrix
rownames(colData) <- GEO.metadata.matrix[,1]

# Check if the data are formatted properly by comparing with old mini-matrices
rna_finger_type <- RNA.fingerprint.matrix[1:10,1:10]
rna_meta_type <- RNA.metadata.matrix[1:10,1:10]
geo_finger_type <- GEO.fingerprint.matrix[1:10,1:10]
geo_meta_type <- colData[1:10,1:7]

# If the above match in format, make the fingerprint columns and colData(aka 
# GEO.metadata.matrix) rows equal
cNames <- colnames(GEO.fingerprint.matrix) # samples we need in both matrices

new_GEO.metadata.matrix <- 
    GEO.metadata.matrix[GEO.metadata.matrix$GSM%in%cNames,]

GEO.metadata.matrix <- new_GEO.metadata.matrix

colData <- GEO.metadata.matrix
rownames(colData) <- GEO.metadata.matrix[,1]

geo_sum_data = SummarizedExperiment(
    assays=list(fingerprint=GEO.fingerprint.matrix), colData=colData)

save(geo_sum_data,file = "SummarizedExperimentGEO.rda")
