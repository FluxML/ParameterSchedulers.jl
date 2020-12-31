using ParameterSchedulers
using Test

@testset "Generic" begin
    include("schedule.jl")
end
@testset "Decay" begin
    include("decay.jl")
end
@testset "Cyclic" begin
    include("cyclic.jl")
end