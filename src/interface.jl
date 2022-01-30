"""
    AbstractSchedule{IsFinite}

Inherit from this type to create a custom schedule.
Type parameter `IsFinite` can take three values:
- `true`: for finite schedules
- `false`: for infinite schedules
- `missing`: for higher-order schedules where the length is unknown
             (similar to `Base.SizeUnknown()`)
- `T`: a type `T` that indicates all iterator interface functions
       should forward to this type

Read the [generic interface](#) docs section for more.
"""
abstract type AbstractSchedule{IsFinite} end

Base.IteratorSize(::Type{<:AbstractSchedule{true}}) = Base.HasLength()
Base.IteratorSize(::Type{<:AbstractSchedule{false}}) = Base.IsInfinite()
Base.IteratorSize(::Type{<:AbstractSchedule{missing}}) = Base.SizeUnknown()
Base.IteratorSize(::Type{<:AbstractSchedule{T}}) where T = Base.IteratorSize(T)

Base.axes(::AbstractSchedule{false}) = (OneToInf(),)
Base.axes(s::AbstractSchedule{true}) = 1:length(s)
Base.axes(::AbstractSchedule{missing}) = (OneToInf(),)

Base.iterate(schedule::AbstractSchedule, t = 1) = schedule(t), t + 1
