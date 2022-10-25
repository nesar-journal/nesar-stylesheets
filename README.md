# NESAR Stylesheets

Required Python libraries: `lxml`, `re`, `os`, `string`, `sys`, `pathlib`, `subprocess`, `time`, `yaml`, `chain`

## Step 1: Going from DOCX to TEI

```
python3 docx_to_tei.py FILENAME.docx
```

Will create a TEI file, lightly postprocessed, called `FILENAME-postprocessed.xml`. It will also create a template for the metadata called `FILENAME.yaml`.

Note that this shell script requires the [TEI stylesheets](https://github.com/TEIC/Stylesheets), and you should change `docx_to_tei.py` to point to the relevant transformation (`docxtotei`) on your own computer. Please edit the variable `bin_path` in `docx_to_tei.py` with the correct path on your machine.

## Step 2: Manually editing and checking the TEI

- [ ] Add **author** (`fileDesc/titleStmt/author`).
- [ ] Add **abstract** (`profileDesc/abstract`).
- [ ] Add **language usage** (`profileDesc/langUsage`) and check all foreign-language text and titles.
- [ ] Check all **bibliography** elements in the text and in the bibliography, and make sure they have operational cross-references.
- [ ] Check the **quotations** to ensure they are in a `<quote>` element with the proper language.

If there are text-critical notes:
- [ ] Put apparatus entries in a `<listApp>` element.

## Step 3: Add the YAML metadata

Edit the file `FILENAME.yaml` to reflect the correct metadata. This will be used in the LaTeX conversion.

## Step 4: Going from TEI to HTML/LaTeX

```
python3 tei_to_html.py FILENAME.xml
```

will generate `FILENAME.html` that can then be used as the HTML galley.

```
python3 tei_to_latex.py FILENAME.xml
```

will generate `FILENAME.pdf` that can be used as the PDF galley.


## More on the PDF conversion

The PDF conversion runs `xelatex`, which is required. The required LaTeX packages are listed in `latex/component-header.tex`. The Python script generates `latex/data.tex` and the associated `latex/metadata-*.tex` files; the `latex/component-*.tex` files do not change. All `metadata` and `component` files, along with `data.tex`, are included in `latex.tex`.

```
|   FILENAME.xml
|
|__ latex
|   |   latex.tex
|   |   component-header.tex
|   |   component-infopage.tex
|   |   component-license-cc-by-4.tex
|   |   component-end.tex
|   |   metadata-article.tex
|   |   metadata-author-full.tex
|   |   metadata-author-list.tex
|   |   metadata-author-short.tex
|   |   metadata-citation.tex
|   |   metadata-date.tex
|   |   metadata-doi.tex
|   |   metadata-issue.tex
|   |   metadata-license.tex
|   |   metadata-shorttitle.tex
|   |   metadata-slug.tex
|   |   metadata-title.tex
|   |   metadata-year.tex
|
|__ images
|   |  ...
|
|__ xsl
|   |  stylesheet-LaTeX.xsl
|
```

Details on BibTeX to follow soon.
