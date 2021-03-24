using AdaptiveResonance
using Test
using Logging
using Random

# Set the log level
LogLevel(Logging.Info)

@testset "Example Scripts" begin
    # Switch to the top for execution because our scripts point to the datasets
    # relative to themselves, not relative to the test dir
    @info "Test directory" pwd()
    cd("../")
    @info "Switching working directory to top" pwd()

    # Run scripts
    include("../src/examples/db.jl")
    include("../src/examples/ps.jl")
    include("../src/examples/xb.jl")
end
