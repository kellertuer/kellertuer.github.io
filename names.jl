#
# Load and handle data for names of people and things
#
using YAML
names = YAML.load_file("data/names.yml")
people = names["people"]

"""
    {{name Person style}}

Print the name of a person fom the `names.yml` `person` dictionary in different styles
* `fullname` – display full name, which is the default
* `shortname` - display first name in short
* `bibname` – display last name, first name

All following styles are ignored without an error if the corresponding field does not exist
Additionally you can style the name with a prefix
* `link_` to wrap the name in a link to their `url`

postfix a <sup> icon link to
* `_fntwitter` – to add a `twitter` icon link
* `_fngithub` – to add their `github` icon link
* `_fnorcid` – to add their `orcid` id link
* `_fnscholar` to add their google `scholar` link

where their order of appearance orders the supnotes.

# Example Styles
* `link_fullname_fntwitter` link the fullname to the url and add a twitter note
* `bibname_fnorcid_fnscholar` add orcid and scholar footnotes to the bibname
"""
function hfun_name(params::Vector{String})::String
    name = params[1]
    style = (length(params) > 1) ? params[2] : "fullname"
    print("Style: $style\n")
    s = ""
    !haskey(names["people"],name) && return "<span class\"error\">Person „$(name)“ not found</span>"
    person = names["people"][name]
    print("person: $person\n")
    fullname = """<span class="person">$(person["name"]["full"])</span>"""
    bibname = """<span class="person">$(person["name"]["bib"])</span>"""
    title_fullname = """<span class="person">$(get(person, "title", ""))$(haskey(person,"title") ? " " : "")$(person["name"]["full"])</span>"""
    occursin("fullname",style) && (s = fullname)
    occursin("nametitle", style) && (s = title_fullname)
    occursin("bibname", style) && (s = bibname)
    print("Styled name $s\n")
    (haskey(person,"url") && occursin("link_",style)) && (s = """<a href="$(person["url"])">$s</a>""")
    supnotes = ["twitter", "github", "orcid", "scholar"]
    supurlprefixes = ["https://twitter.com/", "https://github.com/", "https://orcid.org/", "https://scholar.google.com/citations?user="]
    icons = [
        """<i class="fab fa-twitter"></i>""",
        """<i class="fab fa-github"></i>""",
        """<i class="ai ai-orcid-square"></i>""",
        """<i class="ai ai-google-scholar-square"></i>""",
    ]
    pos = [ occursin("_fn$fn", style) ? first(findfirst(fn,style)) : -1 for fn in supnotes]
    for i in sortperm(pos)
        if haskey(person,supnotes[i]) && (pos[i] > 0)
            s = """$s<sup><a href="$(supurlprefixes[i])$(person[supnotes[i]])">$(icons[i])</a></sup>"""
        end
    end
    print("Final: $s\n\n")
    return s
end