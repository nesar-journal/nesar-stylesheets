import re, os, string, sys, pathlib, time, zipfile, tempfile, shutil
from lxml import etree
from itertools import chain
from saxonche import PySaxonProcessor

namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
parser = etree.XMLParser(recover=True,encoding='utf-8')
submodule_dir = pathlib.Path(__file__).parent.parent / 'tei-stylesheets'
docx_stylesheet = submodule_dir / 'profiles' / 'default' / 'docx' / 'from.xsl'

def docx_to_tei(f):
    inputfile = pathlib.Path(f)
    outputfile = inputfile.with_suffix('.xml')
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            with zipfile.ZipFile(f, 'r') as z:
                z.extractall(tmpdir)
            with PySaxonProcessor(license=False) as proc:
                xslt = proc.new_xslt30_processor()
                xslt.set_parameter('word-directory', proc.make_string_value('file:///' + tmpdir))
                xslt.set_parameter('inputDir', proc.make_string_value(str(inputfile.parent)))
                xslt.set_parameter('mediaDir', proc.make_string_value('word/media'))
                xslt.transform_to_file(
                    source_file=str(pathlib.Path(tmpdir) / 'word' / 'document.xml'),
                    stylesheet_file=str(docx_stylesheet),
                    output_file=str(outputfile),
                )
            media_src = pathlib.Path(tmpdir) / 'word' / 'media'
            if media_src.exists():
                shutil.copytree(str(media_src), str(inputfile.parent / 'media'), dirs_exist_ok=True)
        with open(outputfile, 'r') as o:
            return o.read()
    except Exception as ex:
        template = "The DOCX to TEI conversion failed (type {0}). Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)

def xsl_postprocess(tei,inputfile):
    outputfile = os.path.splitext(inputfile)[0] + "-postprocessed.xml"
    x = etree.fromstring(tei.encode('utf-8'),parser=parser)
    intermed = str(pathlib.Path(inputfile).parent / 'intermed.xml')
    xml_str = etree.tostring(x, pretty_print=True, encoding='unicode')
    with open(intermed,'w') as o:
        o.write(xml_str)
    xsl = str(pathlib.Path(__file__).parent.absolute()) + "/postprocess_tei.xsl"
    with PySaxonProcessor(license=False) as proc:
        xslt = proc.new_xslt30_processor()
        xslt.transform_to_file(
            source_file=intermed,
            stylesheet_file=xsl,
            output_file=outputfile,
        )
    with open(outputfile,"r") as i:
        return i.read().encode('utf-8')

def detect_bibliography(tei):
    tei = tei.decode('utf-8')
    separator_labels = re.compile(r'([0-9]{4})<title>([a-z])</title>',re.MULTILINE)
    tei = re.sub(separator_labels,r'\1\2',tei)
    bibl_with_range = re.compile(r'([A-Z]+[a-z]+) (([0-9]{4})((-|–)([0-9]{4}))*)([a-z])*: (([0-9]+)((-|–)([0-9]+))*( n\. [0-9]+))',re.MULTILINE)
    tei = re.sub(bibl_with_range,r'<ref target="#\1\2">\1 \2</ref>: <citedRange>\8</citedRange>',tei)
    bibl_without_range = re.compile(r'([A-Z]+[a-z]+) (([0-9]{4})((-|–)([0-9]{4}))*([a-z])*)',re.MULTILINE)
    tei = re.sub(bibl_without_range,r'<ref target="#\1\2">\1 \2</ref>',tei)
    bibl_parens_with_range = re.compile(r'([A-Z]+[a-z]+) \((([0-9]{4})((-|–)([0-9]{4}))*([a-z])*): (([0-9]+)((-|–)([0-9]+))*( n\. [0-9]+))\)',re.MULTILINE)
    tei = re.sub(bibl_parens_with_range,r'<ref target="#\1\2">\1</ref> (<ref target="#\1\2">\2</ref>: <citedRange>\8</citedRange>)',tei)
    bibl_parens_without_range = re.compile(r'([A-Z]+[a-z]+) \((([0-9]{4})((-|–)([0-9]{4}))*([a-z])*)',re.MULTILINE)
    tei = re.sub(bibl_parens_without_range,r'<ref target="#\1\2">\1</ref> (<ref target="#\1\2">\2</ref>)',tei)
    bibl_in_bibliography = re.compile(r'<bibl>([A-Z]+[a-z]+)(.*?)\.\s+([0-9]{4})((-|–)([0-9]{4}))*( (\[[0-9]{4}\]))*([a-z])*\.',re.MULTILINE)
    tei = re.sub(bibl_in_bibliography,r'<bibl xml:id="\1\3\4\8\9">\1\2. \3\4\7\9.',tei)
    return tei

def generate_yaml(inputfile):
    with open(inputfile.stem + ".yaml","w") as y:
        y.write("""---
type: article
identifier: SLUG
doi: DOI
title: TITLE
subtitle: SUBTITLE
authors:
  - AUTHOR
abstract: ABSTRACT
dates:
  publication: PUBLICATION DATE
paths:
  cover: COVER JPG
  pdf: PDF
  content: HTML CONTENT
  tei: XML FILE
tags:
  - LIST OF TAGS
""")

def cleanup(inputfile):
    os.remove(inputfile.stem + ".xml")
    os.remove("intermed.xml")
    os.remove(inputfile.stem + "-postprocessed.xml")

if __name__ == "__main__":
    inputfile = pathlib.Path(sys.argv[1]).absolute()
    print(inputfile)
    tei = docx_to_tei(inputfile)
    tei = xsl_postprocess(tei,inputfile)
    tei = detect_bibliography(tei)
    with open(inputfile.stem + "-postprocessed.xml",'w') as o:
        o.write(tei)
    generate_yaml(inputfile)
#    cleanup(inputfile)
