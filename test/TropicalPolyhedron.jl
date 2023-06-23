using Test 
include("../src/Node.jl")
include("../src/TropicalPolyhedron.jl")

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

    @testset "Dimensions" begin 
        p1 = TropicalPolyhedron()
        p2 = TropicalPolyhedron([[N(1), N(2)]], [N(2)], [[N(1), N(2)]], [N(2)])
        @test dim(p1) == 0
        @test constrained_dimensions(p1) == -1
        @test dim(p2) == 1
        @test constrained_dimensions(p2) == 2
    end

    @testset "Add and Remove constraints" begin
        p = TropicalPolyhedron()
        add_constraint!(p, [N(0)], N(0), [N(0)], N(0))
        @test dim(p) == 1
        remove_constraint!(p, 1)
        @test dim(p) == 0
    end

    @testset "Copy of Polyhedron" begin
        p = TropicalPolyhedron()
        add_constraint!(p, [N(0)], N(0), [N(0)], N(0))
        q = copy(p)
        @test p == q
        remove_constraint!(q, 1)
        @test dim(p) == 1
        @test dim(q) == 0
    end

    @testset "Emptiness Tests" begin

        ## Tests on 1D polyhedrons
        p = TropicalPolyhedron()
        q = TropicalPolyhedron()
        add_constraint!(p, [N(0)], N(-Inf), [N(-Inf)], N(1))
        add_constraint!(p, [N(-Inf)], N(0), [N(0)], N(-Inf))
        add_constraint!(q, [N(0)], N(-Inf), [N(-Inf)], N(1))
        add_constraint!(q, [N(-Inf)], N(2), [N(0)], N(-Inf))
        
        @test is_empty(p) == false
        @test is_empty(q) == true

        ## Test on 2D polyhedron
        r = TropicalPolyhedron()
        add_constraint!(r, [N(0), N(-Inf)], N(-Inf), [N(-Inf), N(-Inf)], N(1))
        add_constraint!(r, [N(-Inf), N(-Inf)], N(0), [N(0), N(-Inf)], N(-Inf))
        add_constraint!(r, [N(-Inf), N(0)], N(-Inf), [N(-Inf), N(-Inf)], N(1))
        add_constraint!(r, [N(-Inf), N(-Inf)], N(0), [N(-Inf), N(0)], N(-Inf))

        @test is_empty(r) == false

        ## Test on polyhedron with a node without any outgoing arcs
        s = TropicalPolyhedron()
        add_constraint!(s, [N(0)], N(-Inf), [N(-Inf)], N(3))

        @test is_empty(s) == false
    end

    @testset "Redundancy Tests" begin
        p = TropicalPolyhedron()
        ## Useless constraint
        a, b, c, d = [N(1)], N(1), [N(2)], N(1)
        @test is_redundant(p, a, b, c, d) == true

        ## Constraint x >= 0
        a, b, c, d = [N(-Inf)], N(0), [N(0)], N(-Inf)
        @test is_redundant(p, a, b, c, d) == false
        add_constraint!(p, a, b, c, d)

        ## Constraint x >= -2 (redundants)
        e, f, g, h = [N(-Inf)], N(-2), [N(0)], N(-Inf)
        @test is_redundant(p, e, f, g, h) == true

        ## Test on 2D polyhedron
        r = TropicalPolyhedron()
        add_constraint!(r, [N(0), N(-Inf)], N(-Inf), [N(-Inf), N(-Inf)], N(1))
        add_constraint!(r, [N(-Inf), N(-Inf)], N(0), [N(0), N(-Inf)], N(-Inf))
        add_constraint!(r, [N(-Inf), N(0)], N(-Inf), [N(-Inf), N(-Inf)], N(1))
        add_constraint!(r, [N(-Inf), N(-Inf)], N(0), [N(-Inf), N(0)], N(-Inf))

        a, b, c, d = [N(-Inf), N(-Inf)], N(-2), [N(0), N(-Inf)], N(-Inf)
        @test is_redundant(r, a, b, c, d) == true

        a, b, c, d = [N(-Inf), N(-Inf)], N(0.5), [N(-Inf), N(0)], N(-Inf)
        @test is_redundant(r, a, b, c, d) == false
    end

    @testset "Intersection Tests" begin
        p = TropicalPolyhedron()
        q = TropicalPolyhedron()
        r = TropicalPolyhedron()

        @test intersection(p, q) == q

        add_constraint!(q, [N(0), N(-Inf)], N(-Inf), [N(-Inf), N(-Inf)], N(1))
        add_constraint!(r, [N(0), N(-Inf)], N(-Inf), [N(-Inf), N(-Inf)], N(1))
        p = intersection(p, q)

        @test p == r

        add_constraint!(q, [N(0), N(-Inf)], N(-Inf), [N(-Inf), N(-Inf)], N(1))

        @test intersection(p, q) == r
    end
end