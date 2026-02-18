nextflow.enable.dsl=2

process reset_bam {
    container 'community.wave.seqera.io/library/samtools:1.23--12d9384dd0649f36'
    publishDir "${params.outdir}", mode: 'copy'

    input:
    // We expect a tuple. aln_bai might not exist yet, 
    // so we use the 'checkIfExists' logic in the channel instead.
    tuple path(aln_bam), path(aln_bai)

    output:
    path("${aln_bam.baseName}_reset.bam"), emit: bam

    script:
    // We name the output file based on the input filename
    def reset_bam_name = "${aln_bam.baseName}_reset.bam"
    """
    set -euo pipefail
    echo "Resetting BAM file: ${aln_bam}"
    
    # Check if index exists; if not, create it
    if [[ ! -f "${aln_bai}" ]]; then
        samtools index -@ ${task.cpus} "${aln_bam}"
    fi

    samtools reset \\
        -@ ${task.cpus} \\
        -o ${reset_bam_name} \\
        --remove-tag fn,ms,AS,nn,de,tp,cm,s1,s2,SA,MD,rl,NM,zd \\
        ${aln_bam}
    """
}

workflow {
    // 1. Create a channel for the BAM files
    // 2. Map them to a tuple where the second element is the .bai path
    //    Nextflow will look for a file ending in .bai or .bam.bai
    bam_ch = Channel
        .fromPath(params.aln_bam)
        .map { bam -> 
            def bai = file("${bam}.bai")
            return [ bam, bai ] 
        }

    reset_bam(bam_ch)
}