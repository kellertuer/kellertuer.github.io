
using YAML, Dates
talks = YAML.load_file("data/talks.yaml")

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
    {{talks}}
print whole list of talks
"""
function hfun_talks()
    s = "";
    lastyear = 0
    sorted_talks = sort(collect(talks), lt=isless_talks)
    for talk ∈ sorted_talks
        newyear = parse(Int, Dates.format(talk["date"],"yyyy"))
        if newyear != lastyear
            (lastyear != 0) && (s = "$s\n</ul>") # close old list
            s = """$s
            <h2 class="year">$(newyear)</h2>
            <ul class="talks">
            """
            lastyear = newyear
        end
        s = """$s
            <li>$(format_talk(talk))</li>
            """
    end
    (lastyear != 0) && (s = "$s \n</ul>") # close old list
    return s
end
function format_talk(talk::Dict)
    key = talk["key"]
    ts =  """<a name="$key"></a>"""
    ts = """$(ts)$(entry_to_html(talk,"title"))"""
    #append seminar/conference
    haskey(talk,"conference") && (ts = """$(ts)$(fomat_conference(talk["conference"]))""")
    haskey(talk,"seminar") && (ts = """$(ts)$(fomat_seminar(talk["seminar"], talk["date"]))""")
    # nbote & with TODO
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
        ts = """$ts
        <div id="$key-abstract" class="blockicon abstract collapse fas fa-lg fa-file-alt">
            <div class="content">$(talk["abstract"])</div>
        </div>
        """
    end
    return ts
end

function fomat_conference(conf::Dict)
    s = """
           $(entry_to_html(conf,"name"))
           $(format_duratuion(conf["start"],get(conf,"end",conf["start"])))
           $(entry_to_html(conf,"place"))
        """
    return s
end
function fomat_seminar(seminar::Dict, date::Date)
    s = """
           $(entry_to_html(seminar,"name"))
           $(entry_to_html(seminar,"institute"))
           $(entry_to_html(seminar,"university"))
           $(format_duratuion(date))
           $(entry_to_html(seminar,"place"))
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
    return """<span class="dates">$(d)</span>"""
end
