# Reads data from Yered's PCxN matrices into the MySQL database (pcxn_database_yered)
# It also reforms columns as needed
pcxn_canonical_pathways<-readRDS("pcxn_mean_pcor2_barcode_hallmark.RDS")
dim(pcxn_canonical_pathways)
result<-pcxn_canonical_pathways
result$edge<-paste(result$Pathway.A, result$Pathway.B, sep=":")
length(unique(result$edge))
result<-result[, c(7, 1:6)]
result$edge_id<-1:nrow(result)
result<-result[, c(8, 1:7)]

colnames(result)<-c("correlation_tbl_ID", "edge", "gene_set_A", "gene_set_B", "overlap_coefficient", "correlation", "p_value", "p_adjust")
result<-result[, c("correlation_tbl_ID", "edge", "gene_set_A", "gene_set_B", "correlation", "p_value", "overlap_coefficient", "p_adjust")]
head(result)
result$correlation<-as.numeric(result$correlation)
result$correlation<-signif(result$correlation, digits = 3)
result$p_value<-as.numeric(result$p_value)
result$p_value <-signif(result$p_value, digits=3)
result$overlap_coefficient<-as.numeric(result$overlap_coefficient)
result$overlap_coefficient <-signif(result$overlap_coefficient, digits = 3)
head(result)

library(RMySQL)
con <- dbConnect(RMySQL::MySQL(), dbname = "pcxn_database_yered", user="user1", password = "password1" )
dbListTables(con)
dbRemoveTable(con, "msigdb_h_hallmark_correlation_tbl")
dbListTables(con)
rs <- dbSendQuery(con, "CREATE TABLE IF NOT EXISTS pcxn_database_yered.msigdb_h_hallmark_correlation_tbl (
  correlation_tbl_ID INT NOT NULL AUTO_INCREMENT,
  edge TEXT NOT NULL,
  gene_set_A VARCHAR(200) NOT NULL,
  gene_set_B VARCHAR(200) NOT NULL,
  correlation float NOT NULL,
  p_value double NOT NULL,
  overlap_coefficient float NOT NULL,
  p_adjust double NOT NULL,
  PRIMARY KEY (correlation_tbl_ID),
  INDEX col_edge_idx (edge (10) ASC),
  INDEX fk_gene_set_A_idx (gene_set_A (10) ASC),
  INDEX fk_gene_set_B_idx (gene_set_B (10) ASC)
  )")
dbListTables(con)
dbWriteTable(con, "msigdb_h_hallmark_correlation_tbl", result, row.names = FALSE, overwrite = FALSE, append = TRUE)

rs <- dbSendQuery(con, "SELECT COUNT(*) FROM msigdb_h_hallmark_correlation_tbl")
dbFetch(rs, n = -1)
dbHasCompleted(rs)
dbClearResult(rs)

rs <- dbSendQuery(con, "SELECT * FROM msigdb_h_hallmark_correlation_tbl where correlation_tbl_ID <5")
dbFetch(rs, n = -1)
dbHasCompleted(rs)
dbGetStatement(rs)
dbClearResult(rs)
dbDisconnect(con)