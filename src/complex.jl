"""
    Stateful{T, S}
    Stateful(schedule::T; advance = state -> true)

Create a stateful iterator around `schedule`.
Pass in a predicate, `advance(state)`, to conditionally control iteration.
See also [`ParameterSchedulers.next!`](#) and [`ParameterSchedulers.reset!`](#).
"""
mutable struct Stateful{T, S<:Integer, R}
    schedule::T
    state::S
    advance::R
end
Stateful(schedule; advance = state -> true) = Stateful(schedule, 1, advance)

"""
    next!(iter::Stateful)

Advance `iter` by one iteration
(if `iter.advance(state) == true`) and return the next value.
See also [`ParameterSchedulers.Stateful`](#).
"""
function next!(iter::Stateful)
    val = iter.schedule(iter.state)
    if iter.advance(iter.state)
        iter.state += 1
    end

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

"""
    Constant{T}
    Constant(value)

A constant schedule that is always `value`.
"""
struct Constant{T} <: AbstractSchedule{false}
    value::T
end

Base.eltype(::Type{<:Constant{T}}) where T = T

(schedule::Constant)(t) = schedule.value

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
struct Sequence{T, S} <: AbstractSchedule{missing}
    schedules::T
    step_sizes::S

    function Sequence(schedules, step_sizes)
        _schedules = map(s -> s isa Number ? Constant(s) : s, schedules)

        new{typeof(_schedules), typeof(step_sizes)}(_schedules, step_sizes)
    end
end
Sequence(stages::Pair...) = Sequence(first.(stages), last.(stages))

Base.IteratorEltype(::Type{<:Sequence}) = Base.EltypeUnknown()

function (schedule::Sequence)(t)
    acc = 0
    itr = Iterators.takewhile(enumerate(schedule.step_sizes)) do (i, step)
        acc += step
        return t > acc
    end |> collect
    i, toffset = isempty(itr) ? (0, 0) : last(itr)

    return schedule.schedules[min(i + 1, end)](t - toffset)
end

function Base.iterate(schedule::Sequence, state = (1, 1, 0, schedule.step_sizes))
    t, i, t0, itr = state
    _itr = Iterators.peel(itr)
    if !isnothing(_itr) && (t > t0 + _itr[1]) # move onto next step range
        if !isempty(_itr[2])
            i += 1
            t0 += _itr[1]
        end
        itr = _itr[2]
    end

    return schedule.schedules[i](t - t0), (t + 1, i, t0, itr)
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
struct Loop{T, S<:Integer} <: AbstractSchedule{false}
    f::T
    period::S
end
Loop(f, period) = Loop(f, period)

Base.IteratorEltype(::Type{<:Loop{T}}) where T = Base.IteratorEltype(T)
Base.eltype(::Type{<:Loop{T}}) where T = eltype(T)

(schedule::Loop)(t) = schedule.f(mod1(t, schedule.period))

"""
    Interpolator{T, S}
    Interpolator(schedule, rate)

A schedule whose output is `schedule(t / rate)` (i.e. it interpolates `schedule(t)`).

This can be useful when your code iterates over real numbers at a fixed rate
(e.g. in a fixed time step differential solver),
but you want to use a schedule that iterates discretely over integers.

It could also be used to specify `schedule` in units of epochs,
while iterating it in units of mini-batches.
"""
struct Interpolator{T, S} <: AbstractSchedule{T}
    schedule::T
    rate::S
end

Base.eltype(::Type{<:Interpolator{T}}) where T = eltype(T)
Base.IteratorEltype(::Type{<:Interpolator{T}}) where T = Base.IteratorEltype(T)
Base.IteratorSize(::Type{<:Interpolator{T}}) where T = Base.IteratorSize(T)

(interpolator::Interpolator)(t) = interpolator.schedule(t / interpolator.rate)

struct ComposedSchedule{T, S, F} <: AbstractSchedule{T}
    compose_fn::F
    schedule::T
    parameters::S

    function ComposedSchedule(compose_fn::F, schedule::T, parameters::S) where {T, F, S}
        _parameters = map(p -> p isa Number ? Constant(p) : p, parameters)

        return new{F, T, S}(compose_fn, schedule, _parameters)
    end
end

Base.eltype(::Type{<:ComposedSchedule{T}}) where T = eltype(T)
Base.length(s::ComposedSchedule) = length(s.schedule)

function (composition::ComposedSchedule)(t)
    ps = map(p -> p(t), composition.parameters)
    s = composition.compose_fn(composition.schedule, ps)

    return s(t)
end
