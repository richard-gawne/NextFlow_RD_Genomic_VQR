/*
 * Call variants with FreeBayes
 */
process freeBayes {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }

    container 'staphb/freebayes:1.3.6'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(bamFile), path(bamIndex)
    path referenceGenome

    output:
    tuple val(sample_id), path("${sample_id}.vcf")

    script:
    """
    freebayes -f ${referenceGenome} ${bamFile} > "${sample_id}.vcf"
    """
}

process compressIndexVCF {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'staphb/htslib:1.20'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(vcfFile)

    output:
    tuple val(sample_id), path("${sample_id}.vcf.gz"), path("${sample_id}.vcf.gz.tbi")

    script:
    """
    bgzip -c ${vcfFile} > "${sample_id}.vcf.gz"
    tabix -p vcf "${sample_id}.vcf.gz"
    """
}