using Test
include("../src/Node.jl")

for N in [Float64]

    @testset "Node Initialization" begin
        n1 = Node()
        @test get_value(n1) == N(0)
        @test get_linked_nodes(n1) == []
        try
            n2 = Node(2)
            n3 = Node(3., [n2])
        catch e
            @test isa(e, MethodError) 
        end
    end

    @testset "Getters" begin
        n1 = Node(N(1))
        n2 = Node(N(2), [n1])
        n3 = Node(N(3), [n1, n2])

        @test get_value(n1) == 1.
        @test get_value(n2) == 2.
        @test get_value(n3) == 3.
        @test get_linked_nodes(n1) == []
        @test get_linked_nodes(n2) == [n1]
        @test get_linked_nodes(n3) == [n1, n2]
    end

    @testset "Add of nodes" begin 
        n1 = Node(N(1))
        n2 = Node(N(2), [n1])
        n3 = Node(N(3), [n1])
        add_edge!(n3, n2)
        @test n3 == Node(N(3), [n1, n2])
        add_edge!(n1, Node())
        @test n1 == Node(N(1), [Node()])
        try
            n4 = Node(1.)
            n5 = Node(2)
        catch e
            @test isa(e, MethodError) 
        end
    end

end