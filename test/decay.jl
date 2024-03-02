@testset "Step" begin
    start = rand()
    decay = rand()
    step_sizes = [rand(1:10), rand(1:10)]
    s = Step(start = start, decay = decay, step_sizes = step_sizes)
    @test s == Step(start, decay, step_sizes)
    @test fill(start, step_sizes[1]) ≈ [s(t) for t in 1:step_sizes[1]]
    @test fill(start * decay, step_sizes[2]) ≈ [s(t) for t in (step_sizes[1] + 1):(step_sizes[1] + step_sizes[2])]
    @test fill(start * decay^2, 50 - sum(step_sizes)) ≈ [s(t) for t in (step_sizes[1] + step_sizes[2] + 1):50]
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    s = Step(start, decay, step_sizes[1])
    @test fill(start, step_sizes[1]) ≈ [s(t) for t in 1:step_sizes[1]]
    @test fill(start * decay, step_sizes[1]) ≈ [s(t) for t in (step_sizes[1] + 1):(2 * step_sizes[1])]
    @test fill(start * decay^2, step_sizes[1]) ≈ [s(t) for t in (2 * step_sizes[1] + 1):(3 * step_sizes[1])]
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(start)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "Exp" begin
    start = rand()
    decay = rand()
    s = Exp(start = start, decay = decay)
    @test s == Exp(start, decay)
    @test [start * decay^(t - 1) for t in 1:100] == s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(start)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "Poly" begin
    start = rand()
    degree = rand(1:20)
    max_iter = rand(1:100)
    s = Poly(start = start, degree = degree, max_iter = max_iter)
    @test s == Poly(start, degree, max_iter)
    @test [start * (1 - (t - 1) / max_iter)^degree for t in 1:max_iter] == s.(1:max_iter)
    @test all(p == s(t) for (t, p) in zip(1:max_iter, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(start)
    @test Base.IteratorSize(typeof(s)) == Base.HasLength()
    @test length(s) == max_iter
    @test_throws BoundsError s(max_iter + 1)
    @test axes(s) == 1:length(s)
end

@testset "Inv" begin
    start = rand()
    decay = rand()
    degree = rand(1:20)
    s = Inv(start = start, degree = degree, decay = decay)
    @test s == Inv(start, decay, degree)
    @test [start / (1 + (t - 1) * decay)^degree for t in 1:100] == s.(1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(start)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end
