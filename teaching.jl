using YAML, Dates
students = YAML.load_file("data/students.yaml")
teaching = YAML.load_file("data/teaching.yaml")

"""
    is_less_supervision(a,b)
    return, whether a is a younger student project than b, where if they are equal
    we go for alphabetica, for example also if both are not finished yet
"""
function isless_finished(a::Dict, b::Dict)
    if !haskey(a, "finishes") && !haskey(b, "finished")
        return a["name"] < b["name"]
    end
    !haskey(a, "finished") && return false #a not finished but b, then a is not less
    !haskey(b, "finished") && return false
    # if both are finished compare finished dates
    date_a = parse(Date, string(a["finished"]))
    date_b = parse(Date, string(b["finished"]))
    return !(isless(date_a, date_b))
end
"""
    {{library types file}}

print a library restricted to the comma separated list of types, from the optional library
`file`, which defaults to using the preloaded `data/literature.yaml`.

If no types are given all will be printed

"""
function hfun_students(params)
    types = (length(params) > 0) ? lowercase.(strip.(split(params[1], ","))) : ["all"]
    theses = (length(params) > 1) ? YAML.load_file(params[2]) : students
    reduced_theses = filter(x -> (x["type"] ∈ types) || ("all" ∈ types), theses)
    list_html = ""
    #list = sort(collect(reduced_theses), lt=isless_finished)
    list = collect(reduced_theses)
    for entry ∈ list
        list_html = """$(list_html)
                        $(format_supervision(entry))
                    """
    end
    return """
           <dl class="supervised">
               $list_html
           </dl>
           """
end
function format_supervision(entry)
    # (1) date finished?
    date_format = ""
    if haskey(entry, "finished")
        if haskey(entry, "start")
            ds = Dates.format(entry["start"], "yyyy")
            df = Dates.format(entry["finished"], "yyyy")
            date_format = "$(ds)&nbsp;&mdash;&nbsp;$(df)"
        else
            df1 = Dates.format(entry["finished"], "uuu")
            df2 = Dates.format(entry["finished"], "yyyy")
            date_format = """$(df1)&nbsp;$(df2)"""
        end
    elseif haskey(entry, "start")
        ds1 = Dates.format(entry["start"], "uuu")
        ds2 = Dates.format(entry["start"], "yyyy")
        date_format = """<span class="time-meta">since</span>$(ds1)&nbsp;$(ds2)"""
    else
        date_format = "current"
    end
    # name(s)
    students = ""
    if entry["name"] isa Vector #concat list
        students = join(
            [
                (
                    has_name(name) ? hfun_person([name, "link_shortname"]) :
                    """<span class="person unknown">$name</span>"""
                ) for name ∈ entry["name"]
            ],
            ", ",
            ", and ",
        )
    else
        students =
            has_name(entry["name"]) ? hfun_person([entry["name"], "link_shortname"]) :
            """<span class="person unknown">$(entry["name"])</span>"""
    end

    thesis = ""
    (entry["type"] == "master") && (thesis = "master thesis")
    (entry["type"] == "bachelor") && (thesis = "bachelor thesis")
    (entry["type"] == "studentproject") && (thesis = "student project")
    (entry["type"] == "specialisationproject") && (thesis = "specialisation project")
    (entry["type"] == "phd-active") && (thesis = "PhD project")
    (entry["type"] == "phd") && (thesis = "PhD thesis")
    with_names = ""
    if haskey(entry, "with")
        with_names = join(
            [
                has_name(name) ? hfun_person([name, "link_shortname"]) :
                """<span class="person unknown">$name</span>""" for name ∈ entry["with"]
            ],
            ", ",
            ", and ",
        )
        with_names = """<span class="with">$(with_names)</span>"""
    end
    note = ""
    if haskey(entry, "note")
        note = """\n<span class="note">$(parse_persons(entry["note"]))</a>"""
    end
    s = ""
    s = """$(s)$(entry_to_list_icon(entry,"link"; iconstyle="fas fa-lg", icon="fa-link"))"""
    s = """$(s)$(entry_to_list_icon(entry,"pdf"; iconstyle="fas fa-lg", icon="fa-file-pdf"))"""
    (length(s) > 0) && (s = """
    <ul class="nav nav-icons">
    $s
    </ul>
    """)
    return """<dt>$(date_format)</dt>
    <dd>
    <span class="student">$(students)</span>
    <span class="title">$(fd2html(entry["title"]; internal=true))</span>
    <span class="thesis-type">$(thesis)</span>$(with_names)$(note)$s
    </dd>
    """
end

#
#
#
#
#
function isless_course_date(a::Dict, b::Dict)
    if !haskey(a, "date") && !haskey(b, "date") || a["date"] == b["date"]
        return a["name"] < b["name"]
    end
    !haskey(a, "date") && return false #a not finished but b, then a is not less
    !haskey(b, "date") && return true
    date_a = parse(Date, string(a["date"]))
    date_b = parse(Date, string(b["date"]))
    return !(isless(date_a, date_b))
end


hfun_lectures() = courses(teaching["lectures"])
hfun_exercises() = courses(teaching["exercises"])

function courses(list_of_courses)
    list_html = ""
    list = sort(collect(list_of_courses), lt = isless_course_date)
    for entry ∈ list
        info = """$(entry_to_html(entry,"note"))"""
        if haskey(entry, "with")
            names = join(
                [
                    has_name(name) ? hfun_person([name, "link_shortname"]) :
                    """<span class="person unknown">$name</span>""" for
                    name ∈ entry["with"]
                ],
                ", ",
                ", and ",
            )
            info = """$(info)<span class="with">$names</span>
                """
        end
        instname =
            haskey(entry, "university") ? institute_name(entry["university"], "short") : ""
        (length(info) > 0) && (info = """
                                        <span class="info">$info</span>""")
        list_html = """$(list_html)
                       <dt class="semester">$(get(entry,"term",""))</dt>
                       <dd class="course">
                           $(entry_to_html(entry,"name"; link="link"))$(entry_to_html(entry,"text"))$(instname)$info
                       </dd>
                    """
    end
    return """
              <dl class="courses">
              $(list_html)
              </dl>
           """
end
