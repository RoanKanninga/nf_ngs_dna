#!/bin/bash

set -o pipefail
set -eu

#
# bam /cram
#
if ls "!{samples.combinedIdentifier}.bam"* 1> /dev/null 2>&1
then
	for file in "!{samples.combinedIdentifier}.bam"*
	do
		# Vervang de oude identifier door de nieuwe in de bestandsnaam
		new_name=$(echo "${file}" | sed "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|")
		ln -s "${file}" "${new_name}"
	done
fi


#Prep
perl -pi -e 's|!{samples.combinedIdentifier}|!{samples.externalSampleID}|' "!{samples.combinedIdentifier}"*.md5
rename "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" "!{samples.combinedIdentifier}"*
bedfile="!{params.dataDir}/!{samples.capturingKit}/human_g1k_v37/captured.merged.bed"

if grep "!{samples.combinedIdentifier}" "!{samples.projectResultsDir}/qc/stats.tsv"
then	
	grep "!{samples.combinedIdentifier}" "!{samples.projectResultsDir}/qc/stats.tsv" | perl -p -e "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|" >>  "!{samples.projectResultsDir}/qc/statsRenamed.tsv"
fi

perl -p -e "s|!{samples.combinedIdentifier}|!{samples.externalSampleID}|g" "!{samples.externalSampleID}.cnv.igv_session.xml" > "!{samples.projectResultsDir}/qc/!{samples.externalSampleID}.cnv.igv_session.xml"
echo -e "!{samples.combinedIdentifier}" "!{samples.externalSampleID}" > "!{samples.externalSampleID}.newVCFHeader.txt"

#
## gVCF
#
if [[ -e "!{samples.externalSampleID}.hard-filtered.gvcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.hard-filtered.gvcf.gz" -o "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.hard-filtered.g.vcf.gz"
	md5sum "!{samples.externalSampleID}.hard-filtered.g.vcf.gz" > "!{samples.externalSampleID}.hard-filtered.g.vcf.gz.md5"
fi

#
## sv
#
if [[ -e "!{samples.externalSampleID}.sv.vcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.sv.vcf.gz" -o "!{samples.externalSampleID}.sv.reheadered.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.sv.reheadered.vcf.gz"
fi

#
## cnv
#
if [[ -e "!{samples.externalSampleID}.cnv.vcf.gz" ]]
then
	bcftools reheader -s "!{samples.externalSampleID}.newVCFHeader.txt" "!{samples.externalSampleID}.cnv.vcf.gz" -o "!{samples.externalSampleID}.cnv.reheadered.vcf.gz"
	mv "!{samples.externalSampleID}.cnv.reheadered.vcf.gz" "!{samples.externalSampleID}.cnv.vcf.gz"
	tabix -p vcf "!{samples.externalSampleID}.cnv.vcf.gz"
	md5sum "!{samples.externalSampleID}.cnv.vcf.gz" > "!{samples.externalSampleID}.cnv.reheadered.vcf.gz.md5"

fi

