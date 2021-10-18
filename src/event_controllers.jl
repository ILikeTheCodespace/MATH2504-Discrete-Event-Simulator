#function to generate a Bernoulli(p) random variable
rand_bit(p::Real = 0.5) = rand() ≤ p ? 1 : 0   #\le + [TAB]

function queue_join_with_empty_check(time::Float64, current_station::Int, state::State, new_timed_events::Array{TimedEvent}, scenario::NetworkParameters, arrival_time::Float64)::Bool
    state.queues[current_station] += 1
    state.queues[current_station] == 1 && push!(new_timed_events, TimedEvent(EndOfServiceEvent(), time + rand(Gamma(1/scenario.gamma_shape, scenario.gamma_shape/scenario.μ_vector[current_station])), current_station, arrival_time))
    return true
end

"""
    new_timed_events = process_event(time, state, event)

Generate an array of 0 or more new `TimedEvent`s based on the current `event` and `state`.
"""
function process_event end # This defines a function with zero methods (to be added later)

"""
Terminates the simulation.
"""
function process_event(time::Float64, state::State, es_event::EndSimEvent)
    println("Ending simulation at time $time.")
    return []
end

"""
Prints out the system state at the current time after accepting a LogStateEvent as an arg.
"""
function process_event(time::Float64, state::State, ls_event::LogStateEvent)
    println("Logging state at time $time.")
    println(state)
    return []
end

"""
Handles jobs entering into the system
"""

# Process an arrival event
function process_event(time::Float64, state::State, location_ID, ::ArrivalEvent, scenario::NetworkParameters, arrival_time::Float64 = 0.0)
    # Increase number in system
    state.number_in_system += 1
    new_timed_events = TimedEvent[]

    # Set time ID
    arrival_time = time

    # Prepare next arrival
    push!(new_timed_events,TimedEvent(ArrivalEvent(),time + rand(Gamma(1/scenario.gamma_shape, scenario.gamma_shape/scenario.λ)),0, arrival_time))

    # Using probability vector, find the first station that the new arrival heads to
    current_station = sample(scenario.p_e) 
    
    # Job enters initial station, if it is not full, the job either queues or is being actively serviced. 
    if scenario.K[current_station] != -1
        state.queues[current_station] < scenario.K[current_station] && queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario, arrival_time) && return new_timed_events
    else
        queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario, arrival_time) && return new_timed_events
    end
    
    # If the job doesnt leave the system (Determined by the overflow matrix Q), then a new OverflowEvent is created
    overflow_state_control(time, state, scenario.Q, scenario, arrival_time, current_station, new_timed_events)

    return new_timed_events
end

# Process an EndOfServiceEvent event
function process_event(time::Float64, state::State, location_ID, ::EndOfServiceEvent, scenario::NetworkParameters, arrival_time::Float64)
    new_timed_events = TimedEvent[]

    current_station = location_ID

    state.queues[current_station] -= 1

    overflow_state_control(time, state, scenario.P, scenario, arrival_time, current_station, new_timed_events)

    @assert state.queues[location_ID] > -1
    state.queues[location_ID] > 0 && push!(new_timed_events, TimedEvent(EndOfServiceEvent(), time + rand(Gamma(1/scenario.gamma_shape, scenario.gamma_shape/scenario.μ_vector[current_station])), location_ID, arrival_time))

    return new_timed_events
end

# Process an Orbit and OverflowEvent event
function process_event(time::Float64, state::State, location_ID, ::OverflowEvent, scenario::NetworkParameters, arrival_time::Float64)
    new_timed_events = TimedEvent[]
    current_station = location_ID

    # Job enters initial station, if it is not full, the job either queues or is being actively serviced.
    state.orbiting_jobs -= 1

    if scenario.K[current_station] != -1
        state.queues[current_station] < scenario.K[current_station] && queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario, arrival_time) && return new_timed_events
    else
        queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario, arrival_time) && return new_timed_events
    end

    overflow_state_control(time, state, scenario.Q, scenario, arrival_time, current_station, new_timed_events)

    return new_timed_events
end

# Process an EndSimEvent event
function process_event(time::Float64, state::State, location_ID, es_event::EndSimEvent, scenario::NetworkParameters, arrival_time::Float64)
    return []
end 

function overflow_state_control(time::Float64, state::State, prob_matrix::Matrix{Float64}, scenario::NetworkParameters, arrival_time::Float64, current_station, new_timed_events::Array{TimedEvent})::Nothing
    if rand_bit(1-sum(prob_matrix[current_station,:])) == 1
        state.number_in_system_decreased = true
        state.number_in_system -= 1
        @assert state.number_in_system >= 0
    else
        push!(new_timed_events, TimedEvent(OverflowEvent(), time + rand(Gamma(1/scenario.gamma_shape, scenario.gamma_shape/scenario.η)), sample(AnalyticWeights(prob_matrix[current_station,:])), arrival_time))
        state.orbiting_jobs += 1
    end
    return nothing
end