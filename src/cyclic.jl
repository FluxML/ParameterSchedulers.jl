_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cycle(l0, l1, g) = abs(l0 - l1) * g + min(l0, l1)

"""
    Triangle{T, S<:Integer}(l0, l1, period)
    Triangle(; l0, l1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule with `period`.
The output conforms to
```text
abs(l0 - l1) * (2 / π) * abs(asin(sin(π * (t - 1) / period))) + min(l0, l1)
```

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
"""
struct Triangle{T, S<:Integer} <: AbstractSchedule{false}
    range::T
    offset::T
    period::S
end
Triangle(range::T, offset::T, period::S) where {T, S} = Triangle{T, S}(range, offset, period)
function Triangle(; kwargs...)
    kwargs = depkwargs(:Triangle, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return Triangle(abs(l0 - l1), min(l0, l1), kwargs.period)
end

Base.eltype(::Type{<:Triangle{T}}) where T = T

(schedule::Triangle)(t) = schedule.range * _tri(t, schedule.period) + schedule.offset

"""
    TriangleDecay2{T, S<:Integer}(l0, l1, period)
    TriangleDecay2(; l0, l1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and half the amplitude each cycle.
The output conforms to
```text
abs(l0 - l1) * Triangle(t) / (2^floor((t - 1) / period)) + min(l0, l1)
```
where `Triangle(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))`
(see [`Triangle`](@ref)).

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
"""
function TriangleDecay2(range::T, offset, period) where T
    parameters = (Interpolator(Exp(range, T(1/2)), period), offset, period)
    return ComposedSchedule(Triangle(range, offset, period), parameters)
end
function TriangleDecay2(; kwargs...)
    kwargs = depkwargs(:TriangleDecay2, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return TriangleDecay2(abs(l0 - l1), min(l0, l1), kwargs.period)
end

"""
    TriangleExp{T, S<:Integer}(l0, l1, period, decay)
    TriangleExp(; l0, l1, period, decay)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and an exponentially decaying amplitude.
The output conforms to
```text
abs(l0 - l1) * Triangle(t) * decay^(t - 1) + min(l0, l1)
```
where `Triangle(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))`
(see [`Triangle`](@ref)).

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
- `decay`: the decay rate
"""
TriangleExp(range, offset, period, decay) =
    ComposedSchedule(Triangle(range, offset, period), (Exp(range, decay), offset, period))
function TriangleExp(; kwargs...)
    kwargs = depkwargs(:TriangleExp, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return TriangleExp(abs(l0 - l1), min(l0, l1), kwargs.period, kwargs.decay)
end

"""
    Sin(l0, l1, period)
    Sin(; l0, l1, period)

A sine wave schedule with `period`.
The output conforms to
```text
abs(l0 - l1) * abs(sin(π * (t - 1) / period)) + min(l0, l1)
```

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
"""
struct Sin{T, S<:Integer} <: AbstractSchedule{false}
    range::T
    offset::T
    period::S
end
Sin(range::T, offset::T, period::S) where {T, S} = Sin{T, S}(range, offset, period)
function Sin(; kwargs...)
    kwargs = depkwargs(:Sin, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return Sin(abs(l0 - l1), min(l0, l1), kwargs.period)
end

Base.eltype(::Type{<:Sin{T}}) where T = T

(schedule::Sin)(t) = schedule.range * _sin(t, schedule.period) + schedule.offset

"""
    SinDecay2(l0, l1, period)
    SinDecay2(; l0, l1, period)

A sine wave schedule with `period` and half the amplitude each cycle.
The output conforms to
```text
abs(l0 - l1) * Sin(t) / (2^floor((t - 1) / period)) + min(l0, l1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](@ref)).

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
"""
function SinDecay2(range::T, offset, period) where T
    parameters = (Interpolator(Exp(range, T(1/2)), period), offset, period)
    return ComposedSchedule(Sin(range, offset, period), parameters)
end
function SinDecay2(; kwargs...)
    kwargs = depkwargs(:SinDecay2, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return SinDecay2(abs(l0 - l1), min(l0, l1), kwargs.period)
end

"""
    SinExp(l0, l1, period, decay)
    SinExp(; l0, l1, period, decay)

A sine wave schedule with `period` and an exponentially decaying amplitude.
The output conforms to
```text
abs(l0 - l1) * Sin(t) * γ^(t - 1) + min(l0, l1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](@ref)).

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
- `decay`: the decay rate
"""
SinExp(range, offset, period, decay) = 
    ComposedSchedule(Sin(range, offset, period), (Exp(range, decay), offset, period))
function SinExp(; kwargs...)
    kwargs = depkwargs(:SinExp, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return SinExp(abs(l0 - l1), min(l0, l1), kwargs.period, kwargs.decay)
end

"""
    CosAnneal(l0, l1, period, restart = true)
    CosAnneal(; l0, l1, period, restart = true)

A cosine annealing schedule
(see ["SGDR: Stochastic Gradient Descent with Warm Restarts"](https://arxiv.org/abs/1608.03983v5))
The output conforms to
```text
t̂ = restart ? (t - 1) : mod(t - 1, period)
abs(l0 - l1) * (1 + cos(π * t̂ / period)) / 2 + min(l0, l1)
```
This schedule is also referred to as "cosine annealing (with warm restarts)"
in machine learning literature.

# Arguments
- `range == abs(l0 - l1)`: the dynamic range (given by the endpoints)
- `offset == min(l0, l1)`: the offset / minimum value
- `period::Integer`: the period
- `restart::Bool`: use warm-restarts
"""
struct CosAnneal{T, S<:Integer} <: AbstractSchedule{false}
    range::T
    offset::T
    period::S
    restart::Bool
end
CosAnneal(range, offset, period) = CosAnneal(range, offset, period, true)
function CosAnneal(; kwargs...)
    kwargs = depkwargs(:CosAnneal, kwargs, :λ0 => :l0, :λ1 => :l1)
    l0, l1 = kwargs.l0, kwargs.l1
    return CosAnneal(abs(l0 - l1), min(l0, l1), kwargs.period, kwargs.restart)
end

Base.eltype(::Type{<:CosAnneal{T}}) where T = T

function (schedule::CosAnneal)(t)
    t̂ = schedule.restart ? mod(t - 1, schedule.period) : (t - 1)
    return schedule.range * (1 + cos(π * t̂ / schedule.period)) / 2 + schedule.offset
end
