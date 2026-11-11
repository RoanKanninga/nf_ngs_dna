process bcl2fastq {
	label 'bcl2fastq'
	def rawdata = file(params.samplesheet).getBaseName()

	publishDir "${params.rawdataDir}/${rawdata}", mode: 'copy', pattern: "*.fq.gz"
  publishDir "${params.rawdataDir}/${rawdata}", mode: 'copy', pattern: "${file(params.samplesheet).getName()}"

	input:
	path(illuminaSamplesheet)

	output:
	tuple path("fastq_list.csv"), path("*.fq.gz")

	shell:


	template 'bcl2fastq.sh'

}