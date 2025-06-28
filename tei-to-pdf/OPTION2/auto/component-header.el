(TeX-add-style-hook
 "component-header"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("memoir" "12pt" "article" "twosided")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("extdash" "shortcuts") ("tcolorbox" "most") ("footmisc" "bottom" "marginal" "multiple") ("forest" "linguistics")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "metadata-year"
    "metadata-author-full"
    "metadata-title"
    "metadata-article"
    "metadata-issue"
    "metadata-author-short"
    "title"
    "component-infopage"
    "metadata-author-list"
    "memoir"
    "memoir12"
    "polyglossia"
    "extdash"
    "tikz"
    "pgf"
    "tipa"
    "fontawesome5"
    "calc"
    "natbib"
    "xcolor"
    "catchfile"
    "graphicx"
    "graphbox"
    "ragged2e"
    "changepage"
    "trimspaces"
    "framed"
    "tcolorbox"
    "footmisc"
    "forest"
    "pgfornament"
    "booktabs"
    "multirow"
    "wrapfig"
    "enumitem"
    "hyperref")
   (TeX-add-symbols
    '("phonem" 1)
    '("phonet" 1)
    '("textgreek" 1)
    '("graph" 1)
    '("picon" 1)
    '("oldnumsbold" 1)
    '("oldnums" 1)
    "Nyear"
    "Nauthor"
    "Ntitle"
    "article"
    "issue"
    "sectionsecnumformat"
    "onpage"
    "ccbylicenseButton"
    "journallink"
    "doilink"
    "iay"
    "brand"
    "shauthor"
    "footer"
    "titleM"
    "longmark"
    "mora"
    "syll"
    "thinskip"
    "trim"
    "emdash"
    "Dash"
    "Ldash"
    "Rdash")
   (LaTeX-add-environments
    "changemargin"
    '("exe" 1))
   (LaTeX-add-counters
    "excounter")
   (LaTeX-add-lengths
    "drop")
   (LaTeX-add-polyglossia-langs
    '("english" "defaultlanguage" "")
    '("sanskrit" "otherlanguage" "")
    '("tamil" "otherlanguage" "")
    '("telugu" "otherlanguage" "")
    '("kannada" "otherlanguage" "")
    '("malayalam" "otherlanguage" ""))
   (LaTeX-add-fontspec-newfontcmds
    "tamilfont"
    "sanskritfont"
    "greekfont")
   (LaTeX-add-xcolor-definecolors
    "Nesarlink"
    "Nesarlinkdark"
    "Nesarlinklight"
    "formalshade"
    "darkblue")
   (LaTeX-add-tcolorbox-newtcolorboxes
    '("titlebox" "1" "[" "")
    '("pullquote" "" "" "")))
 :latex)

