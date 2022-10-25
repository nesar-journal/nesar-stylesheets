(TeX-add-style-hook
 "00-header"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("memoir" "12pt" "article" "oneside")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("extdash" "shortcuts") ("footmisc" "bottom" "marginal" "multiple") ("forest" "linguistics") ("metre" "en")))
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
    "author"
    "date"
    "slug"
    "doi"
    "memoir"
    "memoir12"
    "polyglossia"
    "extdash"
    "tikz"
    "pgf"
    "tipa"
    "calc"
    "natbib"
    "xcolor"
    "hyperref"
    "ragged2e"
    "changepage"
    "footmisc"
    "forest"
    "pgfornament"
    "booktabs"
    "multirow"
    "enumitem"
    "metre")
   (TeX-add-symbols
    '("phonem" 1)
    '("phonet" 1)
    '("textgreek" 1)
    '("graph" 1)
    "longmark"
    "mora"
    "syll"
    "thinskip"
    "emdash"
    "Dash"
    "Ldash"
    "Rdash")
   (LaTeX-add-environments
    "changemargin"
    '("exe" 1))
   (LaTeX-add-counters
    "excounter")
   (LaTeX-add-polyglossia-langs
    '("english" "defaultlanguage" "")
    '("sanskrit" "otherlanguage" "")
    '("tamil" "otherlanguage" ""))
   (LaTeX-add-fontspec-newfontcmds
    "tamilfont"
    "sanskritfont"
    "greekfont")
   (LaTeX-add-xcolor-definecolors
    "Nesarlink"))
 :latex)

