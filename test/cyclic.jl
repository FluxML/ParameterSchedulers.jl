_cyclic(λ0, λ1, x) = abs(λ0 - λ1) * x + min(λ0, λ1)

@testset "Tri" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = Tri(λ0 = λ0, λ1 = λ1, period = period)
    @test s == Tri(λ0, λ1, period)
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == (2 / π) * abs(asin(sin(π * (i - 1) / period)))
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "TriDecay2" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = TriDecay2(λ0 = λ0, λ1 = λ1, period = period)
    @test s == TriDecay2(Tri(λ0, λ1, period))
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == (2 / π) * abs(asin(sin(π * (i - 1) / period))) / (2^fld(i - 1, period))
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "TriExp" begin
    λ0 = rand()
    λ1 = rand()
    γ = rand()
    period = rand(1:10)
    s = TriExp(λ0 = λ0, λ1 = λ1, period = period, γ = γ)
    @test s == TriExp(Tri(λ0, λ1, period), Exp(one(λ0), γ))
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == (2 / π) * abs(asin(sin(π * (i - 1) / period))) * γ^(i - 1)
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
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
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == abs(sin(π * (i - 1) / period))
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "SinDecay2" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = SinDecay2(λ0 = λ0, λ1 = λ1, period = period)
    @test s == SinDecay2(Sin(λ0, λ1, period))
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == abs(sin(π * (i - 1) / period)) / (2^fld(i - 1, period))
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "SinExp" begin
    λ0 = rand()
    λ1 = rand()
    γ = rand()
    period = rand(1:10)
    s = SinExp(λ0 = λ0, λ1 = λ1, period = period, γ = γ)
    @test s == SinExp(Sin(λ0, λ1, period), Exp(one(λ0), γ))
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == abs(sin(π * (i - 1) / period)) * γ^(i - 1)
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end

@testset "Cos" begin
    λ0 = rand()
    λ1 = rand()
    period = rand(1:10)
    s = Cos(λ0 = λ0, λ1 = λ1, period = period)
    @test s == Cos(λ0, λ1, period)
    @test ParameterSchedulers.startvalue(s) == λ0
    @test ParameterSchedulers.endvalue(s) == λ1
    i = rand(1:100)
    @test ParameterSchedulers.cycle(s, i) == (1 + cos(2 * π * (i - 1) / period)) / 2
    @test s[i] == _cyclic(λ0, λ1, ParameterSchedulers.cycle(s, i))
    @test all(p == s[t] for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.HasEltype()
    @test eltype(s) == eltype(λ0)
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
end