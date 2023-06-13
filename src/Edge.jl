import Base

"""
    Edge{T<:Real, U<:Real}
Type that represents an oriented edge which is defined by its weight and the arrival node.
### Fields
- `weight` -- Weight of the edge.
- `arrival` -- Arrival node of the edge.
"""
struct Edge{T<:Real, U<:Real}
    weight::T
    arrival::Node{U, T}

    function Edge(weight::T, arrival::Node{U, T}) where {T<:Real, U<:Real}
        return new{T, U}(weight, arrival)
    end
end

"""
    get_weight(edge::Edge{T, U}) where {T<:Real, U<:Real}
### Input
- `edge`  -- An edge.
### Output
The weight of this edge.
"""
function get_weight(edge::Edge{T, U}) where {T<:Real, U<:Real}
    return edge.weight
end

"""
    get_arrival_node(edge::Edge{T, U}) where {T<:Real, U<:Real}
### Input
- `edge`  -- An edge.
### Output
The arrival node of this edge.
"""
function get_arrival_node(edge::Edge{T, U}) where {T<:Real, U<:Real}
    return edge.arrival
end