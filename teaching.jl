using YAML, Dates
students = YAML.load_file("data/students.yaml")
teaching = YAML.load_file("data/teaching.yaml")

"""
    is_less_supervision(a,b)
    return, whether a is a jounger student project than b, where if they are equal
    we go for alphabetica, for example also if both are not finished yet
"""
function isless_finished(a::Dict,b::Dict)
    if !haskey(a, "finishes") && !haskey(b, "finished")
        return a["name"] < b["name"]
    end
    !haskey(a, "finished") && return false #a not finished but b, then a is not less
    !haskey(b, "finished") && return true
    # if both are finished compare finished dates
    date_a = parse(Date, string(a["finished"]))
    date_b = parse(Date, string(b["finished"]))
    return !(isless(date_a,date_b))
end
"""
    {{library types file}}

print a library restricted to the comma separated list of types, from the optional library
`file`, which defaults to using the preloaded `data/literature.yaml`.

If no types are given all will be printed

"""
function hfun_students(params)
    types = (length(params)>0) ? lowercase.(strip.(split(params[1],","))) : ["all",]
    theses = (length(params)>1) ? YAML.load_file(params[2]) : students
    reduced_theses = filter( x-> (x["type"] ∈ types) || ("all" ∈ types), theses)
    list_html = "";
    list = sort(collect(reduced_theses), lt=isless_finished)
    for entry ∈ list
        list_html = """$(list_html)
                        $(format_supervision(entry))
                    """
    end
    return  """
            <dl class="supervised">
                $list_html
            </dl>
            """
end
function format_supervision(entry)
    # (1) date finished?
    df = ""
    if haskey(entry, "finished")
        df = Dates.format(entry["finished"], "uuu<br>yyyy")
    else
        df = "current"
    end
    # name(s)
    students = ""
    if entry["name"] isa Vector #concat list
        students = join( [ (has_name(name) ? hfun_person([name,"link_shortname"]) : """<span class="person unknown">$name</span>""") for name ∈ entry["name"] ], ", ", ", and ")
    else
        students = has_name(entry["name"]) ? hfun_person([entry["name"],"link_shortname"]) : """<span class="person unknown">$(entry["name"])</span>"""
    end

    thesis = "";
    (entry["type"]=="master") && (thesis = "master thesis")
    (entry["type"]=="bachelor") && (thesis = "bachelor thesis")
    (entry["type"]=="studentproject") && (thesis = "student project")
    with_names = "";
    if haskey(entry,"with")
        with_names = join( [ has_name(name) ? hfun_person([name,"link_shortname"]) : """<span class="person unknown">$name</span>""" for name ∈ entry["with"] ], ", ", ", and ")
        with_names = """<span class="with">$(with_names)</span>"""
    end
    return """<dt>$df</dt>
    <dd>
        <span class="student">$(students)</span>
        <span class="title">$(entry["title"])</span>
        <span class="thesis-type">$(thesis)</span>
        $(with_names)
    </dd>
    """
end