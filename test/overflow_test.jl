include("../src/dependencies.jl")
# include("src/dependencies.jl") # This line is just here to test the plot function call at the end of the file from the Julia REPL.

lambda_range = [i for i in 0.2:0.2:1.2]

# Simulation recorded data
sojurn_times = Float64[]
system_job_totals, total_orbiting_jobs = Int64[], Int64[]

# Processed simulation data for project plots.
mean_system_job_totals = zeros(Float64, length(lambda_range))
proportion_orbiting_jobs = zeros(Float64, length(lambda_range))
processed_sojurn_times = []

function plot_data_callbacks(time::Float64, state::NetworkState, event::TimedEvent)
    state.number_in_system_decreased && push!(sojurn_times, time - event.arrival_time)
    push!(total_orbiting_jobs, state.orbiting_jobs)
    push!(system_job_totals, state.number_in_system)
    if state.number_in_system_decreased
        println(state.queues)
        println(state.number_in_system, "\n")
    end
    return nothing
end

"""
Call simulate function below for lambdas in lambda_range
"""

current_scenario = NetworkParameters(  L=3, 
                            gamma_shape = 3.0, 
                            λ = 1, 
                            η = 4.0, 
                            μ_vector = ones(3),
                            P = [0 1.0 0;
                                0 0 1.0;
                                0 0 0],
                            Q = zeros(3,3),
                            p_e = AnalyticWeights([1.0, 0, 0]),
                            K = fill(5,3))

Random.seed!(0)
@time simulate(NetworkState(12, zeros(Int8, current_scenario.L), 0), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), current_scenario, max_time = 100.0, callback = plot_data_callbacks)
# fill(Int8(4),3)
# scenario_plots(processed_sojurn_times, mean_system_job_totals, proportion_orbiting_jobs, 999, lambda_range)