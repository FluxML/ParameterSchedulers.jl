@testset "Step" begin
    λ = rand()
    γ = rand()
    step_sizes = [rand(1:10), rand(1:10)]
    s = Step(λ = λ, γ = γ, step_sizes = step_sizes)
    @test s == Step(λ, γ, step_sizes)
    @test all(λ ≈ s(t) for t in 1:step_sizes[1])
    @test all(λ * γ ≈ s(t) for t in (step_sizes[1] + 1):(step_sizes[1] + step_sizes[2]))
    @test all(λ * γ^2 ≈ s(t) for t in (step_sizes[1] + step_sizes[2] + 1):50)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    s = Step(λ, γ, step_sizes[1])
    @test all(λ ≈ s(t) for t in 1:step_sizes[1])
    @test all(λ * γ ≈ s(t) for t in (step_sizes[1] + 1):(2 * step_sizes[1]))
    @test all(λ * γ^2 ≈ s(t) for t in (2 * step_sizes[1] + 1):(3 * step_sizes[1]))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "Exp" begin
    λ = rand()
    γ = rand()
    s = Exp(λ = λ, γ = γ)
    @test s == Exp(λ, γ)
    @test all(λ * γ^(t - 1) == s(t) for t in 1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end

@testset "Poly" begin
    λ = rand()
    p = rand(1:20)
    max_iter = rand(1:100)
    s = Poly(λ = λ, p = p, max_iter = max_iter)
    @test s == Poly(λ, p, max_iter)
    @test all(λ * (1 - (t - 1) / max_iter)^p == s(t) for t in 1:max_iter)
    @test all(p == s(t) for (t, p) in zip(1:max_iter, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.HasLength()
    @test length(s) == max_iter
    @test_throws BoundsError s(max_iter + 1)
    @test axes(s) == 1:length(s)
end

@testset "Inv" begin
    λ = rand()
    γ = rand()
    p = rand(1:20)
    s = Inv(λ = λ, p = p, γ = γ)
    @test s == Inv(λ, γ, p)
    @test all(λ / (1 + (t - 1) * γ)^p == s(t) for t in 1:100)
    @test all(p == s(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)
end