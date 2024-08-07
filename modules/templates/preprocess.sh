#!/bin/bash

set -o pipefail
set -eu

rename "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" "!{samples.combinedIdentifier}"*

bedfile=!{params.dataDir}/!{samples.capturingKit}/human_g1k_v37/captured.merged.bed

grep "!{samples.combinedIdentifier}" "!{samples.projectResultsDir}/qc/stats.tsv" | perl -p -e "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|" >>  "!{samples.projectResultsDir}/qc/statsRenamed.tsv"

if [[ "!{samples.build}" == "GRCh38" ]]
then
    bedfile="!{params.bedfile_GRCh38}"
fi

bcftools annotate -x 'FORMAT/AF,FORMAT/F1R2,FORMAT/F2R1,FORMAT/GP' "!{samples.externalSampleID}.hard-filtered.vcf.gz" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf"
bgzip -c -f "!{samples.externalSampleID}.variant.calls.genotyped.vcf" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
rsync -Lv "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"* "!{samples.projectResultsDir}/variants/"

if [[ -e "!{samples.externalSampleID}.hard-filtered.gvcf.gz" ]]
then
    rename ".gvcf.gz" ".g.vcf.gz" "!{samples.externalSampleID}.hard-filtered.gvcf.gz"*
    rsync -Lv "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"* "!{samples.projectResultsDir}/variants/gVCF/"
fi

if [[ -e "!{samples.externalSampleID}.bam" ]]
then
    for i in "!{samples.externalSampleID}.bam"*
    do  
        mv $(readlink ${i}) "!{samples.projectResultsDir}/alignment/"
    done
    rename "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" "!{samples.projectResultsDir}/alignment/"*
fi
if [[ -e "!{samples.externalSampleID}.sv.vcf.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}.sv.vcf.gz"* "!{samples.projectResultsDir}/variants/sv/"
fi
if [[ -e "!{samples.externalSampleID}.cnv.vcf.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*cnv* "!{samples.projectResultsDir}/variants/cnv/"
fi 
if [[ -e "!{samples.externalSampleID}.html" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*.{bed,json,html} "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.seg" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*seg* "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.target.counts.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*target.counts* "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.tn.bw" ]]
then
    rsync -Lv "!{samples.externalSampleID}"*tn.tsv.gz "!{samples.projectResultsDir}/qc/"
		rsync -Lv "!{samples.externalSampleID}"*.bw "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.improper.pairs.bw" ]]
then
    rsync -Lv "!{samples.externalSampleID}.improper.pairs.bw" "!{samples.projectResultsDir}/qc/"
fi
if [[ -e "!{samples.externalSampleID}.ploidy.vcf.gz" ]]
then
    rsync -Lv "!{samples.externalSampleID}.ploidy.vcf.gz"* "!{samples.projectResultsDir}/variants/"
fi
if [[ -e "sv" ]]
then
    rsync -Lv "sv" "!{samples.projectResultsDir}/qc/sv_!{samples.externalSampleID}"
fi
