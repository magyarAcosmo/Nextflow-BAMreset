# Nextflow-BAMreset
Reset aligned BAM files to unaligned while maintaining base modification tags, as well as other tags associated with basecalling.

## Usage
```bash
cd Nextflow-BAMreset/
nextflow BAMreset.nf -profile ${profile_config} --aln_bam ${aln_bam} --outdir ${outdir}
```

Default parameters for --aln_bam and --outdir are: 
```nextflow
aln_bam = "${baseDir}/data/*.aln.bam"
outdir  = "${baseDir}/results"
```
Note that the results folder will be made automatically within the root directory, but data must be made first and aligned BAM files moved there if the param.aln_bam is not specified otherwise.

Profiles include local, server, and test. Their configurations are as follows:
```nextflow
profiles {
    // e.g., laptop
    local {
        process {
            withName: reset_bam {
                cpus   = 4
                memory = '8 GB'
            }
        }
        docker.enabled = true
        apptainer.enabled = false
    }

    // For high-performance server
    server {
        process {
            withName: reset_bam {
                cpus   = 32
                memory = '64 GB'
            }
        }
        docker.enabled = false
        apptainer.enabled = true
        // If the server uses Slurm or SGE, you can add that here:
        // process.executor = 'slurm'
    }

    // For testing
    test {
        process {
            withName: reset_bam {
                cpus   = 8
                memory = '16 GB'
            }
        }
        docker.enabled = true
        apptainer.enabled = false
    }
}
```

## samtools reset info
This tool strips all tags added during alignment but maintains tags acquired via basecalling, including base modification and pore/channel information.

Its usage outside of a Nextflow pipeline is:
```bash
samtools reset \
        -@ ${task.cpus} \
        -o ${reset_bam_name} \
        --remove-tag fn,ms,AS,nn,de,tp,cm,s1,s2,SA,MD,rl,NM,zd \
        ${aln_bam}
```
