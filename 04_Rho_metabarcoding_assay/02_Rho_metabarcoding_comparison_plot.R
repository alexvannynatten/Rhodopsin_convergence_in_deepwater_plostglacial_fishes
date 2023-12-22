#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Plots a comparison of the metabarcoding data to the true allele frequency from Sanger results 
# Fig 4
#####################################################################
## Imports files and loads libraries

library(tidyverse)

Sanger_results <- read.csv('../01_Rho_allele_distribution/Rh1_allele_data.csv')
MiSeq_results <- read.csv('/01_output/seqtab_df_out.csv')

#####################################################################
# Formats the data for combining the MiSeq results with the true frequency

true_counts <- Sanger_results %>%
  mutate(Code = gsub('.*\\_', '', Location_code)) %>%
  filter(Code %in% c('LF1', 'LF2', 'LF3', 'SW1', 'SW2', 'DW1', 'DW2', 'DW3')) %>%
  select(Species, Code, Rh1_allele_1, Rh1_allele_2) %>% 
  pivot_longer(!c(Species, Code), 
    names_to = "Allele_name", values_to = "Allele") %>%
  select(!c(Allele_name, Species)) %>%
  mutate(Freq = 1) %>%
  mutate(Type = 'Sanger')

names(MiSeq_results) <- c('Sample', 'Allele', 'Freq', 'Code')
MiSeq_results$Allele <- gsub('Coregonus_artedi_', 'C', MiSeq_results$Allele)
MiSeq_results$Allele <- gsub('Myoxocephalus_thompsonii_', 'S', MiSeq_results$Allele)
MiSeq_results$Allele[MiSeq_results$Allele =='Coregonus_clupeiformis'] <- 'C0'

mb_counts <- aggregate(Freq ~ Code+Allele, MiSeq_results, sum)
mb_counts$Type <- 'Metabarcoding'

mb_counts_avg <- aggregate(Freq ~ Code+Allele, data = mb_counts, sum)
mb_counts_avg$Type <- 'Metabarcoding'

#####################################################################
# Plots the data

read_plot_df <- rbind(mb_counts, true_counts[names(mb_counts)])

ggplot(read_plot_df, aes(fill=Allele, y=paste(Code,Type), x=Freq)) + 
    geom_bar(position="fill", stat="identity", colour = 'black') + 
    theme_test()

ggsave('02_output/Read_count_comparison_plot.pdf')

#####################################################################