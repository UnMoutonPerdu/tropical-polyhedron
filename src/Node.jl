struct Node{T<:Real} 
    val::T
    outgoing::Vector{T}

    function Node(val::T, outgoing::Vector{T}) where {T <: Real}
        return new{T}(val, outgoing)
    end

    function Node(val::T) where {T <: Real}
        return new{T}(val, Vector{T}([]))
    end

    function Node{T}() where {T <: Real}
        return new{T}(T(0), Vector{T}([]))
    end

    function Node()
        return Node{Float64}()
    end
end

