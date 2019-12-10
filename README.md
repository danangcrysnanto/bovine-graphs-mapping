## Sequence read mapping and variant discovery from breed-specific augmented references in cattle

Repository contain scripts to reproduce results in the paper as below:

> Danang Crysnanto and Hubert Pausch.  Sequence read mapping and variant discovery from breed-specific augmented references in cattle. *Biorxiv*

---

### Abstract

**Introduction**

Current bovine genome reference is derived from single highly inbred Hereford cattle, which insufficiently represents sequence variants across diverse range of breeds. The lack of diversity in the linear genome causes reference allele bias, i.e., DNA fragments that contain reference alleles are more likely to align correctly than those containing non-reference alleles. Variation-aware genome graphs may address problems arising from the inadequate representation of the current references.

**Results**

Here we used the existing bovine reference (ARS-UCD1.2) as backbone and added sites of variation that were filtered according to dairy (Brown Swiss, Holstein) and dual-purpose (Fleckvieh, Original Braunvieh) cattle breeds to construct multi- and breed-specific genome graphs using *vg toolkit*. Using both simulated and real short-read data, we showed that mapping to graph genome outperform mapping to the linear genome, even when the reference bases adjusted to the most frequent allele in the population. However, variant prioritization is required to reach high level of accuracy (e.g., adding random and rare variants tend to compromise graph read mapping). Additionally, even though that the best mapping achieved with breed-specific genome graphs, mapping to the pangenome graphs with combined variants are almost as accurate. Finally, we showed that mapping to the informative graph genomes eliminate reference allele bias across all variant length, including long indels.

 **Conclusion**:

Our results demonstrate that with careful variant prioritization, mapping to the graph genomes is superior than linear genome. We anticipated that construction of more comprehensive genome graphs from expanded catalogues of bovine sequence variants and multiple reference-quality assemblies across wide-range of cattle breeds may further improve mapping accuracy. 

----

The accompanying raw data for analysis is available in Zenodo, download and unzip the files. All rawa data is available in `data` folder after unzipping. 

![Illustration of method](methods_fig.png)



The paper contains four main parts, please go to respective pages for more details:

[Part1](part1_varselect): Variant prioritization

[Part2](part2_breedgraphs) : Breeds graphs

[Part3](part3_consensusgenome): Consensus genome

[Part4](part4_variantgenotyping): Variant genotyping



*Note*: 

We use ETH Zurich Leonhard Open Computing cluster, to parallelize all steps. Reproducing in local machine will not be reasonable in terms of memory and computing time. 
However, final results were available in `result` folder  and running only the data analysis presented in Jupyter notebook can be done in local/dekstop computer. 



*This repository is still in very active development, so not all results can be reproduced at this point*

----

### Contributor:

[Danang Crysnanto](mailto:danang.crysnanto@usys.ethz.ch)  
[Animal Genomics ETH Zurich](http://www.ag.ethz.ch/)     	

Email:danang.crysnanto@usys.ethz.ch   
Personal web: [danangcrysnanto.github.io](https://danangcrysnanto.github.io/) 


