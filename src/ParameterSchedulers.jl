module ParameterSchedulers

using Animations
using Base: @kwdef

abstract type AbstractSchedule end

export Step

include("decay.jl")

end