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

ext = Base.get_extension(@__MODULE__, :ParameterSchedulersFluxExt)
if !isnothing(ext)
    Scheduler = ext.Scheduler
    export Scheduler
end

end