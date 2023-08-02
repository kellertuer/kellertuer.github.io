using Dates
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
        Dict{String, Union{Nothing, String, Vector{String},Bool}}(
            push!(
                Pair{String,Union{Nothing, String, Vector{String},Bool}}[
                    var => pagevar("projects/$project", var) for var ∈ ["title", "subtitle", "collaborators", "end", "logo", "more", "start", "summary", "url", "url_text"]
                ],
                "project" => project[1:end-3], # remove md
            )
        )
        for project ∈ project_files
        ]
    sorted_projects = sort(projects, lt = (a,b) -> isnothing(a["end"]) && !isnothing(b["end"]) || isnothing(a["end"]) && ( isnothing(a["start"]) && !isnothing(b["start"]) ||  Date(a["start"]) > Date(b["start"])) || !isnothing(a["end"]) && !isnothing(b["end"]) && (Date(a["end"]) > Date(b["end"])) )
    s = ""
    for project in sorted_projects
        logospan = isnothing(project["logo"]) ? "" : """
            <span class="logo"><img src="../assets/projects/$(project["logo"])"/></span>
            """
        coll = ""
        if !isnothing(project["collaborators"])
            coll = """<span class="collaborators">
                      <ul>
                      <li>
                        $(join([ hfun_person([name, "link_shortname_fnorcid"]) for name in project["collaborators"]], "</li>\n<li>"))</li>
                      </ul>
            """
        end
        subtitlespan = ""
        if !isnothing(project["subtitle"])
            subtitlespan = """<span class="subtitle">$(project["subtitle"])</span>
                            """
        end
        timespan = Dates.format(Date(project["start"]),"yyyy")
        if !isnothing(project["end"])
            timespan = """<span class="timespan">
                          $(timespan)&mdash;$(Dates.format(Date(project["end"]),"yyyy"))
                          </span>
                          """
        else
            timespan = """<span class="timespan">
                          since $(timespan)
                          </span>
                          """
        end
        urlspan = ""
        if !isnothing(project["url"])
            urltext = !isnothing(project["url_text"]) ? project["url_text"] : project["url"]
            urlspan = """<span class="link"><a href="$(project["url"])">$(urltext)</a></span>"""
        end
        morelink = ""
        if isnothing(project["more"]) || project["more"]
            morelink = """<span class="more"><a href="$(project["project"])/">more>></a></span>"""
        end
        s = """$s<dt>
                    <span class="title">$(project["title"])</span>
                    $(subtitlespan)
               </dt>
               <dd>
               <div class="info">
                    $logospan
                    $urlspan
                    $timespan
                    $coll
               </div>
               $(!(isnothing(project["summary"])) ? fd2html(project["summary"]; internal=true) : "")
               $morelink
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