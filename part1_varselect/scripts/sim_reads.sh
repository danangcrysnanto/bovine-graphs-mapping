#!/usr/bin/env bash


#!/usr/bin/env bash
usage (){

cat << EOF
##################################################
        Simulate reads
        -a anims
        -b breeds
##################################################
EOF

exit 1

}

if [[ $# -eq 0 ]];then usage; fi

while getopts ":b:a:" opt;do
        case $opt in
        		a) anims=$OPTARG;;
                b) breeds=$OPTARG ;;
                \?|:|h) usage;;
        esac
done

shift $((OPTIND - 1))



data_dir="../data/part1/vcf_sim"
REFGEN="../data/utilities/UCD12.fa"

vg construct -r $REFGEN -R 25 -C -v ${data_dir}/${breeds}_forsim.vcf.gz -a -f -m 32 > ${breeds}_sim.vg

vg index -t 18 -x ${breeds}_sim.xg -G ${breeds}_sim.gbwt -v ${data_dir}/${breeds}_forsim.vcf.gz ${breeds}_sim.vg

#extract first haplotype from one animals
vg mod -D ${breeds}_sim.vg > ${breeds}_thread-merged_0.vg
vg paths --gbwt ${breeds}_sim.gbwt --extract-vg -x ${breeds}_sim.xg -Q _thread_${anims}_25_0 >> ${breeds}_thread-merged_0.vg
vg mod -N ${breeds}_thread-merged_0.vg > ${breeds}_thread_0.vg

#simulate the reads from haplotype 0
vg index -x ${breeds}_thread_0.xg -t 18 ${breeds}_thread_0.vg
vg sim -s 271 -n 2500000 -e 0.01 -i 0.002 -l 150 -p 500 -v 50 -x ${breeds}_thread_0.xg -a > ${breeds}_thread_0.gam

# do the same for the second haplotype
vg mod -D ${breeds}_sim.vg > ${breeds}_thread-merged_1.vg
vg paths --gbwt ${breeds}_sim.gbwt --extract-vg -x ${breeds}_sim.xg -Q _thread_${anims}_25_1 >> ${breeds}_thread-merged_1.vg
vg mod -N ${breeds}_thread-merged_1.vg > ${breeds}_thread_1.vg

#simulate the reads from haplotype 0
vg index -t 18 -x ${breeds}_thread_1.xg -t 18 ${breeds}_thread_1.vg
vg sim -s 271 -n 2500000 -e 0.01 -i 0.002 -l 150 -p 500 -v 50 -x ${breeds}_thread_1.xg -a > ${breeds}_thread_1.gam

cat ${breeds}_thread_0.gam ${breeds}_thread_1.gam > ${breeds}_sim.gam

#annotate truth position
vg annotate -t 10 -p -x ${breeds}_sim.xg -a ${breeds}_sim.gam |
vg view -a -j - |
jq -c -r '[ .name, .refpos[0].name, .refpos[0].offset ] | @tsv' | sort |gzip > ${breeds}_truth.tsv.gz

# extract the reference path (-D drop -N only retain parts), extract only paths
vg mod -D ${breeds}_sim.vg > ${breeds}_linear-merged.vg
vg paths --extract-vg -x ${breeds}_sim.xg -Q 25 >> ${breeds}_linear-merged.vg
vg mod -N ${breeds}_linear-merged.vg > ${breeds}_linear.vg

vg index --threads 18 -x ${breeds}_linear.xg ${breeds}_linear.vg

vg annotate -n -t 10 -x ${breeds}_linear.xg -a ${breeds}_sim.gam  |tail +2 |sort | gzip > ${breeds}_novelty.tsv.gz

join <(zless ${breeds}_truth.tsv.gz) <(zless ${breeds}_novelty.tsv.gz) | gzip  > ${breeds}_truth_all.tsv.gz


vg view -X ${breeds}_sim.gam | gzip > ${breeds}_sim.fastq.gz

vg view -a ${breeds}_sim.gam |
jq -cr 'select(.name | test("_1$"))' |
vg view -JaG - |
vg view -X - | sed s/_1$// | gzip > ${breeds}_sim_1.fastq.gz

vg view -a ${breeds}_sim.gam |
jq -cr 'select(.name | test("_2$"))' |
vg view -JaG - |
vg view -X - | sed s/_2$// | gzip > ${breeds}_sim_2.fastq.gz




