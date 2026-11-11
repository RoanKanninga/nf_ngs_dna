rawdata=$(basename "!{params.samplesheet}" '.csv')

if 	"/opt/dragen/!{params.dragenVersion}/bin/dragen" -f --bcl-conversion-only true --bcl-input-directory "!{params.sequencersDir}/${rawdata}/"  --output-directory "."  --sample-sheet "!{illuminaSamplesheet}"
then
	cp 'Reports/fastq_list.csv' 'fastq_list.csv'
else
  echo "Something went wrong with the execution of the bcl-conversion"
	exit
fi

cp "!{params.samplesheet}" '.'
	
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

if [[ -n "${sampleSheetColumnOffsets['externalSampleID']+isset}" ]]; then externalSampleIDFieldIndex=$((${sampleSheetColumnOffsets['externalSampleID']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['sequencingStartDate']+isset}" ]]; then sequencingStartDateFieldIndex=$((${sampleSheetColumnOffsets['sequencingStartDate']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['sequencer']+isset}" ]]; then sequencerFieldIndex=$((${sampleSheetColumnOffsets['sequencer']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['run']+isset}" ]]; then runFieldIndex=$((${sampleSheetColumnOffsets['run']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['flowcell']+isset}" ]]; then flowcellFieldIndex=$((${sampleSheetColumnOffsets['flowcell']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['lane']+isset}" ]]; then laneFieldIndex=$((${sampleSheetColumnOffsets['lane']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['barcode']+isset}" ]]; then barcodeFieldIndex=$((${sampleSheetColumnOffsets['barcode']} + 1)); fi
if [[ -n "${sampleSheetColumnOffsets['capturingKit']+isset}" ]]; then capturingKitFieldIndex=$((${sampleSheetColumnOffsets['capturingKit']} + 1)); fi

echo -e "${externalSampleIDFieldIndex}\t${sequencingStartDateFieldIndex}\t${sequencerFieldIndex}\t${runFieldIndex}\t${flowcellFieldIndex}\t${laneFieldIndex}\t${barcodeFieldIndex}"

count=1
while read line
do
	if [[ "${count}" == 1 ]]
	then
		count=2
		continue
	fi 

	externalSampleID=$(echo "${line}" | awk -v eIndex="${externalSampleIDFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	sequencingStartDate=$(echo "${line}" | awk -v eIndex="${sequencingStartDateFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	sequencer=$(echo "${line}" | awk -v eIndex="${sequencerFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	run=$(echo "${line}" | awk -v eIndex="${runFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	flowcell=$(echo "${line}" | awk -v eIndex="${flowcellFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	lane=$(echo "${line}" | awk -v eIndex="${laneFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	barcode=$(echo "${line}" | awk -v eIndex="${barcodeFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
	capturingKit=$(echo "${line}" | awk -v eIndex="${capturingKitFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')

	newFastQfile1="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode}_1.fq.gz"
	newFastQfile2="${sequencingStartDate}_${sequencer}_${run}_${flowcell}_L${lane}_${barcode}_2.fq.gz"
	echo -e "${externalSampleID}\t${sequencingStartDate}\t${sequencer}\t${run}\t${flowcell}\t${lane}\t${barcode}"

	oldFastQfile1=$(find . -name ${externalSampleID}*L00${lane}*_R1_*)
	oldFastQfile2=$(find . -name ${externalSampleID}*L00${lane}*_R2_*)

	oldName1=$(basename "${oldFastQfile1}")
	oldName2=$(basename "${oldFastQfile2}")

	mv "${oldFastQfile1}" "${newFastQfile1}"
	mv "${oldFastQfile2}" "${newFastQfile2}"

	sed -i "s|${oldName1}|${newFastQfile1}|g" 'fastq_list.csv'
	sed -i "s|${oldName2}|${newFastQfile2}|g" 'fastq_list.csv'

done<"!{params.samplesheet}"
count=0
while read fastq_list
do
	if [[ "${count}" == 0 ]]
	then
		echo "${fastq_list},capturingKit" > 'new_fastq_list.csv'
		count=1
	else
		extId=$(echo "${fastq_list}" | awk 'BEGIN {FS=","}{print $2}')
		captKit=$(grep ${extId} "!{params.samplesheet}" | head -1 | awk -v eIndex="${capturingKitFieldIndex}" 'BEGIN {FS=","}{print $eIndex}')
		captKit=$(echo "${captKit}" | awk 'BEGIN {FS="/"}{print $2}')
		echo -e "${fastq_list},${captKit}" >> 'new_fastq_list.csv'
	fi
done<fastq_list.csv

mv 'fastq_list.csv' 'fastq_list.csv.original'
mv 'new_fastq_list.csv' 'fastq_list.csv'
