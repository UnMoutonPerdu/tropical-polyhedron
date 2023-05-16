using Test 
include("TropicalPolyhedron.jl")



for N in [Float64]

    @testset "Tropical Operators" begin 
        a = [3.2, -1., 4.6, 12.2, -4.5]
        b = [-1.2, -3., 7.1, 6.3, -2.]
        c = 4.
    
        @test tropical_sum(a, b) == [3.2, -1., 7.1, 12.2, -2.]
        @test tropical_sum(a, c) == [4., 4., 4.6, 12.2, 4.]
        @test tropical_product(a, b) == [2., -4., 11.7, 18.5, -6.5]
        @test tropical_product(a, c) == [7.2, 3., 8.6, 16.2, -.5]
        @test TropicalPolyhedron([[N(1), N(2)]], [N(2)], [[N(1), N(2)]], [N(2)]) == TropicalPolyhedron([[N(1), N(2)]], [N(2)], [[N(1), N(2)]], [N(2)])
        @test TropicalPolyhedron([[N(1), N(2)]], [N(2)], [[N(1), N(2)]], [N(2)]) != TropicalPolyhedron([[N(1), N(2)]], [N(3)], [[N(1), N(2)]], [N(2)])
    end 


    @testset "Random Polyhedron" begin
        randp = rand(TPoly)
        @test dim(randp) == (2, 2)   
    end


    @testset "Polyhedron" begin 
        p = TropicalPolyhedron{N}()
        q = TropicalPolyhedron([[N(1), N(2)]], [N(2)], [[N(1), N(2)]], [N(2)])
        @test dim(p) == (0,0)
        @test is_empty(p) == true
        add_constraint!(p, [N(1), N(2)], N(2), [N(1), N(2)], N(2))
        @test dim(p) == (1, 2)
        @test is_empty(p) == false
        @test p == q
        remove_constraint!(p, 3)
        @test p == q
        remove_constraint!(p, 1)
        @test is_empty(p) == true
    end


    @testset "Conflicts of constraints" begin
        p = TropicalPolyhedron([[N(0), N(0)]], [N(-Inf)], [[N(-Inf), N(-Inf)]], [N(0)])
        @test dim(p) == (1, 2)
        @test conflicting_constraints(p) == false
        add_constraint!(p, [N(-Inf), N(-Inf)], N(1), [N(0), N(-Inf)], N(-Inf))
        @test conflicting_constraints(p) == true
    end


    @testset "Redundance of constraints" begin
        p = TropicalPolyhedron([[N(0), N(0)]], [N(-Inf)], [[N(-Inf), N(-Inf)]], [N(0)])
        q = TropicalPolyhedron([[N(0), N(0)]], [N(-Inf)], [[N(-Inf), N(-Inf)]], [N(0)])
        @test remove_redundant_constraints(p) == q
        add_constraint!(p, [N(0), N(0)], N(-Inf), [N(-Inf), N(-Inf)], N(0))
        println(p)
        @test remove_redundant_constraints(p) == q
    end

end



#= A = [[-Inf, -Inf]]
B = [0.]
C = [[-1., -1.]]
D = [-Inf]

a = [-Inf, -Inf]
b = 0.
c = [-1., -1.]
d = -Inf

println("\nTropical operators\n")

println("\nInitialisation of polyhedron\n")

initialisedPoly = TropicalPolyhedron(A, B, C, D)

println(initialisedPoly)
println(remove_redundant_constraints!(initialisedPoly))

@testset "Initialised Tropical" begin
    @test dim(initialisedPoly) == (1, 2)
    @test is_empty(initialisedPoly) == false
    add_constraint!(initialisedPoly, a, b, c, d)
    @test dim(initialisedPoly) == (2, 2)
end

println("\nUninitialised polyhedron\n")

uninitialisedPoly = TropicalPolyhedron()

@testset "Uninitialised Tropical" begin
    @test dim(uninitialisedPoly) == (0, 0)
    add_constraint!(uninitialisedPoly, a, b, c, d)
    @test dim(uninitialisedPoly) == (1, 2)
end

println("\nRandom polyhedron\n")

randPoly = rand(TPoly)

@testset "Random Tropical" begin
    @test dim(randPoly) == (2, 2)   
end

println("\nConstraints consistency\n")

A = [[0., 0.], [-Inf, -Inf]]
B = [-Inf, 1.]
C = [[-Inf, -Inf], [0., -Inf]]
D = [0., -Inf]

consitencyPoly = TropicalPolyhedron(A, B, C, D)

@testset "Consistency of constraints" begin
    @test conflicting_constraints(consitencyPoly) == true
end


println(initialisedPoly)
println(remove_redundant_constraints!(initialisedPoly))
println(initialisedPoly)

x = [5, 2]
y = [3, 4]

println(x)
println(y)
println(x+y) =#