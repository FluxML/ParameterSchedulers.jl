# Decay interface

Decay schedules conform the following definition:
```math
s(t) = \lambda g(t)
```
where ``s(t)`` is the schedule output, ``\lambda`` is the base (initial) value, and ``g(t)`` is the decay function. Typically, the decay function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

Unlike the [generic interface](#), the [decay interface](# "`DecaySchedule`") uses the formula above to abstract away most of the iteration and `Base.index` requirements. Instead, a simple interface exists for defining the components of the formula. The required functions and their descriptions are given below.

| Function                                         | Description                           |
|:-------------------------------------------------|:--------------------------------------|
| [`basevalue(s::DecaySchedule)`](# "`basevalue`") | Return the base value, ``\lambda``    |
| [`decay(s::DecaySchedule, t)`](# "`decay`")      | Evaluate the decay function, ``g(t)`` |

Next, we will implement a `Decay2` schedule that halves the parameter value every iteration. First, we define the struct and inherit from [`DecaySchedule`](#).
{cell=decay-interface}
```julia
using ParameterSchedulers

struct Decay2{T<:Number} <: ParameterSchedulers.DecaySchedule
    λ::T
end
```

After this, we can define the interface functions. Our decay function will be defined as ``g(t) = \frac{1}{2^{t - 1}}``.
{cell=decay-interface}
```julia
ParameterSchedulers.basevalue(schedule::Decay2) = schedule.λ
ParameterSchedulers.decay(schedule::Decay2, t) = 1 / 2^(t - 1)
```

Additionally, we can define parts of the iteration interface that cannot be inferred from the formula at the start. These are optional, but they can be helpful for improving performance. In this case, the schedule is an infinite iterator that returns the same type as `λ`.
{cell=decay-interface}
```julia
Base.IteratorEltype(::Type{<:Decay2{T}}) where T = T
Base.IteratorSize(::Type{<:Decay2}) = Base.IsInfinite()
```

Now, we can use `Decay2` schedule like any other decay schedule. Below, sequence two different `Decay2` schedules.
{cell=decay-interface}
```julia
using UnicodePlots

s = Sequence(schedules = [Decay2(0.5), Decay2(0.2)], step_sizes = [5, 5])
t = 1:10 |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```

!!! tip
    Sometimes, it is helpful to override the default iteration behavior for decay schedules. Look at [`Step`](#) for an example for this.