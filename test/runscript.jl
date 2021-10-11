include("../src/dependencies.jl")
# include("src/dependencies.jl") # This line is just here to test the plot function call at the end of the file from the Julia REPL.

lambda_range = 1:5

# Simulation recorded data
sojurn_times, orbiting_jobs_proportion = Float64[], Float64[]
system_job_totals = Int64[]

# Processed simulation data
mean_system_job_totals = zeros(Float64, length(lambda_range))
    
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

function plot_data_callbacks(time::Float64, state::NetworkState, event::TimedEvent)
    state.number_in_system_decreased && push!(sojurn_times, time - event.arrival_time)
    push!(orbiting_jobs_proportion, sum(state.queues)/state.number_in_system)
    push!(system_job_totals, state.number_in_system)
    return nothing
end

@time compile_time_macro = 1
# @time simulate(NetworkState(0, zeros(Int8, scenariotest.L)), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), scenariotest, max_time = 10000.0, callback = plot_data_callbacks)

"""
Call simulate function below for lambdas from 1 to 5
"""
#TODO: This whole loop is pretty gross but was fast to make and gets the job done, consider refactoring for cleanliness

for i in 1:length(lambda_range)
    global sojurn_times, orbiting_jobs_proportion, system_job_totals

    simulate(NetworkState(0, zeros(Int8, scenariotest.L)), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), scenariotest, max_time = 10000.0, callback = plot_data_callbacks)

    system_job_totals_length = length(system_job_totals)
    for j in system_job_totals
        mean_system_job_totals[i] += j/system_job_totals_length
    end

    # TODO: Process the data and set array values to be plotted.
    # for k in 
    # end

    # for l in 
    # end

    sojurn_times, orbiting_jobs_proportion = Float64[], Float64[]
    system_job_totals = Int64[]
end