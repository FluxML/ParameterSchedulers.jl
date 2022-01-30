# Schedule cheatsheet for other frameworks

If you are coming from PyTorch or Tensorflow, the following table should help you find the corresponding schedule policy in ParameterSchedulers.jl.

!!! note
    PyTorch typically wraps an optimizer as the first argument, but we ignore that functionality in the table. To wrap a Flux.jl optimizer with a schedule from the rightmost column, use [`ParameterSchedules.Scheduler`](#).
    The variable `lr` in the middle/rightmost column refers to the initial learning rate of the optimizer.

| PyTorch                                                                        | Tensorflow                                            | ParameterSchedulers.jl                                |
|:-------------------------------------------------------------------------------|:------------------------------------------------------|:------------------------------------------------------|
| `LambdaLR(_, lr_lambda)`                                                       | N/A                                                   | `lr_lambda`                                           |
| `MultiplicativeLR(_, lr_lambda)`                                               | N/A                                                   | N/A                                                   |
| `StepLR(_, step_size, gamma)`                                                  | `ExponentialDecay(lr, step_size, gamma, True)`        | `Step(lr, gamma, step_size)`                          |
| `MultiStepLR(_, milestones, gamma)`                                            | N/A                                                   | `Step(lr, gamma, milestones)`                         |
| `ConstantLR(_, factor, total_iters)`                                           | N/A                                                   | `Sequence(lr * factor => total_iters, lr => nepochs)` |
| `LinearLR(_, start_factor, end_factor, total_iters)`                           | N/A                                                   | `Sequence(Triangle(lr * start_factor, lr * end_factor, 2 * total_iters) => total_iters, lr => nepochs)` |
| `ExponentialLR(_, gamma)`                                                      | `ExponentialDecay(lr, 1, gamma, False)`               | `Exp(lr, gamma)`                                      |
| N/A                                                                            | `ExponentialDecay(lr, steps, gamma, False)`           | `Interpolator(Exp(lr, gamma), steps)`                 |
| `CosineAnnealingLR(_, T_max, eta_min)`                                         | `CosineDecay(lr, T_max, eta_min)`                     | `CosAnneal(lr, eta_min, T_0, false)`                  |
| `CosineAnnealingRestarts(_, T_0, 1, eta_min)`                                  | `CosineDecayRestarts(lr, T_0, 1, 1, eta_min)`         | `CosAnneal(lr, eta_min, T_0)`                         |
| `CosineAnnealingRestarts(_, T_0, T_mult, eta_min)`                             | `CosineDecayRestarts(lr, T_0, T_mult, 1, alpha)`      | See [below](# "Cosine annealing variants")            |
| N/A                                                                            | `CosineDecayRestarts(lr, T_0, T_mult, m_mul, alpha)`  | See [below](# "Cosine annealing variants")            |
| `SequentialLR(_, schedulers, milestones)`                                      | N/A                                                   | `Sequence(schedulers, milestones)`                    |
| `ReduceLROnPlateau(_, mode, factor, patience, threshold, 'abs', 0)`            | N/A                                                   | See [below](# "`ReduceLROnPlateau` style schedules")  |
| `CyclicLR(_, base_lr, max_lr, step_size, step_size, 'triangular', _, None)`    | N/A                                                   | `Triangle(base_lr, max_lr, step_size)`                |
| `CyclicLR(_, base_lr, max_lr, step_size, step_size, 'triangular2', _, None)`   | N/A                                                   | `TriangleDecay2(base_lr, max_lr, step_size)`          |
| `CyclicLR(_, base_lr, max_lr, step_size, step_size, 'exp_range', gamma, None)` | N/A                                                   | `TriangleExp(base_lr, max_lr, step_size, gamma)`      |
| `CyclicLR(_, base_lr, max_lr, step_size, step_size, _, _, scale_fn)`           | N/A                                                   | See [Arbitrary looping schedules](#)                  |
| N/A                                                                            | `InverseTimeDecay(lr, 1, decay_rate, False)`          | `Inv(lr, decay_rate, 1)`                              |
| N/A                                                                            | `InverseTimeDecay(lr, decay_step, decay_rate, False)` | `Interpolator(Inv(lr, decay_rate, 1), decay_step)`    |
| N/A                                                                            | `PolynomialDecay(lr, decay_steps, 0, power, False)`   | `Poly(lr, power, decay_steps)`                        |

## Cosine annealing variants

In addition to the plain cosine annealing w/ warm restarts schedule, we may want to decay the peak learning rate or increase the period. Both can be done using [`ComposedSchedule`](#).

Let's start with the simpler task: decaying the learning rate.
```julia
# decay learning rate by m_mul
s = ComposedSchedule(CosAnneal(range, offset, period),
                     (Step(range, m_mul, period), offset, period))
```



## `ReduceLROnPlateau` style schedules

Unlike PyTorch, ParameterSchedulers.jl doesn't create a monolithic schedule to control dynamic schedules. Instead, [`ParameterSchedulers.Stateful`](#) has an `advance` keyword argument that can allow for arbitrary advancement of schedules based on a predicate function. When combined with `Flux.plateau` as the predicate, we get `ReduceLROnPlateau`.
```julia
# the code below is written to match
# ReduceLROnPlateau(_, 'max', factor, patience, threshold, 'abs', 0)
# we also assume accuracy_func() is an accuracy metric that's already given for our model

# this is done to match ReduceLROnPlateau
# but it could be any schedule
s = Exp(lr, factor)
predicate = Flux.plateau(accuracy_func, patience; min_dist = threshold)
ParameterSchedulers.Stateful(s; advance = predicate)
```
Using this approach, we can be more flexible than PyTorch. You can use any schedule (not just exponential decay) and arbitrary predicates. Make sure to check out the [Flux docmentation on "patience helpers"](https://fluxml.ai/Flux.jl/stable/utilities/#Patience-Helpers) for more ways to customize the predicate (e.g. the `'min'` mode for `ReduceLROnPlateau`).
