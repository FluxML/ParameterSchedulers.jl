"""
    Step{T<:Number, S<:Integer} <: DecaySchedule
    Step(λ, γ, step_size::Integer)
    Step(;λ, γ, step_sizes)

A step schedule decays exponentially by `γ` every step
in `step_sizes`.
The output conforms to
```
λ * γ^{i - 1}
```
where `sum(step_sizes[1:(i - 1)]) < t <= sum(step_sizes[1:i])`

# Arguments:
- `λ::Number`: the base value
- `γ::Number`: the decay rate
- `step_sizes::Union{<:Integer, <:Vector}`: the step sizes
"""
struct Step{T<:Number, S<:Integer} <: DecaySchedule
    λ::T
    γ::T
    step_sizes::Vector{S}
end
Step(λ, γ, step_size::Integer) = Step(λ, γ, [step_size])
Step(;λ, γ, step_sizes) = Step(λ, γ, step_sizes)

basevalue(schedule::Step) = schedule.λ
function decay(schedule::Step, t)
    i = findlast(x -> t > x, cumsum(schedule.step_sizes))
    i = isnothing(i) ? 0 :
            (i >= length(schedule.step_sizes)) ? length(schedule.step_sizes) - 1 : i

    return schedule.γ^i
end

Base.eltype(::Type{<:Step{T}}) where T = T
Base.IteratorSize(::Type{<:Step}) = Base.IsInfinite()

# override default behavior for decay schedules
function Base.iterate(schedule::Step, state = (1, 1, 1))
    t, i, t0 = state
    if (i < length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return basevalue(schedule) * schedule.γ^(i - 1), (t + 1, i, t0)
end


"""
    Exp{T<:Number} <: DecaySchedule
    Exp(;λ, γ)

A exponential decay schedule at rate `γ`.
The output conforms to
```
λ * γ^{t - 1}
```

# Arguments:
- `λ::Number`: the base value
- `γ::Number`: the decay rate
"""
struct Exp{T<:Number} <: DecaySchedule
    λ::T
    γ::T
end
Exp(;λ, γ) = Exp(λ, γ)

basevalue(schedule::Exp) = schedule.λ
decay(schedule::Exp, t) = schedule.γ^(t - 1)

Base.eltype(::Type{<:Exp{T}}) where T = T
Base.IteratorSize(::Type{<:Exp}) = Base.IsInfinite()


"""
    Poly{T<:Number, S<:Integer} <: DecaySchedule
    Poly(;λ, p, max_iter)

A polynomial schedule decays with degree `p`.
The output conforms to
```
λ / (1 - (t - 1) / max_iter)^p
```

# Arguments
- `λ::Number`: the base value
- `p::Integer`: the degree of the polynomial
- `max_iter::Integer`: the total number of iterations
"""
struct Poly{T<:Number, S<:Integer} <: DecaySchedule
    λ::T
    p::S
    max_iter::S
end
Poly(;λ, p, max_iter) = Poly(λ, p, max_iter)

basevalue(schedule::Poly) = schedule.λ
decay(schedule::Poly, t) = (1 - (t - 1) / schedule.max_iter)^schedule.p

Base.eltype(::Type{<:Poly{T}}) where T = T
Base.IteratorSize(::Type{<:Poly}) = Base.HasLength()
Base.length(schedule::Poly) = schedule.max_iter


"""
    Inv{T<:Number, S<:Integer} <: DecaySchedule
    Inv(;λ, γ, p)

A decay schedule that inversely decays with rate `γ`.
The output conforms to
```
λ / (1 + (t - 1) * γ)^p
```

# Arguments
- `λ::Number`: the base value
- `γ::Number`: the decay rate
- `p::Integer`: the degree of decay
"""
struct Inv{T<:Number, S<:Integer} <: DecaySchedule
    λ::T
    γ::T
    p::S
end
Inv(;λ, γ, p) = Inv(λ, γ, p)

basevalue(schedule::Inv) = schedule.λ
decay(schedule::Inv, t) = 1 / (1 + (t - 1) * schedule.γ)^schedule.p

Base.eltype(::Type{<:Inv{T}}) where T = T
Base.IteratorSize(::Type{<:Inv}) = Base.IsInfinite()