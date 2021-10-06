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

########################################################################
### TODO: MAKE THESE RAND FUNCTIONS SAMPLE FROM A GAMMA DISTRIBUTION ###  
########################################################################

# Process an arrival event
function process_event(time::Float64, state::State, ::ArrivalEvent)
    # Increase number in system
    state.number_in_system += 1
    new_timed_events = TimedEvent[]

    # Prepare next arrival
    push!(new_timed_events,TimedEvent(ArrivalEvent(),time + rand(Exponential(1/λ))))

    # If this is the only job on the server

    ############################################################################################ 
    ### FIXME: THIS SHORT CIRCUIT EVALUATION PROBABLY DOESNT WORK FOR THE PROJECT 2 SCENARIO ###  
    ############################################################################################
    state.number_in_system == 1 && push!(new_timed_events,TimedEvent(EndOfServiceEvent(), time + 1/μ))
    return new_timed_events
end

    #####################################################################################################################################
    ### TODO: WHEN I RETURN TO THIS FUNNY HAHA LINE OF CODE, CHANGE IT SO THAT IT USES FILTERS THE NEW ARRIVAL INTO THE FIRST STATION ###  
    #####################################################################################################################################