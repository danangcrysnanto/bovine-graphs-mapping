#!/usr/bin/env bash

usage (){

cat << EOF
##################################################
        VG construct to graph and mapping
        with haplotypes
        -b breeds
        -t thresh
##################################################
EOF

exit 1

}

if [[ $# -eq 0 ]];then usage; fi

while getopts ":b:t:" opt;do
        case $opt in
                b) breeds=$OPTARG ;;
		t) thresh=$OPTARG;;
                \?|:|h) usage;;
        esac
done

shift $((OPTIND - 1))

[ ! -d graph ] &&  mkdir graph
[ ! -d mapping_result ] && mkdir mapping_result

prefix=graph/${breeds}_${thresh/./}
prefix_res=mapping_result/${breeds}_${thresh/./}
data_dir="../data/part1"
vcf_freq="../data/part1/vcf_freq/${breeds}_${thresh/./}"
reads_sim="../data/part1/reads_sim"


#construct and index
#vg construct
vg construct -r $REFGEN -v ${vcf_freq}_phased_sampled.vcf.gz --region 25 -C -a > ${prefix}.vg

#vg index gbwt
vg index -p -b $PWD -t 18 -G ${prefix}.gbwt -v ${vcf_freq}_phased_sampled.vcf.gz ${prefix}.vg

#vg index xg
vg index -b $PWD -p -t 18 -x ${prefix}.xg ${prefix}.vg

#vg index gcsa
vg index -b $PWD -p -t 18 -g ${prefix}.gcsa ${prefix}.vg

# map single end

vg map \
-G $reads_sim/${breeds}_sim.gam \
-x ${prefix}.xg \
-g ${prefix}.gcsa \
-1 ${prefix}.gbwt \
-t 18 \
--refpos-table | sort |gzip > ${prefix_res}_se.txt.gz

join <(zcat ${prefix_res}_se.txt.gz) <(zcat $reads_sim/${breeds}_truth_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 |gzip > ${prefix_res}_se.compare.gz


# map paired end

vg map \
-iG $reads_sim/${breeds}_sim.gam \
-x ${prefix}.xg \
-g ${prefix}.gcsa \
-1 ${prefix}.gbwt \
-t 18 \
--refpos-table | sort |gzip > ${prefix_res}_pe.txt.gz

join <(zcat ${prefix_res}_pe.txt.gz) <(zcat $reads_sim/${breeds}_truth_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 |gzip > ${prefix_res}_pe.compare.gz




