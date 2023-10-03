### PacBio Long-read RNA-seq data processing pipeline

The following pipelines `snakefile` and `snakefile_pigeon` were designed and developed to process probe-enriched PacBio long-read RNA-seq data. 

* `snakefile` contains the upstream part of the analysis.
* `snakefile_pigeon` contains the downstream part of the analysis.

This pipeline is also compatible with bulk RNA-seq PacBio long-read data.

Note these Snakemake pipelines make use of conda environments. `.yaml` environment files are also included in this repository. However, prior to use, switch `prefix: YOUR_PATH` placeholder with your conda path.