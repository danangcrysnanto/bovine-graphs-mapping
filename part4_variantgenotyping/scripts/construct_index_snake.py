#!/usr/bin/env python
configfile: "construct_index_config.yaml"

VG = config["tools"]["vg"]
REF = config["resources"]["reference"]
TEMPDIR = config["resources"]["tempdir"]
VCFDIR = config["resources"]["vcfdir"]
OUTDIR = config["resources"]["outdir"]
CHR_LIST= config["chr_list"]

rule all: 
    input:
        OUTDIR + "/index/BSW.xg",
        OUTDIR + "/index/BSW.gcsa",
        OUTDIR + "/index/BSW.gbwt"

### This done per chromosome
rule vg_construct:
    input: 
        VCFDIR + "/BSW_{chr}.vcf.gz"
    output:
        OUTDIR + "/graphs/{chr}.vg"
    params:
        ref=REF,
        region="{chr}",
        vg=VG
    shell:
        """
        
        {params.vg} construct --region {params.region} --threads 10 -r {params.ref} -v {input} -C -a > {output}

        """


# This gathered operation and updated files
# This is a bit tricky because vg updated the file
# I used touch when the file finished 
rule vg_ids:
    input:
        expand(OUTDIR + "/graphs/{chr}.vg", chr=CHR_LIST)
    output:
        expand(OUTDIR + "/graphs/{chr}_coord.vg", chr=CHR_LIST)
    params:
        vg=VG,
        outdir=OUTDIR
    shell:
        """
        
        {params.vg} ids -j -m {params.outdir}/graphs/mapping {input} && touch {output}
        cp {params.outdir}/graphs/mapping {params.outdir}/graphs/mapping.backup 

        """

rule vg_index_gbwt:
    input:
        OUTDIR + "/graphs/{chr}_coord.vg",
        VCFDIR + "/BSW_{chr}.vcf.gz",
    output:
        OUTDIR + "/index/{chr}.gbwt"
    params:
        vg=VG,
        chr="{chr}",
        outdir=OUTDIR
    shell:
        "{params.vg} index -G {output} -v {input[1]} {params.outdir}/graphs/{params.chr}.vg"

## the chromosome should be in order
rule merge_gbwt:
    input:
        expand(OUTDIR + "/index/{chr}.gbwt", chr=CHR_LIST)
    output:
        OUTDIR + "/index/BSW.gbwt"
    params:
        vg=VG
    shell:
        """

        {params.vg} gbwt -m -f -o {output} {input}

        """


### Using all chromosome vg from ids
rule vg_index_xg:
    input:      
        expand(OUTDIR + "/graphs/{chr}_coord.vg", chr=CHR_LIST)
    output:
        OUTDIR + "/index/BSW.xg"
    params:
        vg=VG,
        ch_start=CHR_LIST[0],
        ch_stop=CHR_LIST[-1],
        tempdir=TEMPDIR,
        outdir=OUTDIR
    shell:
        """

        {params.vg} index -p -t 36 -b {params.tempdir} -x {output} $(seq -f "{params.outdir}/graphs/%g.vg" {params.ch_start} {params.ch_stop})

        
        """

# This prune cannot be scattered because it updates node mapping file
# node id should be updated based on chromosome order
rule vg_prune_graph:
    input:
        expand(OUTDIR + "/graphs/{chr}_coord.vg",chr=CHR_LIST),
        expand(OUTDIR + "/index/{chr}.gbwt", chr=CHR_LIST)
    output:
        expand(OUTDIR + "/graphs/{chr}_pruned.vg",chr=CHR_LIST)
    params:
        vg=VG,
        ch_start=CHR_LIST[0],
        ch_stop=CHR_LIST[-1],
        outdir=OUTDIR
    shell:
        """

        cp {params.outdir}/graphs/mapping.backup {params.outdir}/graphs/mapping
        
        for chr in $(seq {params.ch_start} {params.ch_stop}); do
            {params.vg} prune -t 18 -u -g {params.outdir}/index/${{chr}}.gbwt -a -m {params.outdir}/graphs/mapping {params.outdir}/graphs/${{chr}}.vg > {params.outdir}/graphs/${{chr}}_pruned.vg
        done

        
        """

# Use all chromosome from prune
rule vg_index_gcsa:
    input:
        expand(OUTDIR + "/graphs/{chr}_pruned.vg", chr=CHR_LIST)
    output:
        OUTDIR + "/index/BSW.gcsa"
    params:
        vg=VG,
        tempdir=TEMPDIR,
        outdir=OUTDIR,
        ch_start=CHR_LIST[0],
        ch_stop=CHR_LIST[-1]
    shell:
        """

        {params.vg} index -t 36 -b {params.tempdir} -p -g {output} -f {params.outdir}/graphs/mapping $(seq -f "{params.outdir}/graphs/%g_pruned.vg" {params.ch_start} {params.ch_stop})


        """



