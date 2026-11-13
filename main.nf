#!/usr/bin/env nextflow

include { FASTP   } from './modules/local/fastp'
include { SHOVILL } from './modules/local/shovill'
include { QUAST   } from './modules/local/quast'

workflow {
    if (!params.input) {
        error "Please provide a samplesheet with --input"
    }

    reads_ch = channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta = [id: row.sample, species: row.species]
            def reads = [
                file(row.fastq_1, checkIfExists: true),
                file(row.fastq_2, checkIfExists: true)
            ]
            [meta, reads]
        }

    FASTP(reads_ch)
    SHOVILL(FASTP.out.reads)

    all_contigs = SHOVILL.out.contigs
        .map { meta, contigs -> contigs }
        .collect()
    QUAST(all_contigs)
}
