# ParameterSchedulers

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://fluxml.github.io/ParameterSchedulers.jl/dev)
[![Build Status](https://github.com/FluxML/ParameterSchedulers.jl/workflows/CI/badge.svg)](https://github.com/FluxML/ParameterSchedulers.jl/actions)

ParameterSchedulers.jl provides common machine learning (ML) schedulers for hyper-parameters. Though this package is framework agnostic, a convenient interface for pairing schedules with [Flux.jl](https://github.com/FluxML/Flux.jl) optimizers is available. Using this package with Flux is as simple as:
```julia
using Flux, ParameterSchedulers
using ParameterSchedulers: Scheduler

opt = Scheduler(Exp(λ = 1e-2, γ = 0.8), Momentum())
```

## Available Schedules

This is a table of the common schedules implemented, but ParameterSchedulers provides utilities for creating more exotic schedules as well. The [higher order schedules](# "Complex schedules") should make it so that you will rarely need to write a schedule from scratch.

You can read [this paper](https://arxiv.org/abs/1908.06477) for more information on the schedules below.

<table>
<thead>
<tr>
    <th>Schedule</th>
    <th>Description</th>
    <th>Type</th>
    <th>Example</th>
</tr>
</thead>

<tbody>
<tr><td>

[`Step(;λ, γ, step_sizes)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Step)

</td>
<td>

Exponential decay by `γ` every step in `step_sizes`

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Step(λ = 1.0, γ = 0.8, step_sizes = [2, 3, 2]) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Exp(;λ, γ)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Exp)

</td>
<td>

Exponential decay by `γ` every iteration

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Exp(λ = 1.0, γ = 0.5) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`CosAnneal(;λ0, λ1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.CosAnneal)

</td>
<td>

[Cosine annealing](https://arxiv.org/abs/1608.03983v5)

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = CosAnneal(λ0 = 0.0, λ1 = 1.0, period = 4) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Triangle(;λ0, λ1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.Triangle)

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Triangle(λ0 = 0.0, λ1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`TriangleDecay2(;λ0, λ1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.TriangleDecay2)

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function with half the amplitude every `period`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = TriangleDecay2(λ0 = 0.0, λ1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`TriangleExp(;λ0, λ1, period, γ)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.TriangleExp)

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function with exponential amplitude decay at rate `γ`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = TriangleExp(λ0 = 0.0, λ1 = 1.0, period = 2, γ = 0.8) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Poly(;λ, p, max_iter)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Poly)

</td>
<td>

Polynomial decay at degree `p`

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Poly(λ = 1.0, p = 2, max_iter = t[end]) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Inv(;λ, γ, p)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Inv)

</td>
<td>

Inverse decay at rate `(1 + tγ)^p`

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Inv(λ = 1.0, p = 2, γ = 0.8) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Sin(;λ0, λ1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.Sin)

</td>
<td>

Sine function

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Sin(λ0 = 0.0, λ1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`SinDecay2(;λ0, λ1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.SinDecay2)

</td>
<td>

Sine function with half the amplitude every `period`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = SinDecay2(λ0 = 0.0, λ1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`SinExp(;λ0, λ1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.SinExp)

</td>
<td>

Sine function with exponential amplitude decay at rate `γ`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = SinExp(λ0 = 0.0, λ1 = 1.0, period = 2, γ = 0.8) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

</tbody>
</table>
