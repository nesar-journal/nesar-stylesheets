import re, os, string, sys, pathlib, subprocess, time, yaml, shutil, glob, urllib.request
from lxml import etree
from PIL import Image
from itertools import chain
from saxonche import PySaxonProcessor

current_dir = pathlib.Path(__file__).resolve().parent.absolute()
parent_dir = pathlib.Path(__file__).resolve().parents[1].absolute()

namespaces = {'tei': 'http://www.tei-c.org/ns/1.0'}
parser = etree.XMLParser(recover=True,encoding='utf-8')
input_file = pathlib.Path(sys.argv[1]).absolute()
first_page = 1
schema_file = parent_dir / 'schemas' / 'tei_all.rng'
stylesheet_file = current_dir / 'stylesheet-LaTeX.xsl'
components_directory = current_dir / 'components'
hyphenation_directory = current_dir / 'hyphenation'
images_directory = current_dir / 'images'
latex_directory = input_file.parent / 'latex'
metadata_directory = latex_directory / 'metadata'
preprocessed_file = latex_directory / (input_file.stem + '.xml')
latex_file = latex_directory / (input_file.stem + '.tex')

def validate(f):
    relaxng_doc = etree.parse(str(schema_file))
    print("Checking if document is valid...")
    relaxng = etree.RelaxNG(relaxng_doc)
    return relaxng.assertValid(f)

def generate_latex(tei):
    with PySaxonProcessor(license=False) as proc:
        xslt = proc.new_xslt30_processor()
        xslt.transform_to_file(
            source_file=str(preprocessed_file),
            stylesheet_file=str(stylesheet_file),
            output_file=str(latex_file),
        )
    print("LaTeX file produced.")
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
        out = str(latex_directory / 'images' / (base_name + '.jpg'))
        print(out)
        img = Image.open(file)
        try:
            if img.mode == 'RGBA':
                img = img.convert('RGB')
            img.save(out,'jpeg',quality=50)
        except Exception as e:
            print("An error occurred: {e}")

def load_or_create_pagination():
    pagination_file = input_file.parent / 'pagination.yml'
    if pagination_file.exists():
        with open(pagination_file, 'r') as f:
            return yaml.safe_load(f)
    pagination = {
        'issue': input("Issue number (default: 1): ") or "1",
        'article': input("Article number (default: 1): ") or "1",
        'year': input("Year (default: 2024): ") or "2024",
        'first_page': input("First page (default: 1): ") or "1",
    }
    with open(pagination_file, 'w') as f:
        yaml.dump(pagination, f)
    return pagination

def generate_metadata():
    global first_page
    pagination = load_or_create_pagination()
    issue = str(pagination['issue'])
    article = str(pagination['article'])
    year = str(pagination['year'])
    first_page = str(pagination['first_page'])
    with open(str(metadata_directory) + "/metadata-first-page.tex","w") as firstpage:
        firstpage.write("\\setcounter{page}{"+first_page+"}")
    iy = issue + " (" + year + "): " + first_page + "–\\thelastpage."
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
                    authors_url = 'https://raw.githubusercontent.com/nesar-journal/nesar/master/public/authors.yml'
                    with urllib.request.urlopen(authors_url) as response:
                        authorList = yaml.safe_load(response.read().decode('utf-8'))
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
        data = re.sub(r'—',r' \\Dash ',data)
    with open(str(latex_file),"w") as modified:
        modified.write(data)

def generate_pdf():
    outputs_dir = input_file.parent / 'outputs'
    outputs_dir.mkdir(exist_ok=True)
    pdf_output = outputs_dir / (input_file.stem + '.pdf')
    try:
        for _ in range(2):
            subprocess.run(['xelatex', latex_file.name], cwd=latex_directory, check=True)
        shutil.copy(latex_directory / (input_file.stem + '.pdf'), pdf_output)
        print(f"PDF produced: {pdf_output}")
    except subprocess.CalledProcessError as ex:
        print(f"PDF generation failed: {ex}")

if __name__ == "__main__":
    tei = etree.parse(input_file,parser=parser)
    valid = validate(tei)
    if valid == None:
        print(sys.argv[1] + " is valid TEI.")
        create_latex_directory()
        convert_webp_to_jpg()
        preprocess_xml()
        generate_metadata()
        generate_latex(tei)
        postprocess_latex()
        if '--pdf' in sys.argv:
            generate_pdf()
