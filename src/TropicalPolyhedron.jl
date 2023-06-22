import Base, Random, JuMP, Ipopt
using Random: AbstractRNG, GLOBAL_RNG
using JuMP, Ipopt

#TODO Add the export part


"""
    TropicalPolyhedron{T<:Real} 
Type that represents a tropical polyhedron by external representation (refer to README). 
### Fields
- `A` -- vector of vector of weights on the "smaller than" side.
- `B` -- vector of bias on the "smaller than" side.
- `C` -- vector of vector of coefficients on the "greater than" side.
- `D` -- vector of bias on the "greater than" side.
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
Base.:(==)(P::TropicalPolyhedron{T}, Q::TropicalPolyhedron{T}) where {T<:Real} = (P.A == Q.A) && (P.B == Q.B) && (P.C == Q.C) && (P.D == Q.D)

"""
FUNCTIONS
"""

"""
    dim(P::TropicalPolyhedron{T}) where {T<:Real}
Return the dimension of a tropical polyhedron which corresponds to the number of constraints.
### Input
- `P`  -- a tropical polyhedron.
"""
function dim(P::TropicalPolyhedron{T}) where {T<:Real}
    return size(P.A)[1]
end

"""
    constrained_dimensions(P::TropicalPolyhedron{T}) where {T<:Real}
Return the dimension of the space where the constrained elements are.
### Input
- `P`  -- a tropical polyhedron.
### Output
Returns `-1` if there are no constraints.
"""
function constrained_dimensions(P::TropicalPolyhedron{T}) where {T<:Real} 
    size_vector = 0
    try 
        size_vector = size(P.A[1])[1]
    catch 
        size_vector = -1
    end
    return size_vector
end

"""
    constraints_list(P::TropicalPolyhedron{T}) where {T<:Real}
### Input
- `P`  -- a tropical polyhedron.
### Output
The component matrices of the polyhedron.
"""
function constraints_list(P::TropicalPolyhedron{T}) where {T<:Real}
    return P.A, P.B, P.C, P.D
end

"""
    add_constraint!(P::TropicalPolyhedron{T}, a::Vector{T}, b::T, c::Vector{T}, d::T) where {T<:Real}
Add a constraint to a given polyhedron.
### Input
- `P`  -- a tropical polyhedron.
- `a`  -- vector of the weights of the new constraint on the "smaller than" side
- `b`  -- bias of the new constraint on the "smaller than" side
- `c`  -- vector of the weights of the new constraint on the "greater than" side
- `d`  -- bias of the new constraint on the "greater than" side
"""
function add_constraint!(P::TropicalPolyhedron{T}, a::Vector{T}, b::T, c::Vector{T}, d::T) where {T<:Real}
    if dim(P) > 0 && length(a) != constrained_dimensions(P)
        error("new constraint should have the same number of coefficients that the current constraints")
    else 
        push!(P.A, a)
        push!(P.B, b)
        push!(P.C, c)
        push!(P.D, d)
    end
end

"""
    remove_constraint!(P::TropicalPolyhedron{T}, index::Int) where {T<:Real}
Remove a constraint from a polyhedron. 
### Input
- `P`  -- a tropical polyhedron.
- `index` -- position of the constraint in the matrix representation.
### Output
The polyhedron without the given constraint.
"""
function remove_constraint!(P::TropicalPolyhedron{T}, index::Int) where {T<:Real}
    if index <= dim(P)[1]
        deleteat!(P.A, index)
        deleteat!(P.B, index)
        deleteat!(P.C, index)
        deleteat!(P.D, index)
    end
end

"""
    is_empty(P::TropicalPolyhedron{T}) where {T<:Real}   
A tropical polyhedron is considered as empty if there is no constraint in its definition
or if it's impossible to find an element in the space describing by the polyhedron. Please refer to the 'References' section of the README file.
### Input
- `P`  -- a tropical polyhedron.
- `silent` -- set to false to get some logs on the game.
### Output
``true`` if the tropical polyhedron is empty, ``false`` otherwise.
"""
function is_empty(P::TropicalPolyhedron{T}, silent::Bool=true) where {T<:Real}
    number_constraints = dim(P)
    number_variables = constrained_dimensions(P)
    if number_constraints == 0
        return true
    end 
    number_nodes = number_constraints+number_variables+1
    A, B, C, D = constraints_list(P)

    nodes = Vector{Node{T}}([])
    # We will store a boolean for each node to keep track of whether we've seen them.
    nodes_seen = Vector([false for _ in 1:number_nodes])
    # When we meet a new node, we store the value of the payoff.
    nodes_score = Vector([0 for _ in 1:number_nodes])

    for i in 1:number_nodes
        push!(nodes, Node(i, T))
    end

    for i in 1:number_constraints
        for j in 1:number_variables
            if C[i][j] != T(-Inf) 
                add_connection!(nodes[i], nodes[j+number_constraints], C[i][j])
            end
            if D[i] != T(-Inf)
                add_connection!(nodes[i], nodes[number_nodes], D[i])
            end
            if A[i][j] != T(-Inf)
                add_connection!(nodes[j+number_constraints], nodes[i], -A[i][j])
            end
            if B[i] != T(-Inf)
                add_connection!(nodes[number_nodes], nodes[i], -B[i])
            end
        end
    end

    # Parameters of the mean-payoff game
    cycle_found = false
    max_player_turn = false
    current_node = number_nodes
    number_payments = 0
    payoff = 0

    if !silent 
        println("GAME SETUP\n")
        for i in 1:number_nodes
            println("Node : ", i)
            println("List of linked nodes : ", get_connections(nodes[i]))
        end
        println("\nGAME START\n")
    end

    while !cycle_found
        if !silent 
            println("Current node : ", current_node)
            println("List of linked nodes : ", get_connections(nodes[current_node]))
        end

        if nodes_seen[current_node]
            if !silent
                println("END OF THE GAME : Cycle found")
            end
            cycle_found = true
            payoff -= nodes_score[current_node]
            break
        else 
            nodes_seen[current_node] = true
            nodes_score[current_node] = payoff
        end
        
        node_to_go = 0
        if max_player_turn 
            value = -Inf
        else 
            value = +Inf 
        end

        if number_connections(nodes[current_node]) == 0
            if !silent
                println("END OF THE GAME : No outgoing arcs")
            end

            payoff += T(Inf)
            break
        end

        for k in keys(get_connections(nodes[current_node]))
            if max_player_turn 
                if get_connections(nodes[current_node])[k] > value 
                    value = get_connections(nodes[current_node])[k]
                    node_to_go = k 
                end
            else 
                if get_connections(nodes[current_node])[k] < value 
                    value = get_connections(nodes[current_node])[k]
                    node_to_go = k 
                end
            end
        end
        number_payments += 1
        payoff += value 
        current_node = node_to_go
        max_player_turn = !max_player_turn
    end
    println

    if !silent
        println("Number of payments : ", number_payments)
        println("Payoff : ", payoff)
        println("Number of variables : ", number_variables+1)
        println("Value : ", payoff/number_payments)
    end

    if (payoff/number_payments > 0)
        return false
    else
        return true
    end 
end

"""
    copy(P::TropicalPolyhedron{T}) where {T<:Real}
Make a copy of a tropical polyhedron, independent of it.
### Input
- `P`  -- tropical polyhedron in external representation.
### Output
The copy of the polyhedron.
"""
function copy(P::TropicalPolyhedron{T}) where {T<:Real}
    Z = TropicalPolyhedron()
    for i = 1:dim(P)
        add_constraint!(Z, P.A[i], P.B[i], P.C[i], P.D[i])
    end
    return Z
end

"""
    intersection(P::TropicalPolyhedron{T}, Q::TropicalPolyhedron{T}) where {T<:Real}
For each constraint in the second polyhedron, we test if it is redundant with respect to the first. If it is not, we add it to the first polyhedron.
### Input
- `P`  -- tropical polyhedron in external representation.
- `Q`  -- tropical polyhedron in external representation.
### Output
The intersection of the two polyhedrons.
"""
function intersection(P::TropicalPolyhedron{T}, Q::TropicalPolyhedron{T}) where {T<:Real}
    if dim(Q) == 0
        return P
    end

    if constrained_dimensions(P) != constrained_dimensions(Q)
        error("Constraints should be the same dimension")
    end

    A, B, C, D = constraints_list(Q)

    for i = 1:dim(Q)    
        if is_redundant(P, A[i], B[i], C[i], D[i])
            continue
        else 
            add_constraint!(P, A[i], B[i], C[i], D[i])
        end
    end

    return P
end

function is_redundant(P::TropicalPolyhedron{T}, a::Vector{T}, b::T, c::Vector{T}, d::T, silent::Bool=true) where {T<:Real}
    Z = copy(P)
    size = length(a)
    e = Vector([T(-Inf) for _ in 1:size])
    f = Vector([T(-Inf) for _ in 1:size])
    g = T(-Inf)
    h = T(-Inf)

    eps = T(1e-9)

    for i = 1:size
        if c[i] == T(Inf)
            e[i] = 0
            add_constraint!(Z, deepcopy(e), g, f, h)
            e[i] = T(-Inf)
        else
            e[i] = c[i]
            println(a)
            println(eps)
            add_constraint!(Z, deepcopy(e), g, deepcopy(a).-eps, deepcopy(b).-eps)
            e[i] = T(-Inf)
        end
    end

    if d == T(Inf)
        println("MUGEN")
        return true
    else
        add_constraint!(Z, e, d, deepcopy(a).-eps, deepcopy(b).-eps)
    end

    println(Z)

    println("Test EMPTY")
    return is_empty(Z, silent)
end