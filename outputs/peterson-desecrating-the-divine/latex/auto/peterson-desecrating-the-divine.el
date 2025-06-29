(TeX-add-style-hook
 "peterson-desecrating-the-divine"
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
    "fig1"
    "fig2"
    "fig3"
    "fig4"
    "Sadagopachariar"
    "ToI1910a"
    "ToI1910b"
    "Baslingappa"
    "Pandurang"
    "ToI1911"
    "ToI1916"
    "Dundappa"
    "Saiyid"
    "Martin"
    "Sangabasavaswami"
    "Chandu"
    "ARMAD"
    "Gazetteer"
    "IndianCases"
    "Kane1918"
    "Olivelle1998"
    "Madhva2009"
    "MBh"
    "NarayanaPandita2017"
    "Sivadharmottara"
    "Kasikhanda1908"
    "Sivayogin2015"
    "VP"
    "Vyasastaka"
    "Vyasavarnana"
    "Bayly1985"
    "Biardeau2002"
    "Bisschop2021"
    "Bronner2007"
    "Gruenendahl1989"
    "Gruenendahl2002"
    "Gruenendahl1997"
    "Hiltebeitel2005"
    "Latthe1924"
    "Mackenzie1873"
    "Mesquita2000"
    "Mesquita2008"
    "Minkowski1989"
    "Rao2012"
    "Rao1990"
    "Oppert1893"
    "Pandey1990"
    "Peterson2023"
    "Pinney2004"
    "Pinney2009"
    "Ripepi1997"
    "Saindon20042005"
    "Sakhare1942"
    "Shembavnekar1947"
    "Sheridan1992"
    "Stainton2019"
    "Sullivan1999"))
 :latex)

