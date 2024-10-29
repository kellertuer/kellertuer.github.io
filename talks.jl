
using YAML, Dates
talks = YAML.load_file("data/talks.yaml")
conferences = YAML.load_file("data/conferences.yaml")

# Exclude the ones I organized
organized = ["FNDG24"]
exclude_conf = organized

function isless_talks(a::Dict,b::Dict)
    !haskey(a, "key") && error("Talk $a is missing a key")
    !haskey(b, "key") && error("Talk $b is missing a key")
    !haskey(a, "date") && error("Talk $(a["key"]) is missing a date")
    !haskey(b, "date") && error("Talk $(b["key"]) is missing a date")
    date_a = parse(Date, string(a["date"]))
    date_b = parse(Date, string(b["date"]))
    return !(isless(date_a,date_b))
end

"""
    {{talks highlights}}
print the list of talks, either all grouped by year or the
highlights orderred by their selected order
"""
function hfun_talks(params::Vector{String}=String[])
    highlights = false
    group_by_year = true
    if length(params) > 0
        highlights = true
        group_by_year = false
    else # No parameters, all list -> build exclude
        global exclude_conf = organized
    end
    s = "";
    lastyear = 0
    sorted_talks = sort(collect(talks), lt=isless_talks)
    if highlights
        filtered_talks = filter( x-> (haskey(x,"highlight")), talks)
        sorted_talks = sort(collect(filtered_talks), lt = (a,b) -> a["highlight"] < b["highlight"])
    end
    for talk ∈ sorted_talks
        newyear = parse(Int, Dates.format(talk["date"],"yyyy"))
        if (newyear != lastyear)
            if group_by_year==true
                (lastyear != 0) && (s = "$s\n</ul>") # close old list
                s = """$s
                       <h3 class="year">$(newyear)</h3>
                       <ul class="talks fa-ul">
                """
            else
                if lastyear==0
                    s = """$s
                           <ul class="talks fa-ul">
                        """
                end
            end
            lastyear = newyear
        end
        haskey(talk,"conference") && push!(exclude_conf,talk["conference"])
        s = """$s
            <li><span class="fa-li"><i class="fas fa-chalkboard-teacher"></i></span>$(format_talk(talk))</li>
            """
    end
    s = "$s \n</ul>" # close old list
    return s
end
function format_talk(talk::Dict)
    key = talk["key"]
    ts =  """<a name="$key"></a>"""
    ts = """$(ts)$(entry_to_html(talk,"title"))"""
    #append seminar/conference
    haskey(talk,"conference") && (ts = """$(ts)$(fomat_conference(conferences[talk["conference"]]))""")
    haskey(talk,"seminar") && (ts = """$(ts)$(fomat_seminar(talk["seminar"], talk["date"]))""")
    # note & with TODO
    info = """$(entry_to_html(talk,"note"))"""
    if haskey(talk,"with")
        names = join( [
            has_name(name) ? hfun_person([name,"link_shortname"]) : """<span class="person unknown">$name</span>""" for name ∈ talk["with"]
            ], ", ", ", and ")
        info = """$(info)
                <span class="with">$names</span>
             """
    end
    (length(info) > 0) && (ts = """$(ts)<span class="info">$info</span>""")
    #nav-pills
    ts = """$ts
            <ul class="nav nav-icons">
        """
    # abstract
    if haskey(talk,"abstract") #abstract icon
        ts = """$ts
        <li>
            <a data-toggle="collapse" href="#$key-abstract" title="toggle visibility of the abstract for $key">
                <i class="fas fa-lg fa-file-alt"></i>
            </a>
        </li>"""
    end
    # pdf (slides)
    ts = """$(ts)$(entry_to_list_icon(talk,"slides"; iconstyle="fas fa-lg", icon="fa-file-pdf"))"""
    # video
    ts = """$(ts)$(entry_to_list_icon(talk,"video"; iconstyle="fas fa-lg", icon="fa-file-video"))"""
    # ref
    ts = """$(ts)$(entry_to_list_icon(talk,"literature-reference"; linkprefix="/publications/#", iconstyle="fas fa-lg", icon="fa-book"))"""
    # link
    ts = """$(ts)$(entry_to_list_icon(talk,"doi"; linkprefix="http://dx.doi.org/", iconstyle="ai ai-lg", icon="ai-doi"))"""
    ts = """$(ts)$(entry_to_list_icon(talk,"link"; iconstyle="fas fa-lg", icon="fa-link"))"""
    # link
    # (2) link
    # end nav pills
    ts = """$ts
            </ul>
        """
    # content: abstract
    if haskey(talk,"abstract") # abstract content
        abstract = strip(talk["abstract"])
        abstract = replace(abstract, "\n" => "\n\n")
        ts = """$ts
        <div id="$key-abstract" class="blockicon abstract collapse fas fa-lg fa-file-alt">
            <div class="content">$(fd2html(abstract; internal=true))</div>
        </div>
        """
    end
    return ts
end

function hfun_remainingconferences()
    filtered_conf = filter( x-> (x[1] ∉ exclude_conf), conferences)
    sorted_conf = sort(collect(filtered_conf), lt = (a,b) -> a[2]["start"] > b[2]["start"])
    s = "";
    for conf in sorted_conf
        if conf[2]["start"] < Dates.now()
            s = """$s
                   <li><span class="fa-li"><i class="fas fa-users"></i></span>$(fomat_conference(conf[2]))</li>
                """
        end
    end
    return """
        <ul class="conferences fa-ul">
        $(s)
        </ul>
    """
end
function hfun_forthcomingconferences()
    sorted_conf = sort(collect(conferences), lt = (a,b) -> a[2]["start"] < b[2]["start"])
    s = "";
    for conf in sorted_conf
        if conf[2]["start"] > Dates.now()-Week(2) # all that are newer than 2 weeks
            s = """$s
                   <li><span class="fa-li"><i class="fas fa-users"></i></span>$(fomat_conference(conf[2]))
                   <span class="icons">
                    $(get(conf[2], "talk", false) ? """<i class="fas fa-chalkboard-teacher" title="I am giving a talk"></i>""" : "")
                    $(get(conf[2], "organizer", false) ? """<i class="fas fa-chair" title="I am organizing/chairing a session"></i>""" : "")
                    </span>
                   </li>
                """
        end
    end
    if length(s) > 0
        return """
                  <h2>Forthcoming Events</h2>
                  <p>I plan to attend the following conferences, workshops, or seminars</p>
                  <ul class="conferences fa-ul">
                  $(s)
                  </ul>
        """
    else
        return ""
    end
end
function fomat_conference(conf::Dict)
    s = """
           $(entry_to_html(conf,"name"; link="url"))
           $(format_duratuion(conf["start"],get(conf,"end",conf["start"])))
           $(entry_to_html(conf,"place"; class="place end"))
           $(entry_to_html(conf,"note"; class="note"))
        """
    return s
end
function fomat_seminar(seminar::Dict, date::Date)
    s = """
           $(entry_to_html(seminar,"name";link="url"))$(entry_to_html(seminar,"institute"))$(entry_to_html(seminar,"university"))$(format_duratuion(date))$(entry_to_html(seminar,"place"))
        """
    return s
end
function format_duratuion(s::Date, e::Date=s)
    d = ""
    if year(s) == year(e) && month(s)==month(e)
        if day(s) == day(e)
            d = """$(Dates.format(s,"U d, yyyy"))""" # one day
        else
            # range in same month
            d = """$(Dates.format(s,"U d")) &mdash; $(Dates.format(e,"d, yyyy"))"""
        end
    else
        # different months
        d = """$(Dates.format(s,"U d")) &mdash; $(Dates.format(e,"U d, yyyy"))"""
    end
    return """<span class="dates comma">$(d)</span>"""
end
