### PacBio Long-read RNA-seq data processing pipeline

The following pipelines `snakefile` and `snakefile_pigeon` were designed and developed to process probe-enriched PacBio long-read RNA-seq data. 

* `snakefile` contains the upstream part of the analysis.
* `snakefile_pigeon` contains the downstream part of the analysis.

However, it is also compatible with bulk RNA-seq PacBio long-read data. Some IsoSeq tools were used as part of this pipeline.

Since this Snakemake pipeline makes use of conda environments, `.yaml` environment files were also included in this repository. However, prior to use, change `YOUR_PATH` placeholder to your conda path.