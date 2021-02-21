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
struct Step{T, S<:Integer}
    start::T
    decay::T
    step_sizes::Vector{S}
end
Step(λ, γ, step_size::Integer) = Step(λ, γ, [step_size])
Step(;λ, γ, step_sizes) = Step(λ, γ, step_sizes)

function (schedule::Step)(t)
    i = findlast(x -> t > x, cumsum(schedule.step_sizes))
    i = isnothing(i) ? 0 :
            (i >= length(schedule.step_sizes)) ? length(schedule.step_sizes) - 1 : i

    return schedule.start * schedule.decay^i
end

Base.eltype(::Type{<:Step{T}}) where T = T
Base.IteratorSize(::Type{<:Step}) = Base.IsInfinite()

function Base.iterate(schedule::Step, state = (1, 1, 1))
    t, i, t0 = state
    if (i < length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return schedule.start * schedule.decay^(i - 1), (t + 1, i, t0)
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
struct Exp{T}
    start::T
    decay::T
end
Exp(;λ, γ) = Exp(λ, γ)

(schedule::Exp)(t) = schedule.start * schedule.decay^(t - 1)

Base.eltype(::Type{<:Exp{T}}) where T = T
Base.IteratorSize(::Type{<:Exp}) = Base.IsInfinite()

Base.iterate(schedule::Exp, t = 1) = schedule(t), t + 1

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
struct Poly{T, S<:Integer}
    start::T
    degree::S
    max_iter::S
end
Poly(;λ, p, max_iter) = Poly(λ, p, max_iter)

function (schedule::Poly)(t)
    (t <= length(schedule)) || throw(BoundsError("Cannot index Poly for t > max_iter"))
    return schedule.start * (1 - (t - 1) / schedule.max_iter)^schedule.degree
end

Base.eltype(::Type{<:Poly{T}}) where T = T
Base.IteratorSize(::Type{<:Poly}) = Base.HasLength()
Base.length(schedule::Poly) = schedule.max_iter

Base.iterate(schedule::Poly, t = 1) = schedule(t), t + 1


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
struct Inv{T<:Number, S<:Integer}
    start::T
    decay::T
    degree::S
end
Inv(;λ, γ, p) = Inv(λ, γ, p)

(schedule::Inv)(t) = schedule.start / (1 + (t - 1) * schedule.decay)^schedule.degree

Base.eltype(::Type{<:Inv{T}}) where T = T
Base.IteratorSize(::Type{<:Inv}) = Base.IsInfinite()

Base.iterate(schedule::Inv, t = 1) = schedule(t), t + 1