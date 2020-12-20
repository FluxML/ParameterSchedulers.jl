abstract type AbstractSchedule end

abstract type DecaySchedule <: AbstractSchedule end

# decay interface
function basevalue end
function decay end

Base.getindex(schedule::DecaySchedule, t::Integer) = basevalue(schedule) * decay(schedule, t)
Base.firstindex(schedule::DecaySchedule) = 1

Base.iterate(schedule::DecaySchedule, t = 1) = (schedule[t], t + 1)

abstract type CyclicSchedule <: AbstractSchedule end

# cyclic interface
function startvalue end
function endvalue end
function cycle end

function Base.getindex(schedule::CyclicSchedule, t::Integer)
    k0, k1 = startvalue(schedule), endvalue(schedule)
    
    return abs(k0 - k1) * cycle(schedule, t) + min(k0, k1)
end
Base.firstindex(schedule::CyclicSchedule) = 1

Base.iterate(schedule::CyclicSchedule, t = 1) = (schedule[t], t + 1)