module ParameterSchedulers

using Base.Iterators
using InfiniteArrays: OneToInf
using Optimisers: AbstractRule
import Optimisers

include("interface.jl")

include("decay.jl")
export Step, Exp, Poly, Inv

include("cyclic.jl")
export Triangle, TriangleDecay2, TriangleExp,
       Sin, SinDecay2, SinExp,
       CosAnneal

include("complex.jl")
export Sequence, Loop, Interpolator, Shifted, ComposedSchedule, OneCycle

include("utils.jl")

include("scheduler.jl")
export Scheduler

end