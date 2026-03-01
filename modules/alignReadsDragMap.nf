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
    path reference_hash_dir

    output:
    tuple val(sample_id), path("${sample_id}.sam")

    script:
    """
    echo "Running Align Reads with DRAGMAP"

    dragen-os \
        -r ${reference_hash_dir} \
        -1 ${reads[0]} \
        -2 ${reads[1]} \
        --output-file-prefix ${sample_id} \
        > "${sample_id}.sam"

    echo "Alignment with DRAGMAP complete"
    """
}