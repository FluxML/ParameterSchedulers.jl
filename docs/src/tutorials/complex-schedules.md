# Complex schedules

```@example complex-schedules
using ParameterSchedulers # hide
```

While the [basic schedules](@ref "Basic schedules") tutorial covered the simple decay and cyclic schedules available in ParameterSchedulers.jl, it is possible to more complex schedules for added flexibility.

## Arbitrary functions

Sometimes, a simple function is the easiest way to specify a schedule. Unlike PyTorch's [`LambdaLR`](https://pytorch.org/docs/master/optim.html?highlight=lambdalr#torch.optim.lr_scheduler.LambdaLR), ParameterSchedulers.jl allows you to use the function directly. The schedule output is `f(t)`. While you can use `f` directly to build up complex schedules (as we'll see in the next section), it lacks functionality like `Base.iterate`. If you want `f` to behave more formally like a schedule, implement the [generic interface](@ref "Generic interface") for schedules.

## Arbitrary looping schedules

Let's take the notion of arbitrary schedules one step further, and instead define how a schedule behaves over a given interval or period. Then, we would like to loop that interval over and over. This is precisely what [`Loop`](@ref) achieves. For example, we may want to apply an [`Exp`](@ref) schedule for 10 iterations, then repeat from the beginning, and so forth.
```@example complex-schedules
using UnicodePlots

s = Loop(Exp(λ = 0.1, γ = 0.4), 10)
t = 1:25 |> collect
lineplot(t, s.(t); border = :none)
```

Or we can just an arbitrary function to loop (e.g. `log`).
```@example complex-schedules
s = Loop(log, 10)
lineplot(t, s.(t); border = :none)
```

## Sequences of schedules

Finally, we might concatenate sequences of schedules, applying each one for a given length, then switch to the next schedule in the order. A [`Sequence`](@ref) schedule lets us do this. For example, we can start with a triangular schedule, then switch to a more conservative exponential schedule half way through training.
```@example complex-schedules
nepochs = 50
s = Sequence([Triangle(λ0 = 0.0, λ1 = 0.5, period = 5), Exp(λ = 0.5, γ = 0.5)],
             [nepochs ÷ 2, nepochs ÷ 2])

t = 1:nepochs |> collect
lineplot(t, s.(t); border = :none)
```

Alternatively, we might simply wish to manually set the parameter every interval. `Sequence` also accepts a vector of numbers.
```@example complex-schedules
s = Sequence(1e-1 => 5, 5e-2 => 4, 3.4e-3 => 10)
t = 1:20 |> collect
lineplot(t, s.(t); border = :none)
```

`Sequence` also accepts [`Base.Generators`](https://docs.julialang.org/en/v1.7/manual/arrays/#Generator-Expressions).
```@example complex-schedules
s = Sequence(2 / t for t in 1:10)
t = 1:50 |> collect
lineplot(t, s.(t); border = :none)
```
We can also pass a separate generator for `schedules` and `step_sizes`. When only a single generator is passed, `step_sizes` is the iterator that the generator is based on.

Lastly, the schedules in a `Sequence` can use [`Shifted`](@ref) to start at an iteration other than `t = 1`.

## Interpolating schedules

Sometimes, we want to specify a schedule in different units than our iteration state. Below, we'll see two common examples where this might be the case, and how [`Interpolator`](@ref) can make our lives a bit easier.

In our first example, we'll consider a situation where our iteration state is continuous. This is typical in differential equation solvers where we iterate over time (i.e. over `dt, 2dt, 3dt, ...` where `dt` is the solver time step). Conceptually, each step over time should move our schedule forward "by one" (i.e. over iteration states `1, 2, 3, ...`). To move from one iteration scheme to the other, we want to _interpolate_ our time range at a rate of `dt`.
```@example complex-schedules
dt = 1e-3 # simulation time step in seconds
T = 2 # simulate 2 seconds
# our parameter is 1e-2 for the first half of the simulation
# then it drops to 1e-3 for the second half of the simulation
# we interpolate at a rate of dt
s = Interpolator(Sequence(1e-2 => cld(T, dt) / 2, 1e-3 => cld(T, dt) / 2), dt)

# the time range of the simulation in seconds
trange = dt:dt:T |> collect
lineplot(trange, s.(trange); border = :none)
```
Notice that our schedule changes around 1 second (half way through the simulation).

For the second example, we'll look at a machine learning use-case. We want to write our schedule in terms of epochs, but our training loop iterates the scheduler every mini-batch.
```@example complex-schedules
using Flux
using ParameterSchedulers: Scheduler

nepochs = 3
data = [(rand(4, 10), rand([-1, 1], 1, 10)) for _ in 1:3]
m = Chain(Dense(4, 4, tanh), Dense(4, 1, tanh))
p = Flux.params(m)
s = Interpolator(Sequence(1e-2 => 1, Exp(1e-2, 2.0) => 2), length(data))
opt = Scheduler(s, Descent())
for epoch in 1:nepochs
    for (i, (x, y)) in enumerate(data)
        g = Flux.gradient(() -> Flux.mse(m(x), y), p)
        Flux.update!(opt, p, g)
        println("epoch: $epoch, batch: $i, η: $(opt.optim.eta)")
    end
end
```

## Composing schedules

While the functionality above is already quite powerful, we are still limited to constant values for our schedule's fields. Just like we use schedules to adjust our model's hyper-parameters, we might want to use schedules to adjust our schedule's fields! You can do this with [`ComposedSchedule`](@ref).

In fact, many of the cyclic schedules are built on top of this feature. As an exercise, we will build `SinDecay10` which behaves similar to `SinDecay2` but dropping the peak amplitude by a factor of 10 each time.
```@example complex-schedules
function SinDecay10(range, offset, period)
    parameters = (Step(range, 0.1, period), offset, period)
    ComposedSchedule(Sin(range, offset, period), parameters)
end

SinDecay10(0.5, 0.1, 5)
```
We passed `ComposedSchedule` two arguments:
- a schedule whose fields we want to compose
- a tuple that dictates how each field changes

The `parameters` matches the arguments to the `Sin` positional constructor: `(range, offset, period)`. We specified that the range should decay exponentially by a factor of 10 every `period` steps.

By default, `ComposedSchedule` will use the default constructor to create a new instance of the composed schedule. In our example, this corresponds to something like
```julia
ps = map(p -> p(t), composed.parameters)
s = typeof(composed.schedule)(ps...)
```
If this is not going to work for your schedule, then you can use the three argument form: `ComposedSchedule(compose_fn, schedule, parameters)`. `schedule` and `parameters` are the same arguments as before. `compose_fn` is the new argument that is a function of the form `(schedule, parameter_values) -> new_schedule`. Here is an dummy example that works the same as before but illustrates how to use `compose_fn`.
```julia
function SinDecay10(range, offset, period)
    parameters = (Step(range, 0.1, period), offset, period)
    ComposedSchedule(Sin(range, offset, period), parameters) do schedule, parameter_values
        @show schedule
        @show parameter_values
        Sin(parameter_values...)
    end
end
```
