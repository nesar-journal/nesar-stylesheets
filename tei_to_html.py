import re, os, string, sys, pathlib, subprocess, time
from lxml import etree
from itertools import chain

namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
parser = etree.XMLParser(recover=True,encoding='utf-8')
schemafile = 'schemas/tei_all.rng'

def validate(f):
    relaxng_doc = etree.parse(schemafile)
    print("Checking if document is valid...")
    relaxng = etree.RelaxNG(relaxng_doc)
    return relaxng.assertValid(f)

def generate_html(tei,inputfile):
    outputfile = inputfile.stem + ".html"
    xsl = str(pathlib.Path(__file__).parent.absolute()) + "/xsl/stylesheet-HTML.xsl"
    source = "-s:"+str(inputfile)
    stylesheet = "-xsl:'"+xsl+"'"
    output = "-o:'"+outputfile+"'"
    javacall = "java -cp /usr/share/java/*:/usr/share/java/ant-1.9.6.jar net.sf.saxon.Transform "+source+ " "+stylesheet+" "+output
    try:
        txt = subprocess.Popen(javacall,stdout=subprocess.PIPE,shell=True).wait()
        print("HTML file produced.")
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

def cleanup(inputfile):
    os.remove(inputfile.stem + ".xml")
    os.remove("intermed.xml")
    os.remove(inputfile.stem + "-postprocessed.xml")

if __name__ == "__main__":
    inputfile = pathlib.Path(sys.argv[1]).absolute()
    tei = etree.parse(inputfile,parser=parser)
    valid = validate(tei)
    if valid == None:
        print(sys.argv[1] + " is valid TEI.")
        generate_html(tei,inputfile)
