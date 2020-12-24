module ParameterSchedulers

using Flux

export Lambda, Sequence, Loop,
       Step, Exp, Poly, Inv,
       Tri, TriStep, TriExp,
       Sin, SinStep, SinExp,
       ScheduleIterator, ScheduledOptim, next!

include("schedule.jl")
include("decay.jl")
include("cyclic.jl")
include("optimizers.jl")

end