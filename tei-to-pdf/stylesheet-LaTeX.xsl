<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:strip-space elements="tei:p tei:s tei:list tei:item tei:head tei:note tei:div tei:body tei:text tei:TEI tei:lg tei:quote tei:body tei:bibl"/>
  <xsl:output method="text" omit-xml-declaration="yes"/>

  <xsl:character-map name="special">
    <xsl:output-character character="&amp;" string="\&amp;"/>
    <xsl:output-character character="%" string="\%"/>
    <xsl:output-character character="—" string="\Dash"/>
    <xsl:output-character character="#" string="\#"/>
  </xsl:character-map>

  <!-- Location of the translation document !-->
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  <xsl:variable name="ind" select="'Knda Deva Telu Mlym Taml'"/>
  
    <xsl:template match="/">
      <!--<xsl:result-document href="./latex/data.tex" use-character-maps="special" method="text" omit-xml-declaration="true">!-->
	<xsl:apply-templates/>
      <!--</xsl:result-document>!-->
    </xsl:template> 

    <xsl:template match="tei:abbr">
      <xsl:choose>
	<xsl:when test="./text() = 'BCE' or ./text() = 'CE'">
	  <xsl:text>\textsc{</xsl:text>
	  <xsl:value-of select="lower-case(./text())"/>
	  <xsl:text>}</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
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
    <xsl:template match="tei:author">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:authority" />
    <xsl:template match="tei:availability" />
    <xsl:template match="tei:back">
      <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:bibl[ancestor::tei:cit]">
      <xsl:text>

\medskip\hfill\begin{minipage}{0.9\textwidth}\small\hfill
</xsl:text>
<xsl:apply-templates/>
<xsl:text>\end{minipage}\hspace{2em}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:bibl[not(ancestor-or-self::tei:listBibl or ancestor-or-self::tei:cit)]">
      <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:bibl[parent::tei:listBibl]">
      <xsl:if test="@xml:id">
	<xsl:text>\phantomsection\label{</xsl:text>
	<xsl:value-of select="@xml:id"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
	<xsl:text>\medskip

</xsl:text>
    </xsl:template>

    <xsl:template match="tei:bibl" mode="second">
      <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:biblFull" />
    <xsl:template match="tei:biblStruct" />
    <xsl:template match="tei:body">
      <xsl:text>
\raggedbottom
      </xsl:text>
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:caesura">
      <xsl:text>\\
\mbox{\quad\quad}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:cell">
      <xsl:choose>
	<xsl:when test="@cols">
	  <xsl:text>\multicolumn{</xsl:text><xsl:value-of select="@cols"/><xsl:text>}{c}{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="following-sibling::tei:cell">
	<xsl:text disable-output-escaping="yes"> <![CDATA[&]]></xsl:text>
      </xsl:if>
    </xsl:template>
    <xsl:template match="tei:cell" mode="heading">
      <xsl:choose>
	<xsl:when test="@cols">
	  <xsl:text>\multicolumn{</xsl:text><xsl:value-of select="@cols"/><xsl:text>}{c}{\textbf{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}}</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>\textbf{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="following-sibling::tei:cell">
	<xsl:text disable-output-escaping="yes"> <![CDATA[&]]></xsl:text>
      </xsl:if>
    </xsl:template>
    <xsl:template match="tei:certainty" />
    <xsl:template match="tei:change" />
    <xsl:template match="tei:choice" />
    <xsl:template match="tei:cit">
      <xsl:text>
\begin{pullquote}
</xsl:text>
      <xsl:apply-templates select="tei:quote" mode="plain"/>
      <xsl:apply-templates select="tei:bibl"/>
      <xsl:text>
\end{pullquote}</xsl:text>
<xsl:if test=".//tei:note[@place='foot']">
  <xsl:for-each select=".//tei:note[@place='foot']">
    <xsl:apply-templates select="." mode="text"/>
  </xsl:for-each>
</xsl:if>
    </xsl:template>
    <xsl:template match="tei:citedRange">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:collection" />
    <xsl:template match="tei:colophon" />
    <xsl:template match="tei:correction" />
    <xsl:template match="tei:date[not(ancestor::tei:publicationStmt)]">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:date[ancestor::tei:publicationStmt]">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:del" />
    <xsl:template match="tei:div[@type='ack']">
      <xsl:text>

\bigskip\begingroup\small
\noindent\textsc{acknowledgements:} </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
\endgroup\bigskip
      </xsl:text>
    </xsl:template>
    <xsl:template match="tei:div[parent::tei:body][not(@type='ack')]">
      <xsl:text>
\section{</xsl:text>
      <xsl:apply-templates select="tei:head" mode="bypass"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="tei:head/tei:anchor/@xml:id">
	<xsl:text>\label{</xsl:text>
	<xsl:value-of select="tei:head/tei:anchor/@xml:id"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>
      </xsl:text>
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:div[parent::tei:body]/tei:div">
      <xsl:text>
\subsection{</xsl:text>
      <xsl:apply-templates select="tei:head" mode="bypass"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="tei:head/tei:anchor/@xml:id">
	<xsl:text>\label{</xsl:text>
	<xsl:value-of select="tei:head/tei:anchor/@xml:id"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>
      </xsl:text>
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:div[parent::tei:body]/tei:div/tei:div">
      <xsl:text>
\subsubsection{</xsl:text>
      <xsl:apply-templates select="tei:head" mode="bypass"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="tei:head/tei:anchor/@xml:id">
	<xsl:text>\label{</xsl:text>
	<xsl:value-of select="tei:head/tei:anchor/@xml:id"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>
      </xsl:text>
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:editor" />
    <xsl:template match="tei:editorialDecl" />
    <xsl:template match="tei:encodingDesc" />
    <xsl:template match="tei:expan" />
    <xsl:template match="tei:figure">
      <xsl:text>
\begin{figure}[ht!]\label{fig</xsl:text>
<xsl:value-of select="count(preceding::tei:figure)+1"/>
<xsl:text>}\centering
</xsl:text>
<xsl:if test="tei:graphic">
  <xsl:text>
\includegraphics[width=</xsl:text><xsl:if test="@width and contains(@width,'%')"><xsl:value-of select="translate(@width,'%','')"/></xsl:if><xsl:text>\textwidth]{</xsl:text>
<xsl:value-of select="replace(concat('images/',substring-after(tei:graphic/@url,'/')),'.webp','.jpg')"/>
<xsl:text>}</xsl:text>
</xsl:if>
<xsl:if test="tei:head">
  <xsl:text>
\caption{</xsl:text>
<xsl:apply-templates select="tei:head" mode="bypass"/>
<xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>
\end{figure}
</xsl:text>
    </xsl:template>
    <xsl:template match="tei:fileDesc"/>
    <xsl:template match="tei:filiation" />
    <xsl:template match="tei:foreign">
      <xsl:choose>
	<xsl:when test="@xml:lang">
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>\emph{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:forename" />
    <xsl:template match="tei:front" />
    <xsl:template match="tei:g">
      <xsl:choose>
	<xsl:when test="@ref">
	  <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:charDecl/tei:glyph[@xml:id=@ref]/tei:mapping"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
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
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='bold']">
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='smallcaps']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='subscript']">
      <xsl:text>\textsubscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='superscript']">
      <xsl:text>\textsuperscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:hi">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:history" />
    <xsl:template match="tei:idno">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:institution" />
    <xsl:template match="tei:interpretation" />
    <xsl:template match="tei:item">
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates/>
      <xsl:if test="./following-sibling::tei:item">
	<xsl:text>
	</xsl:text>
      </xsl:if>
    </xsl:template>
    <xsl:template match="tei:join" />
    <xsl:template match="tei:keywords" />
    <xsl:template match="tei:l">
      <xsl:apply-templates/>
      <xsl:if test="./following-sibling::tei:l">
	<xsl:text>\\
</xsl:text>
      </xsl:if>
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
      <xsl:apply-templates/>
      <xsl:if test="following-sibling::tei:lg">
	<xsl:text>

</xsl:text>
      </xsl:if>
    </xsl:template>
    <xsl:template match="tei:license" />
    <xsl:template match="tei:link">
      <xsl:text>\url{</xsl:text><xsl:apply-templates select="@target"/><xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:list[@type='examples']">
      <xsl:text>
\begin{example}
      </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
\end{example}
      </xsl:text>
    </xsl:template>
    <xsl:template match="tei:list[not(@type='examples')]">
      <xsl:text>
\begin{itemize}
      </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
\end{itemize}
      </xsl:text>
    </xsl:template>
    <xsl:template match="tei:listApp" />
    <xsl:template match="tei:listBibl[not(ancestor::tei:listBibl)]">
      <xsl:choose>
	<xsl:when test="tei:head">
	  <xsl:text>
\section*{</xsl:text><xsl:value-of select="tei:head"/><xsl:text>}</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>
\section*{References}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
<xsl:text>
\begin{hangparas}{0.125in}{1}
</xsl:text>
<xsl:apply-templates/>
<xsl:text>
\end{hangparas}
</xsl:text>
    </xsl:template>
    <xsl:template match="tei:listBibl[ancestor::tei:listBibl]">
      <xsl:apply-templates select="tei:head" mode="bypass"/>
      <xsl:if test="@xml:id">
	<xsl:text>\phantomsection\label{</xsl:text>
	<xsl:value-of select="@xml:id"/>
	<xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:text>\begin{itemize}[nosep,leftmargin=2em]
      </xsl:text>
      <xsl:for-each select="tei:bibl">
	<xsl:text>\item </xsl:text>
	<xsl:apply-templates select="." mode="second"/>
      </xsl:for-each>
      <xsl:text>\end{itemize}\medskip

</xsl:text>
    </xsl:template>
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
    <xsl:template match="tei:note[@place='foot'][ancestor::tei:quote]">
      <xsl:text>\footnotemark{}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:note[@place='foot'][ancestor::tei:quote]" mode="text">
      <xsl:text>\footnotetext{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:note[@place='foot'][not(ancestor::tei:quote)]">
      <xsl:text>\footnote{</xsl:text>
      <xsl:text disable-output-escaping="yes"><![CDATA[%]]>
</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}
</xsl:text>
    </xsl:template>
    <xsl:template match="tei:notesStmt" />
    <xsl:template match="tei:num" />
    <xsl:template match="tei:objectDesc" />
    <xsl:template match="tei:origDate" />
    <xsl:template match="tei:origPlace" />
    <xsl:template match="tei:p">
      <xsl:if test="./preceding-sibling::tei:p">
	<xsl:text>

</xsl:text>
      </xsl:if>
      <xsl:if test="ancestor::tei:note[@place='foot']">
	<xsl:if test="preceding-sibling::tei:quote">
	  <xsl:text>\noindent{}</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="./following-sibling::tei:p">
	<xsl:if test="ancestor::tei:quote">
	  <xsl:text>\medskip</xsl:text>
	</xsl:if>
	<xsl:if test="ancestor::tei:note[@place='foot']">
	  <xsl:text>\setlength{\parindent}{2em}</xsl:text>
	</xsl:if>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:template>
    <xsl:template match="tei:pb"/>
    <xsl:template match="tei:persName" />
    <xsl:template match="tei:physDesc" />
    <xsl:template match="tei:placeName" />
    <xsl:template match="tei:prefixDef" />
    <xsl:template match="tei:profileDesc" />
    <xsl:template match="tei:projectDesc" />
    <xsl:template match="tei:ptr">
      <xsl:text>\url{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:publicationStmt" />
    <xsl:template match="tei:pubPlace" />
    <xsl:template match="tei:punctuation" />
    <xsl:template match="tei:q[@type='phonemic']">
      <xsl:text>/</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>/</xsl:text>
    </xsl:template>
    <xsl:template match="tei:quote[ancestor::tei:note[@place='foot']]">
      <xsl:text>
\vspace{-1.5ex}\begin{quote}\raggedright
      </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{quote}\vspace{-1.5ex}
      </xsl:text>
    </xsl:template>
    <xsl:template match="tei:quote[not(ancestor::tei:note[@place='foot'])]">
      <xsl:text>
\begin{pullquote}\raggedright
      </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
\end{pullquote}
      </xsl:text>
      <xsl:if test=".//tei:note[@place='foot']">
	<xsl:for-each select=".//tei:note[@place='foot']">
	  <xsl:apply-templates select="." mode="text"/>
	</xsl:for-each>
      </xsl:if>
    </xsl:template>
    <xsl:template match="tei:quote" mode="plain">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:rdg"/>
    <xsl:template match="tei:ref">
      <xsl:choose>
	<xsl:when test="starts-with(@target,'#')">
	  <xsl:text>\hyperref[</xsl:text>
	  <xsl:value-of select="translate(@target,'#','')"/>
	  <xsl:text>]{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>\href{</xsl:text>
	  <xsl:value-of select="@target"/>
	  <xsl:text>}{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:repository" />
    <xsl:template match="tei:resp" />
    <xsl:template match="tei:respStmt" />
    <xsl:template match="tei:revisionDesc" />
    <xsl:template match="tei:roleName" />
    <xsl:template match="tei:row">
      <xsl:apply-templates/>
      <xsl:text> \\</xsl:text>
      <xsl:if test="not(following-sibling::tei:row)">
	<xsl:text>\bottomrule</xsl:text>
      </xsl:if>
      <xsl:text>
      </xsl:text>
    </xsl:template>
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
    <xsl:template match="tei:table">
      <xsl:text>

\begin{table}[ht!]\label{tab</xsl:text>
<xsl:value-of select="count(preceding::tei:table)+1"/>
<xsl:text>}\centering
</xsl:text>
<xsl:if test="tei:head">
  <xsl:text>\caption{</xsl:text>
  <xsl:apply-templates select="tei:head" mode="bypass"/>
  <xsl:text>}</xsl:text>
</xsl:if>
<xsl:text>
\begin{tabularx}{\textwidth}{</xsl:text>
<xsl:for-each select="./tei:row[1]/tei:cell">
  <xsl:text>X</xsl:text>
</xsl:for-each>
  <xsl:text>}\toprule
</xsl:text>
      <xsl:choose>
	<xsl:when test="./tei:row[@role='label']">
	  <xsl:for-each select="./tei:row[@role='label']/tei:cell">
	    <xsl:apply-templates select="." mode="heading"/>
	  </xsl:for-each>
	  <xsl:text>\\\midrule
	  </xsl:text>
	  <xsl:apply-templates select="./tei:row[not(@role='label')]"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>
\end{tabularx}
\end{table}
      </xsl:text>
    </xsl:template>

    <xsl:template match="tei:TEI">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:term">
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:text">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:textClass" />
    <xsl:template match="tei:textLang" />
    <xsl:template match="tei:title[not(ancestor-or-self::tei:titleStmt)]">
      <xsl:choose>
	<xsl:when test="contains(concat(' ',$ind,' '),concat(' ',substring-after(@xml:lang,'-'),' '))">
	  <xsl:apply-templates/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>\emph{</xsl:text>
	  <xsl:apply-templates/>
	  <xsl:text>}</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:title[ancestor::tei:titleStmt]">
      <xsl:apply-templates/>
    </xsl:template>
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

    <xsl:template match="tei:ab[not(@type='translation')]">
      <xsl:if test="preceding::tei:lg">
	<xsl:text>

	</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:text>\\
</xsl:text>
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
    

    <xsl:template match="text()">
      <xsl:choose>
	<xsl:when test="ancestor-or-self::*[@xml:lang][1]">
	  <xsl:variable name="recentLang">
	    <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
	  </xsl:variable>
	  <xsl:choose>
	    <xsl:when test="$recentLang = 'eng'">
	      <xsl:value-of select="."/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:variable name="script"><xsl:value-of select="substring-after($recentLang,'-')"/></xsl:variable>
	      <xsl:variable name="language"><xsl:value-of select="substring-before($recentLang,'-')"/></xsl:variable>
	      <xsl:choose>
		<xsl:when test="$script != 'Latn'">
		  <xsl:choose>
		    <xsl:when test="$script = 'Knda'">
		      <xsl:text>\textkannada{</xsl:text>
		    </xsl:when>
		    <xsl:when test="$script = 'Deva'">
		      <xsl:text>\textsanskrit{</xsl:text>
		    </xsl:when>
		    <xsl:when test="$script = 'Telu'">
		      <xsl:text>\texttelugu{</xsl:text>
		    </xsl:when>
		    <xsl:when test="$script = 'Mlym'">
		      <xsl:text>\textmalayalam{</xsl:text>
		    </xsl:when>
		    <xsl:when test="$script = 'Taml'">
		      <xsl:text>\texttamil{</xsl:text>
		    </xsl:when>
		  </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:choose>
		    <xsl:when test="ancestor::tei:bibl or ancestor::tei:title">
		      <xsl:text>{</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>\emph{</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		  <xsl:choose>
		    <xsl:when test="position() = 1">
		      <xsl:value-of select="replace(replace(replace(.,'\n+',''),'^\s+',''),'\s+',' ')"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="replace(replace(.,'\n+',' '),'\s+',' ')"/>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:otherwise>
	      </xsl:choose>
	      <xsl:text>}</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="."/>
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
