module ParameterSchedulers

export Lambda, Sequence, Loop,
       Step, Exp, Poly, Inv,
       Tri, TriDecay2, TriExp,
       Sin, SinDecay2, SinExp,
       Cos,
       ScheduleIterator, next!

include("schedule.jl")
include("decay.jl")
include("cyclic.jl")

end