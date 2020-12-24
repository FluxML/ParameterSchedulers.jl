# Basic schedules

While ParameterSchedulers.jl has some complex scheduling capability, its core is made of two types of basic schedules: *[decay schedules](#)* and *[cyclic schedules](#)*. Each type of schedule conforms to an interface and formula which is relevant for understanding the schedules behavior, but more importantly, for creating your own custom schedules. Still, both types of schedules can be indexed and iterated like we saw in the [getting started](#) tutorial.

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

We can access the base value and evaluate the decay function through a provided interface:
{cell=decay-schedules}
```julia
s = Exp(λ = 0.1, γ = 0.8)
println("λ: $(ParameterSchedulers.basevalue(s))")
println("g(1): $(ParameterSchedulers.decay(s, 1))")
println("λ g(1) == s[1]: $(ParameterSchedulers.basevalue(s) * ParameterSchedulers.decay(s, 1) == s[1])")
```
In most situations, you won't use the interface above and rely on `getindex` or `iterate` instead.

As you can see above, [`Exp`](#) is a type of decay schedule. Below is a list of all the decay schedules implemented, and the parameters and decay functions for each one.

| Schedule    | Parameters             | Decay Function |
|:------------|:-----------------------|:---------------|
| [`Step`](#) | `λ`, `γ`, `step_sizes` | ``g(t) = \gamma^{i - 1}`` where ``\sum_{j = 1}^{i - 1} \text{step_sizes}_j < t \leq \sum_{j = 1}^i \text{step_sizes}_j`` |
| [`Exp`](#)  | `λ`, `γ`               | ``g(t) = \gamma^{t - 1}`` |
| [`Poly`](#) | `λ`, `p`, `max_iter`   | ``g(t) = \frac{1}{\left(1 + \lfloor (t - 1) / \text{max_iter} \rfloor\right)^p}`` |
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
where ``s(t)`` is the schedule output, ``\lambda_0`` and ``\lambda_1`` are the start and end values, and ``g(t)`` is the cycle function. Similar to the decay function, the cycle function is expected to be bounded between ``[0, 1]``, but this requirement is only suggested and not enforced.

We can access the start value, end value, and evaluate the cycle function through a provided interface:
{cell=cyclic-schedules}
```julia
s = Tri(λ0 = 0.1, λ1 = 0.4, period = 2)
function f(t)
    λ0 = ParameterSchedulers.startvalue(s)
    λ1 = ParameterSchedulers.endvalue(s)
    
    return abs(λ0 - λ1) * ParameterSchedulers.cycle(s, 1) + min(λ0, λ1)
end
println("λ0: $(ParameterSchedulers.startvalue(s))")
println("λ1: $(ParameterSchedulers.endvalue(s))")
println("g(1): $(ParameterSchedulers.cycle(s, 1))")
println("abs(λ0 - λ1) g(1) + min(λ0, λ1) == s[1]: $(f(1) == s[1])")
```
As with decay schedules, you won't use the interface above and rely on `getindex` and `iterate` for most use-cases.

[`Tri`](#) (used in the above example) is a type of cyclic schedule. Below is a list of all the cyclic schedules implemented, and the parameters and cycle functions for each one.

| Schedule         | Parameters                | Cycle Function |
|:-----------------|:--------------------------|:---------------|
| [`Tri`](#)       | `λ0`, `λ1`, `period`      | ``g(t) = \frac{2}{\pi} \left| \arcsin \left( \sin \left(\frac{\pi (t - 1)}{\text{period}} \right) \right) \right|`` |
| [`TriDecay2`](#) | `λ0`, `λ1`, `period`      | ``g(t) = \frac{1}{2^{\lfloor (t - 1) / \text{period} \rfloor}} g_{\mathrm{Tri}}(t)`` |
| [`TriExp`](#)    | `λ0`, `λ1`, `period`, `γ` | ``g(t) = \gamma^{t - 1} g_{\mathrm{Tri}}(t)`` |
| [`Sin`](#)       | `λ0`, `λ1`, `period`      | ``g(t) = \left| \sin \left(\frac{\pi (t - 1)}{\text{period}} \right) \right|`` |
| [`SinDecay2`](#) | `λ0`, `λ1`, `period`      | ``g(t) = \frac{1}{2^{\lfloor (t - 1) / \text{period} \rfloor}} g_{\mathrm{Sin}}(t)`` |
| [`SinExp`](#)    | `λ0`, `λ1`, `period`, `γ` | ``g(t) = \gamma^{t - 1} g_{\mathrm{Tri}}(t)`` |
| [`Cos`](#)       | `λ0`, `λ1`, `period`      | ``g(t) = \frac{1}{2} \left(1 + \cos \left(\frac{4 \pi t}{\text{period}}\right) \rigth)`` |