# NESAR Stylesheets

## Step 1: Going from DOCX to TEI

```
python3 docx_to_tei.py FILENAME.docx
```

Will create a TEI file, lightly postprocessed, called `FILENAME-postprocessed.xml`.

Note that this shell script requires the [TEI stylesheets](https://github.com/TEIC/Stylesheets), and you should change `docx_to_tei.py` to point to the relevant transformation (`docxtotei`) on your own computer.

## Step 2: Manually editing and checking the TEI

- [ ] Add **author** (`fileDesc/titleStmt/author`).
- [ ] Add **abstract** (`profileDesc/abstract`).
- [ ] Add **language usage** (`profileDesc/langUsage`) and check all foreign-language text and titles.
- [ ] Check all **bibliography** elements in the text and in the bibliography, and make sure they have operational cross-references.
- [ ] Check the **quotations** to ensure they are in a `<quote>` element with the proper language.

If there are text-critical notes:
- [ ] Put apparatus entries in a `<listApp>` element.

## Step 3: Going from TEI to HTML/LaTeX

```
python3 tei_to_html.py FILENAME.xml
```

Will generate `FILENAME.html` that can then be used as the HTML galley.
