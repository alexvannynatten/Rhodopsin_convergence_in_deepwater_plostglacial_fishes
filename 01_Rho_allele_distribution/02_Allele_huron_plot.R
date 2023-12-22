#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Barplot of the distribution of rhodopsin alleles in Lake Huron ciscoes
# Figure 1d
#####################################################################
## Imports files and loads libraries

library(tidyverse)

Rh1_alleles <- read.csv('Rh1_allele_data.csv')

#####################################################################
# Transforms database for plotting in ggplot

Huron_alleles_freq <- Rh1_alleles %>%
  mutate(Code = gsub('.*\\_', '', Location_code)) %>%
  filter(Code %in% c('LF1', 'LF2', 'LF3', 'SW1', 'SW2', 'DW1', 'DW2', 'DW3')) %>%
  filter(!Species == 'Coregonus clupeaformis') %>%
  mutate(Alleles = paste(Rh1_allele_1, Rh1_allele_2)) %>%
  mutate(Alleles = factor(Alleles,
  levels = rev(c('C0 C0', 'C1 C1', 'C1 C2', 'C2 C2', 'C1 C3', 'C2 C3', 'S3 S3')))) %>%
  mutate(Code = factor(Code,
  levels = c('LF1', 'LF2', 'LF3', 'SW1', 'SW2', 'DW1', 'DW2', 'DW3'))) %>%
  group_by(Alleles, Code) %>%
  summarize(Freq = n())

# Bar chart of different haplotypes
ggplot(data = Huron_alleles_freq) +
  geom_bar(aes(Freq, Alleles), stat="identity") +
  facet_grid(cols = vars(Code)) +
  geom_text(aes(Freq, Alleles, label = Freq)) + 
  theme_void()

ggsave('02_output/allele_facet_plot_out.pdf')

#####################################################################
# Some extra data to add to supp table S1 for Lake Huron

Rho_allele_table_huron <- Rh1_alleles %>%
  mutate(Code = gsub('.*\\_', '', Location_code)) %>%
  filter(Code %in% c('LF1', 'LF2', 'LF3', 'SW1', 'SW2', 'DW1', 'DW2', 'DW3')) %>%
  select(Species, Code, Rh1_allele_1, Rh1_allele_2) %>% 
  pivot_longer(!c(Species, Code), 
    names_to = "Allele_name", values_to = "Allele_type") %>%
  group_by(Allele_type, Species) %>%
  summarize(n = n()) 

write.csv(Rho_allele_table_huron, '02_output/Rho_allele_table_huron.csv', row.names = FALSE)

#####################################################################