{cell=getting-started, display=false, output=false, results=false}
```julia
using ParameterSchedulers
```

# Getting started

All schedules types in ParameterSchedulers.jl behave as indexable iterators. For example, we can index the simple exponential decay schedule ([`Exp`](#)) below:
{cell=getting-started}
```julia
s = Exp(λ = 0.1, γ = 0.8)
println("s[1]: $(s[1])")
println("s[5]: $(s[5])")
```
!!! info
    The indices are unitless. So, if you index a schedule every epoch, then the `s[i]` is parameter value at epoch `i`.

We can also use the schedule in an iterable context like a `for`-loop:
{cell=getting-started}
```julia
for (i, param) in enumerate(s)
    (i > 10) && break
    println("s[$i]: $param")
end
```
!!! warning
    Many schedules such as `Exp` are infinite iterators, so iterating over them will result in an infinite loop. You can use [`Base.IteratorSize`](https://docs.julialang.org/en/v1/base/collections/#Base.IteratorSize) to check if a schedule has infinite length.

Notice that the value of `s[1]` and `s[5]` is unchanged even though we accessed the schedule once via `getindex` and again in the `for`-loop. This is because all schedules in ParameterSchedulers.jl are *immutable*. If you want a stateful schedule, then you can use [`ScheduleIterator`](#):
{cell=getting-started}
```julia
stateful_s = ScheduleIterator(s)
println("s: $(next!(stateful_s))")
println("s: $(next!(stateful_s))")
println(stateful_s)
```
We used [`next!`](#) to advance the stateful iterator. Notice that `stateful_s` stores a reference to `s` and the current iteration state (which is `3` since we advanced the iterator twice). Also note that `ScheduleIterator` cannot be indexed (or iterated with `Base.iterate`):
{cell=getting-started}
```julia
try stateful_s[1]
catch e
    println(e)
end
```