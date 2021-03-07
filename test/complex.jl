@testset "Sequence" begin
    schedules = (log, sqrt)
    step_sizes = (rand(1:10), rand(1:10))
    s = Sequence(schedules, step_sizes)
    @test s == Sequence([s => t for (s, t) in zip(schedules, step_sizes)]...)
    i = rand(UInt) + 1
    @test s(i) == ((i > step_sizes[1]) ? sqrt(i - step_sizes[1]) : log(i))
    @test all(p == ((t > step_sizes[1]) ? sqrt(t - step_sizes[1]) : log(t))
              for (t, p) in zip(1:(sum(step_sizes) + 10), s))
    @test Base.IteratorEltype(typeof(s)) == Base.EltypeUnknown()
    @test Base.IteratorSize(typeof(s)) == Base.SizeUnknown()

    params = [rand(), rand()]
    s = Sequence(params, step_sizes)
    @test s(i) == ((i > step_sizes[1]) ? params[2] : params[1])
    @test all(p == ((t > step_sizes[1]) ? params[2] : params[1])
              for (t, p) in zip(1:(sum(step_sizes) + 10), s))
end

@testset "Loop" begin
    period = rand(1:10)
    s = Loop(log, period)
    i = rand(UInt) + 1
    @test s(i) == log(mod1(i, period))
    @test all(p == log(mod1(t, period)) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.IteratorEltype(typeof(log))
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()
    @test axes(s) == (OneToInf(),)

    @testset "utilities" begin
        reverse_f = ParameterSchedulers.reverse(log, period)
        @test all(reverse_f(period - t) == log(t) for t in 1:period)
        symmetric_f = ParameterSchedulers.symmetric(log, period)
        @test all(symmetric_f(t) == ((t < period / 2) ? log(t) : log(period - t)) for t in 1:period)
    end
end

@testset "Stateful" begin
    stateful_s = Stateful(log)
    @test all(next!(stateful_s) == log(i) for i in 1:100)
    reset!(stateful_s)
    @test log(1) == next!(stateful_s)
end