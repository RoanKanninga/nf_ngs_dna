process multiqc {

	publishDir "${samples.flatten().find{ it.projectResultsDir }.projectResultsDir}", mode: 'copy', pattern: "multiqc_report.html"

	input:
	val(samples)

	output:
	path("multiqc_report.html")

	shell:
	def s = samples.flatten().find{ it.projectResultsDir }
	"""
		ml purge
		ml multiqc/1.35-GCCcore-11.3.0
			multiqc "${s.projectResultsDir}/qc/" -o .
	"""
}