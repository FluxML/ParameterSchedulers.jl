_cycle(λ0, λ1, x) = abs(λ0 - λ1) * x + min(λ0, λ1)
_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cos(t, period) = (1 + cos(π * (t - 1) / period)) / 2
_cosrestart(t, period) = (1 + cos(π * mod(t - 1, period) / period)) / 2

@testset "Triangle" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = Triangle(λ0 = λ0, λ1 = λ1, period = period)
    @test s == Triangle(abs(λ0 - λ1), min(λ0, λ1), period)
    @test [_cycle(λ0, λ1, _tri(t, period)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "TriangleDecay2" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = TriangleDecay2(λ0 = λ0, λ1 = λ1, period = period)
    @test s == TriangleDecay2(abs(λ0 - λ1), min(λ0, λ1), period)
    @test [_cycle(λ0, λ1, _tri(t, period) / (2^fld(t - 1, period))) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "TriangleExp" begin
    λ0 = rand()
    λ1 = rand()
    γ = rand()
    period = rand(1:10)
    s = TriangleExp(λ0 = λ0, λ1 = λ1, period = period, γ = γ)
    @test s == TriangleExp(abs(λ0 - λ1), min(λ0, λ1), period, γ)
    @test [_cycle(λ0, λ1, _tri(t, period) * γ^(t - 1)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "Sin" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = Sin(λ0 = λ0, λ1 = λ1, period = period)
    @test s == Sin(abs(λ0 - λ1), min(λ0, λ1), period)
    @test [_cycle(λ0, λ1, _sin(t, period)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "SinDecay2" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = SinDecay2(λ0 = λ0, λ1 = λ1, period = period)
    @test s == SinDecay2(abs(λ0 - λ1), min(λ0, λ1), period)
    @test [_cycle(λ0, λ1, _sin(t, period) / (2^fld(t - 1, period))) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "SinExp" begin
    λ0 = rand()
    λ1 = rand()
    γ = rand()
    period = rand(1:10)
    s = SinExp(λ0 = λ0, λ1 = λ1, period = period, γ = γ)
    @test s == SinExp(abs(λ0 - λ1), min(λ0, λ1), period, γ)
    @test [_cycle(λ0, λ1, _sin(t, period) * γ^(t - 1)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "CosAnneal" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    @testset for (restart, f) in ((true, _cosrestart), (false, _cos))
        s = CosAnneal(λ0 = λ0, λ1 = λ1, period = period, restart = restart)
        @test s == CosAnneal(λ0, λ1, period, restart)
        @test [_cycle(λ0, λ1, f(t, period)) for t in 1:100] ≈ s.(1:100)
        @test all(p == s(t) for (t, p) in zip(1:100, s))
        @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
        @test eltype(s) == eltype(λ0)
        @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
        @test axes(s) == (OneToInf(),)
    end
end