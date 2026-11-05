process run_dragen {
	label 'run_dragen'

	input:
	tuple path(fastq_list),	path(fastq_files)
	
	output:
	val(x)

	shell:
	x="dummy"
	template 'run_dragen.sh'
}