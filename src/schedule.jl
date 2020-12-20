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


struct Sequence{T<:AbstractVector, S<:Integer} <: AbstractSchedule
    schedules::T
    step_sizes::Vector{S}
end

function Base.getindex(schedule::Sequence{T}, t::Integer) where T<:AbstractSchedule
    accum_steps = cumsum(schedule.step_sizes)
    i = findlast(x -> t > x, accum_steps)
    i = isnothing(i) ? 1 : i + 1
    toffset = (i > 1) ? t - accum_steps[i - 1] : t
    
    return schedule.schedules[i][toffset]
end
function Base.iterate(schedule::Sequence{T}, state = (1, 1, 1)) where T<:AbstractSchedule
    t, i, t0 = state
    if (i <= length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return schedule.schedules[i][t - t0 + 1], (t + 1, i, t0)
end

function Base.getindex(schedule::Sequence, t::Integer)
    accum_steps = cumsum(schedule.step_sizes)
    i = findlast(x -> t > x, accum_steps)
    i = isnothing(i) ? 1 : i + 1
    toffset = (i > 1) ? t - accum_steps[i - 1] : t
    
    return schedule.schedules[i](toffset)
end
function Base.iterate(schedule::Sequence{T}, state = (1, 1, 1))
    t, i, t0 = state
    if (i <= length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return schedule.schedules[i](t - t0 + 1), (t + 1, i, t0)
end