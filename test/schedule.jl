@testset "Lambda" begin
    s = Lambda(f = log)
    @test s == Lambda(log)
    i = rand(UInt) + 1
    @test s[i] == log(i)
    @test all(p == log(t) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.EltypeUnknown()
    @test Base.IteratorSize(typeof(s)) == Base.SizeUnknown()
end

@testset "Sequence" begin
    schedules = [Lambda(f = log), Lambda(f = sqrt)]
    step_sizes = [rand(1:10), rand(1:10)]
    s = Sequence(schedules = schedules, step_sizes = step_sizes)
    @test s == Sequence(schedules, step_sizes)
    i = rand(UInt) + 1
    @test s[i] == ((i > step_sizes[1]) ? sqrt(i - step_sizes[1]) : log(i))
    @test all(p == ((t > step_sizes[1]) ? sqrt(t - step_sizes[1]) : log(t))
              for (t, p) in zip(1:(sum(step_sizes) + 10), s))
    @test Base.IteratorEltype(typeof(s)) == Base.EltypeUnknown()
    @test Base.IteratorSize(typeof(s)) == Base.SizeUnknown()

    params = [rand(), rand()]
    s = Sequence(schedules = params, step_sizes = step_sizes)
    @test s[i] == ((i > step_sizes[1]) ? params[2] : params[1])
    @test all(p == ((t > step_sizes[1]) ? params[2] : params[1])
              for (t, p) in zip(1:(sum(step_sizes) + 10), s))
end

@testset "Loop" begin
    period = rand(1:10)
    s = Loop(f = Lambda(f = log), period = period)
    @test s == Loop(Lambda(f = log), period)
    i = rand(UInt) + 1
    @test s[i] == log(mod1(i, period))
    @test all(p == log(mod1(t, period)) for (t, p) in zip(1:100, s))
    @test Base.IteratorEltype(typeof(s)) == Base.IteratorEltype(Lambda(f = log))
    @test Base.IteratorSize(typeof(s)) == Base.IsInfinite()

    @testset "utilities" begin
        reverse_f = ParameterSchedulers.reverse(log, period)
        @test all(reverse_f(period - t) == log(t) for t in 1:period)
        symmetric_f = ParameterSchedulers.symmetric(log, period)
        @test all(symmetric_f(t) == ((t < period / 2) ? log(t) : log(period - t)) for t in 1:period)
    end
end

@testset "ScheduleIterator" begin
    s = Lambda(f = log)
    stateful_s = ScheduleIterator(s)
    @test all(next!(stateful_s) == s[i] for i in 1:100)
end