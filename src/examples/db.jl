"""
    db.jl

Description:
    Example usage of the Davies-Bouldin ICVI.

Author:
    Sasha Petrenko <sap625@mst.edu>
"""

# --------------------------------------------------------------------------- #
# PACKAGES
# --------------------------------------------------------------------------- #

# ICVIs pulled from the AdaptiveResonance package
using AdaptiveResonance

# Quality of life packages for editing and fancy logging
using Revise
using ProgressBars
using Logging
using Plots

# --------------------------------------------------------------------------- #
# CONFIGURATION
# --------------------------------------------------------------------------- #

# Set the log level
LogLevel(Logging.Info)

# Plotting style
# pyplot()
theme(:dark)

# Load the examples helper functions
include("../common.jl")

# Load the trainig data
train_x, train_y = get_cvi_data("data/correct_partition.csv")
n_samples = length(train_y)

# --------------------------------------------------------------------------- #
# INCREMENTAL MODE
#   Run the CVI in incremental mode
# --------------------------------------------------------------------------- #

# Instantiate the icvi with default options
cvi_i = DB()

# Create some storage for our criterion values
criterion_values_i = zeros(n_samples)

# Iterate across all of the samples
for ix = ProgressBar(1:n_samples)
    # Update the CVI internal parameters incrementally
    # NOTE: the package assumes that columns are features and rows are samples
    param_inc!(cvi_i, train_x[:, ix], train_y[ix])
    # Evaluate the CVI to internally store the criterion value
    evaluate!(cvi_i)
    # Extract and save the criterion value at each step
    criterion_values_i[ix] = cvi_i.criterion_value
end

# --------------------------------------------------------------------------- #
# BATCH MODE
#   Run the CVI in batch mode
# --------------------------------------------------------------------------- #

# Instantiate the CVI, same as when done incrementally
cvi_b = DB()

# Compute the parameters in batch
param_batch!(cvi_b, train_x, train_y)

# Evaluate the CVI criterion value
evaluate!(cvi_b)

# NOTE: we only get the last criterion value because we ran in batch mode,
#       which is accessible at cvi_b.criterion_value.

# --------------------------------------------------------------------------- #
# INCREMENTAL MODE: PORCELAIN FUNCTIONS
#   Update and get the CVI at once with the porcelain functions
# --------------------------------------------------------------------------- #

# Instantiate the CVI as both in incremental and batch modes
cvi_p = DB()

# Create storage for the criterion values at each timestep
criterion_values_p = zeros(n_samples)

# Iterate across all samples
for ix = ProgressBar(1:n_samples)
    # Update the CVI parameters and extract the criterion value in one function
    # NOTE: the package assumes that columns are features and rows are samples
    criterion_values_p[ix] = get_icvi!(cvi_p, train_x[:, ix], train_y[ix])
end

# --------------------------------------------------------------------------- #
# VISUALIZATION
# --------------------------------------------------------------------------- #

# Show the last criterion value
@info "Incremental CVI value: $(cvi_i.criterion_value)"
@info "Batch CVI value: $(cvi_b.criterion_value)"
@info "Porcelain Incremental CVI value: $(criterion_values_p[end])"

# Plot
p = plot(1:n_samples, criterion_values_i, title="DB CVI")
plot!(p, 1:n_samples, criterion_values_p)
xlabel!("Sample Index")
ylabel!("CVI")
