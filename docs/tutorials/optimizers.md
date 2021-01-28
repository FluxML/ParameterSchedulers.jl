# Scheduling optimizers

A schedule by itself is not helpful; we need to use the schedules to adjust parameters. In this tutorial, we will examine three ways to do just that --- iterating the schedule, using a stateful iterator, and using an scheduled optimizer.

## Iterating during training

Since every schedule is a standard iterator, we can insert it into a training loop by simply zipping up with another iterator. For example, the following code adjusts the learning rate of the optimizer before each batch of training.
{cell=optimizers}
```julia
using Flux, ParameterSchedulers

data = [(rand(4, 10), rand([-1, 1], 1, 10)) for _ in 1:3]
m = Chain(Dense(4, 4, tanh), Dense(4, 1, tanh))
p = params(m)
opt = Descent()
s = Exp(λ = 1e-1, γ = 0.2)

for (η, (x, y)) in zip(s, data)
    opt.eta = η
    g = Flux.gradient(() -> Flux.mse(m(x), y), p)
    Flux.update!(opt, p, g)
    println("η: $(opt.eta)")
end
```

We can also adjust the learning on an epoch basis instead. All that is required is to change what we zip our schedule with.
{cell=optimizers}
```julia
nepochs = 6
s = Step(λ = 1e-1, γ = 0.2, step_sizes = [3, 2, 1])
for (η, epoch) in zip(s, 1:nepochs)
    opt.eta = η
    for (i, (x, y)) in enumerate(data)
        g = Flux.gradient(() -> Flux.mse(m(x), y), p)
        Flux.update!(opt, p, g)
        println("epoch: $epoch, batch: $i, η: $(opt.eta)")
    end
end
```

## Stateful iteration with training

Sometimes zipping up the schedule with an iterator isn't sufficient. For example, we might want to advance the schedule with every batch but not be forced to restart each epoch. In such a situation with nested loops, it becomes useful to use [`ScheduleIterator`](#) which maintains its own iteration state.
{cell=optimizers}
```julia
nepochs = 3
s = ScheduleIterator(Inv(λ = 1e-1, γ = 0.2, p = 2))
for epoch in 1:nepochs
    for (i, (x, y)) in enumerate(data)
        opt.eta = next!(s)
        g = Flux.gradient(() -> Flux.mse(m(x), y), p)
        Flux.update!(opt, p, g)
        println("epoch: $epoch, batch: $i, η: $(opt.eta)")
    end
end
```

<!-- ## Working with Flux optimizers

!!! warning
    Currently, we are porting `ScheduledOptim` to Flux.jl.
    It may be renamed once it is ported out of this package.

While the approaches above can be helpful when dealing with fine-grained training loops, it is usually simpler to just use a [`ScheduledOptim`](#).
{cell=optimizers}
```julia
nepochs = 3
s = Inv(λ = 1e-1, p = 2, γ = 0.2)
opt = ScheduledOptim(s, Descent())
for epoch in 1:nepochs
    for (i, (x, y)) in enumerate(data)
        g = Flux.gradient(() -> Flux.mse(m(x), y), p)
        Flux.update!(opt, p, g)
        println("epoch: $epoch, batch: $i, η: $(opt.optim.eta)")
    end
end
```
The scheduled optimizer, `opt`, can be used anywhere a Flux optimizer can. For example, it can be passed to `Flux.train!`. -->