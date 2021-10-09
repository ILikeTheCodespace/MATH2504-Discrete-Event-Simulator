include("../src/dependencies.jl")
# include("src/dependencies.jl") # FIXME: This line is just here to test the plot function call at the end of the file from the Julia REPL.
"""
Call simulate function below
"""

time_traj, queue_traj = Float64[], Int[]
sojurn_times = Float64[]
orbiting_jobs_proportion = Float64[]

function record_trajectory(time::Float64, state::NetworkState) 
    push!(time_traj, time)
    push!(queue_traj, state.queues[1])
    return nothing
end
    
scenariotest = NetworkParameters(  L=3, 
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

# simulate(NetworkState(0, zeros(Int8, scenario1.L)), TimedEvent(ArrivalEvent(),0.0), log_times = [5.3,7.5])

function plot_data_callbacks(time::Float64, state::NetworkState, event::TimedEvent)
    state.number_in_system_decreased && push!(sojurn_times, time - event.arrival_time)
    push!(orbiting_jobs_proportion, sum(state.queues)/state.number_in_system)
    return nothing
end

@time compile_time_macro = 1
@time simulate(NetworkState(0, zeros(Int8, scenariotest.L)), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), scenariotest, max_time = 10000.0, callback = plot_data_callbacks)

plot(time_traj, queue_traj)