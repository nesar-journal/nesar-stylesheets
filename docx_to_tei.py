import re, os, string, sys, pathlib, subprocess, time
from lxml import etree
from itertools import chain

namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
parser = etree.XMLParser(recover=True,encoding='utf-8')
bin_path = "bash ~/Applications/Stylesheets/bin/docxtotei"

def docx_to_tei(f):
    docxtotei = bin_path + " " + str(f)
    try:
        proc = subprocess.Popen(docxtotei,shell=True).wait()
        with open(f.stem + ".xml","r") as o:
            text = o.read()
            return text
    except Exception as ex:
        template = "The DOCX to TEI conversion failed (type {0}). Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)

def xsl_postprocess(tei,inputfile):
    outputfile = inputfile.stem + "-postprocessed.xml"
    x = etree.fromstring(tei.encode('utf-8'),parser=parser)
    string = etree.tostring(x, pretty_print=True, encoding='unicode')
    with open('intermed.xml','w') as o:
        o.write(string)
    xsl = str(pathlib.Path(__file__).parent.absolute()) + "/xsl/postprocess_tei.xsl"
    source = "-s:intermed.xml"
    stylesheet = "-xsl:'"+xsl+"'"
    output = "-o:'"+outputfile+"'"
    javacall = "java -cp /usr/share/java/*:/usr/share/java/ant-1.9.6.jar net.sf.saxon.Transform "+source+ " "+stylesheet+" "+output
    try:
        txt = subprocess.Popen(javacall,stdout=subprocess.PIPE,shell=True).wait()
        with open(outputfile,"r") as i:
            return i.read().encode('utf-8')
    except Exception as ex:
        template = "An exception of type {0} occurred B. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)

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
authors: 
  - author:
      firstname: FIRSTNAME (STRING)
      lastname: LASTNAME (STRING)
      institution: INSTITUTION (STRING)
      email: EMAIL (STRING)
title: TITLE (STRING)
shorttitle: TITLE (STRING)
issue: ISSUE (INTEGER)
article: ARTICLE (INTEGER)
year: YEAR (STRING)
date: DATE (STRING)
doi: DOI (STRING)
license: LICENSE (STRING)
slug: SLUG (STRING)
citation: CITATION (STRING)
""")

def cleanup(inputfile):
    os.remove(inputfile.stem + ".xml")
    os.remove("intermed.xml")
    os.remove(inputfile.stem + "-postprocessed.xml")

if __name__ == "__main__":
    inputfile = pathlib.Path(sys.argv[1]).absolute()
    tei = docx_to_tei(inputfile)
    tei = xsl_postprocess(tei,inputfile)
    tei = detect_bibliography(tei)
    with open(inputfile.stem + "-postprocessed.xml",'w') as o:
        o.write(tei)
    generate_yaml(inputfile)
    cleanup(inputfile)
