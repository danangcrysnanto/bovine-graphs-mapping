## Part 4 Read mapping and variant genotyping from whole genome graphs

In this part of the analysis, we constructed whole-genome graphs from ~14.1 million autosomal variants (Chr 1-29) augmented to the UCD1.2 reference. We then assessed its utility for read mapping and sequence variant genotyping (see figure below). 



![Part 4 methods overview](fig/part4_method.png)	





----

#### Requirements

1. VG toolkit version v1.17.0 ["Candida"](https://github.com/vgteam/vg), we do not test the script in other vg versions
2. Python 3.6 with `Snakemake` (version 5.5.4)
3. Samtools
4. Fastp 
5. R (version  3.4.2) with `Tidyverse` library  


Make sure that the programs are in the `$PATH` and the raw data has been downloaded from Zenodo. Most of the work in this part is implemented using `Snakemake` as workflow management system. 

___

#### Details of the experiments

#### 1. Creating whole-genome graphs 

We implemented the whole genome graph construction in a `Snakemake` pipeline. Make sure to edit the `construct_index_config` with the `file` and `path` specifications. The phased variants used to construct graphs is in `data/part4/vcf_construct`. 

The pipeline can be run in `screen` mode as below

```
mv scripts
snakemake --snakefile construct_index_snake.py
```

The overview of the pipeline (for example only including chr 1-3) is visualized as below. Graphs will be constructed separately for each chromosome with `vg construct`, then the node id is updated (so no two nodes can have the same node ID to avoid clashes) using `vg ids`. We then used the `full graphs` to create `xg` and `gbwt` indexes. For k-mer/query index we first need to simplify the graphs using `vg prune`, but we used `gbwt` index to restore edges that are part of the haplotypes. The query or `gcsa` index is finally created using `vg index gcsa`.



![graph construct](fig/graphs_construct_pipeline.png)



**Note**: We used a High-Performance Cluster to run the pipeline. The pipeline needs *at least* 128 GB RAM, 2 TB  disk space, and an intensive I/O. It will run for about ~24 hours. The graph is generated at `$outdir/graph` folder with the three accompanying indexes, `xg` (topological),`gcsa` (kmer or query index), and `gbwt` (haplotype index) in `$outdir/index` folder. 

We have already provided the BSW whole-genome graphs (including indexes) constructed from this pipeline in the data folder at `data/part4/BSW_graphs` . 



#### 2. Read mapping to the whole genome graphs

We then mapped 10 short-read data sets to the Brown Swiss whole-genome graphs. We implemented this mapping experiment also with the `Snakemake` pipeline. 

The pipeline for graph mapping can be run in `screen` mode with the following command:

```
mv scripts
snakemake --snakefile split_mapvg_snake.py
```



The pipeline (see below for example) first will use `fastp` to trim and filter low quality reads and then split the fastq files into smaller files of `80` million reads (~1X coverage). We then mapped each split fastq separately to whole-genome graphs using `vg map` , producing `GAM`  or graph alignment file.  Since we wanted to use standard variant callers (e.g., `Samtools`, `GATK`, `Graphtyper`), we surjected the graph alignment coordinates to the corresponding reference paths using `vg surject`, producing `BAM` files that are compatible with the current variant caller. We finally utilised variant calling pipeline for `Samtools`, `GATK`, `Graphtyper` that we already established in our previous paper ([See here for more details](https://github.com/danangcrysnanto/Graph-genotyping-paper-pipelines)) to discover and genotype variants from surjected graph alignments. 



![Graph mapping illustration](fig/graph_mapping_pipeline.png)



#### 3. Data Analysis

The analysis presented in the paper can be followed interactively through Jupyter notebook in [`analysis/part4_variantgenotyping.ipynb`](analysis/part4_variantgenotyping.ipynb). 

​	

