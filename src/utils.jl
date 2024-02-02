"""
    reverse(f, period)

Return a reverse function such that `reverse(f, period)(t) == f(period - t)`.
"""
reverse(f, period) = t -> f(period - t)

"""
    symmetric(f, period)

Return a symmetric function such that for `t ∈ [1, period / 2)`,
the symmetric function evaluates to `f(t)`, and when `t ∈ [period / 2, period)`,
the symmetric functions evaluates to `f(period - t)`.
"""
symmetric(f, period) = t -> (t < period / 2) ? f(t) : f(period - t)

# Iterators.peel used to throw a BoundsError
# ref: https://github.com/JuliaLang/julia/pull/39607
if VERSION >= v"1.7"
    _peel(itr) = Iterators.peel(itr)
else
    function _peel(itr)
        try
            return Iterators.peel(itr)
        catch e
            if e isa BoundsError
                return nothing
            else
                rethrow(e)
            end
        end
    end
end
