using ParameterSchedulers
using Zygote
using Optimisers
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
    @testset "Basic usage" begin
        m = (W = ones(Float32, 4, 3), b = ones(Float32, 4))
        s = Exp(0.1, 0.5)
        o = Optimisers.setup(Scheduler(Optimisers.Descent, s), m)
        x = ones(Float32, 3)
        for t in 1:10
            g = Zygote.gradient(m -> sum(m.W * x + m.b), m)[1]
            o, m′ = Optimisers.update(o, m, g)
            @test m′.W ≈ m.W - g.W * s(t)
            @test m′.b ≈ m.b - g.b * s(t)
            m = m′
        end
    end
    @testset "Advanced usage" begin
        m = (W = ones(Float32, 4, 3), b = ones(Float32, 4))
        seta = Exp(0.1, 0.5)
        srho = Exp(0.9, 0.9)
        o = Optimisers.setup(Scheduler(Optimisers.Momentum, eta = seta, rho = srho), m)
        x = ones(Float32, 3)
        for t in 1:10
            g = Zygote.gradient(m -> sum(m.W * x + m.b), m)[1]
            o′, m′ = Optimisers.update(o, m, g)
            @test m′.W ≈ m.W - (srho(t) * o.W.state.opt + g.W * seta(t))
            @test m′.b ≈ m.b - (srho(t) * o.b.state.opt + g.b * seta(t))
            m = m′
            o = o′
        end

        o = Optimisers.setup(Scheduler(Optimisers.Momentum, rho = srho), m)
        for t in 1:10
            g = Zygote.gradient(m -> sum(m.W * x + m.b), m)[1]
            o′, m′ = Optimisers.update(o, m, g)
            @test m′.W ≈ m.W - (srho(t) * o.W.state.opt + g.W * 0.01)
            @test m′.b ≈ m.b - (srho(t) * o.b.state.opt + g.b * 0.01)
            m = m′
            o = o′
        end

        o = Optimisers.setup(Scheduler(Optimisers.Momentum, rho = 0.8), m)
        for t in 1:10
            g = Zygote.gradient(m -> sum(m.W * x + m.b), m)[1]
            o′, m′ = Optimisers.update(o, m, g)
            @test m′.W ≈ m.W - (0.8 * o.W.state.opt + g.W * 0.01)
            @test m′.b ≈ m.b - (0.8 * o.b.state.opt + g.b * 0.01)
            m = m′
            o = o′
        end
    end
end
