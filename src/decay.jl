"""
    Step{T, S<:Integer}(start, decay, step_sizes)
    Step(; start, decay, step_sizes)

A step schedule decays exponentially by `decay` every step in `step_sizes`.
The output conforms to
```text
start * decay^{i - 1}
```
where `sum(step_sizes[1:(i - 1)]) < t <= sum(step_sizes[1:i])`

# Arguments
- `start`: the starting value
- `decay`: the decay rate
- `step_sizes::Union{<:Integer, <:Vector}`: the step sizes
"""
struct Step{T, S} <: AbstractSchedule{false}
    start::T
    decay::T
    step_sizes::S

    function Step(start::T, decay::T, step_sizes::S) where {T, S}
        _step_sizes = (S <: Integer) ? Iterators.repeated(step_sizes) : step_sizes
        return new{T, typeof(_step_sizes)}(start, decay, _step_sizes)
    end
end
function Step(; kwargs...)
    kwargs = depkwargs(:Step, kwargs, :λ => :start, :γ => :decay)
    return Step(kwargs.start, kwargs.decay, kwargs.step_sizes)
end


Base.eltype(::Type{<:Step{T}}) where T = T

function (schedule::Step)(t)
    acc = 0
    itr = Iterators.takewhile(enumerate(schedule.step_sizes)) do (i, step)
        acc += step
        return t > acc
    end |> collect
    i = isempty(itr) ? 0 : first(last(itr))

    return schedule.start * schedule.decay^i
end

function Base.iterate(schedule::Step, state = (1, 0, 0, schedule.step_sizes))
    t, i, t0, itr = state
    _itr = _peel(itr)
    if !isnothing(_itr) && (t > t0 + _itr[1]) # move onto next step range
        i += 1
        t0 += _itr[1]
        itr = _itr[2]
    end

    return schedule.start * schedule.decay^i, (t + 1, i, t0, itr)
end

"""
    Exp{T}(start, decay)
    Exp(; start, decay)

A exponential decay schedule at rate `decay`.
The output conforms to
```text
start * decay^{t - 1}
```

# Arguments:
- `start`: the base value
- `decay`: the decay rate
"""
struct Exp{T} <: AbstractSchedule{false}
    start::T
    decay::T
end
function Exp(; kwargs...)
    kwargs = depkwargs(:Exp, kwargs, :λ => :start, :γ => :decay)
    return Exp(kwargs.start, kwargs.decay)
end

Base.eltype(::Type{<:Exp{T}}) where T = T

(schedule::Exp)(t) = schedule.start * schedule.decay^(t - 1)

"""
    Poly{T, S<:Integer}(start, degree, max_iter)
    Poly(; start, degree, max_iter)

A polynomial schedule decays with degree `degree`.
The output conforms to
```text
start / (1 - (t - 1) / max_iter)^degree
```

# Arguments
- `start`: the base value
- `degree::Integer`: the degree of the polynomial
- `max_iter::Integer`: the total number of iterations
"""
struct Poly{T, S<:Integer} <: AbstractSchedule{true}
    start::T
    degree::S
    max_iter::S
end
function Poly(; kwargs...)
    kwargs = depkwargs(:Poly, kwargs, :λ => :start, :p => :degree)
    return Poly(kwargs.start, kwargs.degree, kwargs.max_iter)
end

Base.eltype(::Type{<:Poly{T}}) where T = T
Base.length(schedule::Poly) = schedule.max_iter

function (schedule::Poly)(t)
    (t <= length(schedule)) || throw(BoundsError(schedule, t))
    return schedule.start * (1 - (t - 1) / schedule.max_iter)^schedule.degree
end

"""
    Inv{T, S<:Integer}(start, decay, degree)
    Inv(; start, decay, degree)

A decay schedule that inversely decays with rate `decay`.
The output conforms to
```text
start / (1 + (t - 1) * decay)^degree
```

# Arguments
- `start`: the base value
- `decay`: the decay rate
- `degree::Integer`: the degree of decay
"""
struct Inv{T, S<:Integer} <: AbstractSchedule{false}
    start::T
    decay::T
    degree::S
end
function Inv(; kwargs...)
    kwargs = depkwargs(:Inv, kwargs, :λ => :start, :γ => :decay, :p => :degree)
    return Inv(kwargs.start, kwargs.decay, kwargs.degree)
end

Base.eltype(::Type{<:Inv{T}}) where T = T

(schedule::Inv)(t) = schedule.start / (1 + (t - 1) * schedule.decay)^schedule.degree
