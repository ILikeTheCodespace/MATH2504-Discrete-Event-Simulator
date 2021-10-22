include("../src/dependencies.jl")

function plot_data_callbacks(time::Float64, state::NetworkState, event::TimedEvent)
    return nothing
end

function proportion_test(params::NetworkParameters; max_time::Float64, lambda_range::Vector{Float64})
    print("Begin proportion test [")
    mean_system_job_totals = zeros(Float64, length(lambda_range))
    proportion_orbiting_jobs = zeros(Float64, length(lambda_range))

    for i in 1:length(lambda_range)
        print("-")
        params.λ = lambda_range[i]
        Random.seed!(1)
        sim_states = simulate(NetworkState(0, zeros(Int8, params.L), 0), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), params, max_time = max_time, callback = plot_data_callbacks)
    
        # Test Criteria
        proportion_data = sim_states.orbiting_jobs/sim_states.number_in_system
        !isnan(proportion_data) ? proportion_orbiting_jobs[i] = proportion_data : proportion_orbiting_jobs[i] = 0.0
        @assert proportion_orbiting_jobs[i] >= 0.0 && proportion_orbiting_jobs[i] <= 1.0
        
    end
    print("]")
    println(proportion_orbiting_jobs)
    println("proportion_test - PASSED!")
end

"""
Call simulate function below for lambdas in lambda_range
"""

test_params = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
                                η = 4.0, 
                                μ_vector = ones(3),
                                P = [0 1.0 0;
                                    0 0 1.0;
                                    0.5 0 0],
                                Q = [0 0.5 0;
                                     0 0 0.5;
                                     0.5 0 0],
                                p_e = AnalyticWeights([1.0, 0, 0]),
                                K = fill(5,3))

lambdas = [i for i in 0.2:0.2:1.2] 

proportion_test(test_params, max_time = 1000.0, lambda_range = lambdas)

