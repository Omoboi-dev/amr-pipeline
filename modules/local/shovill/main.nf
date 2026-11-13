process SHOVILL {
    tag "$meta.id"
    publishDir "${params.outdir}/assembly", mode: 'copy'

    conda 'bioconda::shovill=1.4.2'
    container 'quay.io/biocontainers/shovill:1.4.2--hdfd78af_1'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.contigs.fa'), emit: contigs
    path '*.shovill.log',                  emit: log

    script:
    def prefix = meta.id
    """
    shovill \\
        --R1 ${reads[0]} \\
        --R2 ${reads[1]} \\
        --outdir shovill_out \\
        --assembler ${params.assembler} \\
        --minlen 200 \\
        --namefmt '${prefix}_contig%05d' \\
        --cpus ${task.cpus} \\
        --ram ${task.memory.toGiga()}

    cp shovill_out/contigs.fa ${prefix}.contigs.fa
    cp shovill_out/shovill.log ${prefix}.shovill.log
    """
}
