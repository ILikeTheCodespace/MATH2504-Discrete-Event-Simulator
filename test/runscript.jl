include("../src/dependencies.jl")
"""
Call simulate function below
"""

time_traj, queue_traj = Float64[], Int[]

function record_trajectory(time::Float64, state::NetworkState) 
    push!(time_traj, time)
    push!(queue_traj, state.queues[1])
    return nothing
end
    
scenariotest = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = 3, 
                                η = 4.0, 
                                μ_vector = ones(3),
                                P = [0 1.0 0;
                                    0 0 1.0;
                                    0 0 0],
                                Q = zeros(3,3),
                                p_e = AnalyticWeights([1.0, 0, 0]),
                                K = fill(5,3))

# simulate(NetworkState(0, zeros(Int8, scenario1.L)), TimedEvent(ArrivalEvent(),0.0), log_times = [5.3,7.5])

simulate(NetworkState(0, zeros(Int8, scenariotest.L)), TimedEvent(ArrivalEvent(),0.0), scenariotest ,max_time = 20.0, callback = record_trajectory)
plot(time_traj, queue_traj)