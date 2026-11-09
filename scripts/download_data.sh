#!/usr/bin/env bash
#
# Download the samples listed in assets/accessions.csv from ENA, check each
# file arrived intact (MD5), and write data/samplesheet.csv for the pipeline.
#
# Usage: bash scripts/download_data.sh

set -euo pipefail

cd "$(dirname "$0")/.."

ACCESSIONS="assets/accessions.csv"
OUTDIR="data/raw"
SAMPLESHEET="data/samplesheet.csv"
ENA_API="https://www.ebi.ac.uk/ena/portal/api/filereport"

mkdir -p "$OUTDIR"
echo "sample,species,fastq_1,fastq_2" > "$SAMPLESHEET"

tail -n +2 "$ACCESSIONS" | while IFS=, read -r run species; do
    echo "== $run ($species)"

    info=$(curl -sf "$ENA_API?accession=$run&result=read_run&fields=fastq_ftp,fastq_md5&format=tsv" | tail -n 1)
    IFS=';' read -r url1 url2 <<< "$(cut -f2 <<< "$info")"
    IFS=';' read -r md5_1 md5_2 <<< "$(cut -f3 <<< "$info")"

    for pair in "$url1 $md5_1" "$url2 $md5_2"; do
        read -r url md5 <<< "$pair"
        file="$OUTDIR/$(basename "$url")"

        if [[ -f "$file" ]] && echo "$md5  $file" | md5sum -c --status; then
            echo "   $(basename "$file") already downloaded"
            continue
        fi

        echo "   downloading $(basename "$file")"
        curl -fL -C - --retry 5 -o "$file" "https://$url"
        echo "$md5  $file" | md5sum -c --quiet
    done

    echo "$run,$species,$PWD/$OUTDIR/${run}_1.fastq.gz,$PWD/$OUTDIR/${run}_2.fastq.gz" >> "$SAMPLESHEET"
done

echo "Done. Samplesheet written to $SAMPLESHEET"
