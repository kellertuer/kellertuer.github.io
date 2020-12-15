include("yaml.jl")
include("names.jl")
# The following 3 might depend on yaml and names
include("bib.jl")
include("talks.jl")
include("teaching.jl")

#
# Infoblock on projects
#

#
# Overview projects
#
function hfun_projectslist()
    project_files = filter!(x -> endswith(x, ".md") && x != "index.md", readdir("projects"))
    # collect dates
    projects = [
        Dict( [var => pagevar("projects/$project", var) for var ∈ ["title", "partners", "start", "end", "summary"]] )
        for project ∈ project_files
        ]
    sorted_projects = sort(projects, lt = (a,b) -> !isnothing(a["end"]) || Date(a["start"]) < Date(b["start"]) )
    s = ""
    for project in sorted_projects
        s = """$s<dt>$(project["title"])</dt>
               <dd>
                 <div class="info">
                 A
                 </div>
               $(!(isnothing(project["summary"])) ? project["summary"] : "")
               </dd>
            """
    end
    return """<dl class="projectlist">
              $s
              </dl>
    """
    #=    for post in first.(splitext.(posts))
        url = splitext("/blog/$post/")[1]
        title = pagevar(strip(url, '/'), :title)
        date = Date(post[1:10])
        date ≤ today() && write(io, "\n[$title]($url) $date \n")
    end
    return Franklin.fd2html(String(take!(io)), internal=true)
  =#
end