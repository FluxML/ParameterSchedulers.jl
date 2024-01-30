module ParameterSchedulers

using Base.Iterators
using InfiniteArrays: OneToInf

include("interface.jl")

include("decay.jl")
export Step, Exp, Poly, Inv

include("cyclic.jl")
export Triangle, TriangleDecay2, TriangleExp,
       Sin, SinDecay2, SinExp,
       CosAnneal

include("complex.jl")
export Sequence, Loop, Interpolator, Shifted, ComposedSchedule

include("utils.jl")

# TODO: support Optimisers.jl as an ext

"""
    Scheduler{T, O, F}(schedule::AbstractSchedule, opt, update_func)
    Scheduler(schedule, opt; update_func = (o, s) -> (o.eta = s))

Wrap a `schedule` and `opt` together with a `Scheduler`.
The `schedule` is iterated on every call to
[`Flux.apply!`](https://github.com/FluxML/Flux.jl/blob/master/src/optimise/optimisers.jl).
The `Scheduler` can be used anywhere a Flux optimizer is used.

By default, the learning rate (i.e. `opt.eta`) is scheduled.
Set `update_func = (opt, schedule_val) -> ...` to schedule an alternate field.
If `opt` does not have a field `eta`, then there is no default behavior
(you must manually set `update_func`).

# Arguments
- `schedule`: the schedule to use
- `opt`: a Flux optimizer
- `update_func`: a mutating function of with inputs `(optim, param)`
                 that mutates `optim`'s fields based on the current `param` value

# Examples
```julia
# cosine annealing schedule for Descent
julia> s = CosAnneal(λ0 = 0.1, λ1 = 0.8, period = 10);

julia> opt = Scheduler(s, Descent())
Scheduler(CosAnneal{Float64,Int64}(0.1, 0.8, 10), Descent(0.1))

# schedule the momentum term of Momentum
julia> opt = Scheduler(s, Momentum(); update_func = (o, s) -> o.rho = s)
Scheduler(CosAnneal{Float64,Int64}(0.1, 0.8, 10), Momentum(0.01, 0.9, IdDict{Any,Any}()))
```
"""
function Scheduler end

export Scheduler

using PackageExtensionCompat
function __init__()
    @require_extensions
end

end
