mutable struct ScheduledOptim{T<:AbstractSchedule, O, F}
    schedule::ScheduleIterator{T}
    optim::O
    update_func::F
end
ScheduledOptim(schedule::AbstractSchedule, optim, update_func) =
    ScheduledOptim(ScheduleIterator(schedule), optim, update_func)

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