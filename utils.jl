include("yaml.jl")
include("names.jl")
# The following 3 might depend on yaml and names
include("bib.jl")
include("talks.jl")
include("teaching.jl")

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end
