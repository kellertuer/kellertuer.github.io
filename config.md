<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
@def website_title = "Ronny Bergmann"
@def website_descr = "Example website using Franklin"
@def website_url   = "https://ronnybergmann.net/"

@def author = "Ronny Bergmann"

@def mintoclevel = 2

<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
@def ignore = ["data/", "node_modules/", "franklin", "franklin.pub", "Readme.md", "*.jl", "*.json"]

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\cM}{\mathcal M}
\newcommand{\highlight}[1]{~~~<span class="highlight">#1</span>~~~}
\newcommand{\floatleftimg}[2]{~~~<img src="#1" alt="#2" class="floatleft"/>~~~}
\newcommand{\floatrightimg}[2]{~~~<img src="#1" alt="#2" class="floatright"/>~~~}
\newcommand{\ronnybergmann}[1]{~~~<div class="rb#1" id="ronnybergmann"><span class="firstname">Ronny</span><span class="lastname">Bergmann</span></div>~~~}