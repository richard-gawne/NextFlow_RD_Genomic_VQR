/*
 * Index the reference genome using Minimap2
 */

process indexGenomeMinimap2 {

    if (params.platform == 'local') {
        label 'process_low'
    } else if (params.platform == 'cloud') {S
        label 'process_high'
    }

    container 'nanozoo/minimap2:2.28--9e3bd01'

    tag "${referenceGenome.simpleName}"

    input:
    path referenceGenome

    output:
    path "${referenceGenome.simpleName}.mmi"

    script:
    """
    echo "Indexing reference genome ${referenceGenome.simpleName} with Minimap2"
    minimap2 -d ${referenceGenome.simpleName}.mmi ${referenceGenome}
    echo "Minimap2 genome indexing complete"
    """
}