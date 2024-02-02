# Generic interface

All schedules must implement the interface `(s::MySchedule)(t)` which returns the schedule value at iteration `t`. Additionally, a schedule must implement `Base.iterate` from the [iteration interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration) and `Base.eltype` when possible. This is the minimal interface required to work with the rest of ParameterSchedulers.jl.

It is *strongly* recommended that your schedule subtypes [`ParameterSchedulers.AbstractSchedule`](@ref). This will define `Base.iterate` and several other pieces of the iteration interface for you.

`AbstractSchedule` takes a single type parameter, `IsFinite`. Below are the possible values.
- `AbstractSchedule{true}`: use for finite schedules
    - `Base.IteratorSize` is auto-implemented as `Base.HasLength()`
    - `Base.axes(s)` is auto-implemented as `1:length(s)`
    - Requires `Base.length` to be implemented by you
- `AbstractSchedule{false}`: use for infinite schedules
    - `Base.IteratorSize` is auto-implemented as `Base.IsInfinite()`
    - `Base.axes` is auto-implemented as `OneToInf()`
- `AbstractSchedule{missing}`: use for schedules where infinite/finite is unknown
    - `Base.IteratorSize` is auto-implemented as `Base.SizeUnknown()`
    - `Base.axes` is auto-implemented as `OneToInf()`
- `AbstractSchedule{T}`: use for schedules where the length depends on `T`
    - `Base.IteratorSize` is auto-implemented as `Base.IteratorSize(T)`

```@docs
ParameterSchedulers.AbstractSchedule
```

# Examples

## Lambda schedule

Below we implement `Lambda` to illustrate what is required for a custom schedule. `Lambda` simply wraps a function, `f`, and the schedule value at iteration `t` is `f(t)`.
```@example generic-interface
using ParameterSchedulers
using ParameterSchedulers: AbstractSchedule

struct Lambda{T} <: AbstractSchedule{missing}
    f::T
end
```

Next we implement the necessary interfaces. The easiest way to define `(s::Lambda)(t)`, then rely on that to define the iteration behavior.
```@example generic-interface
(schedule::Lambda)(t) = schedule.f(t)

Base.iterate(schedule::Lambda, t = 1) = schedule(t), t + 1

# since the eltype is unknown, we indicate it
Base.IteratorEltype(::Type{<:Lambda}) = Base.EltypeUnknown()
```

!!! tip
    Sometimes, it might be more efficient to define `Base.iterate` separately from `s(t)`. See [`Step`](@ref) for an example what this might look like.

You can also define optional parts of the iteration interface if you choose. They are not required for ParameterSchedulers.jl.

Once you are done defining the above interfaces, you can start using `Lambda` like any other schedule. For example, below we create a [`Loop`](@ref) where the interval is defined as a `Lambda`
```@example generic-interface
using UnicodePlots

s = Loop(Lambda(log), 4)
t = 1:10 |> collect
lineplot(t, s.(t); border = :none)
```

## Decay by half

We will implement a `Decay2` schedule that halves the parameter value every iteration. First, we define the struct.
```@example decay-interface
using ParameterSchedulers
using ParameterSchedulers: AbstractSchedule

# we subtype AbstractSchedule{IsFinite} with IsFinite == false
# this is because this is an infinite schedule
struct Decay2{T<:Number} <: AbstractSchedule{false}
    λ::T
end
```

After this, we can define the interface functions. Our decay function will be defined as ``g(t) = \frac{1}{2^{t - 1}}``.
```@example decay-interface
(schedule::Decay2)(t) = schedule.λ / 2^(t - 1)
```

Now, we can use `Decay2` schedule like any other decay schedule. Below, sequence two different `Decay2` schedules.
```@example decay-interface
using UnicodePlots

s = Sequence(Decay2(0.5) => 5, Decay2(0.2) => 5)
t = 1:10 |> collect
lineplot(t, s.(t); border = :none)
```

## A square wave schedule

Now, we'll use the interface to implement a new cyclic schedule, `Square`, which implements a [square wave](https://en.wikipedia.org/wiki/Square_wave).
```@example cyclic-interface
using ParameterSchedulers
using ParameterSchedulers: AbstractSchedule

struct Square{T<:Number, S<:Integer} <: AbstractSchedule{false}
    λ0::T
    λ1::T
    period::S
end
```

Now, we implement the interface. The cycle function, ``g(t)``, will return `λ1` for the first `period / 2` steps, then `λ0` for the next.
```@example cyclic-interface
(schedule::Square{T})(t) where T =
    (mod(t - 1, schedule.period) < schedule.period / 2) ? schedule.λ1 : schedule.λ0
```

`Square` is ready to use like any other schedule.
```@example cyclic-interface
using UnicodePlots

s = Square(0.2, 0.8, 4)
t = 1:20 |> collect
lineplot(t, s.(t); border = :none)
```