module ParameterSchedulers

using Base: @kwdef

export Step, Exp, Poly, Inv

include("schedule.jl")
include("decay.jl")

end