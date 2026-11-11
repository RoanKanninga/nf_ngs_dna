process copyInfo {
	label 'copyInfo'
	def rawdata = file(params.samplesheet).getBaseName()

  module = ['interop/1.2.0-foss-2022a']

	publishDir "!{params.resultsDir}/${rawdata}", mode: 'copy', pattern: "Info"

	input:
	tuple path(dummy), path(fastq_files)

	output:
	path ("Info")

	shell:
	samplesheet = file(params.samplesheet)
	template 'copyInfo.sh'
}