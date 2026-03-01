/*
 * Create hash table of the reference genome for DRAGMAP
 */

process hashGenomeDragMap {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container "valleema/dragmap:1.2.1"

    tag "hash_genome"

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    path reference_fasta

    output:
    path "dragmap_hash"

    script:
    """
    echo "Creating hash table for DRAGMAP"

    dragen-os \
        --build-hash-table true \
        --ht-reference ${reference_fasta} \
        -r dragmap_hash
    
    echo "Hashing genome with DRAGMAP complete"
    """
}