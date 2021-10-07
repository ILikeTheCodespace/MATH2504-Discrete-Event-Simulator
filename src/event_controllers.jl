# using Distributions, StatsBase
#function to generate a Bernoulli(p) random variable
rand_bit(p::Real = 0.5) = rand() ≤ p ? 1 : 0   #\le + [TAB]

function queue_join_with_empty_check(time::Float64, current_station::Int, state::State, new_timed_events::Array{TimedEvent}, scenario::NetworkParameters)::Bool
    state.queues[current_station] += 1
    state.queues[current_station] == 1 && push!(new_timed_events, TimedEvent(EndOfServiceEvent(), time + rand(Gamma(1/scenario.μ_vector[current_station]))))
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
function process_event(time::Float64, state::State, ::ArrivalEvent, scenario::NetworkParameters)
    # Increase number in system
    state.number_in_system += 1
    new_timed_events = TimedEvent[]

    # Prepare next arrival
    """
    FIXME: The arg. for the Gamma function calls are placeholders since I currently do not understand what theyre asking for an input
    """
    push!(new_timed_events,TimedEvent(ArrivalEvent(),time + rand(Gamma(1/scenario.λ))))

    # Using probability vector, find the first station that the new arrival heads to
    current_station = sample(scenario.p_e)

    """
    The following if block checks if the station is under capacity, if this is true, then the job enters the queue, if the queue is empty as the job enters it, then the job will be serviced and a new TimedEvent will eventually be added to the heap. If the station is at capacity though, then the job will overflow and the corresponding set of calculations will be undertaken to see where the job eventually ends up. TODO: Consider cleaning up later since this code is pretty gross.
    """
    while true 
        state.queues[current_station] < scenario.K[current_station] && queue_join_with_empty_check(time, current_station, state, new_timed_events, scenario) && break
        if rand_bit(1-sum(scenario.Q[current_station,:])) == 1
            state.number_in_system -= 1 
            break
        end
        current_station = sample(AnalyticWeights(scenario.Q[current_station,:]))
    end
    
    # Disgusting scrap code, delete later if the while loop above works
    # if state.queues[first_station] < state.k[first_station]
    #     queue_join_with_empty_check(first_station, new_timed_events)
    # else
    #     current_station = first_station
    #     while true
    #         if rand_bit(1-sum(scenario.Q[current_station,:])) == 1 
    #             state.number_in_system -= 1
    #             break
    #         else
    #             current_station = sample(AnalyticWeights(scenario.Q[current_station,:]))
    #             if state.queues[current_station] < state.k[current_station]
    #                 queue_join_with_empty_check(current_station, new_timed_events)
    #                 break
    #             end
    #         end
    #     end
    # end

    return new_timed_events
end

# Process an EndOfServiceEvent event
function process_event(time::Float64, state::State, ::EndOfServiceEvent, scenario::NetworkParameters)
    new_timed_events = TimedEvent[]
    return new_timed_events
end

# Process an EndOfServiceEvent event
function process_event(time::Float64, state::State, es_event::EndSimEvent, scenario::NetworkParameters)
    println("Ending simulation at time $time.")
    return []
end
