#!/usr/bin/env nextflow

// Enable DSL 2 syntax
nextflow.enable.dsl = 2

// Pipeline parameters
params.reads = "data/mini.fastq.gz"
params.outdir = "results"
params.threads = 4

// Log info
log.info """\
         GENOMICS PIPELINE
         ================
         reads        : ${params.reads}
         outdir      : ${params.outdir}
         threads     : ${params.threads}
         """
         .stripIndent()

// Process 1: Quality control with fastp
process FASTP {
    tag "FASTP on $sample_id"
    publishDir "${params.outdir}/fastp", mode: 'copy'
    
    conda "bioconda::fastp=0.23.4"

    input:
    tuple val(sample_id), path(read)

    output:
    tuple val(sample_id), path("*_cleaned.fastq.gz"), emit: cleaned_reads
    path "*_fastp.{json,html}", emit: fastp_reports

    script:
    """
    fastp \
        -i ${read} \
        -o ${sample_id}_cleaned.fastq.gz \
        -j ${sample_id}_fastp.json \
        -h ${sample_id}_fastp.html \
        -w ${params.threads}
    """
}

// Process 2: Assembly with SPAdes
process SPADES {
    tag "SPADES on $sample_id"
    publishDir "${params.outdir}/spades", mode: 'copy'
    
    conda "bioconda::spades=3.15.5 setuptools"

    input:
    tuple val(sample_id), path(cleaned_read)

    output:
    tuple val(sample_id), path("${sample_id}_assembly"), emit: assembly_dir
    path "${sample_id}_assembly/contigs.fasta", emit: contigs

    script:
    """
    spades.py \
        --sc \
        -s ${cleaned_read} \
        -o ${sample_id}_assembly \
        -t ${params.threads}
    """
}

// Process 3: Read metrics with SeqKit
process SEQKIT {
    tag "SEQKIT on $sample_id"
    publishDir "${params.outdir}/seqkit", mode: 'copy'
    
    conda "bioconda::seqkit=2.5.1"

    input:
    tuple val(sample_id), path(cleaned_read)

    output:
    path "${sample_id}_stats.txt", emit: stats

    script:
    """
    seqkit stats -a ${cleaned_read} > ${sample_id}_stats.txt
    """
}

// Workflow definition
workflow {
    // Create channel from input reads
    read_ch = Channel
        .fromPath(params.reads)
        .map { file -> tuple(file.simpleName, file) }

    // Run FASTP (Module 1)
    FASTP(read_ch)

    // Run SPADES (Module 2) and SEQKIT (Module 3) in parallel using FASTP output
    SPADES(FASTP.out.cleaned_reads)
    SEQKIT(FASTP.out.cleaned_reads)
}

// Workflow completion notification
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
} 