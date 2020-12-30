# Complex schedules

{cell=complex-schedules, display=false, output=false, results=false}
```julia
using ParameterSchedulers
```

While the [basic schedules](#) tutorial covered the simple decay and cyclic schedules available in ParameterSchedulers.jl, it is possible to more complex schedules for added flexibility.

## Arbitrary functions

Sometimes, a simple function is the easiest way to specify a schedule. Similar to PyTorch's [`LambdaLR`](https://pytorch.org/docs/master/optim.html?highlight=lambdalr#torch.optim.lr_scheduler.LambdaLR), ParameterSchedulers.jl provides [`Lambda`](#). Unlike the decay or cyclic schedules that conform to a formula, `Lambda` simply wraps a given function, `f`, and the schedule output is `f(t)`. But, unlike like `f` alone, `Lambda` can be indexed and iterated like all schedules. Below, we wrap a logarithmic function as a schedule.
{cell=complex-schedules}
```julia
using UnicodePlots

s = Lambda(f = log)
t = 1:10 |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```

## Arbitrary looping schedules

Let's take the notion of [`Lambda`](#) one step further, and instead define how a schedule behaves over a given interval or period. Then, we would like to loop that interval over and over. This is precisely what [`Loop`](#) achieves. For example, we may want to apply an [`Exp`](#) schedule for 10 iterations, then repeat from the beginning, and so forth.
{cell=complex-schedules}
```julia
s = Loop(f = Exp(λ = 0.1, γ = 0.4), period = 10)
t = 1:25 |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```

## Sequences of schedules

Finally, we might concatenate sequences of schedules, applying each one for a given length, then switch to the next schedule in the order. A [`Sequence`](#) schedule lets us do this. For example, we can start with a cyclic schedule, then switch to a more conservative exponential schedule half way through training.
{cell=complex-schedules}
```julia
nepochs = 50
s = Sequence(schedules = [Tri(λ0 = 0.0, λ1 = 0.5, period = 5), Exp(λ = 0.5, γ = 0.5)],
             step_sizes = [nepochs ÷ 2, nepochs ÷ 2])
t = 1:nepochs |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```

Alternatively, we might simply wish to manually set the parameter every interval. `Sequence` also accepts a vector of numbers.
{cell=complex-schedules}
```julia
s = Sequence(schedules = [1e-1, 5e-2, 3.4e-3], step_sizes = [5, 4, 10])
t = 1:20 |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```