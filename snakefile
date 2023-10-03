## PacBio probe-enriched long-read data processing pipeline
## Adopted from IsoSeq workflow for long-read transcriptomic data processing

# Note that snakefile is executed from a directory within root analysis directory.
# Hence, relative path is provided with '../' prefix

# Sample wild cards 
IDS, = glob_wildcards("../data/{id}.bam")

# List output files to check for completion
rule all:
    input:
        expand("../refine/{id}.flnc.bam", id=IDS),
        expand("../cluster/{id}.polished.bam", id=IDS),
        expand("../map/{id}.aligned.bam", id=IDS),
        expand("../collapse/{id}.collapsed.gff", id=IDS),

# Refine with isoseq3
# Remove ployA and concatemers from full length tx sequences
# Input: Demultiplexed bam files with no primers or barcodes per sample with correct orientation
# Output: polyA trimmed and concatemer filtered reads
rule refine:
    input: "../data/{id}.bam"
    output: "../refine/{id}.flnc.bam"
    conda: "isoseq_env.yaml"
    benchmark: "../benchmarks/{id}_refine.benchmark"
    params:
        log = "../logs/{id}_refine.log"
    shell: '''isoseq refine --require-polya -j 12 --log-level TRACE --log-file {params.log} {input} ../barcodes.fa {output}'''

# Cluster with isoseq3
# Generate full-length transcripts
# Input: polyA trimmed and concatemer filtered reads
# Output: Consensus sequences of identified clusters
rule cluster:
    input: "../refine/{id}.flnc.bam"
    output: "../cluster/{id}.polished.bam"
    conda: "isoseq_env.yaml"
    resources:
        load = 50
    benchmark: "../benchmarks/{id}_cluster.log"
    params:
        log = "../logs/{id}_cluster.log"
    shell: '''isoseq cluster --verbose --use-qvs -j 32 --log-level TRACE --log-file {params.log} {input} {output}'''

# Align with minimap2 (pbmm2)
# Input: Consensus sequences of identified clusters
# Output: Aligned reads to provided reference
rule pbmm2_align:
    input: "../cluster/{id}.polished.bam"
    output: "../map/{id}.aligned.bam"
    conda: "pbmm2_env.yaml"
    benchmark: "../benchmarks/{id}_align.log"
    resources:
        load = 50
    params:
        log = "../logs/{id}_pbmm2_align.log",
        hq_bam = "../cluster/{id}.polished.hq.bam"
    shell:'''pbmm2 align --sort -m 20G -j 32 --preset ISOSEQ --log-level TRACE --log-file {params.log} /mnt/pacbio_long_read/ref/Homo_sapiens-GCA_009914755.4-softmasked_chr.mmi {params.hq_bam} {output}'''

# Collapse with isoseq
# Generate annotation and collapse redundant transcripts based on exonic locations
# Additional parameters to use if needed: --max-5p-diff 5 --max-3p-diff 5 --min-aln-coverage 0.60 --min-aln-identity 0.90
# Input: Assembled isoforms generated from mapped data
# Output: Collapsed redundant isoforms into unique isoforms
rule collapse:
    input: "../map/{id}.aligned.bam"
    output: "../collapse/{id}.collapsed.gff"
    conda: "isoseq_env.yaml"
    benchmark: "../benchmarks/{id}_collapse.log"
    params:
        log = "../logs/{id}_collapse.log"
    shell:'''isoseq collapse --do-not-collapse-extra-5exons -j 24 --log-level TRACE --log-file {params.log} {input} {output}'''