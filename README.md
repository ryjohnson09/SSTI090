# SSTI090
Microbiome analysis for SSTI-090 study using Drake

## Running Analysis
* Every step of the DADA2 / Phyloseq analysis is wrapped into a function (withing `R/` dir).
* Each function has an output (`target`). Target creation is defined in `R/plan.R`.
* To run the plan, open the `make.R` file and run commands.
* Only steps where the target is out of date will be run.
* Visualize the out of date steps using `vis_drake_graph(plan)`

## Visualizing Results
* Load targets into the global environment using `drake::loadd()`.
* Read targets using `drake::readd()`
