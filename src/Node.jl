import Base

"""
    Node{T<:Real} 
Type that represents a node which is defined by an Identifier (an Int64) and the other nodes to which it is linked.
### Fields
- `id` -- Identifier of the node.
- `connections` -- Dictionnary of linked nodes. The keys are the identifiers of the nodes to which it is linked. The values are the weights of the connections. 
"""
struct Node{T<:Real} 
    id::Int64
    connections::Dict{Int64, T}

    function Node(id::Int64, connections::Dict{Int64, T}) where {T<:Real}
        return new{T}(id, connections)
    end

    function Node(id::Int64, ::Type{T}) where {T<:Real}
        return new{T}(id, Dict{Int64, T}())
    end
end

"""
    Base.:(==)(N::Node{T}, M::Node{T}) where {T<:Real} 
Overriding of the (==) operator for two elements of type Node. 
Two nodes are equal if their identifier is the same. If so, we check if they have the same number of connections.
"""
Base.:(==)(N::Node{T}, M::Node{T}) where {T<:Real} = (get_id(N) == get_id(M)) && (length(get_connections(N)) == length(get_connections(M)))

"""
    get_id(node::Node{T}) where {T<:Real}
### Input
- `node`  -- A node.
### Output
The identifier of the node.
"""
function get_id(node::Node{T}) where {T<:Real}
    return node.id
end

"""
    get_connections(node::Node{T}) where {T<:Real}
### Input
- `node`  -- A node.
### Output
The dictionnary of connections.
"""
function get_connections(node::Node{T}) where {T<:Real}
    return node.connections
end 

"""
    add_connection!(node::Node{T}, other::Node{T}, weight::T) where {T<:Real}
Add a connection to the `other` node with the given `weight` to the dictionnary of the first given node.
### Input
- `node`  -- the node to which we add a connection.
- `other`  -- the new connected node.
- `weight`  -- the weight of the new connection.
### Output
Nothing but modifies the dictionnary of connections of the first node given as an argument.
"""
function add_connection!(node::Node{T}, other::Node{T}, weight::T) where {T<:Real}
    node.connections[get_id(other)] = weight
end

"""
    number_connections(node::Node{T}) where {T<:Real}
### Input
- `node`  -- A node.
### Output
The length of the dictionnary of connections.
"""
function number_connections(node::Node{T}) where {T<:Real}
    return length(get_connections(node))
end