/*
 * Align reads to the indexed genome using DRAGMAP
 */

process alignReadsDragMap {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container "valleema/dragmap:1.2.1"

    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)
    tuple path(genomeFasta), path(hashFiles)

    output:
    tuple val(sample_id), path("${sample_id}.sam")

    script:
    """
    echo "Running Align Reads with DRAGMAP"

    # Use dirname of the first hash file to get the hash directory
    reference_hash_dir=\$(dirname "${hashFiles[0]}")

    dragen-os \
        -r \${reference_hash_dir} \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        --output-file-prefix ${sample_id} \
        > "${sample_id}.sam"

    echo "Alignment with DRAGMAP complete"
    """
}

/*
 * Convert SAM to sorted BAM using samtools
 */

process samToSortedBam {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'staphb/samtools:1.20'

    tag "$sample_id"

    input:
    tuple val(sample_id), path(samFile)

    output:
    tuple val(sample_id), path("${sample_id}.bam")

    script:
    """
    echo "Converting SAM to sorted BAM for sample ${sample_id}"
    samtools sort -o ${sample_id}.bam ${samFile}
    rm ${samFile}
    echo "SAM to sorted BAM conversion complete for sample ${sample_id}"
    """
}