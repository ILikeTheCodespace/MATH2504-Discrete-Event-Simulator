include("../src/dependencies.jl")
# include("src/dependencies.jl") # This line is just here to test the plot function call at the end of the file from the Julia REPL.

lambda_range = 1:5

# Simulation recorded data
sojurn_times = Float64[]
system_job_totals, total_queued_jobs = Int64[], Int64[]

# Processed simulation data for project plots.
mean_system_job_totals = zeros(Float64, length(lambda_range))
processed_sojurn_times = []

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
    # FIXME: THIS TAKES WAY TOO LONG TO PROCESS, CHANGE HOW STATE WORKS!!!!!!
    # push!(total_queued_jobs, sum(state.queues))
    push!(system_job_totals, state.number_in_system)
    return nothing
end

@time compile_time_macro = 1
# @time simulate(NetworkState(0, zeros(Int8, scenariotest.L)), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), scenariotest, max_time = 100000000.0, callback = plot_data_callbacks)

"""
Call simulate function below for lambdas from 1 to 5
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

    global sojurn_times, total_queued_jobs, system_job_totals

    Random.seed!(1)

    simulate(NetworkState(0, zeros(Int8, current_scenario.L)), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), current_scenario, max_time = 1000.0, callback = plot_data_callbacks)

    println("Simulation for lambda = $i complete. Processing data for lambda = $i now.")

    # Logic to generate the data needed for Plot 1.
    system_job_totals_length = length(system_job_totals)
    for j in system_job_totals
        mean_system_job_totals[i] += j/system_job_totals_length
    end

    # Logic to generate the data needed for Plot 2.

    # Logic to generate the data needed for Plot 3.
    push!(processed_sojurn_times, sojurn_times)

    println("Data for lambda = $i has now been processed.")

    sojurn_times = Float64[]
    system_job_totals, total_queued_jobs = Int64[], Int64[]
end

println("Plotting data...")

common_params = Dict( :bins   => 20, 
                      :range  => (0, maximum([maximum(i) for i in processed_sojurn_times])))

PyPlot.hist(processed_sojurn_times)
PyPlot.legend(["λ = $i" for i in lambda_range])
PyPlot.title("Empirical Distribution of Sojurn Times For Scenario 1")
PyPlot.xlabel("Recorded Sojurn Times (Seconds)")
PyPlot.ylabel("Frequency")
PyPlot.savefig("histogram_scenario_1.png")
PyPlot.close()

PyPlot.scatter(lambda_range, mean_system_job_totals)
PyPlot.xticks(lambda_range)
PyPlot.title("Mean Number of Items in the Total System for Scenario 2")
PyPlot.xlabel("λ")
PyPlot.ylabel("Mean Items in System")
PyPlot.savefig("mean_items_scenario_1.png")
PyPlot.close()