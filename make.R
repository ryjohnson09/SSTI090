# SSTI-090 Make File

# Source the R directory
R_functions <- list.files("R", full.names = TRUE)
sapply(R_functions, source)

# Now, your functions and workflow plan should be in your environment.
ls()

# Optionally plot the graph of your workflow.
vis_drake_graph(plan)

# Now it is time to actually run your project.
make(plan)
