@testset "Step" begin
    function _getbucket(t, buckets)
        i = findlast(x -> t > x, cumsum(buckets))
        i = isnothing(i) ? 1 : i + 1

        return i
    end

    λ = rand()
    γ = rand()
    step_sizes = [rand(1:10), rand(1:10)]
    s = Step(λ = λ, γ = γ, step_sizes = step_sizes)
    @test s == Step(λ, γ, step_sizes)
    @test Step(λ, γ, 1).step_sizes == [1]
    @test ParameterSchedulers.basevalue(s) == λ
    i = rand(1:sum(step_sizes))
    @test ParameterSchedulers.decay(s, i) == γ^(_getbucket(i, step_sizes) - 1)
    i = rand(UInt) + 1
    @test s[i] == ParameterSchedulers.basevalue(s) * ParameterSchedulers.decay(s, i)
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "Exp" begin
    λ = rand()
    γ = rand()
    s = Exp(λ = λ, γ = γ)
    @test s == Exp(λ, γ)
    @test ParameterSchedulers.basevalue(s) == λ
    i = rand(UInt) + 1
    @test ParameterSchedulers.decay(s, i) == γ^(i - 1)
    @test s[i] == ParameterSchedulers.basevalue(s) * ParameterSchedulers.decay(s, i)
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "Poly" begin
    λ = rand()
    p = rand(1:20)
    max_iter = rand(1:100)
    s = Poly(λ = λ, p = p, max_iter = max_iter)
    @test s == Poly(λ, p, max_iter)
    @test ParameterSchedulers.basevalue(s) == λ
    i = rand(1:max_iter)
    @test ParameterSchedulers.decay(s, i) == (1 - (i - 1) / max_iter)^p
    @test s[i] == ParameterSchedulers.basevalue(s) * ParameterSchedulers.decay(s, i)
    @test all(p == s[t] for (t, p) in zip(1:max_iter, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.HasLength()
    @test length(s) == max_iter
end

@testset "Inv" begin
    λ = rand()
    γ = rand()
    p = rand(1:20)
    s = Inv(λ = λ, p = p, γ = γ)
    @test s == Inv(λ, γ, p)
    @test ParameterSchedulers.basevalue(s) == λ
    i = rand(UInt) + 1
    @test ParameterSchedulers.decay(s, i) == 1 / (1 + (i - 1) * γ)^p
    @test s[i] == ParameterSchedulers.basevalue(s) * ParameterSchedulers.decay(s, i)
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end