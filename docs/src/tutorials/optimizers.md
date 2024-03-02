# Scheduling optimizers

A schedule by itself is not helpful; we need to use the schedules to adjust parameters. In this tutorial, we will examine three ways to do just that---iterating the schedule, using a stateful iterator, and using an scheduled optimizer.

## Iterating during training

Since every schedule is a standard iterator, we can insert it into a training loop by simply zipping up with another iterator. For example, the following code adjusts the learning rate of the optimizer before each batch of training.
```@example optimizers
using Flux, ParameterSchedulers
using Optimisers: Descent, adjust!

data = [(Flux.rand32(4, 10), rand([-1, 1], 1, 10)) for _ in 1:3]
m = Chain(Dense(4, 4, tanh), Dense(4, 1, tanh))
opt = Descent()
opt_st = Flux.setup(opt, m)
s = Exp(start = 1e-1, decay = 0.2)

for (eta, (x, y)) in zip(s, data)
    global opt_st, m
    adjust!(opt_st, eta)
    g = Flux.gradient(m -> Flux.mse(m(x), y), m)[1]
    opt_st, m = Flux.update!(opt_st, m, g)
    println("opt state: ", opt_st.layers[1].weight.rule)
end
```

We can also adjust the learning on an epoch basis instead. All that is required is to change what we zip our schedule with.
```@example optimizers
nepochs = 6
s = Step(start = 1e-1, decay = 0.2, step_sizes = [3, 2, 1])
for (eta, epoch) in zip(s, 1:nepochs)
    global opt_st
    adjust!(opt_st, eta)
    for (i, (x, y)) in enumerate(data)
        global m
        g = Flux.gradient(m -> Flux.mse(m(x), y), m)[1]
        opt_st, m = Flux.update!(opt_st, m, g)
        println("epoch: $epoch, batch: $i, opt state: $(opt_st.layers[1].weight.rule)")
    end
end
```

## Stateful iteration with training

Sometimes zipping up the schedule with an iterator isn't sufficient. For example, we might want to advance the schedule with every batch but not be forced to restart each epoch. In such a situation with nested loops, it becomes useful to use [`ParameterSchedulers.Stateful`](@ref) which maintains its own iteration state.
{cell=optimizers}
```@example optimizers
nepochs = 3
s = ParameterSchedulers.Stateful(Inv(start = 1e-1, decay = 0.2, degree = 2))
for epoch in 1:nepochs
    for (i, (x, y)) in enumerate(data)
        global opt_st, m
        adjust!(opt_st, ParameterSchedulers.next!(s))
        g = Flux.gradient(m -> Flux.mse(m(x), y), m)[1]
        opt_st, m = Flux.update!(opt_st, m, g)
        println("epoch: $epoch, batch: $i, opt state: $(opt_st.layers[1].weight.rule)")
    end
end
```

## Working with Flux optimizers

While the approaches above can be helpful when dealing with fine-grained training loops, it is usually simpler to just use a [`ParameterSchedulers.Scheduler`](@ref).
```@example optimizers
using ParameterSchedulers: Scheduler

nepochs = 3
s = Inv(start = 1e-1, degree = 2, decay = 0.2)
opt = Scheduler(Descent, s)
opt_st = Flux.setup(opt, m)
for epoch in 1:nepochs
    for (i, (x, y)) in enumerate(data)
        global opt_st, m
        sched_step = opt_st.layers[1].weight.state.t
        println("epoch: $epoch, batch: $i, sched state: $sched_step")
        g = Flux.gradient(m -> Flux.mse(m(x), y), m)[1]
        opt_st, m = Flux.update!(opt_st, m, g)
    end
end
```
The scheduler, `opt`, can be used anywhere a Flux optimizer can. For example, it can be passed to `Flux.train!`:
```@example optimizers
s = Inv(start = 1e-1, degree = 2, decay = 0.2)
opt = Scheduler(Descent, s)
opt_st = Flux.setup(opt, m)
loss(m, x, y) = Flux.mse(m(x), y)
for epoch in 1:nepochs
    sched_step = opt_st.layers[1].weight.state.t
    println("epoch: $epoch, sched state: $sched_step")
    Flux.train!(loss, m, data, opt_st)
end
```

Finally, you might be interested in reading [Interpolating schedules](@ref) to see how to specify a schedule in terms of epochs but iterate it at the granularity of batches.
