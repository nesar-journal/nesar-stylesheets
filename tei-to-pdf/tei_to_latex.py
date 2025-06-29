import re, os, string, sys, pathlib, subprocess, time, yaml, shutil, glob
from lxml import etree
from PIL import Image

from itertools import chain

namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
parser = etree.XMLParser(recover=True,encoding='utf-8')
input_file = pathlib.Path(sys.argv[1]).absolute()
first_page = 1
schema_file = pathlib.Path(str(pathlib.Path(sys.argv[0]).parents[1].absolute()) + "/schemas/tei_all.rng")
stylesheet_file = pathlib.Path(str(pathlib.Path(sys.argv[0]).parents[0].absolute()) + "/stylesheet-LaTeX.xsl")
components_directory = pathlib.Path(str(pathlib.Path(sys.argv[0]).parents[0])+ "/components/").absolute()
hyphenation_directory = pathlib.Path(str(pathlib.Path(sys.argv[0]).parents[0])+ "/hyphenation/").absolute()
images_directory = pathlib.Path(str(pathlib.Path(sys.argv[0]).parents[0])+ "/images/").absolute()
latex_directory = pathlib.Path(str(input_file.parents[0]) + "/latex")
metadata_directory = pathlib.Path(str(latex_directory) + "/metadata")
preprocessed_file = pathlib.Path(str(latex_directory) + "/" + str(input_file.stem) + ".xml")
latex_file = pathlib.Path(str(latex_directory) + "/" + str(input_file.stem) + ".tex")

def validate(f):
    relaxng_doc = etree.parse(str(schema_file))
    print("Checking if document is valid...")
    relaxng = etree.RelaxNG(relaxng_doc)
    return relaxng.assertValid(f)

def generate_latex(tei):
    source = "-s:"+str(preprocessed_file)
    stylesheet = "-xsl:'"+str(stylesheet_file)+"'"
    output = "-o:'"+str(latex_file)+"'"
    javacall = "java -cp /usr/share/java/*:/usr/share/java/ant-1.9.6.jar net.sf.saxon.Transform "+source+ " "+stylesheet+" "+output
    try:
        txt = subprocess.Popen(javacall,stdout=subprocess.PIPE,shell=True).wait()
        print("LaTeX file produced.")
    except Exception as ex:
        template = "An exception of type {0} occurred B. Arguments:\n{1!r}"
        message = template.format(type(ex).__name__, ex.args)
        print(message)
    with open(latex_file,"r") as original:
        latex = original.read()
    with open(latex_file,"w") as new:
        new.write("\\input{components/component-header}\n")
        new.write("\\setcounter{page}{"+str(first_page)+"}\n")
        new.write("\\input{components/component-prefatory}\n")
        new.write(latex)
        new.write("\\input{components/component-end}\n")
        new.write("\\end{document}")

def comma_join(lst):
    if not lst:
        return ""
    elif len(lst) == 1:
        return str(lst[0])
    return "{} and {}".format(", ".join(lst[:-1]), lst[-1])

def convert_webp_to_jpg():
    for file in glob.glob(str(pathlib.Path(sys.argv[1]).parents[0].absolute())+"/*.webp"):
        base_name = pathlib.Path(file).stem
        out = str(pathlib.Path(str(pathlib.Path(sys.argv[1]).parents[0].absolute()) + "/latex")) + "/images/" + base_name + ".jpg"
        print(out)
        img = Image.open(file)
        try:
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            img.save(out,'jpeg',quality=50)
        except Exception as e:
            print(f"An error occurred: {e}")

def generate_metadata():
    default_issue = "1"
    default_article = "1"
    default_year = "2024"
    default_first_page = "1"
    issue = input(f"Issue number (default: {default_issue}): ") or default_issue
    article = input(f"Article number (default: {default_article}): ") or default_article
    year = input(f"Year (default: {default_year}): ") or default_year
    global first_page
    first_page = input(f"First page (default: {default_first_page}): ") or default_first_page
    with open(str(metadata_directory) + "/metadata-first-page.tex","w") as firstpage:
        firstpage.write("\\setcounter{page}{"+first_page+"}")
    iy = issue + " (" + year + "): " + first_page + "–\\total{page}."
    with open(str(metadata_directory) + "/metadata-iy.tex","w") as iyF:
        iyF.write(iy)
    with open(str(pathlib.Path(sys.argv[1]).parents[0].absolute()) + "/metadata.yml","r") as stream:
        try:
            metadata = yaml.safe_load(stream)
            citation = {}
            if "shorttitle" not in metadata:
                metadata["shorttitle"] = metadata["title"]
            for key in metadata:
                metadatafile = str(metadata_directory) + "/metadata-"+key+".tex"
                if key in ["identifier","doi","abstract","tags","title","shorttitle","subtitle"]:
                # write the following metadata items to separate metadata files to be 
                # loaded by LaTeX
                    with open(metadatafile,"w") as out:
                        if key == "tags":
                            s = ", ".join(metadata[key])
                        else:
                            s = metadata[key]
                        s = re.sub(r'<i>(.*?)</i>',r'\\emph{\1}',s)
                        s = re.sub(r'<em>(.*?)</em>',r'\\emph{\1}',s)
                        s = re.sub(r' — ',r' \\Dash ',s)
                        if key == "title":
                            citation["title"] = s
                        if key == "subtitle":
                            citation["title"] = citation["title"] + ": " + s
                        out.write(s)
                if key == "dates":
                    for subkey in metadata[key]:
                        with open(str(metadata_directory) + "/metadata-"+ key +"-" +subkey+".tex","w") as out:
                            out.write(str(metadata[key][subkey]))
                if key == "authors":
                    # We need to make three files for the authors:
                    # First, the full names of all the authors (metadata-author-full.tex),
                    # Then, a list of the authors with all relevant information to be printed
                    # on the title page (metadata-author-list.tex),
                    # and finally the last names only of the authors (+ et al. if more than three)
                    # to be printed in the running header (metadata-author-short.tex)
                    authors = []
                    with open("../nesar/public/authors.yml","r") as authority:
                        authorList = yaml.safe_load(authority)
                        for y in metadata["authors"]:
                            if y in authorList:
                                authors.append(authorList[y])
                            else:
                                print("The NESAR authority files authors.yaml does not contain the author in question. Please add them before proceeding.")
                    with open(str(metadata_directory) +"/metadata-author-full.tex","w") as authFull, open(str(metadata_directory) +"/metadata-author-short.tex","w") as authShort, open(str(metadata_directory) +"/metadata-author-list.tex","w") as authList:
                        fullnames = []
                        shortnames = []
                        institutions = []
                        emails = []
                        columns = []
                        for author in authors:
                            columns.append("c")
                            if author["institution"]:
                                institutions.append("{\\small\\emph{"+author["institution"]+"}}")
                            else:
                                institutions.append(" ")
                            if author["email"]:
                                emails.append("{\\small\\href{mailto:"+author["email"]+"}{"+author["email"]+"}}")
                            else:
                                emails.append(" ")
                            if author["firstName"]:
                                fullnames.append(author["firstName"] + " " + author["lastName"])
                            elif author["name"]:
                                fullnames.append(author["name"])
                            if len(shortnames) < 3:
                                if author["lastName"]:
                                    shortnames.append("\\textsc{"+author["lastName"].lower()+"}")
                                elif author["name"]:
                                    shortnames.append("\\textsc{"+author["name"].lower()+"}")
                        authFull.write(comma_join(fullnames))
                        citation["authors"] = comma_join(fullnames)
                        authShort.write(comma_join(shortnames))
                        if len(authors) > 3:
                            authShort = authShort + ", \\emph{et al.}"
                        authList.write("\\begin{tabular}{" + "@{\\hskip 1.5em}".join(columns) + "}\n")
                        authList.write(" & ".join(fullnames) + "\\\\[1ex]\n")
                        authList.write(" & ".join(institutions) + "\\\\[0.5ex]\n")
                        authList.write(" & ".join(emails) + "\n")
                        authList.write("\\end{tabular}")
                        with open(str(metadata_directory) +"/metadata-citation.tex","w") as cit:
                            cit.write(citation["authors"] + ". “" + citation["title"] + ".” \\emph{New Explorations in South Asia Research} "+iy)
        except yaml.YAMLError as exc:
            print(exc)
        
def create_latex_directory():
    latex_directory.mkdir(parents=True,exist_ok=True)
    metadata_directory.mkdir(parents=True,exist_ok=True)
    try:
        shutil.copytree(components_directory, str(latex_directory) + "/components",dirs_exist_ok=True)
        shutil.copytree(images_directory, str(latex_directory) + "/images",dirs_exist_ok=True)
        shutil.copytree(hyphenation_directory, str(latex_directory) + "/hyphenation",dirs_exist_ok=True)
    except Exception as e:
        print(f"An error occurred: {e}")

def preprocess_xml():
    with open(str(input_file),"r") as original:
        data = original.read()
        # preface ampersands with backslashes
        data = re.sub(r'&amp;',r'\\&amp;',data)
    with open(str(preprocessed_file),"w") as modified:
        modified.write(data)

def postprocess_latex():
    with open(str(latex_file),"r") as original:
        data = original.read()
        # insert thin space between initials of names
        data = re.sub(r'([A-Z])\. ([A-Z])\. ',r'\1.\\thinskip{}\2. ',data)
        # replace emdashes with LaTeX em dashes (with proper spacing)
        data = re.sub(r'—',r' \\Dash ',data)
    with open(str(latex_file),"w") as modified:
        modified.write(data)

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

if __name__ == "__main__":
    tei = etree.parse(input_file,parser=parser)
    valid = validate(tei)
    if valid == None:
        print(sys.argv[1] + " is valid TEI.")
        # 1. copy materials from /tei-to-pdf into /outputs/lastname-title-of-article/latex
        create_latex_directory()
        # 2. convert the webp source images into jpgs
        convert_webp_to_jpg()
        # 3. preprocess the XML so that it can be LaTeX-ified
        preprocess_xml()
        # 4. generate the metadata
        generate_metadata()
        # 5. generate the latex from the stylesheet and the XML file
        generate_latex(tei)
        # 6. postprocess the latex file
        postprocess_latex()
        # 7. run latex
        # generate_pdf(inputfile)
        # if os.path.isfile(inputfile.stem + '.tex'):
        #     generate_pdf(inputfile.stem + '.tex')
