using ClusterValidityIndices
using Test
using Logging
using Random

# Set the log level
LogLevel(Logging.Info)

# Common code tests for coverage
@testset "common.jl" begin
    # Load the common methods
    include("../src/common.jl")
    # Load the data
    data_path = "../data/correct_partition.csv"
    data, labels = get_cvi_data(data_path)
     # Sort it into sequential order
    data, labels = sort_cvi_data(data, labels)
    # Verify that the labels are now monotonic
    @test issorted(labels)
end

# Test all of the provided example CVI scripts
@testset "Example Scripts" begin
    # Switch to the top for execution because our scripts point to the datasets
    # relative to themselves, not relative to the test dir
    @info "Test directory" pwd()
    cd("../")
    @info "Switching working directory to top for running scripts" pwd()

    # Run scripts
    include("../src/examples/combined.jl")
    include("../src/examples/db.jl")
    include("../src/examples/ps.jl")
    include("../src/examples/xb.jl")
end
