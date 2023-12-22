#####################################################################
# Last updated 2023-12-14 - Alexander Van Nynatten
# Pipeline to remove primers and heterogeneity spacers using cutadapt
#####################################################################
## Imports files and loads libraries

#####################################################################
## Step 1 - Cutadapt to remove primer sequences

# extracts tar balls into a second folder for analysis
for f in *.tar.gz; do tar xf "$f" -C ../unzipped/; done # Raw sequence files available on SRA

cd ../raw_data/raw_sequences

# Removes primer sequences and heterogeneity spacers from the forward and reverse reads
ls *_read2.fastq | cut -f1,2 -d "_" > samples \

for sample in $(cat samples)
do

    echo "On sample: $sample"
    
    cutadapt -g GTCATCTTCTTCTGCTACGG \
    -G GCCGGAATGGTCATGAAGA \
    -m 120 -M 150 --discard-untrimmed \
    -o ${sample}_sub_R1_trimmed.fq.gz -p ${sample}_sub_R2_trimmed.fq.gz \
    ${sample}_210513_miseq2_read1.fastq ${sample}_210513_miseq2_read2.fastq \
    >> cutadapt_primer_trimming_stats.txt 2>&1

done

mv *.gz ../../04_Rho_metabarcoding_assay/01_output/trimmed/

#####################################################################
