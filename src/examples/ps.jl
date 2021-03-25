"""
    ps.jl

Description:
    Example usage of the Partition Separation CVI/ICVI.

Author:
    Sasha Petrenko <sap625@mst.edu>

Date:
    3/24/2021
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
# USER CONFIGURATION
#   The user config, such as data paths and plotting parameters
# --------------------------------------------------------------------------- #

# Location of the data
data_path = "data/correct_partition.csv"

# Plotting dots-per-inch
dpi = 300

# Plotting style
theme(:dark)

# Plotting backend
# pyplot()      # Install PyPlot to use this backend as an alternative

# --------------------------------------------------------------------------- #
# SCRIPT CONFIGURATION
# --------------------------------------------------------------------------- #

# Set the log level
LogLevel(Logging.Info)

# Load the examples helper functions
include("../common.jl")

# Load the training data
train_x, train_y = get_cvi_data(data_path)
n_samples = length(train_y)

# --------------------------------------------------------------------------- #
# INCREMENTAL MODE
#   Run the CVI in incremental mode
# --------------------------------------------------------------------------- #

# Instantiate the icvi with default options
cvi_i = PS()

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
cvi_b = PS()

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
cvi_p = PS()

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

# Plot the two incremental trends ("manual" and porcelain) atop one another
p = plot(dpi=dpi)
plot!(p, 1:n_samples, criterion_values_i)
plot!(p, 1:n_samples, criterion_values_p)
title!("PS CVI")
xlabel!("Sample Index")
ylabel!("Criterion Value")
display(p)
