# Generic interface

All schedules must implement the interface `(s::MySchedule)(t)` which returns the schedule value at iteration `t`. Additionally, a schedule must implement the [iteration interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration).

Below we implement `Lambda` to illustrate what is required for a custom schedule. `Lambda` simply wraps a function, `f`, and the schedule value at iteration `t` is `f(t)`.
{cell=generic-interface}
```julia
using ParameterSchedulers

struct Lambda{T}
    f::T
end
```

Next we implement the necessary interfaces. The easiest way to define `(s::Lambda)(t)`, then rely on that to define the iteration behavior.
{cell=generic-interface}
```julia
(schedule::Lambda)(t) = schedule.f(t)

Base.iterate(schedule::Lambda, t = 1) = schedule(t), t + 1
```

!!! tip
    Sometimes, it might be more efficient to define `Base.iterate` separately from `s(t)`. See [`Step`](#) for an example what this might look like.

You can also define optional parts of the iteration interface if you choose. They are not required for ParameterSchedulers.jl.

Once you are done defining the above interfaces, you can start using `Lambda` like any other schedule. For example, below we create a [`Loop`](#) where the interval is defined as a `Lambda`
{cell=generic-interface}
```julia
using UnicodePlots

s = Loop(Lambda(log), 4)
t = 1:10 |> collect
lineplot(t, s.(t); border = :none)
```

# More examples

Below, we implement two more custom schedules that conform to the decay and cyclic defitions. The interface is no different than `Lambda` above.

## Decay by half

We will implement a `Decay2` schedule that halves the parameter value every iteration. First, we define the struct.
{cell=decay-interface}
```julia
using ParameterSchedulers

struct Decay2{T<:Number}
    λ::T
end
```

After this, we can define the interface functions. Our decay function will be defined as ``g(t) = \frac{1}{2^{t - 1}}``.
{cell=decay-interface}
```julia
(schedule::Decay2)(t) = schedule.λ / 2^(t - 1)
Base.iterate(schedule::Decay2, t = 1) = schedule(t), t + 1
```

Now, we can use `Decay2` schedule like any other decay schedule. Below, sequence two different `Decay2` schedules.
{cell=decay-interface}
```julia
using UnicodePlots

s = Sequence(Decay2(0.5) => 5, Decay2(0.2) => 5)
t = 1:10 |> collect
lineplot(t, s.(t); border = :none)
```

## A square wave schedule

Now, we'll use the interface to implement a new cyclic schedule, `Square`, which implements a [square wave](https://en.wikipedia.org/wiki/Square_wave).
{cell=cyclic-interface}
```julia
using ParameterSchedulers

struct Square{T<:Number, S<:Integer}
    λ0::T
    λ1::T
    period::S
end
```

Now, we implement the interface. The cycle function, ``g(t)``, will return `λ1` for the first `period / 2` steps, then `λ0` for the next.
{cell=cyclic-interface}
```julia
(schedule::Square{T})(t) where T =
    (mod(t - 1, schedule.period) < schedule.period / 2) ? schedule.λ1 : schedule.λ0
Base.iterate(schedule::Square, t = 1) = schedule(t), t + 1
```

`Square` is ready to use like any other schedule.
{cell=cyclic-interface}
```julia
using UnicodePlots

s = Square(0.2, 0.8, 4)
t = 1:20 |> collect
lineplot(t, s.(t); border = :none)
```