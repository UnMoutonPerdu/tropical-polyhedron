using Test

for T in [Float64]

    @testset "Edge Initialization" begin
        try
            edge = Edge()
        catch e
            @test isa(e, MethodError) 
        end

        try
            node = Node()
            edge = Edge(node)
        catch e
            @test isa(e, MethodError) 
        end

        try
            edge = Edge(4.)
        catch e
            @test isa(e, MethodError) 
        end

        try
            node = Node(5)
            edge = Edge(4., node)
        catch e
            @test isa(e, MethodError) 
        end
    end

    @testset "Getters" begin
        node = Node()
        edge = Edge(5., node)

        @test get_weight(edge) == 5.
        @test get_arrival_node(edge) == node
    end

end