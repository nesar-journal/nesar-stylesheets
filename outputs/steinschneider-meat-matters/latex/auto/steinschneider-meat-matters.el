(TeX-add-style-hook
 "steinschneider-meat-matters"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "components/component-header"
    "components/component-prefatory"
    "components/component-end")
   (LaTeX-add-labels
    "tab1"
    "tab2"
    "fig1"
    "Alsdorf2010"
    "Ambalavanar2006"
    "Arunacalam2005"
    "Atikalaciriyar1970"
    "Balasubramanian2013"
    "Bayly1989"
    "Beck1972"
    "BenHerut2018"
    "Bryan2006"
    "Bryson2017"
    "Burchett2019"
    "CantalinkaCuvamikal1844"
    "CantalinkaCuvamikal1927"
    "Cettiar1912"
    "ChandraShobhi2005"
    "Cherian2023"
    "Clooney1998"
    "Clooney2014"
    "Cox2005"
    "Doniger2009"
    "Emmrich2011"
    "Fisher2017"
    "Freidenreich2011"
    "Ganesan2009"
    "GhassemFachandi2012"
    "Goodall1998"
    "Hudson1992"
    "Koppedrayer1990"
    "Martin1983"
    "Minkowski2002"
    "Monius2004"
    "Monius2018"
    "Mundra2022"
    "Nanacinkaram1986"
    "Nandy1983"
    "Natarajan1991"
    "Nicholson2010"
    "NilakantaSastri1958"
    "Olivelle1995"
    "Peterson1998"
    "Rabin2017"
    "Rajamanickam1972"
    "Raman2022"
    "Ramanujan1973"
    "Rao1992"
    "Roy2015"
    "Sanderson20122013"
    "Sivaraman2001"
    "SmithHansen2019"
    "Staples2020"
    "Stoker2016"
    "Steinschneider2016"
    "TamilLex"
    "Trento2022"
    "Tubb2007"
    "Ulrich2007"
    "UtanAtikal2009"
    "Venkatraman1990"
    "Weiss2009"
    "Young1995"
    "Zimmerman1987"
    "Zupanov1999"
    "Zvelebil1973"))
 :latex)

