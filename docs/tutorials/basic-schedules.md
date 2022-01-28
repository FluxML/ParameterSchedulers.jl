# Basic schedules

While ParameterSchedulers.jl has some complex scheduling capability, its core is made of two kinds of basic schedules: *[decay schedules](#)* and *[cyclic schedules](#)*. Each kind of schedule conforms to a formula which is relevant for understanding the schedules behavior. Still, both types of schedules can be called and iterated like we saw in the [getting started](#) tutorial.

## Decay schedules

{cell=decay-schedules, display=false, output=false, results=false}
```julia
using ParameterSchedulers
```

A decay schedule is defined by the following formula:
```math
s(t) = \lambda g(t)
```
where ``s(t)`` is the schedule output, ``\lambda`` is the base (initial) value, and ``g(t)`` is the decay function. Typically, the decay function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

For example, here is an exponential decay schedule:
{cell=decay-schedules}
```julia
expdecay(γ, t) = γ^(t - 1)
s = Exp(λ = 0.1, γ = 0.8)
println("λ g(1) == s(1): ",
        0.1 * expdecay(0.8, 1) == s(1))
```

As you can see above, [`Exp`](#) is a type of decay schedule. Below is a list of all the decay schedules implemented, and the parameters and decay functions for each one.

| Schedule    | Parameters             | Decay Function |
|:------------|:-----------------------|:---------------|
| [`Step`](#) | `λ`, `γ`, `step_sizes` | ``g(t) = \gamma^{i - 1}`` where ``\sum_{j = 1}^{i - 1} \text{step\_sizes}_j < t \leq \sum_{j = 1}^i \text{step\_sizes}_j`` |
| [`Exp`](#)  | `λ`, `γ`               | ``g(t) = \gamma^{t - 1}`` |
| [`Poly`](#) | `λ`, `p`, `max_iter`   | ``g(t) = \frac{1}{\left(1 - (t - 1) / \text{max\_iter}\right)^p}`` |
| [`Inv`](#)  | `λ`, `γ`, `p`          | ``g(t) = \frac{1}{(1 + (t - 1) \gamma)^p}`` |

## Cyclic schedules

{cell=cyclic-schedules, display=false, output=false, results=false}
```julia
using ParameterSchedulers
```

A cyclic schedule exhibits periodic behavior, and it is described by the following formula:
```math
s(t) = |\lambda_0 - \lambda_1| g(t) + \min (\lambda_0, \lambda_1)
```
where ``s(t)`` is the schedule output, ``\lambda_0`` and ``\lambda_1`` are the range endpoints, and ``g(t)`` is the cycle function. Similar to the decay function, the cycle function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

For example, here is triangular wave schedule:
{cell=cyclic-schedules}
```julia
tricycle(period, t) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
s = Triangle(λ0 = 0.1, λ1 = 0.4, period = 2)
println("abs(λ0 - λ1) g(1) + min(λ0, λ1) == s(1): ",
        abs(0.1 - 0.4) * tricycle(2, 1) + min(0.1, 0.4) == s(1))
```

[`Triangle`](#) (used in the above example) is a type of cyclic schedule. Below is a list of all the cyclic schedules implemented, and the parameters and cycle functions for each one.

| Schedule              | Parameters                               | Cycle Function |
|:----------------------|:-----------------------------------------|:---------------|
| [`Triangle`](#)       | `λ0`, `λ1`, `period`                     | ``g(t) = \frac{2}{\pi} \left| \arcsin \left( \sin \left(\frac{\pi (t - 1)}{\text{period}} \right) \right) \right|`` |
| [`TriangleDecay2`](#) | `λ0`, `λ1`, `period`                     | ``g(t) = \frac{1}{2^{\lfloor (t - 1) / \text{period} \rfloor}} g_{\mathrm{Triangle}}(t)`` |
| [`TriangleExp`](#)    | `λ0`, `λ1`, `period`, `γ`                | ``g(t) = \gamma^{t - 1} g_{\mathrm{Triangle}}(t)`` |
| [`Sin`](#)            | `λ0`, `λ1`, `period`                     | ``g(t) = \left| \sin \left(\frac{\pi (t - 1)}{\text{period}} \right) \right|`` |
| [`SinDecay2`](#)      | `λ0`, `λ1`, `period`                     | ``g(t) = \frac{1}{2^{\lfloor (t - 1) / \text{period} \rfloor}} g_{\mathrm{Sin}}(t)`` |
| [`SinExp`](#)         | `λ0`, `λ1`, `period`, `γ`                | ``g(t) = \gamma^{t - 1} g_{\mathrm{Sin}}(t)`` |
| [`CosAnneal`](#)      | `λ0`, `λ1`, `period`, `restart == true`  | ``g(t) = \frac{1}{2} \left(1 + \cos \left(\frac{\pi \: \mathrm{mod}(t - 1, \text{period})}{\text{period}}\right) \right)`` |
| [`CosAnneal`](#)      | `λ0`, `λ1`, `period`, `restart == false` | ``g(t) = \frac{1}{2} \left(1 + \cos \left(\frac{\pi \: (t - 1) / \text{period}}{\text{period}}\right) \right)`` |