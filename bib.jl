using YAML, Dates
literature = YAML.load_file("data/literature.yaml")

"""
    isless_bibtex(a,b)

"""
function isless_bibtex(a::Dict,b::Dict)
    #load either publication date or year
    date_a = parse(Date, string( get(a, "publication_date", a["year"]) ))
    date_b = parse(Date, string( get(b, "publication_date", b["year"]) ))
    if date_a == date_b
        # if same day (or year) sort by title
        return isless(a["title"], b["title"])
    else
        # order by reverse date, i.e. newest years top
        return !(isless(date_a,date_b))
    end
end
"""
    {{library types file}}

print a library restricted to the comma separated list of types, from the optional library
`file`, which defaults to using the preloaded `data/literature.yaml`.

If no types are given all will be printed

"""
function hfun_library(params)
    types = (length(params)>0) ? lowercase.(strip.(split(params[1],","))) : ["all",]
    library = (length(params)>1) ? YAML.load_file(params[2]) : literature
    reduced_library = filter( x-> (x[2]["biblatextype"] ∈ types) || ("all" ∈ types), library)
    list_html = "";
    if length(params) > 2
        title = params[3]
        if length(reduced_library) > 0
            list_html = """$(list_html)
                        <h2>$title</h2>
                    """
        end
    end
    list = sort(collect(reduced_library), lt=isless_bibtex, by=x->x[2])
    for entry ∈ list
        list_html = """$(list_html)
                        $(format_bibtex_entry(entry[2],entry[1]))
                    """
    end
    return  """
            <ol class="bibliography" style="counter-reset:bibitem $(length(list)+1)">
                $list_html
            </ol>
            """
end
hfun_library() = hfun_library([])
"""
    print entry with key`params[1]` from the library `params[2]`, which defaults to the preloaded `literature.yaml`
"""
function hfun_bibentry(params)
    key = params[1]
    library = (length(params)>1) ? YAML.load_file(params[2]) : literature
    entry = library[key]
    !(haskey(library,key)) && return "<li> key $key not found in library.</li>"
    return format_bibtex_entry(entry,key)
end
function formatspan(entry,field; class=field, prefix="", remove=[])
    s = "";
    if entry[field] isa Vector #concat list
        s = join( [ (has_name(name) ? hfun_person([name,"bibname_fnorcid"]) : """$(prefix)$(length(prefix)>0 ? " " : "")<span class="person unknown">$name</span>""") for name ∈ entry[field] ], ", ")
    else
        s = """$(prefix)$(length(prefix)>0 ? " " : "")<span class="$field">$(entry[field])</span>"""
    end
    for r in remove
        s = replace(s, r => "")
    end
    return s
end
formatlazyspan(entry,field; kwargs...) = haskey(entry,field) ? formatspan(entry,field; kwargs...) : ""
function format_bibtex_entry(entry,key)
    names = join( [ has_name(name) ? hfun_person([name,"bibname_fnorcid"]) : """<span class="person unknown">$name</span>""" for name ∈ entry["author"] ], ", ")
    s = "";
    if haskey(entry,"image") #image in assets
        s = """$s
            <div class="item-icon-wrapper">
                <img src="../assets/bib/$(entry["image"])" alt="Publication illustration image">
            </div>
            """
    end
    s = """$s
        $(names)$(formatspan(entry,"year"))$(formatspan(entry,"title"; remove=["{","}"]))
        <br>
        $(formatlazyspan(entry, "editor"; prefix="in: "))$(formatlazyspan(entry,"booktitle"; prefix= haskey(entry,"editor") ? ": " : "in: "))$(formatlazyspan(entry, "chapter"; prefix=", Chapter "))$(formatlazyspan(entry,"journaltitle";class="journal"))$(formatlazyspan(entry,"series"; prefix=", "))$(formatlazyspan(entry,"volume"))$(formatlazyspan(entry,"number"))$(formatlazyspan(entry,"issue"))$(formatlazyspan(entry,"pages"))$(formatlazyspan(entry,"publisher"; prefix=", "))$(formatlazyspan(entry,"type"))$(formatlazyspan(entry,"language"; prefix=", "))$(formatlazyspan(entry,"school"; prefix=", "))$(formatlazyspan(entry,"note"))
        <ul class="nav nav-icons">
        """
    #bibtex icon
    s = """$s
        <li>
            <a data-toggle="collapse" href="#$key-bibtex" title="toggle visibility of the biblatex for $key">
                <i class="fas fa-lg fa-file-code"></i>
            </a>
        </li>"""
    if haskey(entry,"abstract") #abstract icon
        s = """$s
            <li>
                <a data-toggle="collapse" href="#$key-abstract" title="toggle visibility of the abstract for $key">
                    <i class="fas fa-lg fa-file-alt"></i>
                </a>
            </li>"""
    end
    if haskey(entry,"eprint") && (lowercase(get(entry,"eprinttype",""))=="arxiv") #pdf icon
        s = """$s
            <li>
                <a href="https://arxiv.org/pdf/$(entry["eprint"])" title="arXiv:$(entry["eprint"])" target="_blank">
                    <i class="fas fa-lg fa-file-pdf"></i>
                </a>
            </li>
            """
    end
    if haskey(entry,"doi") #doi icon
        s = """$s
            <li>
                <a href="http://dx.doi.org/$(entry["doi"])" title="$(entry["doi"])" target="_blank">
                    <i class="ai ai-lg ai-doi"></i>
                </a>
            </li>
            """
    end
    if haskey(entry,"github") #doi icon
        s = """$s
            <li>
                <a href="https://github.com/$(entry["github"])" title="Link to the github repository $(entry["github"])" target="_blank">
                    <i class="fab fa-github"></i>
                </a>
            </li>
            """
    end
    if haskey(entry,"link") #doi icon
        s = """$s
            <li>
                <a href="$(entry["link"])" title="$(entry["link"])" target="_blank">
                    <i class="fas fa-link"></i>
                </a>
            </li>
            """
    end
    s = """$s
        </ul>
    """
    # bibtex entry
    s = """$s
        <div id="$key-bibtex" class="blockicon bibtex collapse fas fa-lg fa-file-code">
            <div class="content">$(format_bibtex_code(entry, key))</div>
        </div>
        """
    if haskey(entry,"abstract") # abstract content
        s = """$s
        <div id="$key-abstract" class="blockicon abstract collapse fas fa-lg fa-file-alt">
            <div class="content">$(entry["abstract"])</div>
        </div>
        """
    end
    return """<li>$s</li>"""
end
"""
    format_bibtex_code(entry,key)

use the dictionary `entry` and the literature `key` to format a biblatex output.
the type os taken from the `biblatextype` field (defaults to "article").
You can `exclude` a set of fields (by default those that are currently used to enhance the entry)
and the `joined` fields are arrays that are joined with `and` after the fields are checked for
valid `names` (from `names.yaml`), where the `bib` form of `name` is taken
"""
function format_bibtex_code(
    entry,
    key;
    excludes = ["biblatextype", "image", "link", "file", "github", "publication_date"],
    field_joins = ["author", "editor"] )
    s = "";
    for f ∈ keys(entry)
        if f ∉ excludes
            v = ""
            if f ∈ field_joins
                v = join(
                    [ has_name(name) ? hfun_person([name, "plain_bibname"]) : name for name ∈ entry[f] ],
                    " and ",
                )
            else
                v = entry[f]
            end
            multiline = lowercase(f) ∈ ["abstract"]
            s = "$s\n    $(f) = {$(multiline ? "\n    " : "")$(v)$(multiline ? "    " : "")}"
        end
    end
    s = """@$(get(entry, "biblatextype", "article")){$key,$s
        }"""
    return s
end