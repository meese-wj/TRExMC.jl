module Simulations

import ..TRExMC: thermalization_sweeps, measurement_sweeps

export thermalize, run_and_record

abstract type AbstractMCProcedure end
struct Thermalization <: AbstractMCProcedure end
struct MonteCarloSimulation <: AbstractMCProcedure end

total_sweeps(::proc_t, mcparams) where proc_t <: AbstractMCProcedure = throw(ArgumentError("The total_sweeps for the $proc_t procedure have not been defined."))
total_sweeps(::Thermalization, mcparams) = thermalization_sweeps(mcparams)
total_sweeps(::MonteCarloSimulation, mcparams) = measurement_sweeps(mcparams)

"""
    monte_carlo!(models, algorithm, mcparams)

A single sweep of the Monte Carlo simulation. It's an 
internal function that is supposed to be used by the 
[`monte_carlo_run!`](@ref) function.
"""
function monte_carlo!(models, algorithm, mcparams)
    return algorithm(models, mcparams)
end

"""
    monte_carlo_run!(models, algorithm, mcparams; kwargs...)

Main Monte Carlo function that performs a certain simulation `algorithm`
on the systems defined by the given `models`. The parameters for the 
simulation are contained with `mcparams`.

Currently, the available keyword arguments (`kwargs`) are:
* `procedure::AbstractMCProcedure = MonteCarloSimulation()`: defines the type of simulation to be run 
* `verbose = false`: whether to dump the progress for run during the simulation
"""
function monte_carlo_run!(models, algorithm, mcparams; 
                          procedure::AbstractMCProcedure = MonteCarloSimulation(), 
                          verbose = false)

    for sweep ∈ range(stop = total_sweeps(procedure, mcparams))
        monte_carlo!(models, algorithm, mcparams)

        if !(procedure isa Thermalization) && take_measurement(sweep, mcparams)
            measure!(models)
        end

        if verbose && display_status(sweep, mcparams)
            status(io(mcparams), models)
            status(io(mcparams), algorithm)
        end
    end

    return (models, algorithm)
end

"""
    thermalize(models, algorithm, mcparams; [kwargs...])

Thermalization process for a given set of `models` to be thermalized
in parallel according to the specified `algorithm` with respect to
the given parameters, `mcparams`.

!!! note
    This is a wrapper around [`monte_carlo_run!`](@ref) with 
    `procedure = Thermalization()`.
"""
thermalize!(models, algorithm, mcparams; kwargs...) = monte_carlo_run!(models, algorithm, mcparams; procedure = Thermalization(), kwargs...)

"""
    run_and_record!(models, algorithm, mcparams; [kwargs...])

Monte Carlo simulation for a set of `models` to be simulated in 
parallel according to the specified `algorithm` with respect to the 
given parameters, `mcparams`.

!!! note
    This is a wrapper around [`monte_carlo_run!`](@ref) with 
    `procedure = MonteCarloSimulation()`.
"""
run_and_record!(models, algorithm, mcparams; kwargs...) = monte_carlo_run!(models, algorithm, mcparams; procedure = MonteCarloSimulation(), kwargs...)

end # Simulations