# Rhodopsin_convergence_in_deepwater_plostglacial_fishes
Code and files for manuscript

- 01_Rho_allele_distribution
  -- 01_Allele_lake_plot.R: Plots the distribution of rhodopsin alleles in both species as a scatter plot (Fig 1b)
  -- 02_Allele_huron_plot.R: Barplot of the distribution of rhodopsin alleles in Lake Huron ciscoes (Fig 1d)
  -- 03_Canada_location_map.R: Maps the locations sampled in the study across Canada (Fig 1a)
  -- 04_Allele_bathymetry_map.R: Maps sampling sites in Lake Huron (Fig 1c)
  -- LakeHuron_sampling.csv: Location data for samples collected in Lake Huron
  -- Rh1_allele_data.csv: Allele information for each sequence included in the study
  -- Sample_location_codes.csv: Location data for samples collected across Canada

- 02_Rho_spectral_sensitivity
  -- 01_Downwelling_light_plot.R: Plots the downwelling light spectra underwater in Lake Huron (Fig 2a)
  -- 02_Lmax_curves_plot.R: Plots the absorbance spectra of different rhodopsin sequences (Fig 2b)
  -- 03_a_measure_distances.py: Generates command line input to measure distances in UCSF Chimera (Fig 2c)
  -- 03_b_centroid_generator.py: Quick code to generate centroids for each amino acid sidechain in rhodopsin (Fig 2c)
  -- 03_c_distance_plot_rho.R: Plots the distance to the chromophore and site 261 in sites that differ in ciscoes and sculpin (Fig 2c)
  -- Io_Jerome1983.csv: Incident light data digitized from Jerome 1983
  -- Kd_Jerome1983.csv: Underwater light attenuation data digitized from Jerome 1983
  
- 03_Rho_phylogeny_ecology
  -- 01_Salmonid_phylogeny_and_depth_plot.R: Plots the species tree of salmonids showing ecological and depth distribution (Fig 3)
  -- 01_Sculpin_phylogeny_and_depth_plot.R: Plots the species tree of salmonids showing ecological and depth distribution (Fig 3)
  -- 02_ASR_rst_extractor.py: Python script for extracting information from PAML rst file output
  -- 03_ASR_substitution_summary.R: Converts PAML RST output files to a list of aa substitutions by branch
  -- 04_Post_prob_nodelabels_plot.R: Plots the probability of F/Y 261 across the phylogenies (Fig 3)

- 04_Rho_metabarcoding_assay
  -- 01_a_cutadapt_Rho_pipeline.R: Pipeline to remove primers and heterogeneity spacers using cutadapt
  -- 01_b_dada2_Rho_pipeline.R: Pipeline using DADA2 to denoise EniRho metabarcoding data
  -- 02_Rho_metabarcoding_comparison_plot.R: Plots a comparison of the metabarcoding data to the true allele frequency from Sanger results  (Fig 4)
  -- Sample_codes.csv: Reference codes for the samples sequences using DNA metabarcoding 
  
