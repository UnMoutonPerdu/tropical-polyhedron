import Base

"""
    Node{T<:Real, U<:Real} 
Type that represents a node which is defined by its value and the other nodes to which it is linked.
### Fields
- `val` -- Value of the node.
- `linked_nodes` -- Vector of nodes to which the node is linked.
"""
struct Node{T<:Real, U<:Real} 
    val::T
    linked_nodes::Vector{Edge{U, T}}

    function Node(val::T, linked_nodes::Vector{Edge{U, T}}) where {T<:Real, U<:Real}
        return new{T, U}(val, linked_nodes)
    end

    function Node(val::T) where {T<:Real}
        return new{T, Float64}(val, Vector{Edge{Float64, Float64}}([]))
    end

    function Node{T, U}() where {T<:Real, U<:Real}
        return new{T, U}(T(0), Vector{Edge{U, T}}([]))
    end

    function Node()
        return Node{Float64, Float64}()
    end
end

"""
    Base.:(==)(N::Node{T, U}, M::Node{T, U}) where {T<:Real, U<:Real} 
Overriding of the (==) operator for two elements of type Node. 
Two nodes are equal if their value is the same. If so, we check if their list of linked nodes is of the same size.
"""
Base.:(==)(N::Node{T, U}, M::Node{T, U}) where {T<:Real, U<:Real} = (get_value(N) == get_value(M)) && (size(get_linked_nodes(N)) == size(get_linked_nodes(M)))

"""
    get_value(node::Node{T, U}) where {T<:Real, U<:Real}
### Input
- `node`  -- A node.
### Output
The value of this node.
"""
function get_value(node::Node{T, U}) where {T<:Real, U<:Real}
    return node.val
end

"""
    get_linked_nodes(node::Node{T, U}) where {T<:Real, U<:Real}
### Input
- `node`  -- A node.
### Output
The vector of nodes to which the node is linked.
"""
function get_linked_nodes(node::Node{T, U}) where {T<:Real, U<:Real}
    return node.linked_nodes
end 

"""
    add_edge!(node::Node{T, U}, other::Node{T, U}, weight::U) where {T<:Real, U<:Real}
Add a node to the list of nodes linked to the first.
### Input
- `node`  -- the node to which we add a link.
- `other`  -- the added node.
- `weight`  -- the weight of the new edge.
### Output
Nothing but modifies the list of linked nodes of the first node given as an argument.
"""
function add_edge!(node::Node{T, U}, other::Node{T, U}, weight::U) where {T<:Real, U<:Real}
    push!(node.linked_nodes, Edge(weight, other))
end