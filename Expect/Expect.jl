module Expect

import Base: convert, isassigned, getindex
export Expected, unexpected

struct Expected{T,E}
    v::Union{T,E}
    ok::Bool
end
convert(::Type{Expected{T,E}}, v::T) where {T, E} = Expected{T, E}(v, true)
convert(::Type{Expected{T,E}}, v::E) where {T, E} = Expected{T, E}(v, false)
convert(::Type{Expected{T,T}}, v::T) where {T}    = Expected{T, T}(v, true)

# `Unexpected` needed to disambiguate when `T == E` and want return an Unexpected
# note, you cannot "expect the unexpected"
struct Unexpected{T}
    v::T
end
unexpected(x) = Unexpected(x)
convert(::Type{Expected{T,E}}, v::Unexpected{E}) where {T, E} = Expected{T, E}(v.v, false)

isassigned(e::Expected) = e.ok
(getindex(e::Expected{T})::T) where {T} = isassigned(e) ? e.v : throw(e.v)

end # module
