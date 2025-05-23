# This file is a part of Julia. License is MIT: https://julialang.org/license

import Core: Bool

# promote Bool to any other numeric type
promote_rule(::Type{Bool}, ::Type{T}) where {T<:Number} = T

typemin(::Type{Bool}) = false
typemax(::Type{Bool}) = true

## boolean operations ##

"""
    !(x)

Boolean not. Implements [three-valued logic](https://en.wikipedia.org/wiki/Three-valued_logic),
returning [`missing`](@ref) if `x` is `missing`.

See also [`~`](@ref) for bitwise not.

# Examples
```jldoctest
julia> !true
false

julia> !false
true

julia> !missing
missing

julia> .![true false true]
1×3 BitMatrix:
 0  1  0
```
"""
!(x::Bool) = not_int(x)

(~)(x::Bool) = !x
(&)(x::Bool, y::Bool) = and_int(x, y)
(|)(x::Bool, y::Bool) = or_int(x, y)

"""
    xor(x, y)
    ⊻(x, y)

Bitwise exclusive or of `x` and `y`. Implements
[three-valued logic](https://en.wikipedia.org/wiki/Three-valued_logic),
returning [`missing`](@ref) if one of the arguments is `missing`.

The infix operation `a ⊻ b` is a synonym for `xor(a,b)`, and
`⊻` can be typed by tab-completing `\\xor` or `\\veebar` in the Julia REPL.

# Examples
```jldoctest
julia> xor(true, false)
true

julia> xor(true, true)
false

julia> xor(true, missing)
missing

julia> false ⊻ false
false

julia> [true; true; false] .⊻ [true; false; false]
3-element BitVector:
 0
 1
 0
```
"""
xor(x::Bool, y::Bool) = (x != y)

"""
    nand(x, y)
    ⊼(x, y)

Bitwise nand (not and) of `x` and `y`. Implements
[three-valued logic](https://en.wikipedia.org/wiki/Three-valued_logic),
returning [`missing`](@ref) if one of the arguments is `missing`.

The infix operation `a ⊼ b` is a synonym for `nand(a,b)`, and
`⊼` can be typed by tab-completing `\\nand` or `\\barwedge` in the Julia REPL.

# Examples
```jldoctest
julia> nand(true, false)
true

julia> nand(true, true)
false

julia> nand(true, missing)
missing

julia> false ⊼ false
true

julia> [true; true; false] .⊼ [true; false; false]
3-element BitVector:
 0
 1
 1
```
"""
nand(x...) = ~(&)(x...)

"""
    nor(x, y)
    ⊽(x, y)

Bitwise nor (not or) of `x` and `y`. Implements
[three-valued logic](https://en.wikipedia.org/wiki/Three-valued_logic),
returning [`missing`](@ref) if one of the arguments is `missing` and the
other is not `true`.

The infix operation `a ⊽ b` is a synonym for `nor(a,b)`, and
`⊽` can be typed by tab-completing `\\nor` or `\\barvee` in the Julia REPL.

# Examples
```jldoctest
julia> nor(true, false)
false

julia> nor(true, true)
false

julia> nor(true, missing)
false

julia> false ⊽ false
true

julia> false ⊽ missing
missing

julia> [true; true; false] .⊽ [true; false; false]
3-element BitVector:
 0
 0
 1
```
"""
nor(x...) = ~(|)(x...)

>>(x::Bool, c::UInt) = Int(x) >> c
<<(x::Bool, c::UInt) = Int(x) << c
>>>(x::Bool, c::UInt) = Int(x) >>> c

signbit(x::Bool) = false
sign(x::Bool) = x
abs(x::Bool) = x
abs2(x::Bool) = x
iszero(x::Bool) = !x
isone(x::Bool) = x

<(x::Bool, y::Bool) = y&!x
<=(x::Bool, y::Bool) = y|!x

## do arithmetic as Int ##

+(x::Bool) =  Int(x)
-(x::Bool) = -Int(x)

+(x::Bool, y::Bool) = Int(x) + Int(y)
-(x::Bool, y::Bool) = Int(x) - Int(y)
*(x::Bool, y::Bool) = x & y
^(x::Bool, y::Bool) = x | !y
^(x::Integer, y::Bool) = ifelse(y, x, one(x))

# preserve -0.0 in `false + -0.0`
function +(x::Bool, y::T)::promote_type(Bool,T) where T<:AbstractFloat
    return ifelse(x, oneunit(y) + y, y)
end
+(y::AbstractFloat, x::Bool) = x + y

# make `false` a "strong zero": false*NaN == 0.0
function *(x::Bool, y::T)::promote_type(Bool,T) where T<:AbstractFloat
    return ifelse(x, y, copysign(zero(y), y))
end
*(y::AbstractFloat, x::Bool) = x * y

div(x::Bool, y::Bool) = y ? x : throw(DivideError())
rem(x::Bool, y::Bool) = y ? false : throw(DivideError())
mod(x::Bool, y::Bool) = rem(x,y)

Bool(x::Real) = x==0 ? false : x==1 ? true : throw(InexactError(:Bool, Bool, x))
