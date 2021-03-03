_cycle(λ0, λ1, x) = abs(λ0 - λ1) * x + min(λ0, λ1)
_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cos(t, period) = (1 + cos(π * mod(t - 1, period) / period)) / 2

@testset "Triangle" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = Triangle(λ0 = λ0, λ1 = λ1, period = period)
    @test s == Triangle(λ0, λ1, period)
    @test all(_cycle(λ0, λ1, _tri(t, period)) == s(t) for t in 1:100)
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
    @test s == TriangleDecay2(λ0, λ1, period)
    @test all(_cycle(λ0, λ1, _tri(t, period) / (2^fld(t - 1, period))) == s(t) for t in 1:100)
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
    @test s == TriangleExp(λ0, λ1, period, γ)
    @test all(_cycle(λ0, λ1, _tri(t, period) * γ^(t - 1)) == s(t) for t in 1:100)
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
    @test s == Sin(λ0, λ1, period)
    @test all(_cycle(λ0, λ1, _sin(t, period)) == s(t) for t in 1:100)
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
    @test s == SinDecay2(λ0, λ1, period)
    @test all(_cycle(λ0, λ1, _sin(t, period) / (2^fld(t - 1, period))) == s(t) for t in 1:100)
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
    @test s == SinExp(λ0, λ1, period, γ)
    @test all(_cycle(λ0, λ1, _sin(t, period) * γ^(t - 1)) == s(t) for t in 1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "Cos" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = Cos(λ0 = λ0, λ1 = λ1, period = period)
    @test s == Cos(λ0, λ1, period)
    @test all(_cycle(λ0, λ1, _cos(t, period)) == s(t) for t in 1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end