process FASTP {
    tag "$meta.id"
    publishDir "${params.outdir}/fastp", mode: 'copy', pattern: '*.{html,json}'

    conda 'bioconda::fastp=1.3.6'
    container 'quay.io/biocontainers/fastp:1.3.6--h43da1c4_0'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.trim.fastq.gz'), emit: reads
    tuple val(meta), path('*.fastp.json'),    emit: json
    path '*.fastp.html',                      emit: html

    script:
    def prefix = meta.id
    """
    fastp \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${prefix}_1.trim.fastq.gz \\
        --out2 ${prefix}_2.trim.fastq.gz \\
        --json ${prefix}.fastp.json \\
        --html ${prefix}.fastp.html \\
        --thread ${task.cpus} \\
        --detect_adapter_for_pe \\
        --cut_right \\
        --cut_right_window_size 4 \\
        --cut_right_mean_quality 20 \\
        --length_required 50
    """
}
