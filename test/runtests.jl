using ParameterSchedulers
using Test

using InfiniteArrays: OneToInf

@testset "Decay" begin
    include("decay.jl")
end
@testset "Cyclic" begin
    include("cyclic.jl")
end
@testset "Complex" begin
    using ParameterSchedulers: Stateful, next!, reset!
    include("complex.jl")
end
