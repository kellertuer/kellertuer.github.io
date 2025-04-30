#
# Collect a few small helpers to generate html from dicrionaries that we got from yamls.
#
function entry_to_html(data, key; class = key, iconstyle = "fas", icon = "", link = "")
    icon_str = length(icon) > 0 ? """<i class="$iconstyle $icon"></i>""" : ""
    !haskey(data, key) && return ""
    prep = data[key]
    if haskey(data, link)
        prep = """<a href="$(data[link])" title="link to $prep">$prep</a>"""
    end
    return """$(icon_str)
              <span class="$class">$prep</span>
           """
end
function entries_to_group(
    data,
    keys;
    classes = keys,
    group_class = "group",
    iconstyle = "fas",
    icon = "",
)
    icon_str = length(icon) > 0 ? """<i class="$iconstyle $icon"></i>""" : ""
    return """$(icon_str)
              <span class="$(group_class)">
                  $(join(entry_to_hmtl.(Ref(data),keys; class=classes), "\n    "))
              </span>
           """
end
function entry_to_list_icon(
    data,
    key;
    linkprefix = "",
    iconstyle = "fas",
    icon = "",
    title = get(data, key, key),
)
    !haskey(data, key) && return ""
    return """
              <li>
                  <a href="$(linkprefix)$(data[key])" title="$(title)" target="_blank">
                      <i class="$iconstyle $icon"></i>
                  </a>
               </li>
           """
end
