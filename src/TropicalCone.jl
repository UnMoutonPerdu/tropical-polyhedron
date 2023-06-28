import Base, Random, JuMP, Ipopt
using Random: AbstractRNG, GLOBAL_RNG
using JuMP, Ipopt

"""
    TropicalCone{T<:Real} 
Type that represents a tropical cone by external representation (refer to README). 
### Fields
- `A` -- vector of vector of weights on the "smaller than" side.
- `C` -- vector of vector of coefficients on the "greater than" side.
"""
struct TropicalCone{T<:Real}
    A::Vector{Vector{T}}
    B::Vector{Vector{T}}

    function TropicalCone(A::Vector{Vector{T}}, B::Vector{Vector{T}}) where {T<:Real}
        return new{T}(A, B)
    end

    function TropicalCone{T}() where (T<:Real)
        return new{T}(Vector{Vector{T}}([]), Vector{Vector{T}}([]))
    end

    function TropicalCone()
        return TropicalCone{Float64}()
    end
end

"""
TROPICAL OPERATORS
"""

"""
    tropical_sum(x::Vector{T}, y::Vector{T}) where {T<:Real}
Definition of the tropical addition operator.
### Input
- `x`  -- a vector of elements of type T
- `y` -- a vector of elements of type T
"""
function tropical_sum(x::Vector{T}, y::Vector{T}) where {T<:Real}
    if size(x)[1] != size(y)[1]
        error("Vectors must have the same size : $(size(x)[1]) != $(size(y)[1])")
    end
    return [max(x[i], y[i]) for i = 1:size(x)[1]]
end

"""
    tropical_sum(x::Vector{T}, y::T) where {T<:Real}
Definition of the tropical addition operator.
### Input
- `x`  -- a vector of elements of type T
- `y` -- an element of type T
"""
function tropical_sum(x::Vector{T}, y::T) where {T<:Real}
    return [max(x[i], y) for i = 1:size(x)[1]]
end

"""
    tropical_product(x::Vector{T}, y::Vector{T}) where {T<:Real}
Definition of the tropical product operator.
### Input
- `x`  -- a vector of elements of type T
- `y` -- a vector of elements of type T
"""
function tropical_product(x::Vector{T}, y::Vector{T}) where {T<:Real}
    if size(x)[1] != size(y)[1]
        error("Vectors must have the same size : $(size(x)[1]) != $(size(y)[1])")
    end
    return return [(x[i] + y[i]) for i = 1:size(x)[1]]
end

"""
    tropical_product(x::Vector{T}, y::T) where {T<:Real}
Definition of the tropical product operator.
### Input
- `x`  -- a vector of elements of type T
- `y` -- an element of type T
"""
function tropical_product(x::Vector{T}, y::T) where {T<:Real}
    return return [(x[i] + y) for i = 1:size(x)[1]]
end

"""
    Base.:(==)(P::TropicalPolyhedron{T}, Q::TropicalPolyhedron{T}) where {T<:Real} 
Overriding of the (==) operator for two elements of type `TropicalPolyhedron`. 
Two tropical polyhedrons are equal if their list of constraints is the same.
"""
Base.:(==)(P::TropicalCone{T}, Q::TropicalCone{T}) where {T<:Real} = (P.A == Q.A) && (P.B == Q.B)

"""
    constraints_list(C::TropicalCone{T}) where {T<:Real}
### Input
- `C`  -- a tropical cone.
### Output
The component matrices of the cone.
"""
function constraints_list(C::TropicalCone{T}) where {T<:Real}
    return C.A, C.B
end

"""
    dim(C::TropicalCone{T}) where {T<:Real}
Return the dimension of a tropical cone which corresponds to the number of constraints.
### Input
- `C`  -- a tropical cone.
"""
function dim(C::TropicalCone{T}) where {T<:Real}
    return size(C.A)[1]
end

"""
    constrained_dimensions(C::TropicalCone{T}) where {T<:Real}
Return the dimension of the space where the constrained elements are.
### Input
- `C`  -- a tropical cone.
### Output
Returns `-1` if there is no constraint.
"""
function constrained_dimensions(C::TropicalCone{T}) where {T<:Real} 
    size_vector = 0
    try 
        size_vector = size(C.A[1])[1]
    catch 
        size_vector = -1
    end
    return size_vector
end

"""
    add_constraint!(C::TropicalCone{T}, a::Vector{T}, b::Vector{T}) where {T<:Real}
Add a constraint to a given tropical cone.
### Input
- `C`  -- a tropical cone.
- `a`  -- vector of the weights of the new constraint on the "smaller than" side
- `b`  -- vector of the weights of the new constraint on the "greater than" side
"""
function add_constraint!(C::TropicalCone{T}, a::Vector{T}, b::Vector{T}) where {T<:Real}
    if dim(C) > 0 && length(a) != constrained_dimensions(C)
        error("new constraint should have the same number of coefficients that the current constraints")
    else 
        push!(C.A, a)
        push!(C.B, b)
    end
end

"""
    remove_constraint!(C::TropicalCone{T}, index::Int64) where {T<:Real}
Remove a constraint from a cone. 
### Input
- `C`  -- a tropical cone.
- `index` -- position of the constraint in the matrix representation.
### Output
The cone without the given constraint.
"""
function remove_constraint!(C::TropicalCone{T}, index::Int64) where {T<:Real}
    if index <= dim(C)[1]
        deleteat!(C.A, index)
        deleteat!(C.B, index)
    end
end



function compute_extreme(C::TropicalCone{T}, cone_dim::Int64, space_dim::Int64) where {T<:Real}
    if cone_dim == 0
        extreme = Vector{Vector{T}}([])
        for i = 1:space_dim
            e = Vector([T(-Inf) for _ in 1:space_dim])
            e[i] = T(0)
            push!(extreme, e)
        end

        return extreme
    else
        G = compute_extreme(C, cone_dim-1, space_dim)
        println("G : ", G)
        Gleq = Vector{Vector{T}}([])
        Gs = Vector{Vector{T}}([])
        for g in G
            if tropical_product(C.A[cone_dim], g) <= tropical_product(C.B[cone_dim], g)
                push!(Gleq, g)
            else
                push!(Gs, g)
            end
        end
        H = deepcopy(Gleq)

        println("a : ", C.A[cone_dim])
        println("b : ", C.B[cone_dim])
        println("H : ", H)
        println("Gleq : ", Gleq)
        println("Gs : ", Gs)

        for gleq in Gleq 
            for gs in Gs 
                h = tropical_sum(tropical_product(tropical_product(C.A[cone_dim], gs), gleq), tropical_product(tropical_product(C.B[cone_dim], gleq), gs))
                if is_extreme(h)
                    first_non_zero = T(-Inf)
                    for elem in h
                        if elem != T(-Inf)
                            first_non_zero = -elem
                            break
                        end
                    end
                    push!(H, tropical_product(h, first_non_zero))
                end
            end
        end

        return H
    end
end

function is_extreme(elem::Vector{T}) where {T<:Real}
    return true
end