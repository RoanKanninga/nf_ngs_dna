#!/bin/bash

set -o pipefail
set -eu

#
# bam /cram
#
if ls !{samples.combinedIdentifier}.bam* 1> /dev/null 2>&1
then
	for file in !{samples.combinedIdentifier}.bam*
	do
		new_name=$(echo "${file}" | sed "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|")
		ln -s "${file}" "${new_name}"
	done
fi

if ls !{samples.combinedIdentifier}.cram* 1> /dev/null 2>&1
then
	for file in !{samples.combinedIdentifier}.cram*
	do
		new_name=$(echo "${file}" | sed "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|")
		ln -s "${file}" "${new_name}"
	done
fi

#
# Prep
#
perl -pi -e 's|!{samples.combinedIdentifier}|!{samples.externalSampleID}|' "!{samples.combinedIdentifier}"*.md5*

rename "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" "!{samples.combinedIdentifier}"*

bedfile=!{params.dataDir}/!{samples.capturingKit}/human_g1k_v37/captured.merged.bed

if grep "!{samples.combinedIdentifier}" "!{samples.projectResultsDir}/qc/stats.tsv"
then	
	grep "!{samples.combinedIdentifier}" "!{samples.projectResultsDir}/qc/stats.tsv" | perl -p -e "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|" >> statsRenamed.tsv
fi

perl -p -e "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|g" "!{samples.externalSampleID}.cnv.igv_session.xml" > "!{samples.externalSampleID}.cnv.igv_session.xml"

if [[ "!{samples.build}" == "GRCh38" ]]
then
	bedfile="!{params.bedfile_GRCh38}"
fi

echo -e "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" > "!{samples.externalSampleID}.newVCFHeader.txt"

#
# vcf and gVCF
#
bcftools annotate -x 'FORMAT/AF,FORMAT/F1R2,FORMAT/F2R1,FORMAT/GP' "!{samples.externalSampleID}.hard-filtered.vcf.gz" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf"
bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.variant.calls.genotyped.vcf" -o "!{samples.externalSampleID}.variant.calls.reheadered.genotyped.vcf"
bgzip -c -f "!{samples.externalSampleID}.variant.calls.reheadered.genotyped.vcf" > "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
tabix -p vcf "!{samples.externalSampleID}.variant.calls.genotyped.vcf.gz"

if [[ -e "!{samples.externalSampleID}.hard-filtered.gvcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.hard-filtered.gvcf.gz" -o "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
	md5sum "!{samples.externalSampleID}.hard-filtered.g.vcf.gz" > "!{samples.externalSampleID}.hard-filtered.g.vcf.gz.md5"
fi

#
# SV and CNV
#
if [[ -e "!{samples.externalSampleID}.sv.vcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.sv.vcf.gz" -o "!{samples.externalSampleID}.sv.reheadered.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.sv.reheadered.vcf.gz"
fi

if [[ -e "!{samples.externalSampleID}.cnv.vcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.cnv.vcf.gz" -o "!{samples.externalSampleID}.cnv.reheadered.vcf.gz"
	mv "!{samples.externalSampleID}.cnv.reheadered.vcf.gz" "!{samples.externalSampleID}.cnv.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.cnv.vcf.gz"
	md5sum "!{samples.externalSampleID}.cnv.vcf.gz" > "!{samples.externalSampleID}.cnv.reheadered.vcf.gz.md5"
fi

#
# SV
#
if [[ -e "sv" ]]
then
	mv 'sv' 'sv_dir'
fi

#
#additional analysis
#
if [[ -e "!{samples.externalSampleID}.targeted.json" ]]
then
	perl -p -e "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|g" "!{samples.externalSampleID}.targeted.json" > "!{samples.externalSampleID}.targeted.renamed.json"
fi

if [[ -e "!{samples.externalSampleID}.targeted.vcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.targeted.vcf.gz" -o "!{samples.externalSampleID}.targeted.reheadered.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.targeted.reheadered.vcf.gz"
fi

if [[ -e "!{samples.externalSampleID}.repeats.vcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.repeats.vcf.gz" -o "!{samples.externalSampleID}.repeats.reheadered.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.repeats.reheadered.vcf.gz"
fi