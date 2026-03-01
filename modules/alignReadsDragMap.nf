/*
 * Align reads to the indexed genome using DRAGMAP
 */

process alignReadsDragMap {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {
        label 'process_high'
    }
    container "ghcr.io/illumina/dragmap:latest"

    tag "$sample_id"

    input:
    tuple val(sample_id), path(reads)   // reads is a tuple of paths for paired-end reads
    path requiredIndexFiles

    output:
    tuple val(sample_id), file("${sample_id}.bam"), file("${sample_id}.bam.bai")

    script:
    """
    INDEX=\$(find -L ./ -name "*.amb" | sed 's/\\.amb\$//')

    echo "Running Align Reads with DRAGMAP"
    echo "\$INDEX"

    # Check if the input FASTQ files exist
    if [ -f "${reads[0]}" ]; then
        if [ -f "${reads[1]}" ]; then
            # Paired-end mode
            dragmap --threads ${task.cpus} --reference \$INDEX --fastq1 ${reads[0]} --fastq2 ${reads[1]} |
            samtools view -b - |
            samtools addreplacerg -r "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:illumina" - > ${sample_id}.bam
        else
            # Single FASTQ mode
            dragmap --threads ${task.cpus} --reference \$INDEX --fastq ${reads[0]} |
            samtools view -b - |
            samtools addreplacerg -r "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:illumina" - > ${sample_id}.bam
        fi
    else
        echo "Error: Read file ${reads[0]} does not exist for sample ${sample_id}."
        exit 1
    fi

    echo "Alignment with DRAGMAP complete"
    """
