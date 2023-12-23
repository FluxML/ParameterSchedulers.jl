_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cycle(λ0, λ1, g) = abs(λ0 - λ1) * g + min(λ0, λ1)

"""
    Triangle{T, S<:Integer}(range0, range1, period)
    Triangle(;λ0, λ1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period`.
The output conforms to
```text
abs(λ0 - λ1) * (2 / π) * abs(asin(sin(π * (t - 1) / period))) + min(λ0, λ1)
```

# Arguments
- `range == abs(λ0 - λ1)`: the dynamic range (given by the endpoints)
- `offset == min(λ0, λ1)`: the offset / minimum value
- `period::Integer`: the period
"""
struct Triangle{T, S<:Integer} <: AbstractSchedule{false}
    range::T
    offset::T
    period::S
end
Triangle(range::T, offset::T, period::S) where {T, S} =
    Triangle{T, S}(range, offset, period)
Triangle(;λ0, λ1, period) = Triangle(abs(λ0 - λ1), min(λ0, λ1), period)

Base.eltype(::Type{<:Triangle{T}}) where T = T

(schedule::Triangle)(t) = schedule.range * _tri(t, schedule.period) + schedule.offset

"""
    TriangleDecay2{T, S<:Integer}(range0, range1, period)
    TriangleDecay2(;λ0, λ1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and half the amplitude each cycle.
The output conforms to
```text
abs(λ0 - λ1) * Triangle(t) / (2^floor((t - 1) / period)) + min(λ0, λ1)
```
where `Triangle(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))`
(see [`Triangle`](@ref)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
TriangleDecay2(range, offset, period) = _tridecay2(range, offset, period)
TriangleDecay2(;λ0, λ1, period) = _tridecay2(abs(λ0 - λ1), min(λ0, λ1), period)

function _tridecay2(range::T, offset, period) where T
    parameters = (Interpolator(Exp(range, T(1/2)), period), offset, period)

    return ComposedSchedule(Triangle(range, offset, period), parameters)
end

"""
    TriangleExp{T, S<:Integer}(range0, range1, period, decay)
    TriangleExp(λ0, λ1, period, γ)
    TriangleExp(;λ0, λ1, period, γ)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and an exponentially decaying amplitude.
The output conforms to
```text
abs(λ0 - λ1) * Triangle(t) * γ^(t - 1) + min(λ0, λ1)
```
where `Triangle(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))`
(see [`Triangle`](@ref)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
- `decay`/`γ`: the decay rate
"""
TriangleExp(range, offset, period, γ) = _triexp(range, offset, period, γ)
TriangleExp(;λ0, λ1, period, γ) = _triexp(abs(λ0 - λ1), min(λ0, λ1), period, γ)

_triexp(range, offset, period, γ) =
    ComposedSchedule(Triangle(range, offset, period), (Exp(range, γ), offset, period))

"""
    Sin(range, offset, period)
    Sin(;λ0, λ1, period)

A sine wave schedule with `period`.
The output conforms to
```text
abs(λ0 - λ1) * abs(sin(π * (t - 1) / period)) + min(λ0, λ1)
```

# Arguments
- `range == abs(λ0 - λ1)`: the dynamic range (given by the endpoints)
- `offset == min(λ0, λ1)`: the offset / minimum value
- `period::Integer`: the period
"""
struct Sin{T, S<:Integer} <: AbstractSchedule{false}
    range::T
    offset::T
    period::S
end
Sin(range::T, offset::T, period::S) where {T, S} = Sin{T, S}(range, offset, period)
Sin(;λ0, λ1, period) = Sin(abs(λ0 - λ1), min(λ0, λ1), period)

Base.eltype(::Type{<:Sin{T}}) where T = T

(schedule::Sin)(t) = schedule.range * _sin(t, schedule.period) + schedule.offset

"""
    SinDecay2(range, offset, period)
    SinDecay2(;λ0, λ1, period)

A sine wave schedule with `period` and half the amplitude each cycle.
The output conforms to
```text
abs(λ0 - λ1) * Sin(t) / (2^floor((t - 1) / period)) + min(λ0, λ1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](@ref)).

# Arguments
- `range == abs(λ0 - λ1)`: the dynamic range (given by the endpoints)
- `offset == min(λ0, λ1)`: the offset / minimum value
- `period::Integer`: the period
"""
SinDecay2(range, offset, period) = _sindecay2(range, offset, period)
SinDecay2(;λ0, λ1, period) = _sindecay2(abs(λ0 - λ1), min(λ0, λ1), period)

function _sindecay2(range::T, offset, period) where T
    parameters = (Interpolator(Exp(range, T(1/2)), period), offset, period)

    return ComposedSchedule(Sin(range, offset, period), parameters)
end

"""
    SinExp(range, offset, period, γ)
    SinExp(;λ0, λ1, period, γ)

A sine wave schedule with `period` and an exponentially decaying amplitude.
The output conforms to
```text
abs(λ0 - λ1) * Sin(t) * γ^(t - 1) + min(λ0, λ1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](@ref)).

# Arguments
- `range == abs(λ0 - λ1)`: the dynamic range (given by the endpoints)
- `offset == min(λ0, λ1)`: the offset / minimum value
- `period::Integer`: the period
- `γ`: the decay rate
"""
SinExp(range, offset, period, γ) = _sinexp(range, offset, period, γ)
SinExp(;λ0, λ1, period, γ) = _sinexp(abs(λ0 - λ1), min(λ0, λ1), period, γ)

_sinexp(range, offset, period, γ) =
    ComposedSchedule(Sin(range, offset, period), (Exp(range, γ), offset, period))

"""
    CosAnneal(range, offset, period, restart = true)
    CosAnneal(;λ0, λ1, period, restart = true)

A cosine annealing schedule
(see ["SGDR: Stochastic Gradient Descent with Warm Restarts"](https://arxiv.org/abs/1608.03983v5))
The output conforms to
```text
t̂ = restart ? (t - 1) : mod(t - 1, period)
abs(λ0 - λ1) * (1 + cos(π * t̂ / period)) / 2 + min(λ0, λ1)
```
This schedule is also referred to as "cosine annealing (with warm restarts)"
in machine learning literature.

# Arguments
- `range == abs(λ0 - λ1)`: the dynamic range (given by the endpoints)
- `offset == min(λ0, λ1)`: the offset / minimum value
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
CosAnneal(;λ0, λ1, period, restart = true) =
    CosAnneal(abs(λ0 - λ1), min(λ0, λ1), period, restart)

Base.eltype(::Type{<:CosAnneal{T}}) where T = T

function (schedule::CosAnneal)(t)
    t̂ = schedule.restart ? mod(t - 1, schedule.period) : (t - 1)

    return schedule.range * (1 + cos(π * t̂ / schedule.period)) / 2 + schedule.offset
end
