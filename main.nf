#!/usr/bin/env nextflow

include { FASTP } from './modules/local/fastp'

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
}
