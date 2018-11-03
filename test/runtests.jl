using Expect
using Test

function relative(a::Float64, b::Float64)::Expected{Float64, ErrorException}
    if a == 0
        return ErrorException("cannot compute relative to 0")
    else
        return (b-a) / a
    end
end

x = relative(3.0, 2.0)
@test isassigned(x)
@test x[] == (2.0 - 3.0) / 3.0
@inferred x[]
y = relative(0.0, 2.0)
@test !isassigned(y)
@test_throws ErrorException y[]

function good_int_or_bad_int(a)::Expected{Int, Int}
    if a < 3
        return a
    else
        return unexpected(a)
    end
end

z = good_int_or_bad_int(1)
@test isassigned(z)
q = good_int_or_bad_int(4)
@test !isassigned(q)
@test_throws 4 q[]
