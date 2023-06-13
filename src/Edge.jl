import Base

"""
    Edge{T<:Real} 
Type that represents an oriented edge which is defined by its weight and the arrival node.
### Fields
- `weight` -- Weight of the edge.
- `arrival` -- Arrival node of the edge.
"""
struct Edge{T<:Real} 
    weight::T
    arrival::Node{T}

    function Edge(weight::T, arrival::Node{T}) where {T<:Real}
        return new{T}(weight, arrival)
    end
end

"""
    get_weight(edge::Edge{T}) where {T<:Real}
### Input
- `edge`  -- An edge.
### Output
The weight of this edge.
"""
function get_weight(edge::Edge{T}) where {T<:Real}
    return edge.weight
end

"""
    get_arrival_node(edge::Edge{T}) where {T<:Real}
### Input
- `edge`  -- An edge.
### Output
The arrival node of this edge.
"""
function get_arrival_node(edge::Edge{T}) where {T<:Real}
    return edge.arrival
end