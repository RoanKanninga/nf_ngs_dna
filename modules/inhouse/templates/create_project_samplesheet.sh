rawdata=$(basename "!{params.samplesheet}" '.csv') 

touch stats.tsv

declare -a sampleSheetColumnNames=()
declare -A sampleSheetColumnOffsets=()
declare    sampleSheetFieldIndex
declare    sampleSheetFieldValueCount

IFS="," read -r -a sampleSheetColumnNames <<< "$(head -1 !{params.samplesheet})"
for (( offset = 0 ; offset < ${#sampleSheetColumnNames[@]} ; offset++ ))
do
	columnName="${sampleSheetColumnNames[${offset}]}"
	sampleSheetColumnOffsets["${columnName}"]="${offset}"

done

if [[ -n "${sampleSheetColumnOffsets['externalSampleID']+isset}" ]]; then
  externalSampleIDFieldIndex=$((${sampleSheetColumnOffsets['externalSampleID']} + 1))
fi
if [[ -n "${sampleSheetColumnOffsets['project']+isset}" ]]; then
  projectFieldIndex=$((${sampleSheetColumnOffsets['project']} + 1))
fi

awk -v p=${projectFieldIndex} 'BEGIN {FS=","}{if (NR>1){print $p}}' "!{params.samplesheet}" > projects.txt
sort -V projects.txt | uniq > uniqprojects.csv

mkdir POST_DRAGEN
while read project
do
	head -1 "!{params.samplesheet}" > "POST_DRAGEN/${project}.csv"
	grep "${project}" "!{params.samplesheet}" >> "POST_DRAGEN/${project}.csv"
done< uniqprojects.csv

touch "!{params.tmpDataDir}/logs/${rawdata}/run01.demultiplexing.finished"