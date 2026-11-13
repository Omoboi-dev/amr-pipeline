process QUAST {
    publishDir "${params.outdir}", mode: 'copy'

    conda 'bioconda::quast=5.3.0'
    container 'quay.io/biocontainers/quast:5.3.0--py313pl5321h5ca1c30_2'

    input:
    path contigs

    output:
    path 'quast', emit: results

    script:
    def labels = [contigs].flatten().collect { it.name.replace('.contigs.fa', '') }.join(',')
    """
    quast.py ${contigs} \\
        --labels ${labels} \\
        --output-dir quast \\
        --threads ${task.cpus}
    """
}
