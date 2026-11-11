process create_project_samplesheet {
  maxForks 1
	def rawdata = file(params.samplesheet).getBaseName()
	publishDir "!{params.resultsDir}/${rawdata}/Analysis", mode: 'copy', pattern: "stats.tsv"
	publishDir "${params.tmpDataDir}/Samplesheets/", mode: 'copy', pattern: "POST_DRAGEN"

	input:
	val(dummy)

	output:
	tuple path("*.tsv"), path("POST_DRAGEN")

	shell:
	template 'create_project_samplesheet.sh'
}