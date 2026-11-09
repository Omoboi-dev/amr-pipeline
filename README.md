# AMR gene detection pipeline

A Nextflow pipeline that takes raw Illumina sequencing reads from bacteria and reports which antimicrobial resistance (AMR) genes each sample carries.

**Status:** in development.

## Planned steps

1. Read quality control and trimming (fastp)
2. Genome assembly (Shovill)
3. Assembly quality check (QUAST)
4. AMR gene detection (AMRFinderPlus)
5. Summary report (Python and MultiQC)
