# TropicalPolyhedron

TropicalPolyhedron is a library for dealing with tropical polyhedrons. Currently, only the external representation is implemented.
This first implementation in Julia is the conclusion of my research internship at LIX (Ecole Polytechnique, Palaiseau) as part of my M.Sc at ISAE-Supaero, Toulouse.

## Reminder

A tropical polyhedron is defined externally by a set of $r$ constraints of the form :

$$A \cdot x + B \leq C \cdot x + D$$

where $x \in \mathbb{R}^d_{\max};\  A,\  C \in  \mathbb{R}^{r\times d}\_{\max}; \ B, \ D \in \mathbb{R}^{r}_{\max}$.

## Usage

The structure of such polyhedrons is given below: 

```
struct TropicalPolyhedron{T<:Real}
    A::Vector{Vector{T}}
    B::Vector{T}
    C::Vector{Vector{T}}
    D::Vector{T}
end
```

To create an empty tropical polyhedron `tpoly`, use the following command:

```
tpoly = TropicalPolyhedron()
```

You can also initialize the polyhedron with values by specifying the 4 matrices `A`, `B`, `C` and `D`:

```
tpoly = TropicalPolyhedron(A, B, C, D)
```

To add a constraint to a polyhedron:

```
#=
    a::Vector{T}
    b::T
    c::Vector{T}
    d::T
=#
add_constraint!(tpoly, a, b, c, d)
```

## References
You can find more information in my research report in this same repository.

For the algorithm checking the emptiness of a tropical polyhedron and for the one checking whether a tropical constraint is redundant with respect to a tropical polyhedron  :

[1] **Tropical Fourier-Motzkin elimination, with an application to real-time verification.** Xavier Allamigeon, Uli Fahrenberg, Stéphane Gaubert, Ricardo D. Katz, Axel Legay. (2013). p.15-20. [doi: 10.1142/S0218196714500258](https://doi.org/10.1142/S0218196714500258), [arXiv: 1308.2122](https://arxiv.org/abs/1308.2122).

[2] **Compression and Approximation of Neural Networks** Hugo Mouton (2023)
