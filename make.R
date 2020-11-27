# SSTI-090 Make File

source("R/packages.R")         # Load all packages required
source("R/process_metadata.R") # Load custom functions
source("R/raw_read_quality_plot.R")
source("R/plan.R")             # Build your workflow plan data frame.

# Now, your functions and workflow plan should be in your environment.
ls()

# Optionally plot the graph of your workflow.
vis_drake_graph(plan)      # nolint

# Now it is time to actually run your project.
make(plan)

# Now, if you make(plan) again, no work will be done
# because the results are already up to date.
# But change the code and some targets will rebuild.