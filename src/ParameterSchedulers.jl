module ParameterSchedulers

using Base.Iterators

export Sequence, Loop,
       Step, Exp, Poly, Inv,
       Tri, TriDecay2, TriExp,
       Sin, SinDecay2, SinExp,
       Cos

include("decay.jl")
include("cyclic.jl")
include("complex.jl")

end