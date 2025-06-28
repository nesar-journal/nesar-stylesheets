<xsl:stylesheet version="2.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:strip-space elements="tei:p tei:s tei:list tei:item tei:head tei:note tei:div tei:body tei:text tei:TEI tei:lg tei:quote tei:back tei:listBibl"/>

  <xsl:character-map name="special">
    <xsl:output-character character="&amp;" string="\&amp;"/>
    <xsl:output-character character="%" string="\%"/>
    <xsl:output-character character="—" string="\Dash"/>
    <xsl:output-character character="#" string="\#"/>
  </xsl:character-map>

  <!-- Location of the translation document !-->
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  <xsl:variable name="ind" select="'Knda Deva Telu Mlym'"/>
  
    <xsl:template match="/">
      <xsl:result-document href="./latex/data.bib" use-character-maps="special" method="text" omit-xml-declaration="true">
	<xsl:apply-templates/>
      </xsl:result-document>
    </xsl:template> 

    <xsl:template match="tei:ab" />
    <xsl:template match="tei:abbr">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:add" />
    <xsl:template match="tei:anchor" />
    <xsl:template match="tei:app" />
    <xsl:template match="tei:author">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:authority" />
    <xsl:template match="tei:availability" />
    <xsl:template match="tei:back">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:bibl"/>
    <xsl:template match="tei:biblFull"/>
    <xsl:template match="tei:biblStruct">
      <xsl:choose>
	<!-- If it has an ANALYTIC element,
	     it is either a journal article or
	     an article in a collection or book. !-->
	<xsl:when test="./tei:analytic">
	  <!-- If there is analytic/author or analytic/editor,
	       we assume that it is a journal article or an
	       article in a collection. Otherwise we assume
	       that it is the "inbook" type of bibtex. !-->
	  <xsl:choose>
	    <!-- case for inbook type !-->
	    <xsl:when test="not(./tei:analytic/tei:author or ./tei:analytic/tei:editor)">
	      <xsl:call-template name="in-book">
		<xsl:with-param name="key" select="@xml:id"/>
		<xsl:with-param name="authors" select="./tei:monogr/tei:author"/>
		<xsl:with-param name="title" select="./tei:analytic/tei:title[@type='main']"/>
		<xsl:with-param name="booktitle" select="./tei:monogr/tei:title[@level='m']"/>
		<xsl:with-param name="publisher" select="./tei:monogr/tei:imprint/tei:publisher"/>
		<xsl:with-param name="pubplace" select="./tei:monogr/tei:imprint/tei:pubPlace"/>
		<xsl:with-param name="pages" select="./tei:monogr/tei:biblScope[@unit='page']"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- case for journal !-->
	    <xsl:when test="./tei:monogr/tei:title[@level='j']">
	      <xsl:call-template name="journal-article">
		<xsl:with-param name="key" select="@xml:id"/>
		<xsl:with-param name="title" select="./tei:analytic/tei:title[@type='main']"/>
		<xsl:with-param name="authors" select="./tei:analytic/tei:author"/>
		<xsl:with-param name="authors" select="./tei:analytic/tei:editor"/>
		<xsl:with-param name="journal" select="./tei:monogr/tei:title[@level='j']"/>
		<xsl:with-param name="volume" select="./tei:monogr/tei:biblScope[@unit='volume']"/>
		<xsl:with-param name="issue" select="./tei:monogr/tei:biblScope[@unit='issue']"/>
		<xsl:with-param name="pages" select="./tei:monogr/tei:biblScope[@unit='page']"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- case for incollection !-->
	    <xsl:otherwise>
	      <xsl:call-template name="in-collection">
		<xsl:with-param name="key" select="@xml:id"/>
		<xsl:with-param name="title" select="./tei:analytic/tei:title[@type='main']"/>
		<xsl:with-param name="authors" select="./tei:analytic/tei:author"/>
		<xsl:with-param name="booktitle" select="./tei:monogr/tei:title[@level='m']"/>
		<xsl:with-param name="editors" select="./tei:monogr/tei:editor"/>
		<xsl:with-param name="publisher" select="./tei:monogr/tei:imprint/tei:publisher"/>
		<xsl:with-param name="pubplace" select="./tei:monogr/tei:imprint/tei:pubPlace"/>
		<xsl:with-param name="pages" select="./tei:monogr/tei:biblScope[@unit='page']"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<!-- case for monographs, reports, etc. !-->
	<xsl:otherwise>
	  <!-- items that have authors (e.g., books) !-->
	  <xsl:choose>
	    <xsl:when test="./tei:monogr/tei:author or ./tei:monogr/tei:editor">
	      <xsl:call-template name="monograph">
		<xsl:with-param name="authors" select="./tei:monogr/tei:author"/>
		<xsl:with-param name="editors" select="./tei:monogr/tei:editor"/>
		<xsl:with-param name="key" select="@xml:id"/>
		<xsl:with-param name="title" select="./tei:monogr/tei:title[@type='main']"/>
		<xsl:with-param name="publisher" select="./tei:monogr/tei:imprint/tei:publisher"/>
		<xsl:with-param name="pubplace" select="./tei:monogr/tei:imprint/tei:pubPlace"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- items that have no authors (e.g., reports) !-->
	    <xsl:otherwise>
	      <xsl:call-template name="report">
		<xsl:with-param name="key" select="@xml:id"/>
		<xsl:with-param name="title" select="./tei:monogr/tei:title[@type='main']"/>
		<xsl:with-param name="publisher" select="./tei:monogr/tei:imprint/tei:publisher"/>
		<xsl:with-param name="pubplace" select="./tei:monogr/tei:imprint/tei:pubPlace"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
      <!-- If the bibligraphy entry has REF elements
	   associated with it, i.e., external links,
	   print them in a list. !-->
      <xsl:if test="./tei:ref">
	<xsl:element name="ul">
	  <xsl:for-each select="./tei:ref">
	    <xsl:element name="li">
	      <xsl:element name="a">
		<xsl:attribute name="href">
		  <xsl:value-of select="."/>
		</xsl:attribute>
		<xsl:attribute name="target">
		  <xsl:text>_blank</xsl:text>
		</xsl:attribute>
		<xsl:value-of select="."/>
	      </xsl:element>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:element>
      </xsl:if>
      <xsl:text>}
</xsl:text>
    </xsl:template>
    <xsl:template match="tei:body"/>
    <xsl:template match="tei:caesura"/>
    <xsl:template match="tei:cell"/>
    <xsl:template match="tei:certainty" />
    <xsl:template match="tei:change" />
    <xsl:template match="tei:choice" />
    <xsl:template match="tei:cit" />
    <xsl:template match="tei:citedRange">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:collection" />
    <xsl:template match="tei:colophon" />
    <xsl:template match="tei:correction" />
    <xsl:template match="tei:date">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:del" />
    <xsl:template match="tei:div"/>
    <xsl:template match="tei:editor">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:editorialDecl" />
    <xsl:template match="tei:encodingDesc" />
    <xsl:template match="tei:expan" />
    <xsl:template match="tei:fileDesc"/>
    <xsl:template match="tei:filiation" />
    <xsl:template match="tei:foreign">
      <xsl:apply-templates/>
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
    <xsl:template match="tei:gap"/>
    <xsl:template match="tei:gloss" />
    <xsl:template match="tei:handDesc" />
    <xsl:template match="tei:handNote" />
    <xsl:template match="tei:head"/>
    <xsl:template match="tei:hi[not(@rend = 'bold')]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:hi[@rend='bold']">
      <xsl:text>\textbf{</xsl:text>
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
    <xsl:template match="tei:l"/>
    <xsl:template match="tei:label" />
    <xsl:template match="tei:lacunaEnd"/>
    <xsl:template match="tei:lacunaStart"/>
    <xsl:template match="tei:language" />
    <xsl:template match="tei:langUsage" />
    <xsl:template match="tei:lb"/>
    <xsl:template match="tei:lem"/>
    <xsl:template match="tei:lg"/>
    <xsl:template match="tei:license" />
    <xsl:template match="tei:list"/>
    <xsl:template match="tei:listApp" />
    <xsl:template match="tei:listBibl">
      <xsl:apply-templates/>
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
    <xsl:template match="tei:note">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:notesStmt" />
    <xsl:template match="tei:num" />
    <xsl:template match="tei:objectDesc" />
    <xsl:template match="tei:origDate" />
    <xsl:template match="tei:origPlace" />
    <xsl:template match="tei:p"/>
    <xsl:template match="tei:pb"/>
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
    <xsl:template match="tei:q"/>
    <xsl:template match="tei:quote"/>
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
    <xsl:template match="tei:row"/>
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
    <xsl:template match="tei:supplied"/>
    <xsl:template match="tei:supportDesc" />
    <xsl:template match="tei:surname" />
    <xsl:template match="tei:surplus" />
    <xsl:template match="tei:table"/>
    <xsl:template match="tei:TEI">
      <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:term">
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:text"/>
    <xsl:template match="tei:textClass" />
    <xsl:template match="tei:textLang" />
    <xsl:template match="tei:title">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
    </xsl:template>
    <xsl:template match="tei:titleStmt" />
    <xsl:template match="tei:trailer"/>
    <xsl:template match="tei:unclear" />
    <xsl:template match="tei:variantEncoding" />
    <xsl:template match="tei:witDetail" />
    <xsl:template match="tei:witness" />



    <!-- Text node processing !-->
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
		  <xsl:text>\emph{</xsl:text>
		  <xsl:value-of select="."/>
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

    <!-- NAMED TEMPLATES !-->
    <xsl:template name="authors">
      <xsl:param name="authors"/>
      <xsl:for-each select="$authors">
	<xsl:choose>
	  <xsl:when test="position() = 1"><!-- if the name is first !-->
	    <xsl:choose>
	      <xsl:when test="./tei:persName/tei:surname">
		<xsl:apply-templates select="./tei:persName/tei:surname"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="./tei:persName/tei:forename"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates select="./tei:persName"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise><!-- if the name isn't first !-->
	    <xsl:choose>
	      <xsl:when test="following-sibling::tei:author">
		<xsl:text>, </xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text> and </xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:choose>
	      <xsl:when test="./tei:persName/tei:surname">
		<xsl:apply-templates select="./tei:persName/tei:forename"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="./tei:persName/tei:surname"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates select="./tei:persName"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:template>


    <xsl:template name="lastnamefirst">
      <xsl:param name="names"/>
      <xsl:for-each select="$names">
	<xsl:choose>
	  <xsl:when test="not(position() = 1)"><!-- if the name isn't first !-->
	    <xsl:choose>
	      <xsl:when test="following-sibling">
		<xsl:text>, </xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text> and </xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:choose>
	      <xsl:when test="./tei:persName/tei:surname">
		<xsl:apply-templates select="./tei:persName/tei:forename"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="./tei:persName/tei:surname"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates select="./tei:persName"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="./tei:persName/tei:surname">
		<xsl:apply-templates select="./tei:persName/tei:surname"/>
		<xsl:text>, </xsl:text>
		<xsl:apply-templates select="./tei:persName/tei:forename"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:apply-templates select="./tei:persName"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:template>

    <xsl:template name="name-list">
      <xsl:param name="names"/>
      <xsl:for-each select="$names">
	<xsl:if test="not(position() = 1)">
	  <xsl:text> and </xsl:text>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="./tei:persName/tei:surname">
	    <xsl:value-of select="./tei:persName/tei:forename"/>
	    <xsl:text> </xsl:text>
	    <xsl:text>{</xsl:text><xsl:value-of select="./tei:persName/tei:surname"/><xsl:text>}</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="./tei:persName"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
    </xsl:template>


    <xsl:template name="in-book">
      <xsl:param name="key"/>
      <xsl:param name="authors"/>
      <xsl:param name="editors"/>
      <xsl:param name="title"/>
      <xsl:param name="booktitle"/>
      <xsl:param name="pages"/>
      <xsl:param name="publisher"/>
      <xsl:param name="pubplace"/>
      <xsl:param name="year"/>
      <xsl:text>@incollection{</xsl:text><xsl:value-of select="$key"/><xsl:text>
</xsl:text>
      <xsl:text>  author = {</xsl:text>
      <xsl:call-template name="name-list">
	<xsl:with-param name="names" select="$authors"/>
      </xsl:call-template>
      <xsl:text>}
</xsl:text>
      <xsl:text>  title = {</xsl:text><xsl:value-of select="$title"/><xsl:text>}
</xsl:text>
      <xsl:text>  booktitle = {</xsl:text><xsl:value-of select="$booktitle"/><xsl:text>}
</xsl:text>
      <xsl:text>  pages = {</xsl:text><xsl:value-of select="$pages"/><xsl:text>}
</xsl:text>
      <xsl:text>  publisher = {</xsl:text><xsl:value-of select="$publisher"/><xsl:text>}
</xsl:text>
      <xsl:text>  address = {</xsl:text><xsl:value-of select="$pubplace"/><xsl:text>}
</xsl:text>
      <xsl:text>  year = {</xsl:text><xsl:value-of select="$year"/><xsl:text>}
</xsl:text>
    </xsl:template>

    <xsl:template name="in-collection">
      <xsl:param name="key"/>
      <xsl:param name="authors"/>
      <xsl:param name="editors"/>
      <xsl:param name="title"/>
      <xsl:param name="booktitle"/>
      <xsl:param name="pages"/>
      <xsl:param name="publisher"/>
      <xsl:param name="pubplace"/>
      <xsl:param name="year"/>
      <xsl:text>@incollection{</xsl:text><xsl:value-of select="$key"/><xsl:text>
</xsl:text>
      <xsl:text>  author = {</xsl:text>
      <xsl:call-template name="name-list">
	<xsl:with-param name="names" select="$authors"/>
      </xsl:call-template>
      <xsl:text>}
</xsl:text>
      <xsl:if test="$editors != false">
	<xsl:text>  editor = {</xsl:text>
	<xsl:call-template name="name-list">
	  <xsl:with-param name="names" select="$editors"/>
	</xsl:call-template>
	<xsl:text>}
</xsl:text>
      </xsl:if>
      <xsl:text>  title = {</xsl:text><xsl:value-of select="$title"/><xsl:text>}
</xsl:text>
      <xsl:text>  booktitle = {</xsl:text><xsl:value-of select="$booktitle"/><xsl:text>}
</xsl:text>
      <xsl:text>  pages = {</xsl:text><xsl:value-of select="$pages"/><xsl:text>}
</xsl:text>
      <xsl:text>  publisher = {</xsl:text><xsl:value-of select="$publisher"/><xsl:text>}
</xsl:text>
      <xsl:text>  address = {</xsl:text><xsl:value-of select="$pubplace"/><xsl:text>}
</xsl:text>
      <xsl:text>  year = {</xsl:text><xsl:value-of select="$year"/><xsl:text>}
</xsl:text>
    </xsl:template>
    <xsl:template name="journal-article">
      <xsl:param name="key"/>
      <xsl:param name="authors"/>
      <xsl:param name="editors"/>
      <xsl:param name="title"/>
      <xsl:param name="journal"/>
      <xsl:param name="volume"/>
      <xsl:param name="issue"/>
      <xsl:param name="pages"/>
      <xsl:param name="year"/>
      <xsl:text>@article{</xsl:text><xsl:value-of select="$key"/><xsl:text>
</xsl:text>
      <xsl:text>  author = {</xsl:text>
      <xsl:call-template name="name-list">
	<xsl:with-param name="names" select="$authors"/>
      </xsl:call-template>
      <xsl:text>}
</xsl:text>
      <xsl:text>  title = {</xsl:text><xsl:value-of select="$title"/><xsl:text>}
</xsl:text>
      <xsl:text>  journal = {</xsl:text><xsl:value-of select="$journal"/><xsl:text>}
</xsl:text>
      <xsl:text>  volume = {</xsl:text><xsl:value-of select="$volume"/><xsl:text>
</xsl:text>
      <xsl:if test="$issue != false">
	<xsl:text>  issue = {</xsl:text><xsl:value-of select="$issue"/><xsl:text>
</xsl:text>
      </xsl:if>
      <xsl:text>  pages = {</xsl:text><xsl:value-of select="$pages"/><xsl:text>
</xsl:text>
      <xsl:text>  year = {</xsl:text><xsl:value-of select="$year"/><xsl:text>
</xsl:text>
    </xsl:template>
    <xsl:template name="monograph">
      <xsl:param name="key"/>
      <xsl:param name="title"/>
      <xsl:param name="authors"/>
      <xsl:param name="publisher"/>
      <xsl:param name="pubplace"/>
      <xsl:param name="year"/>
      <xsl:text>@book{</xsl:text><xsl:value-of select="$key"/><xsl:text>
</xsl:text>
      <xsl:if test="$authors != false">
	<xsl:text>  author = {</xsl:text>
	<xsl:call-template name="name-list">
	  <xsl:with-param name="names" select="$authors"/>
	</xsl:call-template>
	<xsl:text>}
</xsl:text>
      </xsl:if>
      <xsl:if test="$editors != false">
	<xsl:text> editor = {</xsl:text>
	<xsl:call-template name="name-list">
	  <xsl:with-param name="names" select="$editors"/>
	</xsl:call-template>
	<xsl:text>}
</xsl:text>
      </xsl:if>
      <xsl:text>  title = {</xsl:text><xsl:value-of select="$title"/><xsl:text>}
</xsl:text>
      <xsl:text>  year = {</xsl:text><xsl:value-of select="$year"/><xsl:text>}
</xsl:text>
      <xsl:text>  publisher = {</xsl:text><xsl:value-of select="$publisher"/><xsl:text>}
</xsl:text>
      <xsl:text>  address = {</xsl:text><xsl:value-of select="$pubplace"/><xsl:text>}
</xsl:text>
    </xsl:template>

    <xsl:template name="report">
      <xsl:param name="key"/>
      <xsl:param name="title"/>
      <xsl:param name="publisher"/>
      <xsl:param name="pubplace"/>
      <xsl:param name="year"/>
      <xsl:text>@book{</xsl:text><xsl:value-of select="$key"/><xsl:text>
</xsl:text>
      <xsl:text>  title = {</xsl:text><xsl:value-of select="$title"/><xsl:text>}
</xsl:text>
      <xsl:text>  year = {</xsl:text><xsl:value-of select="$year"/><xsl:text>}
</xsl:text>
      <xsl:text>  publisher = {</xsl:text><xsl:value-of select="$publisher"/><xsl:text>}
</xsl:text>
      <xsl:text>  address = {</xsl:text><xsl:value-of select="$pubplace"/><xsl:text>}
</xsl:text>
    </xsl:template>

    <xsl:template name="series">
      <xsl:param name="title"/>
      <xsl:param name="volume"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="$title"/>
      <xsl:text> no. </xsl:text>
      <xsl:apply-templates select="$volume"/>
      <xsl:text>.</xsl:text>
    </xsl:template>
 
</xsl:stylesheet>
