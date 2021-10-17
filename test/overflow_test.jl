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
    return nothing
end

"""
Call simulate function below for lambdas in lambda_range
"""

#TODO: This whole loop is pretty gross but was fast to make and gets the job done, consider refactoring for cleanliness
for i in 1:length(lambda_range)
    current_scenario = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = i, 
                                η = 4.0, 
                                μ_vector = ones(3),
                                P = [0 1.0 0;
                                    0 0 1.0;
                                    0 0 0],
                                Q = zeros(3,3),
                                p_e = AnalyticWeights([1.0, 0, 0]),
                                K = fill(5,3))

    global sojurn_times, total_orbiting_jobs, system_job_totals

    Random.seed!(1)

    println("Starting simulation for λ = ", lambda_range[i])

    @time simulate(NetworkState(0, fill(5, current_scenario.L), 0), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), current_scenario, max_time = 1000.0, callback = plot_data_callbacks)

    println("Simulation for lambda = ", lambda_range[i], " complete. Processing data for lambda = ", lambda_range[i], " now.")

    # Logic to generate the data needed for Plot 1.
    system_job_totals_length = length(system_job_totals)
    for j in system_job_totals
        mean_system_job_totals[i] += j/system_job_totals_length
    end

    # Logic to generate the data needed for Plot 2.
    proportion_orbiting_jobs[i] = last(total_orbiting_jobs)/last(system_job_totals)

    # Logic to generate the data needed for Plot 3.
    push!(processed_sojurn_times, sojurn_times)

    println("Data for lambda = ", lambda_range[i], " has now been processed.\n")

    sojurn_times = Float64[]
    system_job_totals, total_orbiting_jobs = Int64[], Int64[]
end

scenario_plots(processed_sojurn_times, mean_system_job_totals, proportion_orbiting_jobs, 100, lambda_range)