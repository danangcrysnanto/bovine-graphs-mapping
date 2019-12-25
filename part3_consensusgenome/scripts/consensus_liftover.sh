#!/usr/bin/env bash

mode=$1
refgen="../data/part3/reference/Chr25_UCD12.fa"
vcfmajor="../data/part3/vcf_consensus/BSW_major-BSW_pindel.vcf.gz"
vcf2diploid="../data/part3/vcf2diploid.jar"
read_sims="../data/part3/read_sims/BSW_truth.tsv.gz"
novelty_sims="../data/part3/read_sims/BSW_novelty.tsv.gz"
refconsen="25_anims_${mode}.fa"
read_base="../data/part1/reads_sim"


#################################################
#**** Creating consensus from major variants *****

### Replace the reference genome with consensus 
### vcf major contains a single animal with major variants and all genotype 1|1
### vcf2diploid will replace reference bases with all variants defined in vcf 
### and generate two paternal and maternal haplotypes
### because all genotypes are hom alt, then all bases will be replaced
### and maternal and paternal genome is the same consensus genome
java -jar $vcf2diploid -id anims_${mode} -chr $refgen -vcf $vcfmajor


### because all genotypes are hom alt, then all bases will be replaced
### and maternal and paternal genome is the same consensus genome
### Can use one of it
sed '1s/_paternal//g' paternal.chain > BSW_${mode}.chain
sed '1s/_paternal//g' 25_anims_${mode}_paternal.fa > 25_anims_${mode}.fa

bwa index 25_anims_${mode}.fa

### liftover to new coordinate using previously generated files
zless $read_sims |awk '{print $2,$3-1,$3+150,$1}' OFS="\t"| sort -k 2,2 -n > BSW_truth.bed

liftOver -minMatch=0.25 BSW_truth.bed BSW_${mode}.chain BSW_truth_${mode}_lifted.bed BSW_truth_${mode}_unlifted.bed


awk '{print $4,$1,$2}' OFS="\t" BSW_truth_${mode}_lifted.bed|sort -k 1,1 | gzip > BSW_truth_${mode}_pindel.tsv.gz 

#Combined with novelty to get truth all
join <(zless BSW_truth_${mode}_pindel.tsv.gz) <(zless $novelty_sims) | gzip  > BSW_truth_${mode}_pindel_all.tsv.gz 

################################################
#***** Mapping consensus genome with bwa ******

#### bwa mapping as in the vg paper

### paired end mapping

bwa mem -t 18 $refconsen ${read_base}/BSW_sim_1.fastq.gz ${read_base}/BSW_sim_2.fastq.gz |
grep -v ^@  |
perl -ne '@val = split("\t", $_); print @val[0] . "_" . (@val[1] & 64 ? "1" : @val[1] & 128 ? "2" : "?"), "\t" . @val[2] . "\t" . (@val[3] +  int(length(@val[9]) / 2)) . "\t" . @val[4] . "\t" . @val[14] . "\n";' |
sed s/AS:i:// |
sort | gzip > BSW_pe_bwa_pindel_${mode}.pos.gz

join <(zless BSW_pe_bwa_pindel_${mode}.pos.gz) <(zcat BSW_truth_${mode}_pindel_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 | gzip > BSW_pe_bwa_pindel_${mode}.compare.gz


## single end mapping

bwa mem -t 18 $refconsen ${read_base}/BSW_sim.fastq.gz |
grep -v ^@ |
awk -v OFS="\t" '{$4=($4 + int(length($10) / 2)); print}' |
cut -f 1,3,4,5,14 |
sed s/AS:i:// |
sort | gzip > BSW_se_bwa_pindel_${mode}.pos.gz

join <(zless BSW_se_bwa_pindel_${mode}.pos.gz) <(zcat BSW_truth_${mode}_pindel_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 | gzip > BSW_se_bwa_pindel_${mode}.compare.gz

######################################################################
#*** Creating empty graphs (wuthout variants) from consensus genome ***

prefix=BSW_${mode}_pindel_linear

#vg construct
vg construct -r $refconsen  --region 25 -C > ${prefix}.vg

#vg index xg
vg index -b $PWD -p -t 18 -x ${prefix}.xg ${prefix}.vg

#vg index gcsa
vg index -b $PWD -p -t 18 -g ${prefix}.gcsa ${prefix}.vg

#########################################################
#*** Mapping reads to an empty consensus graph with VG***


# map single end

vg map \
-G ${read_base}/BSW_sim.gam \
-x ${prefix}.xg \
-g ${prefix}.gcsa \
-t 18 \
--refpos-table | sort | gzip > ${prefix}_se.txt.gz

join <(zcat ${prefix}_se.txt.gz) <(zcat BSW_truth_${mode}_pindel_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 | gzip > ${prefix}_se.compare.gz


# map paired end

vg map \
-iG ${read_base}/BSW_sim.gam \
-x ${prefix}.xg \
-g ${prefix}.gcsa \
-t 18 \
--refpos-table | sort | gzip > ${prefix}_pe.txt.gz

join <(zcat ${prefix}_pe.txt.gz) <(zcat BSW_truth_${mode}_pindel_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 | gzip > ${prefix}_pe.compare.gz

