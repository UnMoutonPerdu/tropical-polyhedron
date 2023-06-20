"""
    A collection of numerous functions which have been implemented on the basis of LazySets but not used as part of the internship.
"""

"""
NLP Solvers for constraints
"""

function is_nlp_infeasible(status)
    if status == JuMP.LOCALLY_INFEASIBLE || status == JuMP.INFEASIBLE
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
    conflicting_constraints(P::TropicalPolyhedron{T}) where {T<:Real}
A set of constraints are in conflict, if it is not possible to find an element within the described space.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
`true` if there are conflicting constraints, `false` otherwise.
Also returns `false` if the given polyhedron is empty.
"""
function conflicting_constraints(P::TropicalPolyhedron{T}) where {T<:Real}
    if dim(P) >= 1
        return false
    end
    c = [1.0 for _ = 1:size(P.A[1])[1]]
    nlp = nlp_prog(c, P.A, P.B, P.C, P.D)
    return is_nlp_infeasible(nlp.status)
end 

"""
    remove_redundant_constraints(P::TropicalPolyhedron{T}) where {T<:Real}
In a set of constraints, a constraint is said to be redundant if, when we remove it from the space definition,
it is still satisfied.
### Input
- `P`  -- tropical polyhedron in matrix representation
### Output
A copy of the given polyhedron without the redundants constraints if there are. 
"""
function remove_redundant_constraints(P::TropicalPolyhedron{T}) where {T<:Real}
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

"""
    rand(::Type{TropicalPolyhedron{T}}; [T]::Type{<:Real}=Float64, [dim]::Int=2, [spacedim]::Int=2,
         [rng]::AbstractRNG=RandomDevice(), [seed]::Union{Int, Nothing}=nothing)
Create a random polyhedron.
### Input
- `TropicalPolyhedron` -- type for dispatch
- `T`           -- (optional, default: `Float64`) numeric type
- `dim`         -- (optional, default: 2) dimension of the polyhedron
- `spacedim`    -- (optional, default: 2) dimension of the space where the elements are
- `rng`         -- (optional, default: `RandomDevice()`) random number generator
- `seed`        -- (optional, default: `nothing`) seed for reseeding
### Output
A random polyhedron in matrix representation.
"""
function rand(::Type{TropicalPolyhedron}; T::Type{<:Real}=Float64, dim::Int=2, spacedim::Int=2, rng::AbstractRNG=GLOBAL_RNG, seed::Union{Int, Nothing}=nothing)
    rng = Random.seed!(rng, seed)
    randpoly = TropicalPolyhedron{T}()
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