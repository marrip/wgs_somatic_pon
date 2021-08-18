# wgs_somatic_pon

Create panel of normals for different tools

![Snakefmt](https://github.com/marrip/wgs_somatic_pon/actions/workflows/main.yaml/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## :speech_balloon: Introduction

This snakemake workflow is designed to generate panel of normal (PoN) files for
a plethora of tools. Which can in turn be used for variant calling analyses.

### Mutect2

The PoN is generated according to the best practices from GATK as described in
[this tutorial](https://gatk.broadinstitute.org/hc/en-us/articles/360035531132).
For each `.bam` file of a normal sample variants are called using
[mutect2](https://gatk.broadinstitute.org/hc/en-us/articles/360037593851-Mutect2)
and combined into a `.vcf` file representing the PoN.

### CNVkit

For CNVkit, the docs talk about a
[reference of pooled normals](https://cnvkit.readthedocs.io/en/stable/pipeline.html#reference)
which is generated in two steps from `.bam` files of normal samples.

## :heavy_exclamation_mark: Dependencies

To run this workflow, the following tools need to be available:

![python](https://img.shields.io/badge/python-3.8-blue)
[![snakemake](https://img.shields.io/badge/snakemake-6.0.0-blue)](https://snakemake.readthedocs.io/en/stable/)
[![singularity](https://img.shields.io/badge/singularity-3.7-blue)](https://sylabs.io/docs/)

## :school_satchel: Preparations

### Sample data

1. Add all sample ids to `samples.tsv` in the column `sample`.
2. Add sample type information, normal or tumor, to `units.tsv`.
3. Use the `analysis_output` folder from
[wgs_std_viper](https://github.com/marrip/wgs_std_viper) as input.

### Reference data

1. You need a reference `.fasta` file representing the genome used
for mapping. For the different tools to work, you also
need to prepare index files and a `.dict` file.

- The required files for the human reference genome GRCh38 can be downloaded from
[google cloud](https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0).
The download can be manually done using the browser or using `gsutil` via the command line:

```bash
gsutil cp gs://genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.fasta /path/to/download/dir/
```

- If those resources are not available for your reference you may generate them yourself:

```bash
samtools faidx /path/to/reference.fasta
gatk CreateSequenceDictionary -R /path/to/reference.fasta -O /path/to/reference.dict
```

2. In order to split the variant calling process by chromosome, a locus file containg a
list of all available chromosomes is used in the analysis.
3. Mutect2 requires an `.interval_list` file which needs to be supplied. For GRCh38, the
file is also available in the google bucket.
4. Mutect2 also requires a modified  [gnomad database](https://gnomad.broadinstitute.org/) 
as a `.vcf.gz`. For GRCh38, the file can be retrieved from
[google cloud](https://console.cloud.google.com/storage/browser/gatk-best-practices/somatic-hg38;tab=objects?prefix=&forceOnObjectsSortingFiltering=false)
as described under 1.
5. Add the paths of the different files to the `config.yaml`. The index files should be
in the same directory as the reference `.fasta`.
6. Make sure that the docker container versions are correct.

## :white_check_mark: Testing

The workflow repository contains a small test dataset `.tests/integration` which can be run like so:

```bash
cd .tests/integration
snakemake -s ../../workflow/Snakefile -j1 --use-singularity
```

## :rocket: Usage

The workflow is designed for WGS data meaning huge datasets which require a lot of compute power. For
HPC clusters, it is recommended to use a cluster profile and run something like:

```bash
snakemake -s /path/to/Snakefile --profile my-awesome-profile
```

## :judge: Rule Graph

![rule_graph](https://raw.githubusercontent.com/marrip/wgs_somatic_pon/main/images/rulegraph.svg)
