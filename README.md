# ParameterSchedulers

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://fluxml.github.io/ParameterSchedulers.jl/dev)
[![Build Status](https://github.com/FluxML/ParameterSchedulers.jl/workflows/CI/badge.svg)](https://github.com/FluxML/ParameterSchedulers.jl/actions)

ParameterSchedulers.jl provides common machine learning (ML) schedulers for hyper-parameters. Though this package is framework agnostic, a convenient interface for pairing schedules with [Flux.jl](https://github.com/FluxML/Flux.jl) optimizers is available. Using this package with Flux is as simple as:
```julia
using Flux, ParameterSchedulers
using ParameterSchedulers: Scheduler

opt = Scheduler(Momentum, Exp(start = 1e-2, decay = 0.8))
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

[`Step(; start, decay, step_sizes)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Step)

</td>
<td>

Exponential decay by `decay` every step in `step_sizes`

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Step(start = 1.0, decay = 0.8, step_sizes = [2, 3, 2]) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Exp(start, decay)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Exp)

</td>
<td>

Exponential decay by `decay` every iteration

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Exp(start = 1.0, decay = 0.5) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`CosAnneal(;l0, l1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.CosAnneal)

</td>
<td>

[Cosine annealing](https://arxiv.org/abs/1608.03983v5)

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = CosAnneal(l0 = 0.0, l1 = 1.0, period = 4) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`OneCycle(nsteps, maxval)`](https://fluxml.ai/ParameterSchedulers.jl/api/complex.html#ParameterSchedulers.OneCycle)

</td>
<td>

[One cycle cosine](https://arxiv.org/abs/1708.07120)

</td>
<td> Complex </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = OneCycle(10, 1.0) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Triangle(l0, l1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.Triangle)

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Triangle(l0 = 0.0, l1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`TriangleDecay2(l0, l1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.TriangleDecay2)

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function with half the amplitude every `period`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = TriangleDecay2(l0 = 0.0, l1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`TriangleExp(l0, l1, period, decay)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.TriangleExp)

</td>
<td>

[Triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) function with exponential amplitude decay at rate `decay`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = TriangleExp(l0 = 0.0, l1 = 1.0, period = 2, decay = 0.8) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Poly(start, degree, max_iter)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Poly)

</td>
<td>

Polynomial decay at degree `degree`.

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Poly(start = 1.0, degree = 2, max_iter = t[end]) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Inv(start, decay, degree)`](https://fluxml.ai/ParameterSchedulers.jl/api/decay.html#ParameterSchedulers.Inv)

</td>
<td>

Inverse decay at rate `(1 + t * decay)^degree`

</td>
<td> Decay </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Inv(start = 1.0, degree = 2, decay = 0.8) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`Sin(;l0, l1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.Sin)

</td>
<td>

Sine function

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = Sin(l0 = 0.0, l1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`SinDecay2(l0, l1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.SinDecay2)

</td>
<td>

Sine function with half the amplitude every `period`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = SinDecay2(l0 = 0.0, l1 = 1.0, period = 2) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

<tr><td>

[`SinExp(l0, l1, period)`](https://fluxml.ai/ParameterSchedulers.jl/api/cyclic.html#ParameterSchedulers.SinExp)

</td>
<td>

Sine function with exponential amplitude decay at rate `decay`

</td>
<td> Cyclic </td>
<td style="text-align:center">

```@example
using UnicodePlots, ParameterSchedulers # hide
t = 1:10 |> collect # hide
s = SinExp(l0 = 0.0, l1 = 1.0, period = 2, decay = 0.8) # hide
lineplot(t, s.(t); width = 15, height = 3, border = :ascii, labels = false) # hide
```
</td></tr>

</tbody>
</table>
