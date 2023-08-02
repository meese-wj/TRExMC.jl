module TREx

# Use this to reexport the namespaces from each submodule
using Reexport

include("Parameters/Parameters.jl")

include("Models/Models.jl")
@reexport using .Models  # have direct access to Models/submodules

include("Simulations/Simulations.jl")

end
