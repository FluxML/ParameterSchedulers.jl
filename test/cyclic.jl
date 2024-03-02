_cycle(l0, l1, x) = abs(l0 - l1) * x + min(l0, l1)
_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cos(t, period) = (1 + cos(π * (t - 1) / period)) / 2
_cosrestart(t, period) = (1 + cos(π * mod(t - 1, period) / period)) / 2

@testset "Triangle" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    period = rand(1:10)
    s = Triangle(l0 = l0, l1 = l1, period = period)
    @test s == Triangle(abs(l0 - l1), min(l0, l1), period)
    @test [_cycle(l0, l1, _tri(t, period)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(l0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "TriangleDecay2" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    period = rand(1:10)
    s = TriangleDecay2(l0 = l0, l1 = l1, period = period)
    @test s == TriangleDecay2(abs(l0 - l1), min(l0, l1), period)
    @test [_cycle(l0, l1, _tri(t, period) * (0.5^fld(t - 1, period))) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(l0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "TriangleExp" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    decay = rand()
    period = rand(1:10)
    s = TriangleExp(l0 = l0, l1 = l1, period = period, decay = decay)
    @test s == TriangleExp(abs(l0 - l1), min(l0, l1), period, decay)
    @test [_cycle(l0, l1, _tri(t, period) * decay^(t - 1)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(l0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "Sin" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    period = rand(1:10)
    s = Sin(l0 = l0, l1 = l1, period = period)
    @test s == Sin(abs(l0 - l1), min(l0, l1), period)
    @test [_cycle(l0, l1, _sin(t, period)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(l0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "SinDecay2" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    period = rand(1:10)
    s = SinDecay2(l0 = l0, l1 = l1, period = period)
    @test s == SinDecay2(abs(l0 - l1), min(l0, l1), period)
    @test [_cycle(l0, l1, _sin(t, period) * (0.5^fld(t - 1, period))) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(l0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "SinExp" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    decay = rand()
    period = rand(1:10)
    s = SinExp(l0 = l0, l1 = l1, period = period, decay = decay)
    @test s == SinExp(abs(l0 - l1), min(l0, l1), period, decay)
    @test [_cycle(l0, l1, _sin(t, period) * decay^(t - 1)) for t in 1:100] ≈ s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(l0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "CosAnneal" begin
    l0 = 0.5 * rand()
    l1 = 0.5 * rand() + 1
    period = rand(1:10)
    @testset for (restart, f) in ((true, _cosrestart), (false, _cos))
        s = CosAnneal(l0 = l0, l1 = l1, period = period, restart = restart)
        @test s == CosAnneal(abs(l0 - l1), min(l0, l1), period, restart)
        @test [_cycle(l0, l1, f(t, period)) for t in 1:100] ≈ s.(1:100)
        @test all(p == s(t) for (t, p) in zip(1:100, s))
        @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
        @test eltype(s) == eltype(l0)
        @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
        @test axes(s) == (OneToInf(),)
    end
end
