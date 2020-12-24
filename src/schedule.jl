abstract type AbstractSchedule end

mutable struct ScheduleIterator{T, S}
    schedule::T
    state::Union{S, Nothing}
end
function ScheduleIterator(schedule::T) where T<:AbstractSchedule
    _, state = iterate(schedule)
    
    ScheduleIterator{T, typeof(state)}(schedule, nothing)
end

function next!(iter::ScheduleIterator)
    val, iter.state = isnothing(iter.state) ? iterate(iter.schedule) : iterate(iter.schedule, iter.state)

    return val
end
    

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


struct Lambda{T} <: AbstractSchedule
    f::T
end
Lambda(;f) = Lambda(f)

Base.getindex(schedule::Lambda, t) = f(t)

Base.iterate(schedule::Lambda, t = 1) = (schedule[t], t + 1)

reverse(f, period) = t -> f(period - t)
symmetric(f, period) = t -> (t < period / 2) ? f(t) : f(period - t)


at(x::Number, t) = x
at(x::AbstractSchedule, t) = x[t]

struct Sequence{T<:AbstractVector, S<:Integer} <: AbstractSchedule
    schedules::T
    step_sizes::Vector{S}
end

function Base.getindex(schedule::Sequence, t::Integer)
    accum_steps = cumsum(schedule.step_sizes)
    i = findlast(x -> t > x, accum_steps)
    i = isnothing(i) ? 1 : i + 1
    toffset = (i > 1) ? t - accum_steps[i - 1] : t
    
    return at(schedule.schedules[i], toffset)
end
function Base.iterate(schedule::Sequence, state = (1, 1, 1))
    t, i, t0 = state
    if (i <= length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return at(schedule.schedules[i], t - t0 + 1), (t + 1, i, t0)
end
Base.IteratorSize(::Type{<:Sequence}) = Base.SizeUnknown()