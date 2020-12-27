# Generic interface

All schedules must inherit from [`AbstractSchedule`](#). Any concrete subtype must implement the [iteration interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration) and [`Base.getindex`](https://docs.julialang.org/en/v1/manual/interfaces/#Indexing). Below we reimplment [`Lambda`](#) to illustrate what is required for another generic custom schedule.

To avoid a name conflict, we will call our custom schedule `FooSchedule`. Let's start with defining the struct.
{cell=generic-interface}
```julia
using ParameterSchedulers

struct FooSchedule{T} <: ParameterSchedulers.AbstractSchedule
    f::T
end
```

Next we implement the necessart interfaces. The easiest implementation to define `Base.getindex`, then rely on that to define the iteration behavior.
{cell=generic-interface}
```julia
Base.getindex(schedule::FooSchedule, t::Integer) = schedule.f(t)

Base.iterate(schedule::FooSchedule, t = 1) = (schedule[t], t + 1)
```

!!! info
    By default, `Base.firstindex(s::AbstractSchedule) == 1`. This behavior is expected across ParameterSchedulers.jl, so your definition of `Base.getindex` should conform to that.

!!! tip
    Sometimes, it might be more efficient to define `Base.iterate` separately from `Base.getindex`. See [`Step`](#) for an example what this might look like.

Apart to the behavioral methods, there are some additional functions in the iteration interface left to define.
{cell=generic-interface}
```julia
Base.IteratorEltype(::Type{<:FooSchedule}) = Base.EltypeUnknown()
Base.IteratorSize(::Type{<:FooSchedule}) = Base.SizeUnkown()
```
In this case, the element type and length of the iterator is unknown, since `f` is unknown. But you can define more restricted return values for your iterator.

Once you are done defining the above interfaces, you can start using `FooSchedule` like any other schedule. For example, below we create a [`Loop`](#) where the interval is defined as a `FooSchedule`
{cell=generic-interface}
```julia
using UnicodePlots

s = Loop(f = FooSchedule(log), period = 4)
t = 1:10 |> collect
lineplot(t, map(t -> s[t], t); border = :none)
```