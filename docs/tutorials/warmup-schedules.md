# Warm-up Schedules

A popular technique for scheduling learning rates is "warming-up" the optimizer by ramping the learning rate up from zero to the "true" initial learning rate, then starting the "real" schedule. This is easily implementable with ParameterSchedulers.jl using [`Sequence`](#).

## Linear ramp

Suppose we want to increase our learning rate using a linear ramp function. We can achieve this by running a [`Triangle`](#) schedule for a half-period.

{cell=ramp}
```julia
using ParameterSchedulers
using UnicodePlots

min_lr = 1e-6 # don't actually start with lr = 0
initial_lr = 1e-2
warmup = 20 # warmup for 20 epochs

ramp = Triangle(λ0 = min_lr, λ1 = initial_lr, period = 2 * warmup)

t = 1:warmup |> collect
lineplot(t, ramp.(t); border = :none)
```

Of course, if we run the `Triangle` for more than `warmup` iterations, it will be periodic. So, we want to make sure to start our "real" schedule immediately after half a period.

{cell=ramp}
```julia
total_iters = 100

# let's wrap it all up in a convenience constructor
WarmupLinear(startlr, initlr, warmup, total_iters, schedule) =
    Sequence(Triangle(λ0 = startlr, λ1 = initlr, period = 2 * warmup) => warmup,
             schedule => total_iters)

s = WarmupLinear(min_lr, initial_lr, warmup, total_iters, Exp(initial_lr, 0.8))
t = 1:total_iters |> collect
lineplot(t, s.(t); border = :none)
```

## Sine ramp

Another common ramp function is a half period of a sine wave. We can use [`Sin`](#) and the same technique as the previous section.

{cell=ramp}
```julia
WarmupSin(startlr, initlr, warmup, total_iters, schedule) =
    Sequence(Sin(λ0 = startlr, λ1 = initlr, period = 2 * warmup) => warmup,
             schedule => total_iters)

s = WarmupSin(min_lr, initial_lr, warmup, total_iters, Exp(initial_lr, 0.8))
t = 1:total_iters |> collect
lineplot(t, s.(t); border = :none)
```

## Using `Shifted` to start the "real" schedule

Sometimes, the "real" schedule doesn't start at the `initial_lr` like `Exp`. Suppose we want a sine warmup followed by a `Triangle` schedule. `Triangle` starts at `min(λ0, λ1)`, so to get this correct, we want to start the `Triangle` half-way through its first period. We can use [`Shifted`](#) to do this.

{cell=ramp}
```julia
# shift the Triangle by half a period + 1 to start at the peak
tri = Shifted(Triangle(λ0 = min_lr, λ1 = initial_lr, period = 10), 6)
s = WarmupSin(min_lr, initial_lr, warmup, total_iters, tri)
t = 1:50 |> collect
lineplot(t, s.(t); border = :none)
```
