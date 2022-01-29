"""
    Step{T, S<:Integer}(start, decay, step_sizes)
    Step(;λ, γ, step_sizes)

A step schedule decays exponentially by `γ` every step
in `step_sizes`.
The output conforms to
```text
λ * γ^{i - 1}
```
where `sum(step_sizes[1:(i - 1)]) < t <= sum(step_sizes[1:i])`

# Arguments:
- `start`/`λ`: the starting value
- `decay`/`γ`: the decay rate
- `step_sizes::Union{<:Integer, <:Vector}`: the step sizes
"""
struct Step{T, S} <: AbstractSchedule{false}
    start::T
    decay::T
    step_sizes::S

    function Step(λ::T, γ::T, step_sizes::S) where {T, S}
        _step_sizes = (S <: Integer) ? Iterators.repeated(step_sizes) : step_sizes

        return new{T, typeof(_step_sizes)}(λ, γ, _step_sizes)
    end
end
Step(;λ, γ, step_sizes) = Step(λ, γ, step_sizes)

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
    _itr = Iterators.peel(itr)
    if !isnothing(_itr) && (t > t0 + _itr[1]) # move onto next step range
        i += 1
        t0 += _itr[1]
        itr = _itr[2]
    end

    return schedule.start * schedule.decay^i, (t + 1, i, t0, itr)
end

"""
    Exp{T}(start, decay)
    Exp(;λ, γ)

A exponential decay schedule at rate `γ`.
The output conforms to
```text
λ * γ^{t - 1}
```

# Arguments:
- `start`/`λ`: the base value
- `decay`/`γ`: the decay rate
"""
struct Exp{T} <: AbstractSchedule{false}
    start::T
    decay::T
end
Exp(;λ, γ) = Exp(λ, γ)

Base.eltype(::Type{<:Exp{T}}) where T = T

(schedule::Exp)(t) = schedule.start * schedule.decay^(t - 1)

"""
    Poly{T, S<:Integer}(start, degree, max_iter)
    Poly(;λ, p, max_iter)

A polynomial schedule decays with degree `p`.
The output conforms to
```text
λ / (1 - (t - 1) / max_iter)^p
```

# Arguments
- `start`/`λ`: the base value
- `degree`/`p::Integer`: the degree of the polynomial
- `max_iter::Integer`: the total number of iterations
"""
struct Poly{T, S<:Integer} <: AbstractSchedule{true}
    start::T
    degree::S
    max_iter::S
end
Poly(;λ, p, max_iter) = Poly(λ, p, max_iter)

Base.eltype(::Type{<:Poly{T}}) where T = T
Base.length(schedule::Poly) = schedule.max_iter

function (schedule::Poly)(t)
    (t <= length(schedule)) || throw(BoundsError("Cannot index Poly for t > max_iter"))
    return schedule.start * (1 - (t - 1) / schedule.max_iter)^schedule.degree
end

"""
    Inv{T, S<:Integer}(start, decay, degree)
    Inv(;λ, γ, p)

A decay schedule that inversely decays with rate `γ`.
The output conforms to
```text
λ / (1 + (t - 1) * γ)^p
```

# Arguments
- `start`/`λ`: the base value
- `decay`/`γ`: the decay rate
- `degree`/`p::Integer`: the degree of decay
"""
struct Inv{T, S<:Integer} <: AbstractSchedule{false}
    start::T
    decay::T
    degree::S
end
Inv(;λ, γ, p) = Inv(λ, γ, p)

Base.eltype(::Type{<:Inv{T}}) where T = T

(schedule::Inv)(t) = schedule.start / (1 + (t - 1) * schedule.decay)^schedule.degree
