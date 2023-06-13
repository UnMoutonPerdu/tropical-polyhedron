import Base

"""
    Node{T<:Real} 
Type that represents a node which is defined by its value and the other nodes to which it is linked.
### Fields
- `val` -- Value of the node.
- `linked_nodes` -- Vector of nodes to which the node is linked.
"""
struct Node{T<:Real} 
    val::T
    linked_nodes::Vector{Node{T}}

    function Node(val::T, linked_nodes::Vector{Node{T}}) where {T<:Real}
        return new{T}(val, linked_nodes)
    end

    function Node(val::T) where {T<:Real}
        return new{T}(val, Vector{Node{T}}([]))
    end

    function Node{T}() where {T<:Real}
        return new{T}(T(0), Vector{Node{T}}([]))
    end

    function Node()
        return Node{Float64}()
    end
end

"""
    Base.:(==)(N::Node{T}, M::Node{T}) where {T<:Real} 
Overriding of the (==) operator for two elements of type Node. 
Two nodes are equal if their values are the same. If so, we check if their list of linked nodes is of the same size.
"""
Base.:(==)(N::Node{T}, M::Node{T}) where {T<:Real} = 
(get_value(N) == get_value(M)) && check_linked_nodes(N, M)

function check_linked_nodes(N::Node{T}, M::Node{T}) where {T<:Real} 
    if size(get_linked_nodes(N)) != size(get_linked_nodes(M))
        return false 
    end
    for i in 1:size(get_linked_nodes(N))[1]
        if get_value(get_linked_nodes(N)[i]) != get_value(get_linked_nodes(M)[i])
            return false
        end
    end
    return true
end

"""
    get_value(node::Node{T}) where {T<:Real}
### Input
- `node`  -- A node.
### Output
The value of this node.
"""
function get_value(node::Node{T}) where {T<:Real}
    return node.val
end

"""
    get_linked_nodes(node::Node{T}) where {T<:Real}
### Input
- `node`  -- A node.
### Output
The vector of nodes to which the node is linked.
"""
function get_linked_nodes(node::Node{T}) where {T<:Real}
    return node.linked_nodes
end 

"""
    add_edge!(node::Node{T}, other::Node{T}) where {T<:Real}
Add a node to the list of nodes linked to the first.
### Input
- `node`  -- the node to which we add a link.
- `other`  -- the added node.
### Output
Nothing but modifies the first node given as an argument.
"""
function add_edge!(node::Node{T}, other::Node{T}) where {T<:Real}
    push!(node.linked_nodes, other)
end