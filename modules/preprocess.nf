process preprocess {
	module = ['BEDTools/2.30.0-GCCcore-11.3.0','HTSlib/1.16-GCCcore-11.3.0','BCFtools/1.16-GCCcore-11.3.0']

  publishDir "${samples.projectResultsDir}/alignment", mode: 'move', pattern: "${samples.externalSampleID}.{bam*,cram*}"

  publishDir "${samples.projectResultsDir}", mode: 'copy', saveAs: { filename ->
		if (filename.endsWith('.vcf.gz') || filename.endsWith('.vcf.gz.tbi') || filename.endsWith('.roh.bed') || filename.endsWith('.baf.bw')) {
			if (filename.contains('.sv.')) return "variants/sv/${filename}"
			if (filename.contains('.cnv.')) return "variants/cnv/${filename}"
			if (filename.contains('.g.vcf.gz')) return "variants/gVCF/${filename}"
			if (filename.contains('.targeted.') || filename.contains('.repeats.')) return "variants/additional_analysis/${filename}"
			return "variants/${filename}"
		}
		else if (filename.endsWith('.html') || filename.endsWith('.json') || filename.endsWith('.bw') || filename.contains('stats')) {
			if (filename.contains('.targeted.json')) return "variants/additional_analysis/${filename.replace('.targeted.renamed.json', '.targeted.json')}"
				return "qc/${filename}"
		}
		else if (filename.endsWith('.bed.gz') || filename.endsWith('.gff3') || filename.contains('target.counts') || filename.contains('.tn.') || filename.contains('.seg')) {
			return "variants/cnv/${filename}"
		}
		else if (filename == "sv_dir") {
			return "variants/sv/${samples.externalSampleID}"
		}
		return null
	}

	input:
	tuple val(samples), path(files), path(concordanceCheckCallsVcf)

	output:
	tuple val(samples), path("*.variant.calls.genotyped.vcf.gz"), path ("*.variant.calls.genotyped.vcf.gz.tbi"), path("*.hard-filtered.g.vcf.gz*")

	shell:
	template 'preprocess.sh'
}