_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cycle(λ0, λ1, g) = abs(λ0 - λ1) * g + min(λ0, λ1)

"""
    Tri{T, S<:Integer}(range0, range1, period)
    Tri(;λ0, λ1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period`.
The output conforms to
```
abs(λ0 - λ1) * (2 / π) * abs(asin(sin(π * (t - 1) / period))) + min(λ0, λ1)
```

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct Tri{T, S<:Integer}
    range0::T
    range1::T
    period::S
end
Tri(;λ0, λ1, period) = Tri(λ0, λ1, period)

(schedule::Tri)(t) = _cycle(schedule.range0, schedule.range1, _tri(t, schedule.period))

Base.eltype(::Type{<:Tri{T}}) where T = T
Base.IteratorSize(::Type{<:Tri}) = Base.IsInfinite()

Base.iterate(schedule::Tri, t = 1) = schedule(t), t + 1

"""
    TriDecay2{T, S<:Integer}(range0, range1, period)
    TriDecay2(;λ0, λ1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and half the amplitude each cycle.
The output conforms to
```
abs(λ0 - λ1) * Tri(t) / (2^floor((t - 1) / period)) + min(λ0, λ1)
```
where `Tri(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))` (see [`Tri`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct TriDecay2{T, S<:Integer}
    range0::T
    range1::T
    period::S
end
TriDecay2(;λ0, λ1, period) = TriDecay2(λ0, λ1, period)

(schedule::TriDecay2)(t) = _cycle(schedule.range0, schedule.range1,
                                  _tri(t, schedule.period) / (2^fld(t - 1, schedule.period)))

Base.eltype(::Type{<:TriDecay2{T}}) where T = T
Base.IteratorSize(::Type{<:TriDecay2}) = Base.IsInfinite()

Base.iterate(schedule::TriDecay2, t = 1) = schedule(t), t + 1

"""
    TriExp{T, S<:Integer}(range0, range1, period, decay)
    TriExp(λ0, λ1, period, γ)
    TriExp(;λ0, λ1, period, γ)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and an exponentially decaying amplitude.
The output conforms to
```
abs(λ0 - λ1) * Tri(t) * γ^(t - 1) + min(λ0, λ1)
```
where `Tri(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))` (see [`Tri`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
- `decay`/`γ`: the decay rate
"""
struct TriExp{T, S<:Integer}
    range0::T
    range1::T
    period::S
    decay::T
end
TriExp(;λ0, λ1, period, γ) = TriExp(λ0, λ1, period, γ)

startvalue(schedule::TriExp) = schedule.tri.λ0
endvalue(schedule::TriExp) = schedule.tri.λ1
(schedule::TriExp)(t) = _cycle(schedule.range0, schedule.range1,
                               _tri(t, schedule.period) * schedule.decay^(t - 1))

Base.eltype(::Type{<:TriExp{T}}) where T = T
Base.IteratorSize(::Type{<:TriExp}) = Base.IsInfinite()

Base.iterate(schedule::TriExp, t = 1) = schedule(t), t + 1

"""
    Sin{T, S<:Integer}(range0, range1, period)
    Sin(;λ0, λ1, period)

A sine wave schedule with `period`.
The output conforms to
```
abs(λ0 - λ1) * abs(sin(π * (t - 1) / period)) + min(λ0, λ1)
```

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct Sin{T, S<:Integer}
    range0::T
    range1::T
    period::S
end
Sin(;λ0, λ1, period) = Sin(λ0, λ1, period)

(schedule::Sin)(t) = _cycle(schedule.range0, schedule.range1, _sin(t, schedule.period))

Base.eltype(::Type{<:Sin{T}}) where T = T
Base.IteratorSize(::Type{<:Sin}) = Base.IsInfinite()

Base.iterate(schedule::Sin, t = 1) = schedule(t), t + 1

"""
    SinDecay2{T, S<:Integer}(range0, range1, period)
    SinDecay2(;λ0, λ1, period)

A sine wave schedule with `period` and half the amplitude each cycle.
The output conforms to
```
abs(λ0 - λ1) * Sin(t) / (2^floor((t - 1) / period)) + min(λ0, λ1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct SinDecay2{T, S<:Integer}
    range0::T
    range1::T
    period::S
end
SinDecay2(;λ0, λ1, period) = SinDecay2(λ0, λ1, period)

startvalue(schedule::SinDecay2) = schedule.sine.λ0
endvalue(schedule::SinDecay2) = schedule.sine.λ1
(schedule::SinDecay2)(t) = _cycle(schedule.range0, schedule.range1,
                                  _sin(t, schedule.period) / (2^fld(t - 1, schedule.period)))

Base.eltype(::Type{<:SinDecay2{T}}) where T = T
Base.IteratorSize(::Type{<:SinDecay2}) = Base.IsInfinite()

Base.iterate(schedule::SinDecay2, t = 1) = schedule(t), t + 1

"""
    SinExp{T, S<:Integer}(range0, range1, period, decay)
    SinDecay2(;λ0, λ1, period, γ)

A sine wave schedule with `period` and an exponentially decaying amplitude.
The output conforms to
```
abs(λ0 - λ1) * Sin(t) * γ^(t - 1) + min(λ0, λ1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
- `decay`/`γ`: the decay rate
"""
struct SinExp{T, S<:Integer}
    range0::T
    range1::T
    period::S
    decay::T
end
SinExp(;λ0, λ1, period, γ) = SinExp(λ0, λ1, period, γ)

startvalue(schedule::SinExp) = schedule.sine.λ0
endvalue(schedule::SinExp) = schedule.sine.λ1
(schedule::SinExp)(t) = _cycle(schedule.range0, schedule.range1,
                               _sin(t, schedule.period) * schedule.decay^(t - 1))

Base.eltype(::Type{<:SinExp{T}}) where T = T
Base.IteratorSize(::Type{<:SinExp}) = Base.IsInfinite()

Base.iterate(schedule::SinExp, t = 1) = schedule(t), t + 1

"""
    Cos{T, S<:Integer}(range0, range1, period)
    Cos(;λ0, λ1, period)

A cosine wave schedule with `period`.
The output conforms to
```
abs(λ0 - λ1) * (1 + cos(2 * π * (t - 1) / period)) / 2 + min(λ0, λ1)
```
This schedule is also referred to as "cosine annealing" or
"cosine annealing with warm restarts" in machine learning literature.

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct Cos{T, S<:Integer}
    range0::T
    range1::T
    period::S
end
Cos(;λ0, λ1, period) = Cos(λ0, λ1, period)

startvalue(schedule::Cos) = schedule.λ0
endvalue(schedule::Cos) = schedule.λ1
(schedule::Cos)(t) = _cycle(schedule.range0, schedule.range1,
                            (1 + cos(2 * π * (t - 1) / schedule.period)) / 2)

Base.eltype(::Type{<:Cos{T}}) where T = T
Base.IteratorSize(::Type{<:Cos}) = Base.IsInfinite()

Base.iterate(schedule::Cos, t = 1) = schedule(t), t + 1