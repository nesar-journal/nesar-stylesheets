import re, os, string, sys, pathlib, subprocess, time
from lxml import etree
from itertools import chain
from saxonche import PySaxonProcessor

namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
parser = etree.XMLParser(recover=True,encoding='utf-8')
schemafile = str(pathlib.Path(__file__).parent.parent / 'schemas' / 'tei_all.rng')

def validate(f):
    relaxng_doc = etree.parse(schemafile)
    print("Checking if document is valid...")
    relaxng = etree.RelaxNG(relaxng_doc)
    return relaxng.assertValid(f)

def generate_html(tei,inputfile):
    outputs_dir = inputfile.parent / 'outputs'
    outputs_dir.mkdir(exist_ok=True)
    outputfile = outputs_dir / (inputfile.stem + '.html')
    xsl = str(pathlib.Path(__file__).parent.absolute()) + "/stylesheet-HTML.xsl"
    with PySaxonProcessor(license=False) as proc:
        xslt = proc.new_xslt30_processor()
        xslt.transform_to_file(
            source_file=str(inputfile),
            stylesheet_file=xsl,
            output_file=str(outputfile),
        )
    print("HTML file produced.")

if __name__ == "__main__":
    inputfile = pathlib.Path(sys.argv[1]).absolute()
    tei = etree.parse(inputfile,parser=parser)
    valid = validate(tei)
    if valid == None:
        print(sys.argv[1] + " is valid TEI.")
        generate_html(tei,inputfile)
