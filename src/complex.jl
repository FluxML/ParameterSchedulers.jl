"""
    Stateful{T, S}
    Stateful(schedule::T)

Create a stateful iterator around `schedule`.
See also [`ParameterSchedulers.next!`](#) and [`ParameterSchedulers.reset!`](#).
"""
mutable struct Stateful{T, S<:Integer}
    schedule::T
    state::S
end
Stateful(schedule) = Stateful(schedule, 1)

"""
    next!(iter::Stateful)

Advance `iter` by one iteration and return the next value.
See also [`ParameterSchedulers.Stateful`](#).
"""
function next!(iter::Stateful)
    val = iter.schedule(iter.state)
    iter.state += 1

    return val
end

"""
    reset!(iter::Stateful)

Reset `iter` to its initial state.
See also [`ParameterSchedulers.Stateful`](#).
"""
function reset!(iter::Stateful)
    iter.state = 1

    return iter
end

at(x::Number, t) = x
at(f, t) = f(t)

"""
    Sequence{T, S}
    Sequence(schedules, step_sizes)
    Sequence(schedule1 => step1, schedule2 => step2, ...)

A sequence of schedules.
The output of this schedule is the concatenation of `schedules` where each
schedule is evaluated for each step size in `step_sizes`.

Note that `schedules` can also be a vector of numbers (not just schedules).

# Arguments
- `schedules`: a vector of schedules or numbers
- `step_sizes`: a vector of iteration lengths for each schedule
"""
struct Sequence{T, S}
    schedules::T
    step_sizes::S
end
Sequence(stages::Pair...) = Sequence(first.(stages), last.(stages))

function (schedule::Sequence)(t)
    accum_steps = cumsum(schedule.step_sizes)
    i = findlast(x -> t > x, accum_steps)
    i = isnothing(i) ? 1 :
            (i >= length(schedule.schedules)) ? length(schedule.schedules) : i + 1
    toffset = (i > 1) ? t - accum_steps[i - 1] : t
    
    return at(schedule.schedules[i], toffset)
end

Base.IteratorEltype(::Type{<:Sequence}) = Base.EltypeUnknown()
Base.IteratorSize(::Type{<:Sequence}) = Base.SizeUnknown()

function Base.iterate(schedule::Sequence, state = (1, 1, 1))
    t, i, t0 = state
    if (i < length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return at(schedule.schedules[i], t - t0 + 1), (t + 1, i, t0)
end

"""
    Loop{T, S<:Integer}
    Loop(f, period)

Create a schedule that loops `f` every `period` iterations.
`f` must be callabe (a function or schedule).

# Arguments
- `f`: the schedule to loop
- `period::Integer`: how often to loop
"""
struct Loop{T, S<:Integer}
    f::T
    period::S
end
Loop(f, period) = Loop(f, period)

(schedule::Loop)(t) = schedule.f(mod1(t, schedule.period))

Base.IteratorEltype(::Type{<:Loop{T}}) where T = Base.IteratorEltype(T)
Base.eltype(::Type{<:Loop{T}}) where T = eltype(T)
Base.IteratorSize(::Type{<:Loop}) = Base.IsInfinite()

Base.iterate(schedule::Loop, t = 1) = schedule(t), t + 1

"""
    reverse(f, period)

Return a reverse function such that `reverse(f, period)(t) == f(period - t)`.
"""
reverse(f, period) = t -> f(period - t)
"""
    symmetric(f, period)

Return a symmetric function such that for `t ∈ [1, period / 2)`,
the symmetric function evaluates to `f(t)`, and when `t ∈ [period / 2, period)`,
the symmetric functions evaluates to `f(period - t)`.
"""
symmetric(f, period) = t -> (t < period / 2) ? f(t) : f(period - t)