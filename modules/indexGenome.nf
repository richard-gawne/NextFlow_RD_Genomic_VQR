/*
 * Define the indexGenome process that creates a BWA index
 * given the genome fasta file
 */
process indexGenome {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_medium'
    }
    container 'variantvalidator/indexgenome:1.1.0'


    // Publish indexed files to the specified directory
    publishDir("$params.outdir/GENOME_IDX", mode: "copy")

    input:
    path genomeFasta

    output:
    tuple path(genomeFasta), path("bwa_index/*"), path("${genomeFasta.simpleName}.fasta.fai"), path("${genomeFasta.simpleName}.dict")

    script:
    """
    echo "Running Index Genome"

    mkdir -p bwa_index/

    # Generate BWA index
    bwa index -p bwa_index/${genomeFasta.simpleName} "${genomeFasta}"

    # Generate samtools faidx
    samtools faidx "${genomeFasta}"

    # Generate Fasta dict
    picard CreateSequenceDictionary R="${genomeFasta}" O="${genomeFasta.simpleName}.dict"

    echo "Genome Indexing complete."
    """
}
