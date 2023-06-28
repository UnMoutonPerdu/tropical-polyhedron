using Test 
include("../src/TropicalCone.jl")

for N in [Float64]

    @testset "Dimensions" begin 
        c1 = TropicalCone()
        c2 = TropicalCone([[N(1), N(2)]], [[N(1), N(2)]])
        @test dim(c1) == 0
        @test constrained_dimensions(c1) == -1
        @test dim(c2) == 1
        @test constrained_dimensions(c2) == 2
    end

    @testset "Add and Remove constraints" begin
        c = TropicalCone()
        add_constraint!(c, [N(0)], [N(0)])
        @test dim(c) == 1
        remove_constraint!(c, 1)
        @test dim(c) == 0
    end

    @testset "Extreme elements" begin
        c = TropicalCone()
        #println(compute_extreme(c, 0, 2))

        add_constraint!(c, [N(0), N(-Inf)], [N(-Inf), N(0)])
        println(compute_extreme(c, 1, 2))

        add_constraint!(c, [N(-Inf), N(0)], [N(3), N(-Inf)])
        #println(compute_extreme(c, 2, 2))
    end

end