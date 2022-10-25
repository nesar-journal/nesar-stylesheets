import re, os, string, sys, pathlib, subprocess, time, yaml
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

def generate_latex(tei,inputfile):
    outputfile = inputfile.stem + ".tex"
    xsl = str(pathlib.Path(__file__).parent.absolute()) + "/xsl/stylesheet-LaTeX.xsl"
    source = "-s:"+str(inputfile)
    stylesheet = "-xsl:'"+xsl+"'"
    output = "-o:'"+outputfile+"'"
    javacall = "java -cp /usr/share/java/*:/usr/share/java/ant-1.9.6.jar net.sf.saxon.Transform "+source+ " "+stylesheet
    try:
        txt = subprocess.Popen(javacall,stdout=subprocess.PIPE,shell=True).wait()
        print("LaTeX file produced.")
    except Exception as ex:
        template = "An exception of type {0} occurred B. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)

def comma_join(lst):
    if not lst:
        return ""
    elif len(lst) == 1:
        return str(lst[0])
    return "{} and {}".format(", ".join(lst[:-1]), lst[-1])

def generate_metadata(inputfile):
    with open(inputfile.stem + ".yaml","r") as stream:
        try:
            metadata = yaml.safe_load(stream)
            if "shorttitle" not in metadata:
                metadata["shorttitle"] = metadata["title"]
            for key in metadata:
                if key == "authors":
                    with open("./latex/metadata-author-full.tex","w") as authFull:
                        authors = []
                        for x in metadata["authors"]:
                            authors.append(x["author"]["firstname"] + " " + x["author"]["lastname"])
                        authFull.write(comma_join(authors))
                    with open("./latex/metadata-author-short.tex","w") as authShort:
                        authors = []
                        for x in metadata["authors"]:
                            authors.append("\\textsc{"+x["author"]["lastname"].lower()+"}")
                        authShort.write(comma_join(authors))
                    with open("./latex/metadata-author-list.tex","w") as authList:
                        columns = [] 
                        authors = []
                        institutions = []
                        emails = []
                        for i in metadata["authors"]:
                            columns.append("c")
                            authors.append(i["author"]["firstname"] + " " + i["author"]["lastname"])
                            institutions.append("{\\small\\emph{"+ i["author"]["institution"] + "}}")
                            emails.append("{\\small\\href{mailto:"+i["author"]["email"]+"}{\\texttt{"+i["author"]["email"]+"}}}")
                            authList.write("\\begin{tabular}{" + "@{\hskip 1.5em}".join(columns) + "}\n")
                            authList.write(" & ".join(authors) + "\\\\[2ex]\n")
                            authList.write(" & ".join(institutions) + "\\\\[1ex]\n")
                            authList.write(" & ".join(emails) + "\n")
                            authList.write("\\end{tabular}")
                else:
                    with open("./latex/metadata-"+key+".tex","w") as out:
                        out.write(str(metadata[key]))
        except yaml.YAMLError as exc:
            print(exc)
        
def generate_pdf(inputfile):
    try:
        os.chdir('latex')
        txt = subprocess.Popen("xelatex latex.tex", shell=True)
        txt.communicate()
        txt = subprocess.Popen("xelatex latex.tex", shell=True)
        txt.communicate()
        txt = subprocess.Popen("bibtex latex", shell=True)
        txt.communicate()
        txt = subprocess.Popen("xelatex latex.tex", shell=True)
        txt.communicate()
        os.replace("latex.pdf","../"+inputfile.stem+".pdf")
        print("PDF file produced.")
    except Exception as ex:
        template = "An exception of type {0} occurred B. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)

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
        generate_latex(tei,inputfile)
        generate_metadata(inputfile)
        generate_pdf(inputfile)
        if os.path.isfile(inputfile.stem + '.tex'):
            generate_pdf(inputfile.stem + '.tex')
