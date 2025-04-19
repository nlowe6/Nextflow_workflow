# Genomics Analysis Pipeline

This Nextflow pipeline is for BIOL7210

## Pipeline Overview

```
Sequential and Parallel Flow:

FASTP (QC) ─┬─> SPADES (Assembly)
            └─> SEQKIT (Metrics)
```

## Requirements

- Nextflow (v24.10.5)
- Conda (v24.7.1)
- WSL2 or Linux

## Quick Start

1. Clone this repository:
```bash
git clone git@github.com:nlowe6/Nextflow_workflow.git
cd Nextflow_workflow
```

2. Create Nextflow conda environment:
```bash
conda env create -f environment.yml
conda activate nf
```

3. Run the pipeline with test data:
```bash
nextflow run main.nf --reads "data/*.fastq.gz"
```

## Test Dataset

The `data/` directory contains a small test dataset. The test data is a subset of single-end reads from a bacterial genome.

## Pipeline Components

1. **FASTP** (v0.23.4)
   - Quality control and adapter trimming
   - Outputs cleaned FASTQ files and QC reports

2. **SPAdes** (v3.15.5)
   - De novo genome assembly using single-end reads
   - Outputs contigs and assembly information

3. **SeqKit** (v2.5.1)
   - Read statistics calculation
   - Outputs detailed metrics about the cleaned reads

## Output Structure

```
results/
├── fastp/
│   ├── *_cleaned.fastq.gz
│   └── *_fastp.{json,html}
├── spades/
│   ├── */assembly/
│   └── contigs.fasta
└── seqkit/
    └── *_stats.txt
```

## Parameters

- `--reads`: Input single-end reads (default: "data/*.fastq.gz")
- `--outdir`: Output directory (default: "results")
- `--threads`: Number of threads (default: 4)

