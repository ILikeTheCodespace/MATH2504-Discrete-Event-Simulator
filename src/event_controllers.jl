using Distributions, StatsBase

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
function process_event(time::Float64, state::State, scenario::NetworkParameters, ::ArrivalEvent)
    # Increase number in system
    state.number_in_system += 1
    new_timed_events = TimedEvent[]

    # Prepare next arrival
    """
    FIXME: The arg. for the Gamma function calls are placeholders since I currently do not understand what theyre asking for an input
    """
    push!(new_timed_events,TimedEvent(ArrivalEvent(),time + rand(Gamma(1/λ))))

    # Using probability vector, find the first station that the new arrival heads to
    first_station = sample(scenario.p_e)

    """ - NOTE FROM WILL - I think the logic of this section needs to be completely reworked. What we want is to check if the station is under capacity, if this is true, then the job enters the queue, if the queue is empty as the job enters it, then the job will be serviced and a new TimedEvent will be added to the heap. If the station is at capacity though, then the job will overflow and the corresponding set of calculations will be undertaken to see where the job eventually ends up.

    # If this is the only job on the station

    # FIXME: The arg. for the Gamma function calls are placeholders since I currently do not understand what theyre asking for an input

    # state.number_in_system == 1 && push!(new_timed_events,TimedEvent(EndOfServiceEvent(), time + rand(Gamma(1/μ))))
    """

    return new_timed_events
end