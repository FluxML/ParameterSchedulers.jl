struct Tri{T<:Number, S<:Integer} <: CyclicSchedule
    λ0::T
    λ1::T
    period::S
end
Tri(;λ0, λ1, period) = Tri(λ0, λ1, period)

startvalue(schedule::Tri) = schedule.λ0
endvalue(schedule::Tri) = schedule.λ1
cycle(schedule::Tri, t) = (2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))

Base.eltype(::Type{<:Tri{T}}) where T = T
Base.IteratorSize(::Type{<:Tri}) = Base.IsInfinite()


struct TriStep{T<:Tri} <: CyclicSchedule
    tri::T
end
TriStep(λ0, λ1, period) = TriStep(Tri(λ0, λ1, period))
TriStep(;λ0, λ1, period) = TriStep(λ0, λ1, period)

startvalue(schedule::TriStep) = schedule.tri.λ0
endvalue(schedule::TriStep) = schedule.tri.λ1
cycle(schedule::TriStep, t) = cycle(schedule.tri, t) / (2^fld(t - 1, schedule.tri.period))

Base.eltype(::Type{<:TriStep{Tri{T}}}) where T = T
Base.IteratorSize(::Type{<:TriStep}) = Base.IsInfinite()


struct TriExp{F<:Number, T<:Tri{F}, S<:Exp{F}} <: CyclicSchedule
    tri::T
    exp::S
end
TriExp(λ0, λ1, period, γ) = TriExp(Tri(λ0, λ1, period), Exp(one(λ0), γ))
TriExp(;λ0, λ1, period, γ) = TriExp(λ0, λ1, period, γ)

startvalue(schedule::TriExp) = schedule.tri.λ0
endvalue(schedule::TriExp) = schedule.tri.λ1
cycle(schedule::TriExp, t) = decay(schedule.exp, t) * cycle(schedule.tri, t)

Base.eltype(::Type{<:TriExp{T}}) where T = T
Base.IteratorSize(::Type{<:TriExp}) = Base.IsInfinite()


struct Sin{T<:Number, S<:Integer} <: CyclicSchedule
    λ0::T
    λ1::T
    period::S
end
Sin(;λ0, λ1, period) = Sin(λ0, λ1, period)

startvalue(schedule::Sin) = schedule.λ0
endvalue(schedule::Sin) = schedule.λ1
cycle(schedule::Sin, t) = abs(sin(π * (t - 1) / schedule.period))

Base.eltype(::Type{<:Sin{T}}) where T = T
Base.IteratorSize(::Type{<:Sin}) = Base.IsInfinite()


struct SinStep{T<:Sin} <: CyclicSchedule
    sine::T
end
SinStep(λ0, λ1, period) = SinStep(Sin(λ0, λ1, period))
SinStep(;λ0, λ1, period) = SinStep(λ0, λ1, period)

startvalue(schedule::SinStep) = schedule.sine.λ0
endvalue(schedule::SinStep) = schedule.sine.λ1
cycle(schedule::SinStep, t) = cycle(schedule.sine, t) / (2^fld(t - 1, schedule.sine.period))

Base.eltype(::Type{<:SinStep{Sin{T}}}) where T = T
Base.IteratorSize(::Type{<:SinStep}) = Base.IsInfinite()


struct SinExp{F<:Number, T<:Sin{F}, S<:Exp{F}} <: CyclicSchedule
    sine::T
    exp::S
end
SinExp(λ0, λ1, period, γ) = SinExp(Sin(λ0, λ1, period), Exp(one(λ0), γ))
SinExp(;λ0, λ1, period, γ) = SinExp(λ0, λ1, period, γ)

startvalue(schedule::SinExp) = schedule.sine.λ0
endvalue(schedule::SinExp) = schedule.sine.λ1
cycle(schedule::SinExp, t) = decay(schedule.exp, t) * cycle(schedule.sine, t)

Base.eltype(::Type{<:SinExp{T}}) where T = T
Base.IteratorSize(::Type{<:SinExp}) = Base.IsInfinite()


struct Cos{T<:Number, S<:Integer} <: CyclicSchedule
    λ0::T
    λ1::T
    period::S
end
Cos(;λ0, λ1, period) = Cos(λ0, λ1, period)

startvalue(schedule::Cos) = schedule.λ0
endvalue(schedule::Cos) = schedule.λ1
cycle(schedule::Cos, t) = (1 + cos(4 * π * t / schedule.period)) / 2

Base.eltype(::Type{<:Cos{T}}) where T = T
Base.IteratorSize(::Type{<:Cos}) = Base.IsInfinite()