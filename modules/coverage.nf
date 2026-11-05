process coverage {
	maxForks 20

	module = ['HTSlib/1.16-GCCcore-11.3.0','BCFtools/1.16-GCCcore-11.3.0','gVCF2BED/1.2.0-GCCcore-11.3.0']

	publishDir "${samples.projectResultsDir}/coverage", mode: 'copy', saveAs: { filename ->
		def gender = samples.Gender ? samples.Gender.toLowerCase() : 'unknown'
		if (gender != 'male' && gender != 'female') {
		gender = 'unknown'
		}

		if (filename.endsWith('.incl_TotalAvgCoverage_TotalPercentagebelow10x.txt')) {
			return filename
		}
		else if (filename.contains('.coveragePerTarget')) {
			return "CoveragePerTarget/${gender}/${filename}"
		}
		else if (filename.contains('.coveragePerBase')) {
			return "CoveragePerBase/${gender}/${filename}"
		}
		else if (filename.endsWith('.txt')) {
			return filename
		}
		return null
	}
	input:
	tuple val(samples), path(vcf), path(vcf_index), path(gvcf_files)

	output:
	tuple val(samples), path("*.txt")

	shell:
	template 'coverage.sh'


}