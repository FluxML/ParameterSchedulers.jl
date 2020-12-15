@kwdef struct NStep{T<:Number, S<:Integer, A} <: AbstractSchedule
    λ::T
    γ::T
    step_sizes::Vector{S}
    schedule::A = Sequence([Animation(0, λ * γ^(i - 1), noease(), step_size, λ * γ^i)
                           for (i, step_size) in enumerate(step_sizes)], 1, 0)
end

Animations.at(schedule::NStep, t::Integer) = at(schedule.schedule, t)