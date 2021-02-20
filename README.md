# ParameterSchedulers

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://darsnack.github.io/ParameterSchedulers.jl/dev)
[![Build Status](https://github.com/darsnack/ParameterSchedulers.jl/workflows/CI/badge.svg)](https://github.com/darsnack/ParameterSchedulers.jl/actions)

ParameterSchedulers.jl provides common machine learning (ML) schedulers for hyper-parameters. Though this package is framework agnostic, a convenient interface for pairing schedules with [Flux.jl](https://github.com/FluxML/Flux.jl) optimizers is available. Using this package with Flux is as simple as:
```julia
using Flux, ParameterSchedulers

opt = Exp(Momentum(); λ = 1e-2, γ = 0.8)
```

## Available Schedules

This is a table of the common schedules implemented, but ParameterSchedulers provides utilities for creating more exotic schedules as well. You can read [this paper](https://arxiv.org/abs/1908.06477) for more information on the schedules below.

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

[`Step(;λ, γ, step_sizes)`](# "`Step`")

</td>
<td>

Exponential decay by `γ` every step in `step_sizes`

</td>
<td> Decay </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Step(λ = 1.0, γ = 0.8, step_sizes = [2, 3, 2])
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`Exp(;λ, γ)`](# "`Exp`")

</td>
<td>

Exponential decay by `γ` every iteration

</td>
<td> Decay </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Exp(λ = 1.0, γ = 0.5)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`Poly(;λ, p, max_iter)`](# "`Poly`")

</td>
<td>

Polynomial decay at degree `p`

</td>
<td> Decay </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Poly(λ = 1.0, p = 2, max_iter = t[end])
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`Inv(;λ, γ, p)`](# "`Inv`")

</td>
<td>

Inverse decay at rate `(1 + tγ)^p`

</td>
<td> Decay </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Inv(λ = 1.0, p = 2, γ = 0.8)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`Tri(;λ0, λ1, period)`](# "`Tri`")

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Tri(λ0 = 0.0, λ1 = 1.0, period = 2)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`TriDecay2(;λ0, λ1, period)`](# "`TriDecay2`")

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function with half the amplitude every `period`

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = TriDecay2(λ0 = 0.0, λ1 = 1.0, period = 2)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`TriExp(;λ0, λ1, period, γ)`](# "`TriExp`")

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function with exponential amplitude decay at rate `γ`

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = TriExp(λ0 = 0.0, λ1 = 1.0, period = 2, γ = 0.8)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`Sin(;λ0, λ1, period)`](# "`Sin`")

</td>
<td>

Sine function

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Sin(λ0 = 0.0, λ1 = 1.0, period = 2)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`SinDecay2(;λ0, λ1, period)`](# "`SinDecay2`")

</td>
<td>

Sine function with half the amplitude every `period`

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = SinDecay2(λ0 = 0.0, λ1 = 1.0, period = 2)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`SinExp(;λ0, λ1, period)`](# "`SinExp`")

</td>
<td>

Sine function with exponential amplitude decay at rate `γ`

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = SinExp(λ0 = 0.0, λ1 = 1.0, period = 2, γ = 0.8)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>

<tr><td>

[`Cos(;λ0, λ1, period)`](# "`Cos`")

</td>
<td>

Cosine function

</td>
<td> Cyclic </td>
<td style="text-align:center">

{:cell, display=false}
```julia
using UnicodePlots, ParameterSchedulers
t = 1:10 |> collect
s = Cos(λ0 = 0.0, λ1 = 1.0, period = 2)
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false)
```
</td></tr>
</tbody>
</table>