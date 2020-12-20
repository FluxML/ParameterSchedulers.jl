abstract type AbstractSchedule end

abstract type DecaySchedule <: AbstractSchedule end

# decay interface
function basevalue end
function decay end

Base.getindex(schedule::DecaySchedule, t::Integer) = basevalue(schedule) * decay(schedule, t)
Base.firstindex(schedule::DecaySchedule) = 1

Base.iterate(schedule::DecaySchedule, t = 1) = (schedule[t], t + 1)