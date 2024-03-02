# Basic schedules

While ParameterSchedulers.jl has some complex scheduling capability, its core is made of two kinds of basic schedules: *[decay schedules](@ref "Decay schedules")* and *[cyclic schedules](@ref "Cyclic schedules")*. Each kind of schedule conforms to a formula which is relevant for understanding the schedules behavior. Still, both types of schedules can be called and iterated like we saw in the [getting started](@ref "Getting started") tutorial.

## Decay schedules

```@example decay-schedules
using ParameterSchedulers # hide
```

A decay schedule is defined by the following formula:
```math
s(t) = l \times g(t)
```
where ``s(t)`` is the schedule output, ``l`` is the base (initial) value, and ``g(t)`` is the decay function. Typically, the decay function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

For example, here is an exponential decay schedule:
```@example decay-schedules
expdecay(decay, t) = decay^(t - 1)
s = Exp(start = 0.1, decay = 0.8)
println("l g(1) == s(1): ", 0.1 * expdecay(0.8, 1) == s(1))
```

As you can see above, [`Exp`](@ref) is a type of decay schedule. Below is a list of all the decay schedules implemented, and the parameters and decay functions for each one.

| Schedule       | Parameters             | Decay Function |
|:---------------|:-----------------------|:---------------|
| [`Step`](@ref) | `start`, `decay`, `step_sizes` | ``g(t) = \texttt{decay}^{i - 1}`` where ``\sum_{j = 1}^{i - 1} \texttt{step\_sizes}_j < t \leq \sum_{j = 1}^i \texttt{step\_sizes}_j`` |
| [`Exp`](@ref) | `start`, `decay` | ``g(t) = \texttt{decay}^{t - 1}`` |
| [`Poly`](@ref) | `start`, `degree`, `max_iter` | ``g(t) = \dfrac{1}{\left(\dfrac{1 - (t - 1)}{\texttt{max\_iter}}\right)^\texttt{degree}}`` |
| [`Inv`](@ref) | `start`, `decay`, `degree` | ``g(t) = \dfrac{1}{\left(1 + \texttt{decay} \times (t - 1) \right)^\texttt{degree}}`` |

## Cyclic schedules

```@example cyclic-schedules
using ParameterSchedulers #hide
```

A cyclic schedule exhibits periodic behavior, and it is described by the following formula:
```math
s(t) = |l_0 - l_1| g(t) + \min (l_0, l_1)
```
where ``s(t)`` is the schedule output, ``l_0`` and ``l_1`` are the range endpoints, and ``g(t)`` is the cycle function. Similar to the decay function, the cycle function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

For example, here is triangular wave schedule:
```@example cyclic-schedules
tricycle(period, t) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
s = Triangle(l0 = 0.1, l1 = 0.4, period = 2)
println(
    "abs(l0 - l1) * g(1) + min(l0, l1) == s(1): ",
    abs(0.1 - 0.4) * tricycle(2, 1) + min(0.1, 0.4) == s(1)
)
```

[`Triangle`](@ref) (used in the above example) is a type of cyclic schedule. Below is a list of all the cyclic schedules implemented, and the parameters and cycle functions for each one.

| Schedule                 | Parameters                               | Cycle Function |
|:-------------------------|:-----------------------------------------|:---------------|
| [`Triangle`](@ref) | `l0`, `l1`, `period` | ``g(t) = \dfrac{2}{\pi} \left\| \arcsin (\sin (\frac{\pi (t - 1)}{\text{period}})) \right\| `` |
| [`TriangleDecay2`](@ref) | `l0`, `l1`, `period` | ``g(t) = \dfrac{1}{2^{\lfloor (t - 1) / \texttt{period} \rfloor}} g_{\texttt{Triangle}}(t)`` |
| [`TriangleExp`](@ref)    | `l0`, `l1`, `period`, `decay`            | ``g(t) = \texttt{decay}^{t - 1} g_{\texttt{Triangle}}(t)`` |
| [`Sin`](@ref)            | `l0`, `l1`, `period`                     | ``g(t) = \left\| \sin \left(\frac{\pi (t - 1)}{\texttt{period}} \right) \right\|`` |
| [`SinDecay2`](@ref)      | `l0`, `l1`, `period`                     | ``g(t) = \dfrac{1}{2^{\lfloor (t - 1) / \texttt{period} \rfloor}} g_{\texttt{Sin}}(t)`` |
| [`SinExp`](@ref)         | `l0`, `l1`, `period`, `decay`             | ``g(t) = \texttt{decay}^{t - 1} g_{\texttt{Sin}}(t)`` |
| [`CosAnneal`](@ref)      | `l0`, `l1`, `period`, with `restart = true`  | ``g(t) = \dfrac{1}{2} \left(1 + \cos \left(\frac{\pi \: \mathrm{mod}(t - 1, \texttt{period})}{\texttt{period}}\right) \right)`` |
| [`CosAnneal`](@ref)      | `l0`, `l1`, `period`, with `restart = false` | ``g(t) = \dfrac{1}{2} \left(1 + \cos \left(\frac{\pi \: (t - 1)}{\texttt{period}}\right) \right)`` |
