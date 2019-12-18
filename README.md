## Sequence read mapping and variant discovery from breed-specific augmented references in cattle

Repository contains scripts to reproduce results in the paper as below:

> Danang Crysnanto and Hubert Pausch.  Sequence read mapping and variant discovery from breed-specific augmented references in cattle. *Biorxiv*

---

### Abstract

**Background**

The bovine reference genome is represented as a linear sequence that was created from a single animal of the Hereford cattle breed. Lack of diversity is a drawback of linear references that causes reference allele bias. High nucleotide diversity and the separation of individuals by hundreds of breeds make cattle uniquely suited to investigate the optimal composition of variation-aware references.



**Results**

We augment the bovine linear reference sequence (ARS-UCD1.2) with variants filtered for allele frequency in dairy (Brown Swiss, Holstein) and dual-purpose (Fleckvieh, Original Braunvieh) cattle breeds to construct breed-specific and pan-genome reference graphs using *vg toolkit*. We find that read mapping is more accurate to variation-aware than linear references if pre-selected variants were used for graph construction. Graphs that contain random variants don’t improve read mapping accuracy over the linear reference sequence. Breed-specific augmented graphs and pan-genome graphs enable almost similar accuracy improvements over the linear reference. We construct a whole-genome graph that contains the Hereford-based reference sequence and 14 million variants filtered for allele frequency in the Brown Swiss cattle breed. We show that our novel variation-aware reference facilitates accurate and unbiased genotyping of sequence variants. 



**Conclusions**

We developed a variation-aware reference graph in an agricultural animal using a set of variants that were filtered for allele frequency: https://link.to.zenodo. The novel reference structure improves sequence read mapping and variant genotyping over the linear reference. Our work may serve as a guideline to establish variation-aware reference structures in species with high genetic diversity and many sub-populations.

----



![Illustration of method](methods_fig.png)



The paper contains four main parts, please go to respective pages for more details:

[Part1](part1_varselect): Variant prioritization [![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/danangcrysnanto/bovine-graphs-mapping/master?filepath=part1_varselect/analysis/part1_varselect.ipynb)

[Part2](part2_breedgraphs) : Breeds graphs [![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/danangcrysnanto/bovine-graphs-mapping/master?filepath=part2_breedgraphs/analysis/part2_breedgraphs.ipynb)

[Part3](part3_consensusgenome): Consensus genome [![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/danangcrysnanto/bovine-graphs-mapping/master?filepath=part3_consensusgenome/analysis/part3_consensusgenome.ipynb)

[Part4](part4_variantgenotyping): Variant genotyping [![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/danangcrysnanto/bovine-graphs-mapping/master?filepath=part4_variantgenotyping/analysis/part4_variantgenotyping.ipynb)



*Note*: 

The data analyses utilized the ETH Zurich Leonhard Open High Performance Computing because of the high computing resources requirement. Reproducing in a local (dekstop) machine will not be possible in terms of memory and computing time. 

However, final results are available in `result` folder  and we have setup integration with `binder`, final data analyses can be repeated using `launch binder` button as above (also possible in local dekstop after `cloning` the repo)

The accompanying raw data for analyses are available via Zenodo, please download and untar-unzip the files. All raw data are available in `data` folder after unzipping. 

```
tar -zxvf data.tar.gz
```



----

### Contributor:

[Danang Crysnanto](mailto:danang.crysnanto@usys.ethz.ch)  
[Animal Genomics ETH Zurich](http://www.ag.ethz.ch/)     	

Email: danang.crysnanto@usys.ethz.ch   

License: [MIT](LICENSE)



