
module ParameterSchedulersFluxExt

using ParameterSchedulers, Flux

export Scheduler

mutable struct Scheduler{T, O, F} <: Flux.Optimise.AbstractOptimiser
    state::IdDict{Any, Int}
    schedule::T
    optim::O
    update_func::F

    function Scheduler(state::IdDict{Any, Int},
                       schedule::T,
                       optim::O,
                       update_func::F) where {T, O, F}
        Base.depwarn("""`Scheduler` will transition to explicit Optimisers.jl style
                        optimizers in the next release""", :Scheduler)

        return new{T, O, F}(state, schedule, optim, update_func)
    end
end

ParameterSchedulers.Scheduler(state, schedule, opt, update_func) =
    Scheduler(state, schedule, opt, update_func)

ParameterSchedulers.Scheduler(schedule, opt, update_func) =
    Scheduler(IdDict{Any, Int}(), schedule, opt, update_func)

Base.show(io::IO, s::Scheduler) =
    print(io, "Scheduler(", s.schedule, ", ", s.optim, ")")

function Flux.Optimise.apply!(opt::Scheduler, x, Δ)
    # get iteration
    t = get!(opt.state, x, 1)
    opt.state[x] = t + 1

    # set param
    opt.update_func(opt.optim, opt.schedule(t))

    # do normal apply
    return Flux.Optimise.apply!(opt.optim, x, Δ)
end

for Opt in (Descent, Momentum, Nesterov, RMSProp,
            Adam, RAdam, AdaMax, OAdam, AdaGrad,
            AdaDelta, AMSGrad, NAdam, AdaBelief)
    @eval begin
        ParameterSchedulers.Scheduler(schedule, opt::$Opt; update_func = (o, s) -> (o.eta = s)) =
            ParameterSchedulers.Scheduler(schedule, opt, update_func)
    end
end

end # module
