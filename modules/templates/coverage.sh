#!/bin/bash

set -o pipefail
set -eu

outputName="PseudoExome"
bedfile="!{params.dataDir}/UMCG/Diagnostics/Exoom_v4/human_g1k_v37/Exoom_v4.merged.bed"

if [[ !{samples.capturingKit} == *"Targeted"* ]]
then
	bedfile="!{params.dataDir}/Agilent/Targeted_v6/human_g1k_v37/captured.merged.bed"
	outputName=$(echo "!{samples.capturingKit}" | awk 'BEGIN {FS="/"}{print $2}')
fi

if [[ "!{samples.build}" == "GRCh38" ]]
then
    bedfile="!{params.bedfile_GRCh38}"
fi

bcftools view --regions-file "${bedfile}"  -O z -o "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz"  "!{samples.projectResultsDir}/variants/gVCF/!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz"

outputFile="!{samples.externalSampleID}.${outputName}.CoverageOutput.csv"

gvcf2bed2.py \
-I "!{samples.externalSampleID}.hard-filtered.${outputName}.g.vcf.gz" \
-O "${outputFile}" \
-b "${bedfile}"

awk '{sumDP+=$11;sumTargetSize+=$12;sumCoverageInDpLow+=$13;sumZeroCoverage+=14}END{print "avgCov: "(sumDP/sumTargetSize)"\t%coverageBelow10: "((sumCoverageInDpLow/sumTargetSize)*100)"\t%ZeroCoverage: "((sumZeroCoverage/sumTargetSize)*100)}' "${outputFile}" > "!{samples.externalSampleID}.incl_TotalAvgCoverage_TotalPercentagebelow10x.txt"

awk 'BEGIN{OFS="\t"}{if (NR>1){print (NR-1),$1,$2+1,$3,$8,$4,$12,"CDS","1"}else{print "Index\tChr\tChr Position Start\tChr Position End\tAverage Counts\tDescription\tReference Length\tCDS\tContig"}}' "${outputFile}" > "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt"

grep -v "NC_001422.1" "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt" > "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt.tmp"
echo "phiX is removed for !{samples.externalSampleID}.${outputName}.coveragePerTarget" 
mv -v "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt.tmp" "!{samples.externalSampleID}.${outputName}.coveragePerTarget.txt"
