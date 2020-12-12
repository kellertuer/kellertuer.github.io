using YAML
literature = YAML.load_file("data/literature.yaml")




function hfun_bibentry(params)
    key = params[1]
    display_key = length(params) > 1 ? params[2] : key
    !(haskey(literature,key)) && return "<li> key $key not found in literature."
    entry = literature[key]
    names = string( [ hfun_name([name,"bibname_fnorcid"]) for name ∈ entry["author"] ]...)
    s = """$names, ($(entry["year"])). <span class="title">$(entry["title"])</span>
    <span class="journal">$(entry["journaltitle"])</span>
    $(haskey(entry,"volume") ? "<span class=\"volume\">$(entry["volume"])</span>" : "")
    $(haskey(entry,"number") ? "<span class=\"number\">$(entry["number"])</span>" : "")
    $(haskey(entry,"pages") ? "<span class=\"pages\">$(entry["pages"])</span>" : "")
    <ul class="nav, nav-pills">"""
    if haskey(entry,"abstract") #abstract icon
        s = """$s
            <li>
                <a data-toggle="collapse" href="#$key-abstract" class aria-expanded="false">
                    <i class="fas fa-lg fa-file-alt"></i>
                </a>
            </li>"""
    end
    if haskey(entry,"eprint") && (get(entry,"eprinttype","")=="arxiv") #pdf icon
        s = """$s
            <li>
                <a href="https://arxiv.org/pdf/$(entry["eprint"])" title="$(entry["eprint"])" target="_blank">
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
    s = """$s
        </ul>
    """
    if haskey(entry,"abstract") # abstract content
        s = """$s
        <div id="$key-abstract" class="abstract">
            $(entry["abstract"])
        </div>
        """
    end
    return """<li>$s</li>"""
end
