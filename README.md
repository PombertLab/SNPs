# SNPs - SSRG
A Simple Pipeline to Assess Genetic Diversity Between Bacterial Genomes

This simple tool calculates pairwise SNPs for every possible combination in the genomes provided as input.

- I. queryNCBI.pl downloads genomes from the NCBI Genomes FTP site. The Tab-delimited input list can be generated from NCBI's Genome Assembly and Annotation reports (e.g. http://www.ncbi.nlm.nih.gov/genome/genomes/186?#).
-	II. SSRG.pl generates FASTQ datasets from fasta files at user specified read lengths, with coverages of 50X or 100X. Note that this works only for haploid genomes. This tool is especially useful to compare genomes in databases for which sequencing reads are unavailable.
-	III. get_SNPs.pl maps FASTQ files provided against references genomes using BWA, Bowtie2 or HISAT2, as specified by the user. SNPs and indels (optional) are then calculated with Samtools + VarScan2. Both synthetic reads generated by SSRG.pl and/or regular FASTQ files using the Sanger Q33 scoring scheme can be used as input.
-	IV. SNPs reported in the VCF files can be summarized with count_SNPs.pl.

Requirements:
- Unix/Linux or MacOS X
- Perl 5
- BWA 0.7.12 - http://bio-bwa.sourceforge.net/
- Bowtie2 2.2.9+ - http://bowtie-bio.sourceforge.net/bowtie2/index.shtml
- HISAT2 2.0+ - https://ccb.jhu.edu/software/hisat2/index.shtml
- Samtools 0.1.19 - http://www.htslib.org/
- VarScan2 2.4.2+ - http://dkoboldt.github.io/varscan/

## On Fedora
dnf install bwa; dnf install samtools
