using Test
include("../src/Node.jl")

for T in [Float64]

    @testset "Node Initialization and Getters" begin

        ## Basic Initialization
        n1 = Node()
        @test get_value(n1) == T(0)
        @test get_linked_nodes(n1) == Dict()   
        
        ## Complete Initialization
        n1 = Node(T(2), Dict(T(3) => T(1)))
        @test get_value(n1) == T(2)
        @test get_linked_nodes(n1) == Dict(T(3) => T(1))

        ## Type conflict
        try
            n2 = Node(2, Dict(2 => 3.))
        catch e
            @test isa(e, MethodError) 
        end
    end

    @testset "Add of nodes" begin 

        n1 = Node(T(1))
        n2 = Node(T(2))

        @test number_outgoing_arcs(n1) == 0
        add_edge!(n1, n2, T(2))
        @test number_outgoing_arcs(n1) == 1

    end

end