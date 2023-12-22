#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Pipeline using DADA2 to denoise EniRho metabarcoding data
#####################################################################
## Step 2 - Denoise sequencing reads using DADA2

library(dada2)
library(tidyverse)

# Loads the metabarcoding data
fnFs <- sort(list.files('01_output/trimmed', pattern="R1_trimmed.fq.gz", full.names = TRUE))
fnRs <- sort(list.files('01_output/trimmed', pattern="R2_trimmed.fq.gz", full.names = TRUE))
sample.names <- paste0('BPLRHO', sapply(strsplit(basename(fnFs), "_"), `[`, 2))

# plotQualityProfile(fnFs[1:3])
# plotQualityProfile(fnRs[1:3])

filtFs <- file.path('01_output/', "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path('01_output/', "filtered", paste0(sample.names, "_R_filt.fastq.gz"))

# Filters the data
    # Removes any sequences with Ns
    # Removes 10 bp from both ends of reads (lower quality reads)
    # Truncates the read at first base with a Phred score less than 14
    # Maximum of 1 expected error in forward and reverse reads

filterAndTrim(fnFs, filtFs, fnRs, filtRs, 
    multithread=TRUE, maxN=0, trimLeft = 10, trimRight = 10, truncQ=14, maxEE=c(1,1))

errFs <- learnErrors(filtFs)
errRs <- learnErrors(filtRs)

dadaFs <-  dada(filtFs, err=errFs, pool=TRUE)
dadaRs <- dada(filtRs, err=errRs, pool=TRUE)

mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)
seqtab <- makeSequenceTable(mergers)

# Removes chimeras and reads shorter than the expected read length of 165 bp
seqtab_nochim <- removeBimeraDenovo(seqtab, verbose=T)
seqtab_nochim_noshort <- seqtab_nochim[ ,nchar(colnames(seqtab_nochim)) > 164]

################################################################################
## Step 3 - Classifies sequences using BLAST and rhodopsin database

blast_df <- data.frame(
    Names = paste0('>', colnames(seqtab_nochim_noshort)), 
    Seqs = colnames(seqtab_nochim_noshort)
    )

sink("01_output/Rh1_variants.fas")
for(i in 1:nrow(blast_df)) {
    cat(blast_df$Names[i], "\n", blast_df$Seqs[i], "\n")
}
sink()

# system('makeblastdb -in GL_Rh1.fas -dbtype nucl -out GL_Rh1_BLAST_db') # if a new database is needed

system(gsub("[\r\n]", "", 
    'blastn 
    -task blastn 
    -query 01_output/Rh1_variants.fas 
    -db ./seq_db/GL_Rh1_BLAST_db 
    -out 01_output/seqs_classified.tsv 
    -evalue 1e-6 
    -max_target_seqs 1 
    -outfmt "6 qseqid sseqid pident"'
    ))

LH_Rh1_seqs <- read.table('01_output/seqs_classified.tsv', sep = '\t', header = FALSE)
LH_Rh1_seqs <- LH_Rh1_seqs[LH_Rh1_seqs$V3 > 99.0, ]

colnames(seqtab_nochim_noshort) <- ifelse(colnames(seqtab_nochim_noshort) %in% LH_Rh1_seqs$V1,
    LH_Rh1_seqs$V2[match(colnames(seqtab_nochim_noshort), LH_Rh1_seqs$V1)],
    'unclassified')

################################################################################
## Step 4 - Transforms data for plotting and corrects for possible contamination

# Simplifies row names
rownames(seqtab_nochim_noshort) <- sapply(strsplit(rownames(seqtab_nochim_noshort), "_"), `[`, 1)

# Converts sequence table to a tidy dataframe
seqtab_df <- data.frame(seqtab_nochim_noshort, Sample = rownames(seqtab_nochim_noshort))
seqtab_df_tidy <- gather(seqtab_df, 'Sequence', 'Reads', -Sample)
seqtab_df_tidy$Sequence <- sapply(strsplit(seqtab_df_tidy$Sequence, "\\."), `[`, 1)

# Adds location data to the sample names
Sample_codes <- read.csv('Sample_codes.csv')
seqtab_df_tidy$Location <- Sample_codes$Location[match(seqtab_df_tidy$Sample, Sample_codes$Sample)]

# Makes dataframe of maximum read counts for species in no template controls
NTC_df <- aggregate(Reads ~ Sequence, data = seqtab_df_tidy[seqtab_df_tidy$Location == 'NTC', ], max)

# Subtracts NTCs from sample reads
seqtab_df_tidy$Reads <- seqtab_df_tidy$Reads - 
	NTC_df$Reads[match(seqtab_df_tidy$Sequence, NTC_df$Sequence)]
seqtab_df_tidy$Reads <- ifelse(seqtab_df_tidy$Reads < 0, 0, seqtab_df_tidy$Reads)

write.csv(seqtab_df_tidy, '01_output/rho_seqtab_df_tidy.csv')

################################################################################