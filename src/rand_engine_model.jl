######################################
### BOILERPLATE FROM LECTURE NOTES ### 
######################################

abstract type Event end
abstract type State end

# Captures an event and the time it takes place
struct TimedEvent
    event::Event
    time::Float64
    location_ID::Int
    arrival_time::Float64
end

# Comparison of two timed events - this will allow us to use them in a heap/priority-queue
isless(te1::TimedEvent, te2::TimedEvent) = te1.time < te2.time

"""
Object which represents state of overall system, e.g. total jobs orbiting, 
total jobs within system.
"""

mutable struct NetworkState <: State
    number_in_system::Int # Total number of jobs within the network
    queues::Array{Int64} #Int64 used because scenario 4 has an infinite queue
    number_in_system_decreased::Bool
    orbiting_jobs::Int
    NetworkState() = new(0)
    NetworkState(x::Int, y::Array{Int8}, z::Int) = new(x,y, false, z)
end

struct ArrivalEvent <: Event end
struct EndOfServiceEvent <: Event end
struct OverflowEvent <: Event end 

# Generic events that we can always use
"""
    EndSimEvent()

Return an event that ends the simulation.
"""
struct EndSimEvent <: Event end

"""
    LogStateEvent()

Return an event that prints a log of the current simulation state.
"""
struct LogStateEvent <: Event end

"""
The main simulation function gets an initial state and an initial event
that gets things going. Optional arguments are the maximal time for the
simulation, times for logging events, and a call-back function.
"""

function simulate(init_state::State, init_timed_event::TimedEvent
                    ; 
                    max_time::Float64 = 10.0, 
                    log_times::Vector{Float64} = Float64[],
                    callback = (time, state) -> nothing)

    # The event queue
    priority_queue = BinaryMinHeap{TimedEvent}()

    # Put the standard events in the queue
    push!(priority_queue, init_timed_event)
    # FIXME: TESTING NAN FOR THE FINAL VALUE OF TIMED EVENT
    push!(priority_queue, TimedEvent(EndSimEvent(), max_time, 0, NaN))
    for log_time in log_times
        push!(priority_queue, TimedEvent(LogStateEvent(), log_time, 0, NaN))
    end

    # initilize the state
    state = deepcopy(init_state)
    time = 0.0

    # Callback at simulation start
    callback(time, state, TimedEvent[])

    # The main discrete event simulation loop - SIMPLE!
    while true
        # Get the next event
        timed_event = pop!(priority_queue)

        # Advance the time
        time = timed_event.time

        # Act on the event
        new_timed_events = process_event(time, state, timed_event.event) 

        # If the event was an end of simulation then stop
        if timed_event.event isa EndSimEvent
            break 
        end

        # The event may spawn 0 or more events which we put in the priority queue 
        for nte in new_timed_events
            push!(priority_queue,nte)
        end

        # Callback for each simulation event
        callback(time, state, timed_event)
    end
end;

"""
Overload Simulate with the Project 2 specific Simulate function, differs by taking in the premade NetworkParameters object as an arg.
"""

function simulate(init_state::State, init_timed_event::TimedEvent, scenario::NetworkParameters
    ; 
    max_time::Float64 = 10.0, 
    log_times::Vector{Float64} = Float64[],
    callback = (time, state) -> nothing)

    # The event queue
    priority_queue = BinaryMinHeap{TimedEvent}()

    # Put the standard events in the queue
    push!(priority_queue, init_timed_event)
    # FIXME: TESTING NAN FOR THE FINAL VALUE OF TIMED EVENT
    push!(priority_queue, TimedEvent(EndSimEvent(), max_time, 0, NaN))
    for log_time in log_times
        push!(priority_queue, TimedEvent(LogStateEvent(), log_time, 0, NaN))
    end

    # Initialize the network state
    state = deepcopy(init_state)
    time = 0.0

    # # initialize the queue states of the stations
    # state.queues = zeros(Int8, scenario.L) This is probably a bad approach to take when taking a "generic" system so Im commenting it out for the time being

    # Callback at simulation start
    callback(time, state, init_timed_event)
    
    # The main discrete event simulation loop 
    while true
        # Get the next event
        timed_event = pop!(priority_queue)

        # Advance the time
        time = timed_event.time

        # Act on the event
        new_timed_events = process_event(time, state, timed_event.location_ID, timed_event.event, scenario, timed_event.arrival_time)

        # If the event was an end of simulation then stop
        if timed_event.event isa EndSimEvent
            break 
        end

        # The event may spawn 0 or more events which we put in the priority queue 
        for nte in new_timed_events
            push!(priority_queue,nte)
        end
        
        # Callback for each simulation event
        callback(time, state, timed_event)

        # Reset state changed variable
        state.number_in_system_decreased = false
    end
    println(state.orbiting_jobs)
    println(state.number_in_system)
end

