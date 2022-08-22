<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:strip-space elements="tei:p tei:s"/>

  <!-- Location of the translation document !-->
  <xsl:variable name="translation" select="document('../xml/DHARMA_CritEdSiksaGuru_transEng01.xml')"/>
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <!-- The skeleton of the document, into which the elements will be injected in a hierarchical sequence. !-->
  <!-- Note that this contains the RELEDPAR setup. !-->
  <xsl:template match="/">
    <xsl:text>
\tolerance=1000
\hyphenpenalty=0
\sidenotemargin{outer}
\firstlinenum{1}
\linenumincrement{1}

\linenummargin{left}
\Xnolemmaseparator[A]
\Xinplaceoflemmaseparator[A]{1em}
\Xafternumber[A]{0pt}
\Xnotefontsize[A]{\small}
% variants: register B
\newcommand{\variant}[1]{\Bfootnote{#1}}
\Xarrangement[B]{paragraph}
\Xinplaceoflemmaseparator[B]{0.5em}
\Xhangindent[B]{2.5em}
% foliation: register C
\Xarrangement[C]{paragraph}
\newcommand{\folio}[1]{\edtext{}{\Cfootnote{#1}}}
\Xnolemmaseparator[C]
\Xinplaceoflemmaseparator[C]{1em}
\Xafternumber[C]{0pt}
\Xnotefontsize[C]{\footnotesize}
\setgoalfraction{0.7}
\setlength{\ledlsnotewidth}{1.5em}
\setlength{\ledrsnotewidth}{1.5em}
\setlength{\ledlsnotesep}{3em}
\setlength{\ledrsnotesep}{3em}
\renewcommand\footnoterule{%
  \kern -3pt
  \hrule width \textwidth height 0.5pt
  \kern 2pt\vspace*{3pt}%
}
\renewcommand{\Afootnoterule}{\footnoterule}
\renewcommand{\Bfootnoterule}{\footnoterule}
\renewcommand{\Cfootnoterule}{\footnoterule}
</xsl:text>
    <xsl:apply-templates/>
  </xsl:template> 

  <xsl:template match="tei:ab" />
  <xsl:template match="tei:abbr" />
  <xsl:template match="tei:add" />
  <xsl:template match="tei:anchor" />
  <xsl:template match="tei:app[not(@type='orthographic')]">
    <xsl:choose>
      <xsl:when test="tei:lem or tei:rdgGrp/tei:lem">
	<xsl:choose>
	  <xsl:when test="tei:lem">
	    <xsl:if test="@type='corrupt'">
	      <xsl:text>{\fontspec{EB Garamond}†}</xsl:text>
	    </xsl:if>
	    <xsl:text>\edtext{</xsl:text><xsl:apply-templates select="tei:lem"/><xsl:text>}{\lemma{</xsl:text><xsl:apply-templates select="tei:lem"/><xsl:text>}\variant{</xsl:text>
	    <xsl:call-template name="rdg">
	      <xsl:with-param name="rdg" select="tei:lem"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:when test="tei:rdgGrp/tei:lem"><!-- if the lemma is part of an orthographic reading group !-->
	    <xsl:text>\maintextlang{</xsl:text><xsl:apply-templates select="tei:rdgGrp/tei:lem"/><xsl:text>}{\lemma{</xsl:text><xsl:apply-templates select="tei:rdgGrp/tei:lem"/><xsl:text>}\variant{</xsl:text>
	    <xsl:call-template name="rdg">
	      <xsl:with-param name="rdg" select="tei:rdgGrp/tei:lem"/>
	    </xsl:call-template>
	    <xsl:text>{\fontspec{EB Garamond}\ (\textasciitilde\ </xsl:text>
	    <xsl:for-each select="tei:rdgGrp/tei:rdg">
	      <xsl:call-template name="rdg">
		<xsl:with-param name="rdg" select="."/>
	      </xsl:call-template>
	    </xsl:for-each>
	    <xsl:text>)}</xsl:text>
	  </xsl:when>
	</xsl:choose>
	<xsl:if test="tei:rdgGrp[not(tei:lem)] or tei:rdg">
	  <xsl:text>; </xsl:text>
	  <xsl:if test="tei:rdgGrp[not(tei:lem)]"><!-- if there is an orthographic reading group (not including a lemma) !-->
	    <xsl:for-each select="tei:rdgGrp/tei:rdg">
	      <xsl:choose>
		<xsl:when test="position()=1">
		  <xsl:text>\maintextlang{</xsl:text><xsl:apply-templates select="."/><xsl:text>\ }</xsl:text>
		  <xsl:call-template name="rdg">
		    <xsl:with-param name="rdg" select="."/>
		  </xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>{\fontspec{EB Garamond}\ (\textasciitilde\ </xsl:text>
		  <xsl:call-template name="rdg">
		    <xsl:with-param name="rdg" select="."/>
		  </xsl:call-template>
		  <xsl:text>)}</xsl:text>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:for-each>
	    <xsl:text>{\fontspec{EB Garamond}</xsl:text>
	    <xsl:choose>
	      <xsl:when test="./following-sibling::tei:rdg">
		<xsl:text>; </xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>.</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:text>}</xsl:text>
	  </xsl:if>
	  <xsl:if test="tei:rdg">
	    <xsl:for-each select="tei:rdg">
	      <!-- for the reading in the apparatus !-->
	      <xsl:choose>
		<!-- if there is text to print !-->
		<xsl:when test="normalize-space(.) != ''">
		  <xsl:text>\maintextlang{</xsl:text><xsl:apply-templates/><xsl:text>\ }</xsl:text>
		</xsl:when>
		<!-- if not, we have gaps, omissions, etc. !-->
		<xsl:otherwise>
		  <xsl:if test="tei:lacunaStart">
		    <xsl:text>[\dots{} </xsl:text>
		  </xsl:if>
		  <xsl:if test="tei:lacunaEnd">
		    <xsl:text>\dots{}] </xsl:text>
		  </xsl:if>
		  <xsl:if test="tei:gap">
		    <xsl:apply-templates select="tei:gap"/>
		  </xsl:if>
		</xsl:otherwise>
	      </xsl:choose>
	      <!-- for the label !-->
	      <xsl:call-template name="rdg">
		<xsl:with-param name="rdg" select="."/>
	      </xsl:call-template>
	      <xsl:text>{\fontspec{EB Garamond}</xsl:text>
	      <xsl:choose>
		<xsl:when test="./following-sibling::tei:rdg">
		  <xsl:text>, </xsl:text>
		</xsl:when>
		<!-- if there is a lacuna in the manuscript !-->
		<xsl:when test="../preceding-sibling::tei:app/tei:rdg[./tei:lacunaStart][1]">
		  <xsl:variable name="witness">
		    <xsl:value-of select="../preceding-sibling::tei:app/tei:rdg[./tei:lacunaStart][1]/@wit"/>
		  </xsl:variable>
		  <xsl:variable name="startNum" select="count(../preceding-sibling::tei:app/tei:rdg[./tei:lacunaStart])"/>
		  <xsl:choose>
		    <xsl:when test="../preceding-sibling::tei:app/tei:rdg[@wit='$witness'][./tei:lacunaEnd][1]">
		      <xsl:variable name="endNum" select="count(../preceding-sibling::tei:app/tei:rdg[@wit='$witness'][./tei:lacunaEnd])"/>
		      <xsl:if test="$startNum - $endNum = 1">
			<xsl:text>, </xsl:text>
		      </xsl:if>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>, </xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:text>.</xsl:text>
		</xsl:otherwise>
	      </xsl:choose>
	      <xsl:text>}</xsl:text>
	    </xsl:for-each>
	  </xsl:if>
	  <!-- to deal with lacunas: check Axelle's solution,
	       which is probably better. !-->
	  <xsl:if test="./preceding-sibling::tei:app/tei:rdg[./tei:lacunaStart][1]">
	    <xsl:variable name="witness">
	      <xsl:value-of select="./preceding-sibling::tei:app/tei:rdg[./tei:lacunaStart][1]/@wit"/>
	    </xsl:variable>
	    <xsl:variable name="startNum" select="count(./preceding-sibling::tei:app/tei:rdg[./tei:lacunaStart])"/>
	    <xsl:choose>
	      <xsl:when test="./preceding-sibling::tei:app/tei:rdg[@wit='$witness'][./tei:lacunaEnd][1]">
		<xsl:variable name="endNum" select="count(./preceding-sibling::tei:app/tei:rdg[@wit='$witness'][./tei:lacunaEnd])"/>
		<xsl:if test="$startNum - $endNum = 1">
		  <xsl:text>{\fontspec{EB Garamond}\emph{lac.} \textbf{\textsc{</xsl:text><xsl:value-of select="translate(translate($witness,'#',''),$uppercase,$lowercase)"/><xsl:text>}}}</xsl:text>
		</xsl:if>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text>{\fontspec{EB Garamond}\emph{lac.} \textbf{\textsc{</xsl:text><xsl:value-of select="translate(translate($witness,'#',''),$uppercase,$lowercase)"/><xsl:text>}}}</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:if>
	</xsl:if>
	<!-- if there are notes !-->
	<xsl:if test="tei:note">
	  <xsl:choose>
	    <xsl:when test="tei:note/preceding-sibling::tei:rdg">
	      <xsl:text>\ </xsl:text>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:text>. </xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:for-each select="tei:note">
	    <xsl:choose>
	      <xsl:when test="@xml:lang='eng'">
		<xsl:text>\textenglish{</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>}</xsl:text>
		<xsl:if test="following-sibling::*">
		  <xsl:text>\quad{}</xsl:text>
		</xsl:if>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates/>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:if test="@resp">
	      <xsl:text>(</xsl:text>
	      <xsl:value-of select="translate(@resp,'#','')"/>
	      <xsl:text>)</xsl:text>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:if>
	<xsl:text>}}</xsl:text>
	<xsl:if test="@type='corrupt'">
	  <xsl:text>{\fontspec{EB Garamond}†}</xsl:text>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise><!-- if there is no lemma or rdgGrp with a lemma in it !-->
	<xsl:text>\edtext{}{\Cfootnote[nosep]{</xsl:text>
	<xsl:apply-templates select="tei:note"/>
	<xsl:text>}}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:author" />
  <xsl:template match="tei:authority" />
  <xsl:template match="tei:availability" />
  <xsl:template match="tei:back" />
  <xsl:template match="tei:bibl" />
  <xsl:template match="tei:biblFull" />
  <xsl:template match="tei:biblStruct" />
  <xsl:template match="tei:body">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:caesura">
    <xsl:text>\\
\mbox{\quad\quad}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:certainty" />
  <xsl:template match="tei:change" />
  <xsl:template match="tei:choice" />
  <xsl:template match="tei:cit" />
  <xsl:template match="tei:citedRange" />
  <xsl:template match="tei:collection" />
  <xsl:template match="tei:colophon" />
  <xsl:template match="tei:correction" />
  <xsl:template match="tei:date" />
  <xsl:template match="tei:del" />
  <xsl:template match="tei:div[@type='chapter']">
    <xsl:variable name="id" select="concat('#',./@xml:id)"/>
    <xsl:variable name="translationnode" select="$translation//tei:div[@corresp = $id]"/>
    <xsl:text>\begin{pages}\begin{Leftside}\beginnumbering</xsl:text>
    <xsl:if test="tei:head">
      <xsl:text>\pstart{}</xsl:text>
      <xsl:apply-templates select="tei:head" mode="bypass"/>
      <xsl:text>\pend
</xsl:text>
    </xsl:if>
    <xsl:for-each select="tei:p">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:text>\endnumbering\end{Leftside}\begin{Rightside}\firstlinenum{10000}\beginnumbering</xsl:text>
    <xsl:if test="tei:head">
      <xsl:text>\pstart\mbox{\quad}\pend

</xsl:text>
    </xsl:if>
    <xsl:for-each select="$translationnode/tei:p">
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <xsl:text>\endnumbering\end{Rightside}\end{pages}\Pages</xsl:text>
  </xsl:template>
  <xsl:template match="tei:editor" />
  <xsl:template match="tei:editorialDecl" />
  <xsl:template match="tei:encodingDesc" />
  <xsl:template match="tei:expan" />
  <xsl:template match="tei:fileDesc" />
  <xsl:template match="tei:filiation" />
  <xsl:template match="tei:foreign">
    <xsl:text>\emph{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:forename" />
  <xsl:template match="tei:front" />
  <xsl:template match="tei:g" />
  <xsl:template match="tei:gap">
    <xsl:choose>
      <xsl:when test="@reason='lost'">
	<xsl:choose>
	  <xsl:when test="@quantity">
	    <xsl:text>[</xsl:text><xsl:value-of select="@quantity"/><xsl:text>+]</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text>\emph{lac.} </xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="@reason='omitted'">
	<xsl:text>\emph{om.} </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:gloss" />
  <xsl:template match="tei:handDesc" />
  <xsl:template match="tei:handNote" />
  <xsl:template match="tei:head"/>
  <xsl:template match="tei:head" mode="bypass">
    <xsl:choose>
      <xsl:when test="./parent::tei:div[@type='chapter']">
	<xsl:text>\skipnumbering\eledsection{</xsl:text>
	<xsl:apply-templates/>
	<xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:hi" />
  <xsl:template match="tei:history" />
  <xsl:template match="tei:idno" />
  <xsl:template match="tei:institution" />
  <xsl:template match="tei:interpretation" />
  <xsl:template match="tei:item" />
  <xsl:template match="tei:join" />
  <xsl:template match="tei:keywords" />
  <xsl:template match="tei:l">
    <xsl:if test="not(ancestor::tei:div[@type='block'])">
      <xsl:if test="parent::tei:lg[@cert='low'] and following-sibling::tei:l"><xsl:text>\mbox{[}</xsl:text></xsl:if>
      <xsl:text>\sk{</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="not(ancestor::tei:div[@type='block'])">
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="following-sibling::tei:l"><xsl:text>\\</xsl:text></xsl:if>
    <xsl:if test="parent::tei:lg[@cert='low'] and not(following-sibling::tei:l)"><xsl:text>\mbox{]}</xsl:text></xsl:if>
  </xsl:template>
  <xsl:template match="tei:label" />
  <xsl:template match="tei:lacunaEnd">
    <xsl:variable name="witness" select="translate(../@wit,'#','')"/>
    <xsl:text>\edlabel{lacuna-</xsl:text>
    <xsl:value-of select="$witness"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="generate-id(tei:lacunaEnd[@wit=$witness])"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:lacunaStart">
    <xsl:variable name="witness" select="translate(../@wit,'#','')"/>
    <xsl:text>\edlabel{lacuna-</xsl:text>
    <xsl:value-of select="$witness"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="generate-id(tei:lacunaStart[@wit=$witness])"/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:language" />
  <xsl:template match="tei:langUsage" />
  <xsl:template match="tei:lb">
    <xsl:text>\\</xsl:text>
  </xsl:template>
  <xsl:template match="tei:lem">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:lg">
    <xsl:variable name="xmlid" select="substring-after(@xml:id,'.')"/>
    <xsl:variable name="verseno">
      <xsl:choose>
	<xsl:when test="contains($xmlid,'A')">
	  <xsl:text>\devanagarinumeral{</xsl:text>
	  <xsl:value-of select="substring-before($xmlid,'A')"/>
	  <xsl:text>}\sk{-क}</xsl:text>
	</xsl:when>
	<xsl:when test="contains($xmlid,'B')">
	  <xsl:text>\devanagarinumeral{</xsl:text>
	  <xsl:value-of select="substring-before($xmlid,'B')"/>
	  <xsl:text>}\sk{-ख}</xsl:text>
	</xsl:when>
	<xsl:when test="contains($xmlid,'C')">
	  <xsl:text>\devanagarinumeral{</xsl:text>
	  <xsl:value-of select="substring-before($xmlid,'C')"/>
	  <xsl:text>}\sk{-ग}</xsl:text>
	</xsl:when>
	<xsl:when test="contains($xmlid,'D')">
	  <xsl:text>\devanagarinumeral{</xsl:text>
	  <xsl:value-of select="substring-before($xmlid,'D')"/>
	  <xsl:text>}\sk{-घ}</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>\devanagarinumeral{</xsl:text>
	  <xsl:value-of select="$xmlid"/>
	  <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\ledsidenote{</xsl:text>
    <xsl:value-of select="$verseno"/><xsl:text>}</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>

    </xsl:text>
  </xsl:template>
  <xsl:template match="tei:license" />
  <xsl:template match="tei:list" />
  <xsl:template match="tei:listApp" />
  <xsl:template match="tei:listBibl" />
  <xsl:template match="tei:listPrefixDef" />
  <xsl:template match="tei:listWit" />
  <xsl:template match="tei:locus" />
  <xsl:template match="tei:measure" />
  <xsl:template match="tei:msContents" />
  <xsl:template match="tei:msDesc" />
  <xsl:template match="tei:msFrag" />
  <xsl:template match="tei:msIdentifier" />
  <xsl:template match="tei:msItem" />
  <xsl:template match="tei:msName" />
  <xsl:template match="tei:msPart" />
  <xsl:template match="tei:name" />
  <xsl:template match="tei:normalization" />
  <xsl:template match="tei:note" />
  <xsl:template match="tei:notesStmt" />
  <xsl:template match="tei:num" />
  <xsl:template match="tei:objectDesc" />
  <xsl:template match="tei:origDate" />
  <xsl:template match="tei:origPlace" />
  <xsl:template match="tei:p">
    <xsl:variable name="xmlid" select="@xml:id"/>
    <xsl:text>\pstart
</xsl:text>
    <xsl:if test="@xml:id">
      <xsl:text>\label{p:</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:if test="not(@corresp)">
      <xsl:text>\maintextlang{</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="not(@corresp)">
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>\pend

</xsl:text>
  </xsl:template>
  <xsl:template match="tei:pb">
    <xsl:variable name="witness" select="translate(@edRef,'#','')"/>
    <xsl:text>\folio{</xsl:text>
    <xsl:choose>
      <xsl:when test="preceding-sibling::node()[not(self::tei:pb)][1][self::text()][.!='']">
	<xsl:variable name="before" select="normalize-space(translate(preceding-sibling::text()[1],',',''))"/>
	<xsl:value-of select="concat('-',tokenize($before,' ')[last()])"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::node()[not(self::tei:pb)][1][self::tei:app]">
	<xsl:choose>
	  <xsl:when test="preceding-sibling::tei:app/tei:lem[@wit[contains(.,$witness)]]/text()[.!='']">
	    <xsl:variable name="before" select="normalize-space(translate(preceding-sibling::tei:app/tei:lem[@wit[contains(.,$witness)]]/text(),',',''))"/>
	    <xsl:value-of select="concat('-',tokenize($before,' ')[last()])"/>
	  </xsl:when>
	  <xsl:when test="preceding-sibling::tei:app/tei:rdg[@wit[contains(.,$witness)]]/text()[.!='']">
	    <xsl:variable name="before" select="normalize-space(translate(preceding-sibling::tei:app/tei:rdg[@wit[contains(.,$witness)]]/text(),',',''))"/>
	    <xsl:value-of select="concat('-',tokenize($before,' ')[last()])"/>
	  </xsl:when>
	  <xsl:otherwise/>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:text>[</xsl:text>
    <xsl:text>\textbf{</xsl:text>
    <xsl:value-of select="$witness"/>
    <xsl:text>}:</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>]</xsl:text>
    <xsl:choose>
      <xsl:when test="following-sibling::node()[not(self::tei:pb)][1][self::text()][.!='']">
	<xsl:variable name="after" select="normalize-space(translate(following-sibling::text()[1],',',''))"/>
	<xsl:value-of select="concat(tokenize($after,' ')[1],'-')"/>
      </xsl:when>
      <xsl:when test="following-sibling::node()[not(self::tei:pb)][1][self::tei:app]">
	<xsl:choose>
	  <xsl:when test="following-sibling::tei:app/tei:lem[@wit[contains(.,$witness)]]/text()[.!='']">
	    <xsl:variable name="after" select="normalize-space(translate(following-sibling::tei:app/tei:lem[@wit[contains(.,$witness)]]/text(),',',''))"/>
	    <xsl:value-of select="concat(tokenize($after,' ')[1],'-')"/>
	  </xsl:when>
	  <xsl:when test="following-sibling::tei:app/tei:rdg[@wit[contains(.,$witness)]]/text()[.!='']">
	    <xsl:variable name="after" select="normalize-space(translate(following-sibling::tei:app/tei:rdg[@wit[contains(.,$witness)]]/text(),',',''))"/>
	    <xsl:value-of select="concat(tokenize($after,' ')[1],'-')"/>
	  </xsl:when>
	  <xsl:otherwise/>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:persName" />
  <xsl:template match="tei:physDesc" />
  <xsl:template match="tei:placeName" />
  <xsl:template match="tei:prefixDef" />
  <xsl:template match="tei:profileDesc" />
  <xsl:template match="tei:projectDesc" />
  <xsl:template match="tei:ptr" />
  <xsl:template match="tei:publicationStmt" />
  <xsl:template match="tei:pubPlace" />
  <xsl:template match="tei:punctuation" />
  <xsl:template match="tei:q" />
  <xsl:template match="tei:quote">
    <xsl:text>“</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>”</xsl:text>
  </xsl:template>
  <xsl:template match="tei:rdg"/>
  <xsl:template match="tei:ref" />
  <xsl:template match="tei:repository" />
  <xsl:template match="tei:resp" />
  <xsl:template match="tei:respStmt" />
  <xsl:template match="tei:revisionDesc" />
  <xsl:template match="tei:roleName" />
  <xsl:template match="tei:said" />
  <xsl:template match="tei:samplingDesc" />
  <xsl:template match="tei:schemaRef" />
  <xsl:template match="tei:secl" />
  <xsl:template match="tei:seg" />
  <xsl:template match="tei:settlement" />
  <xsl:template match="tei:sic" />
  <xsl:template match="tei:sourceDesc" />
  <xsl:template match="tei:sp" />
  <xsl:template match="tei:space" />
  <xsl:template match="tei:span" />
  <xsl:template match="tei:speaker" />
  <xsl:template match="tei:stage" />
  <xsl:template match="tei:subst" />
  <xsl:template match="tei:summary" />
  <xsl:template match="tei:supplied">
    <xsl:choose>
      <xsl:when test="@reason = 'omitted'">
	<xsl:text>⟨</xsl:text>
	<xsl:apply-templates/>
	<xsl:text>⟩</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="tei:supportDesc" />
  <xsl:template match="tei:surname" />
  <xsl:template match="tei:surplus" />
  <xsl:template match="tei:TEI">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:teiHeader" />
  <xsl:template match="tei:term">
    <xsl:text>\textbf{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="tei:text">
    <xsl:choose>
      <xsl:when test="@xml:lang='kaw-Latn'">
\newcommand{\maintextlang}[1]{\normalfont{#1}}
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>
\newcommand{\maintextlang}[1]{\normalfont{#1}}
	</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:textClass" />
  <xsl:template match="tei:textLang" />
  <xsl:template match="tei:title" />
  <xsl:template match="tei:titleStmt" />
  <xsl:template match="tei:unclear" />
  <xsl:template match="tei:variantEncoding" />
  <xsl:template match="tei:witDetail" />
  <xsl:template match="tei:witness" />


  
  <!-- NOTES: Using ledpar's endnotes features. !-->
  <!-- Notes to the text !-->
  <xsl:template match="tei:note[@type='totext']">
    <xsl:text>\footnoteB{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Notes to the translation !-->
  <xsl:template match="tei:note[@type='totrans']">
    <xsl:text>\endnote{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- Explanatory footnotes !-->
  <xsl:template match="tei:note[@type='footnote']">
    <xsl:text>\footnoteA{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:ab[@type='translation']">
    <xsl:variable name="xmlid" select="@cRef"/>
    <xsl:variable name="verseno" select="substring-after(@cRef,'.')"/>
    <xsl:choose>
      <xsl:when test="contains($verseno,'.1')"/>
      <xsl:when test="contains($verseno,'.2')"/>
      <xsl:when test="contains($verseno,'.3')"/>
      <xsl:otherwise>
	<xsl:text>\ledrightnote{</xsl:text><xsl:value-of select="string($verseno)"/><xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@cert='low'">
      <xsl:text>[</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="@cert='low'">
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:trailer">
    <xsl:text>\begin{center}\sk{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}\end{center}</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:l/tei:seg">
    <xsl:choose>
      <xsl:when test="../following-sibling::tei:l">
	<xsl:choose>
          <xsl:when test="./following-sibling::tei:seg"><xsl:apply-templates/><xsl:text>\\</xsl:text></xsl:when>
          <xsl:otherwise><xsl:text>\mbox{\hspace{2em}}</xsl:text><xsl:apply-templates/><xsl:text>\\</xsl:text></xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
          <xsl:when test="./following-sibling::tei:seg"><xsl:apply-templates/><xsl:text>\\</xsl:text></xsl:when>
          <xsl:otherwise><xsl:text>\mbox{\hspace{2em}}</xsl:text><xsl:apply-templates/><xsl:text>\\</xsl:text></xsl:otherwise>
      </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:ref[@type='pratīka']">
    <xsl:text>\textbf{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- bold labels !-->
  <xsl:template match="tei:label">
    <xsl:text>\textbf{</xsl:text><xsl:apply-templates /><xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:emph">
    <xsl:text>\emph{</xsl:text><xsl:apply-templates /><xsl:text>}</xsl:text>
  </xsl:template>
  
  <!-- fix whitespace !-->
  <xsl:template match="tei:p/text()">
    <xsl:choose>
      <xsl:when test="position() = 1">
	<xsl:value-of select="replace(replace(replace(.,'\n+',''),'^\s+',''),'\s+',' ')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="replace(replace(.,'\n+',' '),'\s+',' ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template name="rdg">
  <xsl:param name="rdg"/>
  <xsl:text>{\fontspec{EB Garamond}</xsl:text>
  <xsl:choose>
    <!-- if the reading is an original scribal reading a.c. !-->
    <xsl:when test="$rdg/@type='ac'">
      <xsl:if test="$rdg/@wit">
	<xsl:text>\textbf{\textsc{</xsl:text><xsl:value-of select="translate(translate($rdg/@wit,'#',''),$uppercase,$lowercase)"/><xsl:text>}} </xsl:text>
      </xsl:if>
      <xsl:text>\emph{a.c.}</xsl:text>
      <xsl:if test="$rdg/@source">
	<xsl:text>\textbf{</xsl:text><xsl:value-of select="translate($rdg/@source,'#','')"/><xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- if it is a scribal correction !-->
    <xsl:when test="$rdg/@type='pc'">
      <xsl:if test="$rdg/@wit">
	<xsl:text>\textbf{\textsc{</xsl:text><xsl:value-of select="translate(translate($rdg/@wit,'#',''),$uppercase,$lowercase)"/><xsl:text>}} </xsl:text>
      </xsl:if>
      <xsl:text>\emph{p.c.}</xsl:text>
      <xsl:if test="$rdg/@source">
	<xsl:text>\ \textbf{</xsl:text><xsl:value-of select="translate($rdg/@source,'#','')"/><xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- if it is a manuscript reading !-->
    <xsl:when test="$rdg/@wit">  
      <xsl:text>\textbf{\textsc{</xsl:text><xsl:value-of select="translate(translate($rdg/@wit,'#',''),$uppercase,$lowercase)"/><xsl:text>}}</xsl:text>
      <xsl:if test="$rdg/@source">
	<xsl:text>\ \textbf{</xsl:text><xsl:value-of select="translate($rdg/@source,'#','')"/><xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- if it is an emendation !-->
    <xsl:when test="$rdg[starts-with(@type, 'em')]">
      <xsl:text>\emph{em.}</xsl:text>
      <xsl:if test="$rdg/@type='em-mc'">
	<xsl:text> \emph{m.c.}</xsl:text>
      </xsl:if>
      <xsl:if test="$rdg/@resp"><xsl:value-of select="translate($rdg/@resp,'#','')"/></xsl:if>
      <xsl:if test="$rdg/@source">
	<xsl:text>\textbf{</xsl:text>
	<xsl:value-of select="translate($rdg/@source,'#','')"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- if it is an normalization !-->
    <xsl:when test="$rdg[starts-with(@type, 'norm')]">
      <xsl:text> \emph{norm.}</xsl:text>
    </xsl:when>
    <!-- silent / orthographic emendations !-->
    <xsl:when test="$rdg/@resp">
	<xsl:value-of select="translate($rdg/@resp,'#','')"/><xsl:text></xsl:text>
    </xsl:when>
    <!-- editorial change (prev. ed.) without ms. authority !-->
    <xsl:when test="$rdg/@source">
      <xsl:text>\textbf{</xsl:text>
      <xsl:value-of select="translate($rdg/@source,'#','')"/>
      <xsl:text>}</xsl:text>
    </xsl:when>
    <!-- omission !-->
    <xsl:when test="normalize-space(.)=''">
      <xsl:text>\emph{om.} </xsl:text>
      <xsl:if test="$rdg/@resp">
	<xsl:value-of select="translate($rdg/@resp,'#','')"/><xsl:text></xsl:text>
      </xsl:if>
      <xsl:if test="$rdg/@source">
	<xsl:text>\textbf{</xsl:text>
	<xsl:value-of select="translate($rdg/@source,'#','')"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
    </xsl:when>
    <!-- all other cases !-->
    <xsl:otherwise>
      <xsl:text>\textbf{</xsl:text>
      <xsl:value-of select="translate($rdg/@source,'#','')"/>
      <xsl:text>}</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="$rdg/tei:note">
    <xsl:text> (</xsl:text><xsl:apply-templates select="$rdg/tei:note"/><xsl:text>)</xsl:text>
  </xsl:if>
  <xsl:text>}</xsl:text>
</xsl:template>
  
</xsl:stylesheet>
