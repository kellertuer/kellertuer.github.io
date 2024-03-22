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
@delay function hfun_projectslist()
    project_files = filter!(x -> endswith(x, ".md") && x != "index.md", readdir("projects"))
    # collect dates
    projects = [
        Dict{String, Union{Nothing, String, Vector{String},Bool}}(
            push!(
                Pair{String,Union{Nothing, String, Vector{String},Bool}}[
                    var => pagevar("projects/$project", var) for var ∈ ["date_end", "date_start"]
                ],
                "project" => project[1:end-3], # remove md
            )
        )
        for project ∈ project_files
        ]
    # @info projects
    # is a earlier than b? first running projects (no end) sorted by start, then
    function dates_lt(a,b)
        if isnothing(a["date_end"]) && !isnothing(b["date_end"])
            # a is still running, but b is not so it is less than b
            return true
            # if both are still running -> continue, we compare starts
        end
        if isnothing(b["date_end"]) && !isnothing(a["date_end"])
            # b is still running but a not -> b < a
            return false
        end
        # Now end is either nothing for both or given for both
        if (isnothing(a["date_start"]) && !isnothing(b["date_start"])) || (!isnothing(a["date_start"]) && isnothing(b["date_start"]))
            # safety, one has no start but the other one has. The one with start is less
            # if a is nothing its less, otherwise b
            return isnothing(a["date_start"])
        end
        if !isnothing(a["date_start"]) && !isnothing(b["date_start"]) # both have a start
            return Date(a["date_start"]) > Date(b["date_start"]) # compare dates, the younger one is less
        end
        # in all other cases (e.g. both starts nothing) take those
        if !isnothing(a["date_start"]) && !isnothing(b["date_start"]) # both have a start
            return Date(a["date_start"]) > Date(b["date_start"]) # compare dates, the younger one is less
        end
        # if any start here still nothing -> both are nothing -> compare ends
        if !isnothing(a["date_end"]) && !isnothing(b["date_end"])
            return Date(a["date_end"]) > Date(b["date_end"])
        end
        # maybe everything is nothing? Then we reach this and return true
        return true
    end
    sorted_projects = sort(projects, lt = dates_lt)
    s = ""
    for project_dates in sorted_projects
        @info "projects/$(project_dates["project"]).md"
        project = Dict(
            Pair{String,Union{Nothing,String,Vector{String},Bool}}[
                var => pagevar("projects/$(project_dates["project"]).md",var)
                for var ∈ ["title", "subtitle", "collaborators", "date_end", "logo", "more", "date_start", "summary", "url", "url_text"]
        ]...,
            "project" => project_dates["project"],
        )
        @info project
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
        @info project
        @info project["date_start"]
        timespan = ""
        !isnothing(project["date_start"]) && (timespan = Dates.format(Date(project["date_start"]),"yyyy"))
        if !isnothing(project["date_end"])
            timespan = """<span class="timespan">
                          $(timespan)&mdash;$(Dates.format(Date(project["date_end"]),"yyyy"))
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