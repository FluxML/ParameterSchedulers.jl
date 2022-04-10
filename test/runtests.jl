using ParameterSchedulers
using Flux
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
@testset "Scheduler" begin
    using ParameterSchedulers: Scheduler
    m = Chain(Dense(10, 5), Dense(5, 2))
    ps = Flux.params(m)
    s = Exp(0.1, 0.5)
    o = Scheduler(s, Momentum())
    for t in 1:10
        g = Flux.gradient(() -> sum(m(rand(Float32, 10, 2))), ps)
        Flux.update!(o, ps, g)
        @test o.optim.eta == s(t)
        for p in ps
            @test o.state[p] == t + 1
        end
    end
end
