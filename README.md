# Expect

[![Build Status](https://travis-ci.org/KristofferC/Expect.jl.svg?branch=master)](https://travis-ci.org/KristofferC/Expect.jl)


Expect is a Julia implementation of the proposed C++ feature `std::expected`.
The [talk by Andrei Alexandrescu](https://www.youtube.com/watch?v=PH4WBuE1BHI&t=2383s) gives a
good summary of the reasons and is recommended watching.
Note that it is still unknown to the author if this pattern is useful in a dynamically typed language like Julia,
hence this package to try it out.

In short, `std::expected` (in this package exported as `Expected`) is a wrapper
around a value (the good case) or an explanation for why creating that value failed (the bad case).
The wrapped value is accessed using `v[]` which will in the bad case throw.
Functions using `Expected` should annotate the return type of the function as
`::Expected{T, E}` where `T` is the type of the expected value and `E` is the type of the
"unexpected" value (what we want to return in the bad case).
If `T == E` then in the bad case one needs to wrap the return value using `unexpected`.
Automatic conversion from the function return type annotation takes care of the rest.
`isassigned` can be used to see if an `Expected` is in the good case.

Let's say we have some integer division routine that we want to return an error when
we divide by zero (note that Julia already throws an error for this).
We would use `Expect` in the following way:

```jl
using Expect
struct DivideByZeroException <: Exception end

function safe_divide(a::T, b::T)::Expected{T, DivideByZeroException} where {T <: Integer}
    b == 0 && return DivideByZeroException()
    return div(a, b)
end
```

Here is how a caller would use `safe_divide` in the good case:

```jl
julia> v = safe_divide(5, 2)
Expected{Int64,DivideByZeroException}(2, true)

julia> isassigned(v)
true

julia> v[]
2
```

And in the bad case:

```jl
julia> v = safe_divide(5, 0)
Expected{Int64,DivideByZeroException}(DivideByZeroException(), false)

julia> isassigned(v)
false

julia> v[]
ERROR: DivideByZeroException()
...
```

The advantage over just throwing in `safe_divide` is that this gives the caller a chance
to more succintly deal with the error locally (without using try catch).
