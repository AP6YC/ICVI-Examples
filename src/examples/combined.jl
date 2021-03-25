"""
    combined.jl

Description:
    Example usage of the the DB, PS, and XB CVIs/ICVIs.

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
data_paths = readdir("data", join=true)

# Plotting dots-per-inch
dpi = 300

# Plotting style
theme(:dark)

# Plotting backend
# gr()            # GR backend (default for Plots.jl)
pyplot()        # PyPlot backend

# --------------------------------------------------------------------------- #
# SCRIPT CONFIGURATION
# --------------------------------------------------------------------------- #

# Set the log level
LogLevel(Logging.Info)

# Load the examples helper functions
include("../common.jl")
include("../experiments.jl")

# Construct the cvis
cvis = [
    XB,
    DB,
    PS
]
n_cvis = length(cvis)

# Iterate across all the data
for data_path in data_paths
    @info "Testing data path: $data_path"
    # Load the training data
    data, labels = get_cvi_data(data_path)
    data, labels = sort_cvi_data(data, labels)
    # Iterate across all CVIs
    for cvi in cvis
        @info "Testing CVI: $(typeof(cvi))"
        test_cvi(cvi(), data, labels)
    end
end