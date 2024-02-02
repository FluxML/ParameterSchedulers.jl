# Basic schedules

While ParameterSchedulers.jl has some complex scheduling capability, its core is made of two kinds of basic schedules: *[decay schedules](@ref "Decay schedules")* and *[cyclic schedules](@ref "Cyclic schedules")*. Each kind of schedule conforms to a formula which is relevant for understanding the schedules behavior. Still, both types of schedules can be called and iterated like we saw in the [getting started](@ref "Getting started") tutorial.

## Decay schedules

```@example decay-schedules
using ParameterSchedulers # hide
```

A decay schedule is defined by the following formula:
```math
s(t) = \lambda g(t)
```
where ``s(t)`` is the schedule output, ``\lambda`` is the base (initial) value, and ``g(t)`` is the decay function. Typically, the decay function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

For example, here is an exponential decay schedule:
```@example decay-schedules
expdecay(γ, t) = γ^(t - 1)
s = Exp(λ = 0.1, γ = 0.8)
println("λ g(1) == s(1): ",
        0.1 * expdecay(0.8, 1) == s(1))
```

As you can see above, [`Exp`](@ref) is a type of decay schedule. Below is a list of all the decay schedules implemented, and the parameters and decay functions for each one.

| Schedule       | Parameters             | Decay Function |
|:---------------|:-----------------------|:---------------|
| [`Step`](@ref) | `λ`, `γ`, `step_sizes` | ``g(t) = \gamma^{i - 1}`` where ``\sum_{j = 1}^{i - 1} \text{step\_sizes}_j < t \leq \sum_{j = 1}^i \text{step\_sizes}_j`` |
| [`Exp`](@ref)  | `λ`, `γ`               | ``g(t) = \gamma^{t - 1}`` |
| [`Poly`](@ref) | `λ`, `p`, `max_iter`   | ``g(t) = \frac{1}{\left(1 - (t - 1) / \text{max\_iter}\right)^p}`` |
| [`Inv`](@ref)  | `λ`, `γ`, `p`          | ``g(t) = \frac{1}{(1 + (t - 1) \gamma)^p}`` |

## Cyclic schedules

```@example cyclic-schedules
using ParameterSchedulers #hide
```

A cyclic schedule exhibits periodic behavior, and it is described by the following formula:
```math
s(t) = |\lambda_0 - \lambda_1| g(t) + \min (\lambda_0, \lambda_1)
```
where ``s(t)`` is the schedule output, ``\lambda_0`` and ``\lambda_1`` are the range endpoints, and ``g(t)`` is the cycle function. Similar to the decay function, the cycle function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

For example, here is triangular wave schedule:
```@example cyclic-schedules
tricycle(period, t) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
s = Triangle(λ0 = 0.1, λ1 = 0.4, period = 2)
println("abs(λ0 - λ1) g(1) + min(λ0, λ1) == s(1): ",
        abs(0.1 - 0.4) * tricycle(2, 1) + min(0.1, 0.4) == s(1))
```

[`Triangle`](@ref) (used in the above example) is a type of cyclic schedule. Below is a list of all the cyclic schedules implemented, and the parameters and cycle functions for each one.

| Schedule                 | Parameters                               | Cycle Function |
|:-------------------------|:-----------------------------------------|:---------------|
| [`Triangle`](@ref)       | `λ0`, `λ1`, `period`                     | ``g(t) = \frac{2}{\pi} \left| \arcsin \left( \sin \left(\frac{\pi (t - 1)}{\text{period}} \right) \right) \right|`` |
| [`TriangleDecay2`](@ref) | `λ0`, `λ1`, `period`                     | ``g(t) = \frac{1}{2^{\lfloor (t - 1) / \text{period} \rfloor}} g_{\mathrm{Triangle}}(t)`` |
| [`TriangleExp`](@ref)    | `λ0`, `λ1`, `period`, `γ`                | ``g(t) = \gamma^{t - 1} g_{\mathrm{Triangle}}(t)`` |
| [`Sin`](@ref)            | `λ0`, `λ1`, `period`                     | ``g(t) = \left| \sin \left(\frac{\pi (t - 1)}{\text{period}} \right) \right|`` |
| [`SinDecay2`](@ref)      | `λ0`, `λ1`, `period`                     | ``g(t) = \frac{1}{2^{\lfloor (t - 1) / \text{period} \rfloor}} g_{\mathrm{Sin}}(t)`` |
| [`SinExp`](@ref)         | `λ0`, `λ1`, `period`, `γ`                | ``g(t) = \gamma^{t - 1} g_{\mathrm{Sin}}(t)`` |
| [`CosAnneal`](@ref)      | `λ0`, `λ1`, `period`, `restart == true`  | ``g(t) = \frac{1}{2} \left(1 + \cos \left(\frac{\pi \: \mathrm{mod}(t - 1, \text{period})}{\text{period}}\right) \right)`` |
| [`CosAnneal`](@ref)      | `λ0`, `λ1`, `period`, `restart == false` | ``g(t) = \frac{1}{2} \left(1 + \cos \left(\frac{\pi \: (t - 1)}{\text{period}}\right) \right)`` |