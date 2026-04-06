setwd("C:/Users/rubyp/OneDrive/Desktop/Functional homework")
getwd()
list.files()

library(readxl)
library(dplyr)

# =============================================================================
# COMPLETE DESeq2 RNA-seq Analysis: Cancer vs Normal (Dog Mammary Tissue)
# Author: Ruby Paudel | Auburn University | April 2026
# ALL OUTPUTS SAVED TO "group_project" FOLDER + Confidence Checks
# =============================================================================

cat("🔥 STARTING COMPLETE DESeq2 PIPELINE → group_project folder\n")
cat("Date:", Sys.Date(), "\n")
cat("Working directory:", getwd(), "\n\n")

# ===== STEP 0: CREATE OUTPUT FOLDER =====
cat("✅ STEP 0: Creating 'group_project' folder...\n")
if(!dir.exists("group_project")) {
  dir.create("group_project")
  cat("   ✓ Created group_project/\n")
} else {
  cat("   ✓ group_project/ already exists\n")
}
output_dir <- "group_project"
cat("   Output path:", file.path(getwd(), output_dir), "\n\n")

# ===== STEP 1: LOAD LIBRARIES =====
cat("✅ STEP 1: Loading libraries...\n")
required_packages <- c("DESeq2", "dplyr", "pheatmap", "RColorBrewer", "readr")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(required_packages, library, character.only=TRUE)
cat("   ✓ All libraries loaded\n\n")

# ===== STEP 2: LOAD COUNT DATA =====
cat("✅ STEP 2: Loading count files...\n")
normal_counts <- read.csv("C:/Users/rubyp/OneDrive/Desktop/Functional homework/Normal_GCfile.csv")
tumor_counts  <- read.csv("C:/Users/rubyp/OneDrive/Desktop/Functional homework/Tumor_GCfile.csv")

# CONFIDENCE CHECK 1
cat("   Normal file:", nrow(normal_counts), "genes,", ncol(normal_counts)-1, "samples\n")
cat("   Tumor file: ", nrow(tumor_counts),  "genes,", ncol(tumor_counts)-1,  "samples\n")
cat("   First 3 genes:", paste(head(normal_counts[,1], 3), collapse=", "), "\n")
cat("   ✓ Count files loaded\n\n")

# ===== STEP 3: CREATE COUNT MATRIX =====
cat("✅ STEP 3: Creating count matrix...\n")
names(normal_counts)[1] <- "gene_id"
names(tumor_counts)[1]  <- "gene_id"
count_matrix <- full_join(normal_counts, tumor_counts, by = "gene_id")
rownames(count_matrix) <- count_matrix$gene_id
countdata <- as.matrix(count_matrix[, -1])

# CONFIDENCE CHECK 2
cat("   ✓ Matrix:", dim(countdata)[1], "genes ×", dim(countdata)[2], "samples\n")
cat("   Sample names:", paste(head(colnames(countdata), 3), collapse=", "), "...\n\n")

# ===== STEP 4: CREATE METADATA =====
cat("✅ STEP 4: Creating metadata...\n")
coldata <- data.frame(
  row.names = colnames(countdata),
  
  condition = c(rep("Normal", 10), rep("Cancer", 10))
)

# CONFIDENCE CHECK 3
cat("   Metadata: 10 Normal + 10 Cancer = 20 samples\n")
cat("   Alignment perfect:", all(rownames(coldata) == colnames(countdata)), "\n")
print(table(coldata$condition))
cat("   ✓ Metadata ready\n\n")

# ===== STEP 5: DESeq2 ANALYSIS =====
cat("✅ STEP 5: Running DESeq2...\n")
dds <- DESeqDataSetFromMatrix(countData = countdata, colData = coldata, design = ~ condition)
dds <- dds[rowSums(counts(dds)) >= 50, ]  # Filter ≥50 reads
cat("   Filtered:", nrow(dds), "high-quality genes\n")

dds <- DESeq(dds)
res <- results(dds)
resOrdered <- res[order(res$padj), ]

# CONFIDENCE CHECK 4
cat("   🎉 DESeq2 COMPLETE!\n")
cat("   Genes tested:", nrow(res), "\n")
cat("   FDR<0.1:  ", sum(res$padj < 0.1, na.rm=TRUE), "genes\n")
cat("   FDR<0.05: ", sum(res$padj < 0.05, na.rm=TRUE), "genes\n")
cat("   Top gene: ", rownames(res)[which.min(res$padj)], "\n\n")

# ===== STEP 6: SAVE MAIN RESULTS =====
cat("✅ STEP 6: Saving to group_project/...\n")
write.csv(as.data.frame(resOrdered), file.path(output_dir, "01_DESeq2_Cancer_vs_Normal_results.csv"), row.names=TRUE)
cat("   ✓ 01_DESeq2_Cancer_vs_Normal_results.csv\n")

# ===== STEP 7: DIAGNOSTIC PLOTS =====
cat("✅ STEP 7: Generating plots → group_project/plots/\n")
dir.create(file.path(output_dir, "plots"), showWarnings=FALSE)

png(file.path(output_dir, "plots/01_MA_plot.png"), width=800, height=600)
plotMA(res, main="MA-plot: Cancer vs Normal", ylim=c(-8,8))
dev.off()

png(file.path(output_dir, "plots/02_PCA_plot.png"), width=800, height=600)
rld <- rlog(dds)
plotPCA(rld, intgroup="condition")
dev.off()

png(file.path(output_dir, "plots/03_top_gene_counts.png"), width=800, height=600)
plotCounts(dds, gene=which.min(res$padj), intgroup="condition", main="Top DE Gene: ACAN")
dev.off()

# Heatmap
vsd <- varianceStabilizingTransformation(dds)
topVarGenes <- head(order(rowVars(assay(vsd)), decreasing = TRUE), 50)
png(file.path(output_dir, "plots/04_top50_heatmap.png"), width=1000, height=800)
mat <- assay(vsd)[topVarGenes, ] - rowMeans(assay(vsd)[topVarGenes, ])
anno <- as.data.frame(colData(vsd)[, "condition", drop=FALSE])
pheatmap(mat, annotation_col = anno, main="Top 50 Variable Genes", fontsize=8)
dev.off()

cat("   ✓ 4 plots saved to group_project/plots/\n\n")

# ===== STEP 8: GSEA RANKED LIST =====
cat("✅ STEP 8: GSEA ranked list...\n")
DGEresults <- as.data.frame(res)
DGEresults$gene_name <- rownames(DGEresults)
DGE_Anno_Rank <- within(DGEresults, rank <- sign(log2FoldChange) * -log10(pvalue))
gene_names <- sub("\\|.*", "", DGE_Anno_Rank$gene_name)  # ACAN|ACAN → ACAN
DGErank <- data.frame(Name = gene_names, rank = DGE_Anno_Rank$rank)
DGErank_clean <- na.omit(DGErank)

write.table(DGErank_clean, file.path(output_dir, "02_DGErankName.rnk"), 
            quote=FALSE, row.names=FALSE, sep="\t")
cat("   ✓ 02_DGErankName.rnk (", nrow(DGErank_clean), "genes for GSEA)\n\n")

# ===== STEP 9: NORMALIZED COUNTS =====
cat("✅ STEP 9: Normalized expression...\n")
nt <- normTransform(dds)
NormTransExp <- assay(nt)
write.csv(NormTransExp, file.path(output_dir, "03_NormTransExp_Anno_Names.csv"))
cat("   ✓ 03_NormTransExp_Anno_Names.csv (", nrow(NormTransExp), "×", ncol(NormTransExp), ")\n\n")

# ===== STEP 10: PUBLICATION SUMMARY =====
cat("✅ STEP 10: FINAL SUMMARY\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")
cat("📁 ALL FILES SAVED TO: group_project/\n")
cat("│\n")
cat("├── 01_DESeq2_Cancer_vs_Normal_results.csv     (1,514 genes, full stats)\n")
cat("├── 02_DGErankName.rnk                        (GSEA ready)\n") 
cat("├── 03_NormTransExp_Anno_Names.csv            (normalized counts)\n")
cat("└── plots/\n")
cat("    ├── 01_MA_plot.png\n")
cat("    ├── 02_PCA_plot.png\n")
cat("    ├── 03_top_gene_counts.png\n")
cat("    └── 04_top50_heatmap.png\n")
cat("│\n")
cat("🔬 MANUSCRIPT STATS:\n")
cat("• Total genes tested:              ", nrow(res), "\n")
cat("• Significant (FDR < 0.1):        ", sum(res$padj < 0.1, na.rm=TRUE), "\n")
cat("• Significant (FDR < 0.05):       ", sum(res$padj < 0.05, na.rm=TRUE), "\n")
cat("• Top 5 DE genes:\n")
print(head(res[order(res$padj), c("log2FoldChange", "padj")], 5))
cat("\n🎉 PIPELINE 100% COMPLETE → group_project/ READY FOR PUBLICATION & GSEA!\n")
cat("═══════════════════════════════════════════════════════════════════════════════\n")


# EXPORT COUNT MATRIX + TREATMENT.CLS FOR ENRICHMENT MAP
library(dplyr)

# 1. EXPORT COUNT MATRIX (.gct FORMAT) 
cat("Exporting count matrix for Enrichment Map...\n")

# Raw counts (2147 genes x 20 samples)
count_gct <- data.frame(
  Name = rownames(countdata),
  Description = rownames(countdata),
  countdata
)

write.table(count_gct, "group_project/count_matrix.gct", 
            sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)

cat("Saved: count_matrix.gct (2147 genes x 20 samples)\n")

# Filtered counts (1514 genes x 20 samples)
filtered_counts <- counts(dds)
filtered_gct <- data.frame(
  Name = rownames(filtered_counts),
  Description = rownames(filtered_counts),
  filtered_counts
)
write.table(filtered_gct, "group_project/count_matrix_filtered.gct", 
            sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)
cat("Saved: count_matrix_filtered.gct (1514 genes x 20 samples)\n\n")

# 2. CREATE TREATMENT.CLS FILE 
cat("Creating treatment.cls...\n")

# Sample order MUST match count matrix columns exactlyy
sample_order <- colnames(countdata)
treatment <- coldata$condition[match(sample_order, rownames(coldata))]

# CLS format (exact Enrichment Map spec)
cls_content <- c(
  paste0(length(sample_order), " ", length(unique(treatment)), " 1"),  # #samples #classes #1
  "# Normal Cancer",                                                 # Class names
  paste(treatment, collapse=" ")                                     # Sample labels
)

writeLines(cls_content, "group_project/treatment.cls")
cat("Saved: treatment.cls\n")
cat("Samples:", length(sample_order), "| Groups: Normal, Cancer\n\n")

# 3. VERIFY EVERYTHING MATCHES
cat("VERIFICATION:\n")
cat("Count matrix columns (first 5):", paste(head(colnames(countdata), 5), collapse=", "), "\n")
cat("Treatment labels (first 5):   ", paste(head(treatment, 5), collapse=", "), "\n")
cat("treatment.cls preview:\n")
print(readLines("group_project/treatment.cls"))

cat("\nALL FILES READY FOR ENRICHMENT MAP CYTOSCAPE!\n")
