using Test
include("../src/Node.jl")

for T in [Float64]

    @testset "Node Initialization and Getters" begin

        ## Basic Initialization
        try
            n1 = Node()
        catch e
            @test isa(e, MethodError)
        end
        n1 = Node(0, T)
        @test get_id(n1) == 0
        @test get_connections(n1) == Dict()  
        @test number_connections(n1) == 0
        
        ## Complete Initialization
        n1 = Node(1, Dict(2 => T(1)))
        @test get_id(n1) == 1
        @test get_connections(n1) == Dict(2 => T(1))
        @test number_connections(n1) == 1

        ## Type conflict
        try
            n2 = Node(2, Dict(T(2) => T(3)))
        catch e
            @test isa(e, MethodError) 
        end

        try
            n2 = Node(T(2), Dict(2 => T(3)))
        catch e
            @test isa(e, MethodError) 
        end
    end

    @testset "Add of nodes" begin 

        n1 = Node(1, T)
        n2 = Node(2, T)

        @test number_connections(n1) == 0
        add_connection!(n1, n2, T(2))
        @test number_connections(n1) == 1

    end

end