using AdaptiveResonance
using Test
using Logging
using Random

# Set the log level
LogLevel(Logging.Info)

@testset "Example Scripts" begin
    include("../src/examples/db.jl")
    include("../src/examples/ps.jl")
    include("../src/examples/xb.jl")
end
