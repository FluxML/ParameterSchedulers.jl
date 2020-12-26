"""
    ScheduledOptim{T<:AbstractSchedule, O, F}
    ScheduledOptim(schedule::AbstractSchedule, opt, update_func)
    ScheduledOptim(schedule::AbstractSchedule, opt; update_func = (o, s) -> (o.eta = s))
    (::Type{<:AbstractSchedule})(opt; update_func = (o, s) -> (o.eta = s), kwargs...)

Wrap a `schedule` and `opt` together into a `ScheduledOptim`.
The `schedule` is iterated statefully using [`ScheduleIterator`](#) on every
call to [`Flux.apply!`](https://github.com/FluxML/Flux.jl/blob/master/src/optimise/optimisers.jl).
The `ScheduledOptim` can be used anywhere a Flux optimizer is used.

The keyword argument constructor sets `update_func` to schedule the learning rate of `opt`.

Instead of constructing `schedule` and `opt` separately,
you can use the `::Type{<:AbstractSchedule}` constructor (e.g. [`Exp`](#) below):
```julia
# create a Flux.Momentum optimizer
# where the learning rate is adjusted with
# Exp(λ = 0.1, γ = 0.8) decay schedule
opt = Exp(Momentum(); λ = 0.1, γ = 0.8)
```

# Arguments
- `schedule::AbstractSchedule`: the schedule to use
- `opt`: a Flux optimizer
- `update_func`: a mutating function of with inputs `(optim, param)`
                 that updates `optim` based on the current `param` value
"""
mutable struct ScheduledOptim{T<:AbstractSchedule, O, F}
    schedule::ScheduleIterator{T}
    optim::O
    update_func::F
end
ScheduledOptim(schedule::AbstractSchedule, opt, update_func) =
    ScheduledOptim(ScheduleIterator(schedule), opt, update_func)

function Flux.Optimise.apply!(opt::ScheduledOptim, x, Δ)
    # set param
    opt.update_func(opt.optim, next!(opt.schedule))

    # do normal apply
    return Flux.Optimise.apply!(opt.optim, x, Δ)
end

for Opt in (Descent, Momentum, Nesterov, RMSProp,
            ADAM, RADAM, AdaMax, OADAM, ADAGrad,
            ADADelta, AMSGrad, NADAM, AdaBelief)
    @eval begin
        ScheduledOptim(schedule::AbstractSchedule, opt::$Opt; update_func = (o, s) -> (o.eta = s)) =
            ScheduledOptim(schedule, opt, update_func)
        (::Type{T})(opt::$Opt; update_func = (o, s) -> (o.eta = s), kwargs...) where T<:AbstractSchedule =
            ScheduledOptim(T(kwargs...), opt, update_func)
    end
end