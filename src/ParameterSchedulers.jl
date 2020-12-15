module ParameterSchedulers

using Animations
using Base: @kwdef

abstract type AbstractSchedule end

export NStep

include("decay.jl")

end