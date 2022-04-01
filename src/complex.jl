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

    function Sequence(schedules::Base.Generator, step_sizes)
        _schedules = Iterators.map(s -> s isa Number ? Constant(s) : s, schedules)

        new{typeof(_schedules), typeof(step_sizes)}(_schedules, step_sizes)
    end
    function Sequence(schedules, step_sizes)
        _schedules = map(s -> s isa Number ? Constant(s) : s, schedules)

        new{typeof(_schedules), typeof(step_sizes)}(_schedules, step_sizes)
    end
end
Sequence(stages::Pair...) = Sequence(first.(stages), last.(stages))
Sequence(schedule_fn::Base.Generator) = Sequence(schedule_fn, schedule_fn.iter)

Base.IteratorEltype(::Type{<:Sequence}) = Base.EltypeUnknown()

function (schedule::Sequence)(t)
    acc = 0
    itr = Iterators.takewhile(enumerate(schedule.step_sizes)) do (i, step)
        acc += step
        return t > acc
    end |> collect
    i, toffset = isempty(itr) ? (0, 0) : (last(itr)[1], acc - last(itr)[2] - 1)
    sitr = _peel(Iterators.drop(schedule.schedules, i))
    s = isnothing(sitr) ? schedule.schedules[end] : first(sitr)

    # @show s, t, toffset, acc
    return s(t - toffset)
end

function Base.iterate(schedule::Sequence,
                      state = (1, 0, _peel(schedule.schedules)..., schedule.step_sizes))
    t, t0, s, sched_itr, step_itr = state
    _step_itr = _peel(step_itr)
    if !isnothing(_step_itr) && (t > t0 + _step_itr[1]) # move onto next step range
        if !isempty(_step_itr[2])
            s, sched_itr = _peel(sched_itr)
            t0 += _step_itr[1]
        end
        step_itr = _step_itr[2]
    end

    return s(t - t0), (t + 1, t0, s, sched_itr, step_itr)
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
    Interpolator{T, S, F}
    Interpolator(schedule, rate, ceil_fn = x -> ceil(Int, x))

A schedule whose output is `schedule(t / rate)` (i.e. it interpolates `schedule(t)`).

This can be useful when your code iterates over real numbers at a fixed rate
(e.g. in a fixed time step differential solver),
but you want to use a schedule that iterates discretely over integers.

It could also be used to specify `schedule` in units of epochs,
while iterating it in units of mini-batches.

Specify `ceil_fn` to apply a ceiling (or flooring) function to `t / rate`.
"""
struct Interpolator{T, S, F} <: AbstractSchedule{T}
    schedule::T
    rate::S
    ceil_fn::F
end
Interpolator(schedule, rate) = Interpolator(schedule, rate, x -> ceil(Int, x))

Base.eltype(::Type{<:Interpolator{T}}) where T = eltype(T)
Base.IteratorEltype(::Type{<:Interpolator{T}}) where T = Base.IteratorEltype(T)
Base.IteratorSize(::Type{<:Interpolator{T}}) where T = Base.IteratorSize(T)

(interpolator::Interpolator)(t) =
    interpolator.schedule(interpolator.ceil_fn(t / interpolator.rate))

"""
    Shifted(schedule, offset)

A `schedule` who's starting iteration is shifted to `offset`.
(i.e. calling an `Shifted` with `t = 1` is equivalent to calling
`schedule` with `t = offset`)
"""
struct Shifted{T} <: AbstractSchedule{T}
    schedule::T
    offset::Int
end

Base.eltype(::Type{<:Shifted{T}}) where T = eltype(T)
Base.IteratorEltype(::Type{<:Shifted{T}}) where T = Base.IteratorEltype(T)

(offset_schedule::Shifted)(t) = offset_schedule.schedule(t - 1 + offset_schedule.offset)

"""
    ComposedSchedule([(s, ps) -> T(ps...), ]schedule::T, parameters)

A `schedule` whose fields are given by `parameters.(t)` at iteration `t`.

At each step `t`, this gets a new set of parameters with `parameters.(t)`,
then creates a new `schedule` given the first (optional) argument.
The new `schedule(t)` is the returned value.
"""
struct ComposedSchedule{T, S, F} <: AbstractSchedule{T}
    compose_fn::F
    schedule::T
    parameters::S

    function ComposedSchedule(compose_fn::F, schedule::T, parameters::S) where {T, F, S}
        _parameters = map(p -> p isa Number ? Constant(p) : p, parameters)

        return new{T, typeof(_parameters), F}(compose_fn, schedule, _parameters)
    end
end
ComposedSchedule(schedule::T, parameters::Union{Tuple, AbstractVector}) where T =
    ComposedSchedule((s, ps) -> T(ps...), schedule, parameters)

function Base.show(io::IO, schedule::ComposedSchedule{T}) where T
    ioc = IOContext(io, :compact => true)
    print(ioc, "ComposedSchedule(", T, ", ")
    show(ioc, schedule.parameters)
    print(io, ")")
end

Base.eltype(::Type{<:ComposedSchedule{T}}) where T = eltype(T)
Base.length(s::ComposedSchedule) = length(s.schedule)
Base.axes(s::ComposedSchedule) = axes(s.schedule)

function (composition::ComposedSchedule)(t)
    ps = map(p -> p(t), composition.parameters)
    s = composition.compose_fn(composition.schedule, ps)

    return s(t)
end
