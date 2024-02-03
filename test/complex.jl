@testset "Sequence" begin
    schedules = (log, sqrt)
    step_sizes = (rand(1:10), rand(1:10))
    s = Sequence(schedules, step_sizes)
    @test s == Sequence([s => t for (s, t) in zip(schedules, step_sizes)]...)
    i = rand(UInt) + 1
    @test s(i) ≈ ((i > step_sizes[1]) ? sqrt(i - step_sizes[1]) : log(i))
    @test all(p ≈ ((t > step_sizes[1]) ? sqrt(t - step_sizes[1]) : log(t))
              for (t, p) in zip(1:50, s))
    @test Base.IteratorEltype(typeof(s)) == Base.EltypeUnknown()
    @test Base.IteratorSize(typeof(s)) == Base.SizeUnknown()

    params = [rand(), rand()]
    s = Sequence(params, step_sizes)
    @test s(i) == ((i > step_sizes[1]) ? params[2] : params[1])
    @test all(p == ((t > step_sizes[1]) ? params[2] : params[1])
              for (t, p) in zip(1:50, s))

    # test iterating past end of sequence
    s = Sequence(1 => 1, Step(0.1, 0.5, 10) => 50)
    @test s(1) == 1
    @test s(2) == 0.1
    @test s(42) == 0.00625
    @test s(52) == 0.003125

    @testset "Infinite Sequences" begin
        s = Sequence(Exp(1.0, 0.5 * step) for step in OneToInf())
        t0 = 1
        for step in 1:4
            e = Exp(1.0, 0.5 * step)
            ts = t0:(t0 - 1 + step)
            @test s.(ts) ≈ e.(1:step)
            t0 += step
        end
    end
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

@testset "Interpolator" begin
    dt = 1e-3
    s = Interpolator(sin, dt, identity)
    @test [s(t) for t in dt:dt:(100 * dt)] ≈ sin.(1:100)

    values = [1, 2, 3]
    epochs = [10, 10, 30]
    nbatches = 5
    s = Interpolator(Sequence([1, 2, 3], epochs), nbatches)
    correct_seq = vcat([fill(v, nbatches * nepochs) for (v, nepochs) in zip(values, epochs)]...)
    @test [s(t) for t in 1:(sum(epochs) * nbatches)] == correct_seq
end

@testset "Shifted" begin
    s = Triangle(l0 = 0, l1 = 1, period = 10)
    soffset = Shifted(s, 5)

    @test [soffset(t) for t in 1:50] == [s(t) for t in 5:54]
end

@testset "Stateful" begin
    stateful_s = Stateful(log)
    @test all(next!(stateful_s) == log(i) for i in 1:100)
    reset!(stateful_s)
    @test log(1) == next!(stateful_s)
    stateful_s = Stateful(log; advance = s -> s == 1)
    @test log(1) == next!(stateful_s)
    @test log(2) == next!(stateful_s)
    @test log(2) == next!(stateful_s)
end

@testset "OneCycle" begin
    function onecycle(t, nsteps, startval, maxval, endval, pct)
        warmup = ceil(Int, pct * nsteps)
        warmdown = nsteps - warmup

        if t > nsteps
            return endval
        elseif  t <= warmup
            return _cycle(startval, maxval, _sin(t, 2 * warmup))
        else
            return _cycle(maxval, endval, _cos(t, 2 * warmdown))
        end
    end

    nsteps = 50
    maxval = 1f-1
    s = OneCycle(nsteps, maxval)
    @test all(s(t) == onecycle(t, nsteps, maxval / 25, maxval, maxval / 1f5, 0.25)
              for t in 1:(2 * nsteps))
    startval = 1f-4
    endval = 1f-2
    pct = 0.3
    s = OneCycle(nsteps, maxval; startval, endval, percent_start = pct)
    @test all(s(t) == onecycle(t, nsteps, startval, maxval, endval, pct)
              for t in 1:(2 * nsteps))
end
