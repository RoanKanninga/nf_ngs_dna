process run_dragen_solo {
  maxForks 1
  label 'run_dragen_solo'
	def rawdata = file(params.samplesheet).getBaseName()
	publishDir "!{params.resultsDir}/${rawdata}/Analysis", mode: 'copy', pattern: "stats.tsv"

	input:
	tuple val(samples), path(fastqList)

	output:
	val(x)

	shell:
	x="dummy"

	template 'run_dragen_solo.sh'
}