struct Step{T<:Number, S<:Integer} <: DecaySchedule
    λ::T
    γ::T
    step_sizes::Vector{S}
end
Step(λ, γ, step_size::Integer) = Step(λ, γ, [step_size])
Step(;λ, γ, step_sizes) = Step(λ, γ, step_sizes)

basevalue(schedule::Step) = schedule.λ
decay(schedule::Step, t) = schedule.γ^t

Base.eltype(::Type{<:Step{T}}) where T = T
Base.IteratorSize(::Type{<:Step}) = Base.IsInfinite()

# override default behavior for decay schedules
function Base.getindex(schedule::Step, t::Integer)
    i = findlast(x -> t > x, cumsum(schedule.step_sizes))
    i = isnothing(i) ? 0 : i
    
    return basevalue(schedule) * schedule.γ^i
end
function Base.iterate(schedule::Step, state = (1, 1, 1))
    t, i, t0 = state
    if (i <= length(schedule.step_sizes)) && (t >= t0 + schedule.step_sizes[i])
        # move onto next step range
        i += 1
        t0 = t
    end

    return basevalue(schedule) * schedule.γ^(i - 1), (t + 1, i, t0)
end


struct Exp{T<:Number} <: DecaySchedule
    λ::T
    γ::T
end
Exp(;λ, γ) = Exp(λ, γ)

basevalue(schedule::Exp) = schedule.λ
decay(schedule::Exp, t) = schedule.γ^(t - 1)

Base.eltype(::Type{<:Exp{T}}) where T = T
Base.IteratorSize(::Type{<:Exp}) = Base.IsInfinite()


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