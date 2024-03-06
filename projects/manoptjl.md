# Manopt.jl

+++
title = "Manopt.jl"
subtitle = "Optimization on Riemannian manifolds"
url = "https://manoptjl.org"
url_text = "manoptjl.org"
logo = "manoptjl-logo.png"
date_start = "2016-11-20"
more = false
summary = "This toolbox provides an easy access to image processing tasks for such data, and optimization on manifolds in Julia. In general the toolbox combines ideas from [manopt](https://manopt.org) and [pymanopt](https://pymanopt.org) and can be used with all manifolds from [Manifolds.jl](https://juliamanifolds.github.io/Manifolds.jl/)"
+++

For a function f that maps from a [Riemannian manifold](https://en.wikipedia.org/wiki/Riemannian_manifold)
ℳ onto the real line, we aim to solve

@@no-number
$$\text{Minimize}\quad f(x) \text{ such that } x \in \mathcal M$$
@@

`Manopt.jl` provides a framework for optimization on manifolds.
It follows the same ideology as [Manopt](https://manopt.org) and [pymanopt](https://pymanopt.org).
This toolbox aims to provide an easy access to optimization methods on manifolds
for [Julia](https://julialang.org), including example data and visualization methods.
