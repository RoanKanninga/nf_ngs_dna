process create_xml {

	publishDir "${samples.projectResultsDir}/", mode: 'copy', saveAs: { fileName ->
		if (fileName.endsWith('.xml')) {
			return "qc/${samples.externalSampleID}.igv_session_versie8.xml"
		}
		else if (fileName == "hg38_recurrentCNVs.bed"){
			return fileName
		}
		return null
	}
	input:
	tuple val(samples), path(vcf), path(vcf_index), path(gvcf_files)

	output:
	tuple val(samples), path("*.xml"), path("hg38_recurrentCNVs.bed")

	shell:
	template 'create_xml.sh'

}
