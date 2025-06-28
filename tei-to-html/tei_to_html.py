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
    outputfile = inputfile.with_suffix('.html')
    xsl = str(pathlib.Path(__file__).parent.absolute()) + "/stylesheet-HTML.xsl"
    source = "-s:"+str(inputfile)
    stylesheet = "-xsl:'"+xsl+"'"
    output = "-o:'"+str(outputfile)+"'"
    javacall = "java -cp /usr/share/java/*:/usr/share/java/ant-1.9.6.jar net.sf.saxon.Transform "+source+ " "+stylesheet+" "+output
    try:
        txt = subprocess.Popen(javacall,stdout=subprocess.PIPE,shell=True).wait()
        print("HTML file produced.")
    except Exception as ex:
        template = "An exception of type {0} occurred B. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)

if __name__ == "__main__":
    inputfile = pathlib.Path(sys.argv[1]).absolute()
    tei = etree.parse(inputfile,parser=parser)
    valid = validate(tei)
    if valid == None:
        print(sys.argv[1] + " is valid TEI.")
        generate_html(tei,inputfile)
