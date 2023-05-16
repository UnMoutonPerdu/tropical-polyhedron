import Base, Random, JuMP, Ipopt
using Random: AbstractRNG, GLOBAL_RNG
using JuMP, Ipopt

#TODO Add the export part


"""
    TropicalPolyhedron{T<:Real} 
Type that represents a tropical polyhedron in matrix representation, that is,
a finite intersection of tropical half-spaces defined as the classical ones but in 
a tropical algebra. 
### Fields
- `A` -- Vector of vector of weights on the "smaller than" side.
- `B` -- Vector of bias on the "smaller than" side.
- `C` -- Vector of vector of coefficients on the "greater than" side.
- `D` -- Vector of bias on the "greater than" side.
"""
struct TropicalPolyhedron{T<:Real}
    A::Vector{Vector{T}}
    B::Vector{T}
    C::Vector{Vector{T}}
    D::Vector{T}

    function TropicalPolyhedron(A::Vector{Vector{T}}, B::Vector{T}, C::Vector{Vector{T}}, D::Vector{T}) where {T<:Real}
        return new{T}(A, B, C, D)
    end

    function TropicalPolyhedron{T}() where (T<:Real)
        return new{T}(Vector{Vector{T}}([]), Vector{T}([]), Vector{Vector{T}}([]), Vector{T}([]))
    end

    function TropicalPolyhedron()
        return TropicalPolyhedron{Float64}()
    end
end

# Convenience type 
const TPoly{T} = TropicalPolyhedron{T}

"""
    dim(P::TPoly{T}) where {T<:Real}
Return the dimension of a tropical polyhedron in matrix representation.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
The dimension of the tropical polyhedron given as the pair ``(n, m)`` where n is the number of half-spaces 
characterising the set, and m is the size of the elements included in the polyhedron.
If their are no constraints in the defintion of the polyhedron, ``m`` is set to ``0``.
"""
function dim(P::TPoly{T}) where {T<:Real}
    dim_poly = size(P.A)[1]
    size_vector = 0
    try 
        size_vector = size(P.A[1])[1]
    catch 
        size_vector = 0
    end
    return dim_poly, size_vector
end

"""
    is_empty(P::TPoly{T}) where {T<:Real}   
A tropical polyhedron is considered as empty if there is no constraint in its definition
or if it's impossible to find an element in the space describing by the polyhedron.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
``true`` if the tropical polyhedron is empty, ``false`` otherwise.
"""
function is_empty(P::TPoly{T}) where {T<:Real}
    return dim(P)[1] > 0 ? conflicting_constraints(P) : true
end

"""
    add_constraint!(P::TPoly{T}, a::Vector{T}, b::T, c::Vector{T}, d::T) where {T<:Real}
Add a constraint to a polyhedron. The constraint as given as 4 separated vectors.
### Input
- `P`  -- tropical polyhedron in matrix representation
- `a`  -- vector of the weights of the new constraint on the "smaller than" side
- `b`  -- bias of the new constraint on the "smaller than" side
- `c`  -- vector of the weights of the new constraint on the "greater than" side
- `d`  -- bias of the new constraint on the "greater than" side
### Output
The modified polyhedron.
"""
function add_constraint!(P::TPoly{T}, a::Vector{T}, b::T, c::Vector{T}, d::T) where {T<:Real}
    if !is_empty(P) && length(a) != length(P.A[1])
        error("new constraint should have the same number of coefficients that the current constraints")
    else 
        push!(P.A, a)
        push!(P.B, b)
        push!(P.C, c)
        push!(P.D, d)
    end
end

"""
    remove_constraint!(P::TPoly{T}, index::Int) where {T<:Real}
Remove a constraint from a polyhedron. 
### Input
- `P`  -- tropical polyhedron in matrix representation
- `index` -- position of the constraint in the matrix representation
### Output
The polyhedron without the given constraint.
"""
function remove_constraint!(P::TPoly{T}, index::Int) where {T<:Real}
    if index <= dim(P)[1]
        deleteat!(P.A, index)
        deleteat!(P.B, index)
        deleteat!(P.C, index)
        deleteat!(P.D, index)
    end
end

"""
    constraints_list(P::TPoly{T}) where {T<:Real}
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
The component matrices of the polyhedron.
"""
function constraints_list(P::TPoly{T}) where {T<:Real}
    return P.A, P.B, P.C, P.D
end

"""
    rand(::Type{TPoly{T}}; [T]::Type{<:Real}=Float64, [dim]::Int=2, [spacedim]::Int=2,
         [rng]::AbstractRNG=RandomDevice(), [seed]::Union{Int, Nothing}=nothing)
Create a random polyhedron.
### Input
- `TPoly` -- type for dispatch
- `T`           -- (optional, default: `Float64`) numeric type
- `dim`         -- (optional, default: 2) dimension of the polyhedron
- `spacedim`    -- (optional, default: 2) dimension of the space where the elements are
- `rng`         -- (optional, default: `RandomDevice()`) random number generator
- `seed`        -- (optional, default: `nothing`) seed for reseeding
### Output
A random polyhedron in matrix representation.
"""
function rand(::Type{TPoly}; T::Type{<:Real}=Float64, dim::Int=2, spacedim::Int=2, rng::AbstractRNG=GLOBAL_RNG, seed::Union{Int, Nothing}=nothing)
    rng = Random.seed!(rng, seed)
    randpoly = TPoly{T}()
    for _ in 1:dim
        a = Vector{T}([])
        c = Vector{T}([])
        for _ in 1:spacedim
            push!(a, Random.rand(rng, T))
            push!(c, Random.rand(rng, T))
        end
        add_constraint!(randpoly, a, Random.rand(rng, T), c, Random.rand(rng, T))
    end
    return randpoly
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
### Output
The vector of results of the operation element by element.
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
### Output
The vector of results of the operation element by element.
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
### Output
The vector of results of the operation element by element.
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
### Output
The vector of results of the operation element by element.
"""
function tropical_product(x::Vector{T}, y::T) where {T<:Real}
    return return [(x[i] + y) for i = 1:size(x)[1]]
end

Base.:(==)(P::TPoly{T}, Q::TPoly{T}) where {T<:Real} = (P.A == Q.A) && (P.B == Q.B) && (P.C == Q.C) && (P.D == Q.D)





"""
SET OPERATIONS
"""

"""
    copy(P::TPoly{T}) where {T<:Real}
Make a copy of a tropical polyhedron, independent of it.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
The copy of the polyhedron.
"""
function copy(P::TPoly{T}) where {T<:Real}
    Z = TropicalPolyhedron()
    for i = 1:dim(P)[1]
        add_constraint!(Z, P.A[i], P.B[i], P.C[i], P.D[i])
    end
    return Z
end

"""
    intersection(P::TPoly{T}, Q::TPoly{T}) where {T<:Real}
Computes the intersection of 2 tropical polyhedrons. The function firstly
concatenates the vectors of the representation, and then removes the redundant 
constraints.
### Input
- `P`  -- tropical polyhedron in matrix representation
- `Q`  -- tropical polyhedron in matrix representation
### Output
The intersection of the two polyhedrons.
"""
function intersection(P::TPoly{T}, Q::TPoly{T}) where {T<:Real}
    if dim(P)[2] != dim(Q)[2]
        error("Constraints should be the same dimension")
    end

    Z = copy(P)
    for i = 1:dim(Q)[1]
        add_constraint!(Z, Q.A[i], Q.B[i], Q.C[i], Q.D[i])
    end

    remove_redundant_constraints(Z)

    return Z
end

"""
NLP Solvers for constraints
"""

function is_nlp_infeasible(status)
    if status == JuMP.LOCALLY_INFEASIBLE 
        return true
    end
    return status == JuMP.INFEASIBLE_OR_UNBOUNDED
end

function is_nlp_optimal(status)
    if status == JuMP.OPTIMAL || status == JuMP.LOCALLY_SOLVED
        return true
    end
    return false 
end

function nlp_prog(c, A, B, C, D, solver=Ipopt.Optimizer, silent::Bool=true)
    size_vector = size(A[1])[1]
    dim_poly = size(A)[1]
    model = Model(solver)
    if silent 
        set_silent(model)
    end 
    @variable(model, x[1:size_vector])
    @NLobjective(model, Min, sum(c[i]*x[i] for i = 1:size_vector))      
    for i = 1:dim_poly
        @NLconstraint(model, max(maximum(x[j]+A[i][j] for j = 1:size_vector), B[i]) <= max(maximum(x[j]+C[i][j] for j = 1:size_vector), D[i]))
    end
    optimize!(model)
    return (status = termination_status(model),
            objval = objective_value(model),
            sol    = value.(x),
            model  = model)
end

function nlp_prog(c, d, A, B, C, D, solver=Ipopt.Optimizer, silent::Bool=true)
    size_vector = size(A[1])[1]
    dim_poly = size(A)[1]
    model = Model(solver)
    if silent 
        set_silent(model)
    end 
    @variable(model, x[1:size_vector])
    @NLobjective(model, Min, max(maximum(c[1][i]+x[i] for i = 1:size_vector),d[1]))    
    @NLconstraint(model, [i=1:size_vector], 5 <= x[i] <= 5)
    for i = 1:dim_poly
        @NLconstraint(model, max(maximum(x[j]+A[i][j] for j = 1:size_vector), B[i]) <= max(maximum(x[j]+C[i][j] for j = 1:size_vector), D[i]))
    end
    optimize!(model)
    return (status = termination_status(model),
            objval = objective_value(model),
            sol    = value.(x),
            model  = model)
end

"""
FUNCTIONS ON CONSTRAINTS
"""

"""
    conflicting_constraints(P::TPoly{T}) where {T<:Real}
A set of constraints are in conflict, if it is not possible to find an element within the described space.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
`true` if there are conflicting constraints, `false` otherwise.
Also returns `false` if the given polyhedron is empty.
"""
function conflicting_constraints(P::TPoly{T}) where {T<:Real}
    if dim(P)[1] == 0
        return false
    end
    c = [1.0 for _ = 1:size(P.A[1])[1]]
    nlp = nlp_prog(c, P.A, P.B, P.C, P.D)
    return is_nlp_infeasible(nlp.status)
end 

"""
    remove_redundant_constraints(P::TPoly{T}) where {T<:Real}
In a set of constraints, a constraint is said to be redundant if, when we remove it from the space definition,
it is still satisfied.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
A copy of the given polyhedron without the redundants constraints if there are. 
"""
function remove_redundant_constraints(P::TPoly{T}) where {T<:Real}
    Pcop = copy(P)
    if is_empty(Pcop)
        return Pcop
    end 
    A, B, C, D = constraints_list(Pcop)
    dim_poly, size_vector = dim(Pcop)
    if dim_poly == 1 || size_vector == 0 
        return Pcop
    end
    non_redundant_indices = 1:dim_poly

    for j = 1:dim_poly
        constraint_indices = setdiff(non_redundant_indices, j)
        if length(constraint_indices) == 0
            break
        end
        α = A[j, :]
        β = B[j]
        Ar = A[constraint_indices, :]
        Br = B[constraint_indices]
        Cr = C[constraint_indices, :]
        Dr = D[constraint_indices]
        nlp = nlp_prog(α, β, Ar, Br, Cr, Dr)
        if is_nlp_infeasible(nlp.status)
            return Pcop
        elseif is_nlp_optimal(nlp.status)
            objval = nlp.objval
            sol = nlp.sol
            if objval <= max(maximum(C[j][i]+sol[i] for i = 1:size_vector), D[j])
                # the constraint is redundant
                non_redundant_indices = setdiff(non_redundant_indices, j)
            end
        else
            println(nlp.sol)
            error("LP is not optimal; the status of the LP is $(nlp.status)")
        end
    end
    for i = non_redundant_indices
        remove_constraint!(Pcop, i)    
    end
    return Pcop
end