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

    publishDir "${params.outdir}/GENOME_IDX", mode: 'copy'

    input:
    path genomeFasta

    output:
    tuple path(genomeFasta), path("dragmap_hash/*")

    script:
    """
    echo "Creating hash table for DRAGMAP"

    mkdir -p dragmap_hash

    dragen-os \
        --build-hash-table true \
        --ht-reference ${genomeFasta} \
        --output-directory dragmap_hash
    
    echo "Hashing genome with DRAGMAP complete"
    """
}

/*
 * Prepare the reference genome for GATK by creating a FASTA index and dictionary
 */
process prepareReferenceGATK {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }

    container 'variantvalidator/gatk4:4.3.0.0'

    tag "${genomeFasta.simpleName}"

    input:
    tuple path(genomeFasta), path(hashFiles)

    output:
    tuple path(genomeFasta), path(hashFiles), path("${genomeFasta.simpleName}.fasta.fai"), path("${genomeFasta.simpleName}.dict")

    script:
    """
    echo "Creating FASTA index and dictionary for ${genomeFasta.simpleName}"

    # Index FASTA for samtools/GATK
    samtools faidx ${genomeFasta}

    # Create GATK dictionary
    gatk CreateSequenceDictionary -R ${genomeFasta} -O ${genomeFasta.simpleName}.dict

    echo "FASTA index and dictionary complete"
    """
}