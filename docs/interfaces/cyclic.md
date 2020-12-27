# Cyclic interface

A cyclic schedule conforms to the formula
```math
s(t) = |\lambda_0 - \lambda_1| g(t) + \min (\lambda_0, \lambda_1)
```
where ``s(t)`` is the schedule output, ``\lambda_0`` and ``\lambda_1`` are the start and end values, and ``g(t)`` is the cycle function. The cycle function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

Unlike the [generic interface](#), the [cyclic interface](# "`CyclicSchedule`") uses the formula above to abstract away most of the iteration and `Base.index` requirements. Instead, a simple interface exists for defining the components of the formula. The required functions and their descriptions are given below.

| Function                                            | Description                           |
|:----------------------------------------------------|:--------------------------------------|
| [`startvalue(s::CyclicSchedule)`](# "`startvalue`") | Return the start value, ``\lambda_0`` |
| [`endvalue(s::CyclicSchedule)`](# "`endvalue`")     | Return the end value, ``\lambda_1``   |
| [`cycle(s::CyclicSchedule, t)`](# "`cycle`")        | Evaluate the cycle function, ``g(t)`` |

Below, we'll use this interface to implement a new cyclic schedule, `Square`, which implements a [square wave](https://en.wikipedia.org/wiki/Square_wave). We start by inheriting from [`CyclicSchedule`](#).
{cell=cyclic-interface}
```julia
using ParameterSchedulers

struct Square{T<:Number, S<:Integer} <: ParameterSchedulers.CyclicSchedule
    λ0::T
    λ1::T
    period::S
end
```

Now, we implement the interface. The cycle function, ``g(t)``, will return 1 for the first `period / 2` steps, then 0 for the next.
{cell=cyclic-interface}
```julia
ParameterSchedulers.startvalue(schedule::Square) = schedule.λ0
ParameterSchedulers.endvalue(schedule::Square) = schedule.λ1
ParameterSchedulers.cycle(schedule::Square{T}, t) where T =
    (mod(t - 1, schedule.period) < schedule.period / 2) ? one(T) : zero(T)
```

Additionally, we can define parts of the iteration interface that cannot be inferred from the formula at the start. These are optional, but they can be helpful for improving performance. In this case, the schedule is an infinite iterator that returns the same type as `λ0` or `λ1`.
{cell=cyclic-interface}
```julia
Base.IteratorEltype(::Type{<:Square{T}}) where T = T
Base.IteratorSize(::Type{<:Square}) = Base.IsInfinite()
```

`Square` is ready to use like any other schedule.
{cell=cyclic-interface}
```julia
using UnicodePlots

s = Square(0.2, 0.8, 4)
t = 1:20 |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```

!!! tip
    Sometimes, it is helpful to override the default iteration behavior for cyclic schedules. Look at [`Step`](#) for an example for this.