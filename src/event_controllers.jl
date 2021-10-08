# using Distributions, StatsBase
#function to generate a Bernoulli(p) random variable
rand_bit(p::Real = 0.5) = rand() ≤ p ? 1 : 0   #\le + [TAB]

function queue_join_with_empty_check(time::Float64, current_station::Int, state::State, new_timed_events::Array{TimedEvent}, scenario::NetworkParameters)::Bool
    state.queues[current_station] += 1
    state.queues[current_station] == 1 && push!(new_timed_events, TimedEvent(EndOfServiceEvent(), time + rand(Gamma(scenario.gamma_shape, scenario.μ_vector[current_station])), current_station))
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
function process_event(time::Float64, state::State, location_ID, ::ArrivalEvent, scenario::NetworkParameters)
    # Increase number in system
    state.number_in_system += 1
    new_timed_events = TimedEvent[]

    # Prepare next arrival
    """
    FIXME: The arg. for the Gamma function calls are placeholders since I currently do not understand what theyre asking for an input
    """
    push!(new_timed_events,TimedEvent(ArrivalEvent(),time + rand(Gamma(scenario.gamma_shape, scenario.λ)),0))

    # Using probability vector, find the first station that the new arrival heads to
    current_station = sample(scenario.p_e) 
    
    # Job enters initial station, if it is not full, the job either queues or is being actively serviced. TODO: Consider cleaning up later since this code is pretty gross.
    state.queues[current_station] < scenario.K[current_station] && queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario) && return new_timed_events

    """
    FIXME: The arg. for the Gamma function calls are placeholders since I currently do not understand what theyre asking for an input
    """
    # TODO: FIXME: This if block is repeated multiple times throughout this file, this is poor practice and should be replaced with a function call ASAP. 

    # If the job doesnt leave the system (Determined by the overflow matrix Q), then a new OverflowEvent is created
    if rand_bit(1-sum(scenario.Q[current_station,:])) == 1
        state.number_in_system -= 1
    else
        push!(new_timed_events, TimedEvent(OverflowEvent(), time + rand(Gamma(scenario.gamma_shape, scenario.η)), sample(AnalyticWeights(scenario.Q[current_station,:]))))
    end

    return new_timed_events
end

# Process an EndOfServiceEvent event
function process_event(time::Float64, state::State, location_ID, ::EndOfServiceEvent, scenario::NetworkParameters)
    new_timed_events = TimedEvent[]

    current_station = location_ID

    state.queues[current_station] -= 1

    if rand_bit(1-sum(scenario.P[current_station,:])) == 1
        state.number_in_system -= 1
    else
        push!(new_timed_events, TimedEvent(OverflowEvent(), time + rand(Gamma(scenario.gamma_shape, scenario.η)), sample(AnalyticWeights(scenario.P[current_station,:]))))
    end

    @assert state.queues[location_ID] > -1
    return state.queues[location_ID] > 0 ? [TimedEvent(EndOfServiceEvent(), time + rand(Gamma(scenario.gamma_shape, scenario.μ_vector[current_station])), location_ID)] : TimedEvent[]
end

# Process an Orbit and OverflowEvent event
function process_event(time::Float64, state::State, location_ID, ::OverflowEvent, scenario::NetworkParameters)
    new_timed_events = TimedEvent[]

    current_station = location_ID
    # Job enters initial station, if it is not full, the job either queues or is being actively serviced. TODO: Consider cleaning up later since this code is pretty gross.
    # TODO: Check if the guard clause here is needed, or if theres a smarter way to go about this
    state.queues[current_station] < scenario.K[current_station] && queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario) && return new_timed_events

    if rand_bit(1-sum(scenario.Q[current_station,:])) == 1
        state.number_in_system -= 1
    else
        push!(new_timed_events, TimedEvent(OverflowEvent(), time + rand(Gamma(scenario.gamma_shape, scenario.η)), sample(AnalyticWeights(scenario.Q[current_station,:]))))
    end

    return new_timed_events
end

# Process an EndSimEvent event
function process_event(time::Float64, state::State, location_ID, es_event::EndSimEvent, scenario::NetworkParameters)
    println("Ending simulation at time $time.")
    return []
end