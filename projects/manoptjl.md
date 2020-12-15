# Manopt.jl

@def title = "Manopt.jl"
@def url = "https://manoptjl.org"
@def logo = "projects/manifoldsjl-logo.png"
@def start = "2016-11-20"

For a function f that maps from a [Riemannian manifold](https://en.wikipedia.org/wiki/Riemannian_manifold)
ℳ onto the real line, we aim to solve

$$\text{Minimize} f(x) \text{ such that } x \in \mathcal M$$

`Manopt.jl` provides a framework for optimization on manifolds.
It follows the same ideology as [Manopt](https://manopt.org) and [pymanopt](https://pymanopt.org).
This toolbox aims to provide an easy access to optimization methods on manifolds
for [Julia](https://julialang.org), including example data and visualization methods.
