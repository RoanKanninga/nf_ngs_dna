#!/bin/bash

set -o pipefail
set -eu

echo -e "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" > "!{samples.externalSampleID}.newVCFHeader.txt"
bedfile="!{params.dataDir}/!{samples.capturingKit}/human_g1k_v37/captured.merged.bed"

if [[ "!{samples.build}" == "GRCh38" ]]
then
	bedfile="!{params.bedfile_GRCh38}"
fi

echo "##intervals=[${bedfile}]" > "bedfile.txt"
bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{genotypedVCFgz_in}" | bcftools annotate -h "bedfile.txt" -O v -o "reheadered_annotated.tmp.vcf"

bedtools intersect -header -a "reheadered_annotated.tmp.vcf" -b ${bedfile} > "!{samples.externalSampleID}.captured.vcf"

bgzip -c -f "!{samples.externalSampleID}.captured.vcf" > "!{samples.externalSampleID}.captured.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.captured.vcf.gz"

touch "!{params.tmpDataDir}/logs/!{samples.project}/run01.nextflow_pipeline.finished"

