# NESAR Stylesheets

Required Python libraries: `lxml`, `re`, `os`, `string`, `sys`, `pathlib`, `subprocess`, `time`, `yaml`, `chain`, `shutil`, `glob`, `PIL`

This a repository that makes it easier to converting a DOCX file (hopefully formatting according to the [guidelines](https://nesarjournal.org/submit) on the NESAR website) into the formats published by NESAR, namely HTML and PDF, through the intermediary of a TEI file. There are three pipelines:
- [DOCX to TEI](#going-from-docx-to-tei)
- [TEI to HTML](#going-from-tei-to-html)
- [TEI to PDF](#going-from-tei-to-pdf)

## Going from DOCX to TEI

We do not use DOCX to produce the production files (HTML and PDF). We convert the text data from the DOCX into a TEI file, and we store the metadata for the file in a YAML file. These two files will then be used for all downstream conversions (see below).

### Step 1: Automatic conversion

```
python3 docx_to_tei/docx_to_tei.py FILENAME.docx
```

1. Note that this shell script requires the [TEI stylesheets](https://github.com/TEIC/Stylesheets), and you should change `docx_to_tei.py` to point to the relevant transformation (`docxtotei`) on your own computer. Please edit the variable `bin_path` in `docx_to_tei.py` with the correct path on your machine.

2. Also note that this will create a directory in `/output` based on the filename, and our convention is `lastname-title-of-article`, so the original DOCX file should have this format.

The resulting files will live in `/output/lastname-title-of-article`, and will be:
- `lastname-title-of-article-postprocessed.xml`
- `metadata.yml`

The first is a lightly postprocessed version of the automatically-created TEI file. Both files will need to be edited manually (see immediately below).

### Step 2: Manually editing and checking the TEI

- [ ] Add **author** (`fileDesc/titleStmt/author`).
- [ ] Add **abstract** (`profileDesc/abstract`).
- [ ] Add **language usage** (`profileDesc/langUsage`) and check all foreign-language text and titles.
- [ ] Check all **bibliography** elements in the text and in the bibliography, and make sure they have operational cross-references.
- [ ] Check the **quotations** to ensure they are in a `<quote>` element with the proper language.

If there are text-critical notes:
- [ ] Put apparatus entries in a `<listApp>` element.

### Step 3: Add the YAML metadata

Edit the file `metadata.yml` to reflect the correct metadata. This will be used in the LaTeX conversion, but it's also a necessary component of the NESAR website.

## Going from TEI to HTML


```
python3 tei-to-html/tei_to_html.py outputs/lastname-title-of-article/lastname-title-of-article.xml
```

will generate `lastname-title-of-article.html` that can then be used as the HTML galley.

Notes:
1. The script will first try to validate the TEI file against the schemas in `/schemas`. It will not proceed if the TEI is invalid.

## Going from TEI to PDF

We use LaTeX to produce the PDF files. This means the TEI file and YAML metadata need to be converted into a LaTeX file, which is then edited manually for fine-tuning, and compiled into a PDF.

### Step 1: Generate the LaTeX files

```
python3 tei-to-pdf/tei_to_latex.py outputs/lastname-title-of-article/lastname-title-of-article.xml
```

Note that this script will ask you for some metadata, including the issue number, article number, year, and start page. (The latter is relevant because we paginate continuously throughout an issue, so the start page of an article should be one plus the last page of the previous article.)

This sets up a directory called `latex` in `lastname-title-of-article` that contains the following files and subdirectories:
```
|   lastname-title-of-article.tex
|
|__ components
|
|__ images
|
|__ metadata
```

The LaTeX file, `lastname-title-of-article.tex` is generated by the stylesheet `stylesheet-LaTeX.xsl` in `tei-to-pdf`. It includes templates that are kept in `components`, which is simply copied from the directory of the same name in `tei-to-pdf`. `images` also contains everything included in the directory of the same name in `tei-to-pdf`, but it *also* includes JPG versions of the WEBP images included with the article. (Those are converted by `tei-to-latex.py`.) The `metadata` directory contains files that are generated by the script, and not copied over from the templates; these files are specific to each article and mostly represent the article metadata.

### Step 2: Manually edit the LaTeX files

You should be able to compile the LaTeX file in the `latex` directory, which will give you an idea of how the PDF will look *if you don't do anything else to it*. But you will almost certainly have to make some changes, which might include:

- Fixing 'runts'
- Fixing hyphenation (and adding new hyphenation patterns to `tei-to-pdf/hyphenation/nesarhyphenation.sty`)
- Adjusting tables
- Adjusting page breaks

It is useful to keep track of the manual changes needed in a text file, since you may want to regenerate the LaTeX file automatically from the TEI source, which will destroy all of the manually-introduced changes.

### Step 3: Generate the final PDF of the article

Once the manual edits are complete, you can compile the LaTeX file again:

```
xelatex lastname-title-of-article.tex
```

and this will generate `lastname-title-of-article.pdf`, the PDF galley of the article.

## To come

BibTeX support?
