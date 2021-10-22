include("../src/dependencies.jl")

sojurn_times = Float64[]

number_in_system_integral = 0
prev_number_in_system = 0
prev_time = 0

processed_sojurn_times = []


function mode_1(time::Float64, state::NetworkState, event::TimedEvent)
    global number_in_system_integral += (time - prev_time) * prev_number_in_system
    global prev_number_in_system = state.number_in_system
    global prev_time = time
    return nothing
end

function mode_2(time::Float64, state::NetworkState, event::TimedEvent)
    state.number_in_system_decreased && push!(sojurn_times, time - event.arrival_time)
    return nothing
end

modes_dict = Dict(1 => mode_1, 2 => mode_2)

function run_script(params::NetworkParameters; max_time::Float64, lambda_range::Vector{Float64}, mode::Int=1, plot_num::Int=1)

    global modes_dict
    
    plot_data_callbacks = modes_dict[mode]

    mean_system_job_totals = zeros(Float64, length(lambda_range))
    proportion_orbiting_jobs = zeros(Float64, length(lambda_range))

    for i in 1:length(lambda_range)

        global sojurn_times, prev_time, prev_number_in_system, number_in_system_integral, processed_sojurn_times

        params.λ = lambda_range[i]
    
        Random.seed!(1)
    
        println("Starting simulation for λ = ", lambda_range[i])
        
        sim_states = simulate(NetworkState(0, zeros(Int8, params.L), 0), TimedEvent(ArrivalEvent(),0.0, 0, 0.0), params, max_time = max_time, callback = plot_data_callbacks)
    
        println("Simulation for lambda = ", lambda_range[i], " complete. Processing data for lambda = ", lambda_range[i], " now.")
    
        if mode == 1
            # Logic to generate the data needed for Plot 1.
            mean_system_job_totals[i] = number_in_system_integral/max_time

            # Logic to generate the data needed for Plot 2.
            proportion_data = sim_states.orbiting_jobs/sim_states.number_in_system
            !isnan(proportion_data) ? proportion_orbiting_jobs[i] = proportion_data : proportion_orbiting_jobs[i] = 0.0
            
            # proportion_orbiting_jobs[i] = sim_states.orbiting_jobs/sim_states.number_in_system == NaN ? 0.0 : sim_states.orbiting_jobs/sim_states.number_in_system

        elseif mode == 2
            # Logic to generate the data needed for Plot 3.
            push!(processed_sojurn_times, sojurn_times)
        else
            throw(DomainError(mode, "Mode number currently unsupported."))
        end

        println("Data for lambda = ", lambda_range[i], " has now been processed.\n")
    
        sojurn_times = Float64[]
        prev_time = 0
        prev_number_in_system = 0
        number_in_system_integral = 0
    end
    scenario_plots(processed_sojurn_times, mean_system_job_totals, proportion_orbiting_jobs, plot_num, lambda_range, mode)
end

#################################
### NetworkParameters Outline ###
#################################

"""
@with_kw mutable struct NetworkParameters
    L::Int #amount of stations
    gamma_shape::Float64 #external rate of arrivals
    λ::Float64 #This is undefined for the scenarios since it is varied
    η::Float64 #overflow movement rate
    μ_vector::Vector{Float64} #service rates
    P::Matrix{Float64} #routing matrix
    Q::Matrix{Float64} #overflow matrix
    p_e::AbstractWeights #external arrival distribution
    K::Vector{Int} #-1 means infinity 
end
"""

###############################
### HOW TO USE THIS PROGRAM ###
###############################

"""
Please follow the instructions to README.md which explains how to use this program. The following variables test_params and lambdas along with the subsequent call to run_script are all the inputs needed to run this program. Once the inputs are what you want to them to be, run this script without debugging in VSCode with Ctrl+F5 and wait for the script to finish processing the request. Once finished, the script will output PNG files related to the mode that you have selected.
"""

test_params = NetworkParameters(  L=3, 
                                gamma_shape = 3.0, 
                                λ = NaN, 
                                η = 4.0, 
                                μ_vector = ones(3),
                                P = [0 1.0 0;
                                    0 0 1.0;
                                    0.5 0 0],
                                Q = zeros(3,3),
                                p_e = AnalyticWeights([1.0, 0, 0]),
                                K = fill(5,3))

lambdas = [i for i in 0.2:0.2:0.8] 

run_script(test_params, max_time = 10000.0, lambda_range = lambdas, mode=1, plot_num=102)
