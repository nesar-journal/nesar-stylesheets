(TeX-add-style-hook
 "component-prefatory"
 (lambda ()
   (TeX-run-style-hooks
    "components/component-infopage"
    "metadata/metadata-first-page"
    "metadata/metadata-subtitle"
    "metadata/metadata-author-list"
    "metadata/metadata-abstract"
    "metadata/metadata-tags"))
 :latex)

