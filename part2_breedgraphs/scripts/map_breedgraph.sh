#!/usr/bin/env bash

usage (){

cat << EOF
##################################################
        VG construct to graph and mapping
        based on breeds
        -b breeds
	-r replication (1-10)
##################################################
EOF

exit 1

}

if [[ $# -eq 0 ]];then usage; fi

while getopts ":b:r:" opt;do
        case $opt in
                b) breeds=$OPTARG ;;
		r) replication=$OPTARG ;;
                \?|:|h) usage;;
        esac
done

shift $((OPTIND - 1))

[ ! -d graph ] &&  mkdir graph
[ ! -d mapping_result ] && mkdir mapping_result

prefix=graph/${breeds}_${replication}_003_phased

data_dir="../data/part2"
vcf_breed="../data/part2/vcf_breed/${breeds}_${replication}_003_phased_sampled.vcf.gz"
reads_sim="../data/part1/reads_sim"
REFGEN="../data/utilities/UCD12.fa"

#vg construct
vg construct -r $REFGEN -v $vcf_breed --region 25 -C -a > ${prefix}.vg

#vg index gbwt
vg index -p -b $PWD -t 18 -G ${prefix}.gbwt -v $vcf_breed ${prefix}.vg

#vg index xg
vg index -b $PWD -p -t 18 -x ${prefix}.xg ${prefix}.vg

#vg index gcsa
vg index -b $PWD -p -t 18 -g ${prefix}.gcsa ${prefix}.vg

# map single end

vg map \
-G $reads_sim/BSW_sim.gam \
-x ${prefix}.xg \
-g ${prefix}.gcsa \
-1 ${prefix}.gbwt \
-t 18 \
--refpos-table | sort |gzip > mapping_result/${breeds}_${replication}_003_pan_se.txt.gz

join <(zcat mapping_result/${breeds}_${replication}_003_pan_se.txt.gz) <(zcat $reads_sim/BSW_truth_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 |gzip > mapping_result/${breeds}_${replication}_003_pan_se.compare.gz

#collect statistics
scripts/get_stats_rep.R -b ${breeds} -r ${replication} -m se

# map paired end

vg map \
-iG $reads_sim/BSW_sim.gam \
-x ${prefix}.xg \
-g ${prefix}.gcsa \
-1 ${prefix}.gbwt \
-t 18 \
--refpos-table | sort |gzip > mapping_result/${breeds}_${replication}_003_pan_pe.txt.gz

join <(zcat mapping_result/${breeds}_${replication}_003_pan_pe.txt.gz) <(zcat $reads_sim/BSW_truth_all.tsv.gz) | scripts/vg_compare_pos_sim.py 150 | gzip > mapping_result/${breeds}_${replication}_003_pan_pe.compare.gz


#collect statistics
scripts/get_stats_rep.R -b ${breeds} -r ${replication} -m pe




