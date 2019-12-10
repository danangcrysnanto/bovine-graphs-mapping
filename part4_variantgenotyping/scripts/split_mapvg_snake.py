#!/usr/bin/env python

configfile: "config_splitmapvg.yaml"

# parse files and directory
FASTQDIR=config["resources"]["fastqdir"]
BASE_GRAPH=config["resources"]["base_graph"]
OUTDIR=config["resources"]["outdir"]
TEMPDIR=config["resources"]["tempdir"]

# parsing keywords
ANIM_LIST, =glob_wildcards(FASTQDIR + "/{anims}_1.fastq.gz")

SPLIT_SIZE=config["split_size"]

#parse program
FASTP=config["tools"]["fastp"]
VG=config["tools"]["vg"]
SAMTOOLS=config["tools"]["samtools"]


rule all:
	input: expand(OUTDIR+"/bam_surject_combined/{anims}.bam",anims=ANIM_LIST)


checkpoint split_fastq:
	input:
		read1= FASTQDIR + "/{anims}_1.fastq.gz",
		read2= FASTQDIR + "/{anims}_2.fastq.gz"
	output:
		temp(directory(OUTDIR + "/{anims}_fastqsplit"))
	params:
		split_size=SPLIT_SIZE,
		fastp=FASTP,
        outdir=OUTDIR
	shell:
		"""
            cd {params.outdir} 

			mkdir {wildcards.anims}_fastqsplit

			cd {wildcards.anims}_fastqsplit

			{params.fastp}  --split_by_lines={params.split_size}  \
			--split_prefix_digits=2 \
			--out1={wildcards.anims}_1.split.fastq.gz \
			--out2={wildcards.anims}_2.split.fastq.gz \
			--in1={input.read1} \
			--in2={input.read2}

		"""


rule map_fastq:
	input:
		split1=OUTDIR + "/{anims}_fastqsplit/{part}.{anims}_1.split.fastq.gz",
		split2=OUTDIR + "/{anims}_fastqsplit/{part}.{anims}_2.split.fastq.gz"
	output:
		OUTDIR + "/gam_split/part{part}_{anims}.gam"
	params:
		base_graph=BASE_GRAPH,
		vg=VG
	shell:
		"""
			{params.vg} map \
			-f {input.split1} -f {input.split2} \
			-x {params.base_graph}.xg \
            -g {params.base_graph}.gcsa \
            -1 {params.base_graph}.gbwt \
			-t 18 > {output}

		"""

##get how many splitting for each sample
rule surject_bam:
    input:
        OUTDIR + "/gam_split/part{part}_{anims}.gam"
    output:
        temp(OUTDIR + "/bam_surject_part/part{part}_{anims}_surject.bam")
    params:
        vg=VG,
        xg_graph=BASE_GRAPH+".xg"
    shell:
        """

        {params.vg} surject {input} \
        -x {params.xg_graph} \
        -t 18 \
        -i \
        -b > {output}

        """


def get_part(wildcards):
    checkpoint_output=checkpoints.split_fastq.get(**wildcards).output[0]
    all_parts, =glob_wildcards(checkpoint_output+f"/{{parts}}.{wildcards.anims}_1.split.fastq.gz")
    return (OUTDIR + f"/bam_surject_part/part{part}_{wildcards.anims}_surject.bam" for part in all_parts)


### combined bam per animals from parallelize mapping

rule combined_bam:
    input:
        get_part
    output:
        OUTDIR+"/bam_surject_combined/{anims}.bam"
    params:
        tempdir=TEMPDIR,
        samtools=SAMTOOLS
    shell:
        """

        {params.samtools} cat {input} | samtools sort -@ 10 -O BAM -o {output} -T {params.tempdir} -

        {params.samtools} index -@ 10 {output}

        """