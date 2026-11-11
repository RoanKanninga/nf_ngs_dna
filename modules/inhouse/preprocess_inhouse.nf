process preprocess_inhouse {

	module = ['BEDTools/2.30.0-GCCcore-11.3.0','HTSlib/1.16-GCCcore-11.3.0','BCFtools/1.16-GCCcore-11.3.0']

	publishDir "${samples.projectResultsDir}", mode: 'copy', saveAs: { filename ->
		if (filename.endsWith('.vcf.gz') || filename.endsWith('.vcf.gz.tbi') || filename.endsWith('.roh.bed') || filename.endsWith('.baf.bw')) {
			if (filename.contains('.sv.')) return "variants/sv/${filename}"
			if (filename.contains('.cnv.')) return "variants/cnv/${filename}"
			if (filename.contains('.hard-filtered.g.vcf.gz')) return "variants/gVCF/${filename}"
			if (filename.contains('.captured.')) return "variants/${filename}"
			if (filename.contains('.targeted.') || filename.contains('.repeats.')) return "variants/additional_analysis/${filename}"
			return "variants/${filename}"
		}
		else if (filename.contains('.bam') || filename.contains('.cram')) {
			return "alignment/${filename}"
		}
		else if (filename.endsWith('.html') || filename.endsWith('.json') || filename.endsWith('.bw') || filename.contains('metrics')) {
			return "qc/${filename}"
		}
		else if (filename.endsWith('.bed.gz') || filename.endsWith('.gff3') || filename.contains('target.counts') || filename.contains('.tn.') || filename.contains('.seg')) {
			return "variants/cnv/${filename}"
		}
		else if (filename == "sv_dir") {
			return "qc/sv_${samples.externalSampleID}"
		}
		return null
  }

	input:
	tuple val(samples), path(files), path(concordanceCheckCallsVcf)

	output:
	tuple val(samples), path("*")

  shell:

  template 'preprocess_inhouse.sh'

  stub:

  """
		touch "${samples.externalSampleID}.variant.calls.genotyped.vcf.gz"
		touch "${samples.externalSampleID}.captured.vcf.gz"
		touch "${samples.externalSampleID}.hard-filtered.g.vcf.gz"
  """
}