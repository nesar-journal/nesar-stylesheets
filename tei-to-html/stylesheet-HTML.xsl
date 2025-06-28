<xsl:stylesheet version="3.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:fn="http://www.w3.org/2005/xpath-functions"
		xmlns:ext="http://exslt.org/common">
  <xsl:output method="html" 
	      indent="yes" 
	      suppress-indentation="tei:hi tei:ref tei:p tei:em"
	      omit-xml-declaration="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- Given a TEI document, this stylesheet transforms it 
       into an XHTML fragment. !-->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template> 
  <!-- AB !-->
  <xsl:template match="tei:ab">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- ABBR !-->
  <xsl:template match="tei:abbr">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:add" />
  <!-- ADD !-->
  <xsl:template match="tei:anchor" />
  <!-- APP !-->
  <xsl:template match="tei:app">
    <xsl:element name="li">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- AUTHOR !-->
  <xsl:template match="tei:author" />
  <!-- AUTHORITY !-->
  <xsl:template match="tei:authority" />
  <!-- AVAILABILITY !-->
  <xsl:template match="tei:availability">
    <xsl:element name="div">
      <xsl:element name="div">
	<xsl:element name="img">
	  <xsl:attribute name="src">/assets/images/open_access_F6820B.png</xsl:attribute>
	  <xsl:attribute name="height">32px</xsl:attribute>
	</xsl:element>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- BACK !-->
  <xsl:template match="tei:back">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- BIBL !-->
  <xsl:template match="tei:bibl[not(ancestor-or-self::tei:listBibl)]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:bibl[ancestor-or-self::tei:listBibl]">
    <xsl:element name="li">
      <xsl:if test="@xml:id">
	<xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:biblFull" />
  <!-- BIBLSTRUCT !-->
  <!-- The preferred element for bibliography items. !-->
  <xsl:template match="tei:biblStruct">
    <xsl:element name="li">
      <xsl:if test="@xml:id">
	<xsl:attribute name="id">
	  <xsl:value-of select="@xml:id"/>
	</xsl:attribute>
      </xsl:if>
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
	      <xsl:variable name="authorstring">
		<xsl:choose>
		  <xsl:when test="./tei:analytic/tei:author">
		    <xsl:call-template name="authors">
		      <xsl:with-param name="authors" select="./tei:analytic/tei:author"/>
		    </xsl:call-template>
		  </xsl:when>
		  <xsl:when test="./tei:analytic/tei:editor">
		    <xsl:call-template name="editors">
		      <xsl:with-param name="editors" select="./tei:analytic/tei:editor"/>
		    </xsl:call-template>
		  </xsl:when>
		</xsl:choose>
	      </xsl:variable>
	      <xsl:value-of select="$authorstring"/>
	      <xsl:if test="substring($authorstring,string-length($authorstring),1) != '.'">
		<xsl:text>.</xsl:text>
	      </xsl:if>
	      <xsl:text> </xsl:text>
	      <xsl:call-template name="journal-article">
		<xsl:with-param name="title" select="./tei:analytic/tei:title[@type='main']"/>
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
		<xsl:with-param name="authors" select="./tei:analytic/tei:author"/>
		<xsl:with-param name="title" select="./tei:analytic/tei:title[@type='main']"/>
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
	      <xsl:variable name="authorstring">
		<xsl:choose>
		  <xsl:when test="./tei:monogr/tei:author">
		    <xsl:call-template name="authors">
		      <xsl:with-param name="authors" select="./tei:monogr/tei:author"/>
		    </xsl:call-template>
		  </xsl:when>
		  <xsl:when test="./tei:analytic/tei:editor">
		    <xsl:call-template name="editors">
		      <xsl:with-param name="editors" select="./tei:monogr/tei:editor"/>
		    </xsl:call-template>
		  </xsl:when>
		  <xsl:otherwise/>
		</xsl:choose>
	      </xsl:variable>
	      <xsl:value-of select="$authorstring"/>
	      <xsl:if test="substring($authorstring,string-length($authorstring),1) != '.'">
		<xsl:text>.</xsl:text>
	      </xsl:if>
	      <xsl:text> </xsl:text>
	      <xsl:call-template name="monograph">
		<xsl:with-param name="title" select="./tei:monogr/tei:title[@type='main']"/>
		<xsl:with-param name="publisher" select="./tei:monogr/tei:imprint/tei:publisher"/>
		<xsl:with-param name="pubplace" select="./tei:monogr/tei:imprint/tei:pubPlace"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
		<xsl:with-param name="authoreditor">
		  <xsl:choose>
		    <xsl:when test=".//tei:author or .//tei:editor">
		      <xsl:text>true</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:text>false</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:with-param>
	      </xsl:call-template>
	    </xsl:when>
	    <!-- items that have no authors (e.g., reports) !-->
	    <xsl:otherwise>
	      <xsl:call-template name="monograph">
		<xsl:with-param name="title" select="./tei:monogr/tei:title[@type='main']"/>
		<xsl:with-param name="publisher" select="./tei:monogr/tei:imprint/tei:publisher"/>
		<xsl:with-param name="pubplace" select="./tei:monogr/tei:imprint/tei:pubPlace"/>
		<xsl:with-param name="year" select="./tei:monogr/tei:imprint/tei:date"/>
		<xsl:with-param name="authoreditor" select="false"/>
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
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:body">
    <xsl:apply-templates/>
    <!-- Note division !-->
    <xsl:element name="div">
      <xsl:attribute name="class">nesar-notes</xsl:attribute>
      <xsl:element name="h2">
	<xsl:text>Notes</xsl:text>
      </xsl:element>
      <xsl:element name="ol">
	<xsl:for-each select=".//tei:note[@place='foot']">
	  <xsl:apply-templates select="." mode="endnotes"/>
	</xsl:for-each>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:caesura"/>
  <xsl:template match="tei:certainty" />
  <xsl:template match="tei:change">
    <xsl:element name="li">
      <xsl:value-of select="./tei:date"/>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="./tei:name"/>
      <xsl:text>): </xsl:text>
      <xsl:apply-templates select="./tei:desc"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:choice" />
  <xsl:template match="tei:cit">
    <!-- cit must have a quote and bibl element !-->
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="class">text-blockquote</xsl:attribute>
	<xsl:element name="blockquote">
	  <xsl:if test="@type">
	    <xsl:attribute name="class">
	      <xsl:value-of select="@type"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:apply-templates select="tei:quote"/>
	  <xsl:element name="p">
	    <xsl:attribute name="class">bibl-string</xsl:attribute>
	    <xsl:apply-templates select="tei:bibl"/>
	  </xsl:element>
	</xsl:element>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">sidenote-column</xsl:attribute>
	<xsl:if test=".//tei:note[@place='foot']">
	  <xsl:element name="ul">
	    <xsl:attribute name="class">sidenotes</xsl:attribute>
	    <xsl:for-each select=".//tei:note[@place='foot']">
	      <xsl:apply-templates select="." mode="sidenotes"/>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:citedRange">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:cell">
    <xsl:element name="td">
      <xsl:if test="@cols">
	<xsl:attribute name="colspan">
	  <xsl:value-of select="@cols"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:collection" />
  <xsl:template match="tei:colophon" />
  <xsl:template match="tei:correction" />
  <xsl:template match="tei:date">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:del" />
  <xsl:template match="tei:desc">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:div[@type='ack']">
    <xsl:element name="div">
      <xsl:attribute name="class">acknowledgements</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[parent::tei:body][not(@type='ack')]">
    <xsl:element name="div">
      <xsl:attribute name="class">text-section</xsl:attribute>
      <xsl:if test="tei:head">
	<xsl:element name="h2">
	  <xsl:apply-templates select="tei:head" mode="bypass"/>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[parent::tei:body]/tei:div">
    <xsl:element name="div">
      <xsl:if test="tei:head">
	<xsl:element name="h3">
	  <xsl:apply-templates select="tei:head" mode="bypass"/>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[parent::tei:body]/tei:div/tei:div">
    <xsl:element name="div">
      <xsl:if test="tei:head">
	<xsl:element name="h4">
	  <xsl:apply-templates select="tei:head" mode="bypass"/>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:editor" />
  <xsl:template match="tei:editorialDecl" />
  <xsl:template match="tei:editionStmt"/>
  <xsl:template match="tei:encodingDesc" />
  <xsl:template match="tei:expan" />
  <xsl:template match="tei:fileDesc">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:figure">
    <xsl:variable name="figurenumber">
      <xsl:value-of select="count(preceding::tei:figure)+1"/>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="class">figure-wrapper</xsl:attribute>
	<xsl:element name="figure">
	  <xsl:if test="tei:graphic">
	    <xsl:element name="img">
	      <xsl:attribute name="src">
		<xsl:value-of select="tei:graphic/@url"/>
	      </xsl:attribute>
	      <xsl:if test="tei:figDesc">
		<xsl:attribute name="alt">
		  <xsl:value-of select="tei:figDesc"/>
		</xsl:attribute>
	      </xsl:if>
	    </xsl:element>
	  </xsl:if>
	</xsl:element>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">figure-label</xsl:attribute>
	<xsl:if test="tei:head">
	  <xsl:element name="figcaption">
	    <xsl:element name="h5">
	      <xsl:element name="a">
		<xsl:attribute name="id">
		  <xsl:value-of select="concat('fig',$figurenumber)"/>
		</xsl:attribute>
	      </xsl:element>
	      <xsl:text>Figure </xsl:text>
	      <xsl:value-of select="$figurenumber"/>
	    </xsl:element>
	    <xsl:apply-templates select="tei:head" mode="bypass"/>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:filiation" />
  <xsl:template match="tei:foreign">
    <xsl:element name="span">
      <xsl:attribute name="class">foreign</xsl:attribute>
      <xsl:if test="@xml:lang">
	<xsl:call-template name="langScript">
	  <xsl:with-param name="langScript" select="@xml:lang"/>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:forename">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:front">
    <xsl:element name="div">
      <xsl:attribute name="class">frontmatter</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
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
  <xsl:template match="tei:head[ancestor::tei:figure]" mode="bypass">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:head[ancestor::tei:table]" mode="bypass">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:head" mode="bypass">
    <xsl:if test="tei:anchor">
      <xsl:element name="a">
	<xsl:attribute name="id">
	  <xsl:value-of select="tei:anchor/@xml:id"/>
	</xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:if test="@n">
      <xsl:value-of select="@n"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:head[@type='toc']" mode="toc">
    <xsl:element name="li">
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:value-of select="concat('#',./tei:anchor/@xml:id)"/>
	</xsl:attribute>
	<xsl:if test="@n">
	  <xsl:value-of select="@n"/>
	  <xsl:text> </xsl:text>
	</xsl:if>
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='smallcaps']">
    <xsl:element name="span">
      <xsl:attribute name="style">font-variant:small-caps;</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='bold']">
    <xsl:element name="b">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:hi[@rend='subscript']">
    <xsl:element name="sub">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:hi">
    <xsl:element name="em">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:history" />
  <xsl:template match="tei:idno[@type='DOI']">
    <xsl:element name="p">
      <xsl:element name="b">
	<xsl:text>DOI: </xsl:text>
      </xsl:element>
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:value-of select="concat('https://doi.org/',.)"/>
	</xsl:attribute>
	<xsl:value-of select="."/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:institution" />
  <xsl:template match="tei:interpretation" />
  <xsl:template match="tei:item">
    <xsl:element name="li">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:join" />
  <xsl:template match="tei:keywords" />
  <xsl:template match="tei:l">
    <xsl:element name="span">
      <xsl:attribute name="class">l</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:label">
    <xsl:element name="span">
      <xsl:if test="@type">
	<xsl:attribute name="class">
	  <xsl:value-of select="@type"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:lacunaEnd"/>
  <xsl:template match="tei:lacunaStart"/>
  <xsl:template match="tei:language" />
  <xsl:template match="tei:langUsage" />
  <xsl:template match="tei:lb">
    <xsl:element name="br"/>
  </xsl:template>
  <xsl:template match="tei:lem">
    <xsl:call-template name="rdg">
      <xsl:with-param name="rdg" select="."/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:lg">
    <xsl:element name="div">
      <xsl:attribute name="class">lg</xsl:attribute>
      <xsl:if test="@met">
	<xsl:attribute name="data-nesar-meter"><xsl:value-of select="@met"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:licence">
    <xsl:element name="div">
      <xsl:attribute name="class">nesar-license</xsl:attribute>
      <xsl:choose>
	<xsl:when test="@target = 'https://creativecommons.org/licenses/by/4.0/'">
	  <xsl:element name="div">
	    <xsl:element name="a">
	      <xsl:attribute name="href">https://creativecommons.org/licenses/by/4.0/</xsl:attribute>
	      <xsl:element name="img">
		<xsl:attribute name="src">/assets/images/cc_icon_F6820B_x2.png</xsl:attribute>
		<xsl:attribute name="height">32px</xsl:attribute>
	      </xsl:element>
	    </xsl:element>
	    <xsl:element name="a">
	      <xsl:attribute name="href">https://creativecommons.org/licenses/by/4.0/</xsl:attribute>
	      <xsl:element name="img">
		<xsl:attribute name="src">/assets/images/attribution_icon_F6820B_x2.png</xsl:attribute>
		<xsl:attribute name="height">32px</xsl:attribute>
	      </xsl:element>
	    </xsl:element>
	  </xsl:element>
	  <xsl:element name="div">
	    <xsl:apply-templates/>
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:link">
    <xsl:element name="a">
      <xsl:attribute name="href">
	<xsl:value-of select="@target"/>
      </xsl:attribute>
      <xsl:value-of select="@target"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:list[@type='examples']">
    <xsl:variable name="n">
      <xsl:value-of select="count(preceding::tei:list[@type='examples']/tei:item)"/>
    </xsl:variable>
    <xsl:element name="ol">
      <xsl:attribute name="class">examples</xsl:attribute>
      <xsl:attribute name="start">
	<xsl:value-of select="$n + 1"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:list[not(@type='examples')][parent::tei:div]">
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:element name="ul">
	<xsl:attribute name="class">text-list</xsl:attribute>
	<xsl:apply-templates/>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">sidenote-column</xsl:attribute>
	<xsl:if test=".//tei:note[@place='foot']">
	  <xsl:element name="ul">
	    <xsl:attribute name="class">sidenotes</xsl:attribute>
	    <xsl:for-each select=".//tei:note[@place='foot']">
	      <xsl:apply-templates select="." mode="sidenotes"/>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:listApp">
    <xsl:element name="ul">
      <xsl:attribute name="class">apparatus</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <!-- LISTBIBL !-->
  <xsl:template match="tei:listBibl[not(ancestor::tei:listBibl)]">
    <xsl:element name="div">
      <xsl:attribute name="class">bibliography</xsl:attribute>
      <xsl:if test="tei:head">
	<xsl:element name="h3">
	  <xsl:apply-templates select="tei:head" mode="bypass"/>
	</xsl:element>
      </xsl:if>
      <xsl:element name="ul">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:listBibl[ancestor::tei:listBibl]">
    <xsl:element name="li">
      <xsl:attribute name="class">text-group</xsl:attribute>
      <xsl:if test="tei:head">
	<xsl:element name="h4">
	  <xsl:apply-templates select="tei:head" mode="bypass"/>
	</xsl:element>
      </xsl:if>
      <xsl:element name="ul">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:listChange">
    <xsl:element name="ul">
      <xsl:apply-templates/>
    </xsl:element>
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
  <xsl:template match="tei:name">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:normalization" />
  <xsl:template match="tei:note[@place='foot']">
    <xsl:element name="sup">
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:value-of select="concat('#',@xml:id)"/>
	</xsl:attribute>
	<xsl:attribute name="id">
	  <xsl:value-of select="concat('ret-',@xml:id)"/>
	</xsl:attribute>
	<xsl:value-of select="@n"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:note[@place='foot']" mode="endnotes">
    <xsl:element name="li">
      <xsl:attribute name="value">
	<xsl:value-of select="@n"/>
      </xsl:attribute>
      <xsl:attribute name="id">
	<xsl:value-of select="@xml:id"/>
      </xsl:attribute>
      <xsl:apply-templates mode="endnotes"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:note[@place='foot']" mode="sidenotes">
    <xsl:element name="li">
      <xsl:apply-templates mode="sidenotes"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:notesStmt" />
  <xsl:template match="tei:num" />
  <xsl:template match="tei:objectDesc" />
  <xsl:template match="tei:origDate" />
  <xsl:template match="tei:origPlace" />
  <xsl:template match="tei:p[not(ancestor::tei:note)][not(ancestor::tei:teiHeader)][not(ancestor::tei:quote)]">
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="class">text-paragraph</xsl:attribute>
	<xsl:element name="p">
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">sidenote-column</xsl:attribute>
	<xsl:if test=".//tei:note[@place='foot']">
	  <xsl:element name="ul">
	    <xsl:attribute name="class">sidenotes</xsl:attribute>
	    <xsl:for-each select=".//tei:note[@place='foot']">
	      <xsl:apply-templates select="." mode="sidenotes"/>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:p[ancestor::tei:note]" mode="endnotes">
    <xsl:element name="p">
      <xsl:if test="not(preceding-sibling::tei:*)">
	<xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:value-of select="concat(concat('#','ret-'),ancestor::tei:note/@xml:id)"/>
	  </xsl:attribute>
	  <xsl:attribute name="class">jump-up</xsl:attribute>
	  <xsl:text>↑</xsl:text>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:p" mode="sidenotes">
    <xsl:element name="p">
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:value-of select="concat('#',ancestor::tei:note/@xml:id)"/>
	</xsl:attribute>
	<xsl:value-of select="../@n"/>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:p[ancestor::tei:teiHeader]">
    <xsl:element name="p">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:p[ancestor::tei:quote]">
    <xsl:element name="p">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:pb"/>
  <xsl:template match="tei:persName">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:physDesc" />
  <xsl:template match="tei:placeName" />
  <xsl:template match="tei:prefixDef" />
  <xsl:template match="tei:profileDesc" />
  <xsl:template match="tei:projectDesc" />
  <xsl:template match="tei:ptr">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
      <xsl:value-of select="@target"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:publicationStmt"/>
  <xsl:template match="tei:publisher">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:pubPlace">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:punctuation" />
  <xsl:template match="tei:q[@type='phonemic']">
    <xsl:element name="span">
      <xsl:attribute name="class">phonemic</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:q">
    <xsl:element name="span">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:quote">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:quote[ancestor::tei:note[@place='foot']]" mode="endnotes">
    <xsl:element name="div">
      <xsl:attribute name="class">quote-in-note</xsl:attribute>
      <xsl:if test="not(preceding-sibling::tei:*)">
	<xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:value-of select="concat(concat('#','ret-'),ancestor::tei:note/@xml:id)"/>
	  </xsl:attribute>
	  <xsl:attribute name="class">jump-up</xsl:attribute>
	  <xsl:text>↑</xsl:text>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:quote[ancestor::tei:note[@place='foot']]" mode="sidenotes">
    <xsl:element name="div">
      <xsl:attribute name="class">quote-in-note</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:quote[not(ancestor::tei:cit)][not(ancestor::tei:note[@place='foot'])]">
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="class">text-blockquote</xsl:attribute>
	<xsl:element name="blockquote">
	  <xsl:if test="@type">
	    <xsl:attribute name="class">
	      <xsl:value-of select="@type"/>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">sidenote-column</xsl:attribute>
	<xsl:if test=".//tei:note[@place='foot']">
	  <xsl:element name="ul">
	    <xsl:attribute name="class">sidenotes</xsl:attribute>
	    <xsl:for-each select=".//tei:note[@place='foot']">
	      <xsl:apply-templates select="." mode="sidenotes"/>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:rdg">
    <xsl:call-template name="rdg">
      <xsl:with-param name="rdg" select="."/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template match="tei:ref">
    <xsl:element name="a">
      <xsl:if test="@target">
	<xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:repository" />
  <xsl:template match="tei:resp" />
  <xsl:template match="tei:respStmt" />
  <xsl:template match="tei:revisionDesc">
    <xsl:element name="div">
      <xsl:attribute name="class">nesar-revision-desc</xsl:attribute>
      <xsl:element name="h3">
	<xsl:text>Revision history</xsl:text>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:roleName" />
  <xsl:template match="tei:row">
    <xsl:element name="tr">
      <xsl:apply-templates/>
    </xsl:element>
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
  <xsl:template match="tei:supplied" />
  <xsl:template match="tei:supportDesc" />
  <xsl:template match="tei:surname">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:surplus" />
  <xsl:template match="tei:table">
    <xsl:variable name="tablenumber">
      <xsl:value-of select="count(preceding::tei:table)+1"/>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:element name="div">
	<xsl:attribute name="class">table-wrapper</xsl:attribute>
	<xsl:element name="table">
	  <xsl:choose>
	    <xsl:when test="./tei:row[@role='label']">
	      <xsl:element name="thead">
		<xsl:apply-templates select="./tei:row[@role='label']"/>
	      </xsl:element>
	      <xsl:element name="tbody">
		<xsl:apply-templates select="./tei:row[not(@role='label')]"/>
	      </xsl:element>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:apply-templates/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:element>
      </xsl:element>
      <xsl:element name="div">
	<xsl:attribute name="class">table-label</xsl:attribute>
	  <xsl:if test="tei:head">
	    <xsl:element name="h5">
	      <xsl:element name="a">
		<xsl:attribute name="id">
		  <xsl:value-of select="concat('tab',$tablenumber)"/>
		</xsl:attribute>
	      </xsl:element>
	      <xsl:text>Table </xsl:text>
	      <xsl:value-of select="$tablenumber"/>
	    </xsl:element>
	    <xsl:element name="caption">
	      <xsl:apply-templates select="tei:head" mode="bypass"/>
	    </xsl:element>
	  </xsl:if>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:TEI">
    <xsl:element name="html">
      <xsl:element name="body">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:teiHeader"/>
  <xsl:template match="tei:teiHeader" mode="bypass">
    <xsl:element name="div">
      <xsl:attribute name="class">nesar-header</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:term"/>
  <xsl:template match="tei:text">
    <xsl:if test=".//tei:head[@type='toc']">
      <xsl:element name="div">
	<xsl:attribute name="class">nesar-toc</xsl:attribute>
	<xsl:element name="ul">
	  <xsl:apply-templates select=".//tei:head[@type='toc']" mode="toc"/>
	</xsl:element>
      </xsl:element>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:apply-templates select="../tei:teiHeader" mode="bypass"/>
  </xsl:template>
  <xsl:template match="tei:textClass" />
  <xsl:template match="tei:textLang" />
  <xsl:template match="tei:title[not(ancestor-or-self::tei:titleStmt)][not(ancestor-or-self::tei:biblStruct)]">
    <xsl:element name="i">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:titleStmt" />
  <xsl:template match="tei:unclear">
    <xsl:element name="span">
      <xsl:attribute name="class">unclear</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:variantEncoding" />
  <xsl:template match="tei:witDetail" />
  <xsl:template match="tei:witness" />

  <!-- WRAP ALL TEXT ELEMENTS WITH LANGUAGE AND SCRIPT ATTRIBUTES !-->
  <!-- Okay, I am not sure whether we want to do this for 
       *all* foreign text, or just those in quote environments.
       Probably the latter. If you want to match *all* foreign 
       text, use the xpath text()[ancestor-or-self::*[@xml:lang][1]. !-->
  <xsl:template match="text()[ancestor-or-self::tei:quote[@xml:lang][1]] | text()[ancestor-or-self::tei:q[@xml:lang][1]]">
    <xsl:variable name="recentLang">
      <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$recentLang = 'eng'">
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="span">
	  <xsl:attribute name="class">scriptWrapper</xsl:attribute>
	  <xsl:call-template name="langScript">
	    <xsl:with-param name="langScript" select="$recentLang"/>
	  </xsl:call-template>
	  <xsl:attribute name="data-nesar-original">
	    <xsl:value-of select="."/>
	  </xsl:attribute>
	  <xsl:if test="ancestor-or-self::*[@rend='closetranscription'][1]">
	    <xsl:attribute name="data-nesar-transcription-type">
	      <xsl:text>close</xsl:text>
	    </xsl:attribute>
	  </xsl:if>
	  <xsl:value-of select="."/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- TEXT PROCESSING:
       remove dashes from edited text !-->
  <xsl:template match="text()">
    <xsl:copy-of select="replace(replace(.,' *— *','&#8212;'),'…','&#x2026;')"/>
  </xsl:template>

  <!-- NAMED TEMPLATES !-->
  <xsl:template name="langScript">
    <xsl:param name="langScript"/>
    <xsl:if test="contains($langScript,'-')">
      <xsl:attribute name="data-nesar-lang"><xsl:value-of select="substring-before($langScript,'-')"/></xsl:attribute>
      <xsl:attribute name="data-nesar-script"><xsl:value-of select="substring-after($langScript,'-')"/></xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="rdg">
    <xsl:param name="rdg"/>
    <xsl:element name="span">
      <xsl:element name="span">
	<xsl:attribute name="class">app-label</xsl:attribute>
	<!-- witnesses !-->
	<xsl:if test="$rdg/@wit">
	  <xsl:for-each select="tokenize($rdg/@wit,' ')">
	    <xsl:element name="h6">
	      <xsl:attribute name="class">wit</xsl:attribute>
	      <xsl:value-of select="translate(.,'#','')"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:if>
	<!-- sources !-->
	<xsl:if test="$rdg/@source">
	  <xsl:for-each select="tokenize($rdg/@source,' ')">
	    <xsl:element name="h6">
	      <xsl:attribute name="class">source</xsl:attribute>
	      <xsl:value-of select="translate(.,'#','')"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:if>
	<!-- resp !-->
	<xsl:if test="$rdg/@resp">
	  <xsl:for-each select="tokenize($rdg/@resp,' ')">
	    <xsl:element name="h6">
	      <xsl:attribute name="class">resp</xsl:attribute>
	      <xsl:value-of select="translate(.,'#','')"/>
	    </xsl:element>
	  </xsl:for-each>
	</xsl:if>
      </xsl:element>
      <xsl:element name="span">
	<xsl:attribute name="class">rdgtext</xsl:attribute>
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
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
  <xsl:template name="firstnamefirst">
    <xsl:param name="names"/>
    <xsl:for-each select="$names">
      <xsl:if test="not(position() = 1)"><!-- if the name isn't first !-->
	<xsl:choose>
	  <xsl:when test="following-sibling">
	    <xsl:text>, </xsl:text>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:text> and </xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
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
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="editors">
    <xsl:param name="editors"/>
    <xsl:for-each select="$editors">
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
	    <xsl:when test="following-sibling::tei:editor">
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
    <xsl:choose>
      <xsl:when test="count(ext:node-set($editors)) > 1">
	<xsl:text> (eds.)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text> (ed.)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="year">
    <xsl:param name="year"/>
    <xsl:value-of select="$year"/>
  </xsl:template>
  <xsl:template name="in-book">
    <xsl:param name="authors"/>
    <xsl:param name="title"/>
    <xsl:param name="booktitle"/>
    <xsl:param name="pages"/>
    <xsl:param name="publisher"/>
    <xsl:param name="pubplace"/>
    <xsl:param name="year"/>
    <xsl:variable name="authorstring">
      <xsl:call-template name="authors">
	<xsl:with-param name="authors" select="$authors"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$authorstring"/>
    <xsl:if test="substring($authorstring,string-length($authorstring),1) != '.'">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="$year"/>
    <xsl:text>. “</xsl:text>
    <xsl:apply-templates select="$title"/>
    <xsl:if test="not(contains('?!',substring($title,string-length($title),1)))">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text>” </xsl:text>
    <xsl:text>In </xsl:text>
    <xsl:element name="em">
      <xsl:apply-templates select="$booktitle"/>
    </xsl:element>
    <xsl:if test="$pages">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$pages"/>
    </xsl:if>
    <xsl:text>. </xsl:text>
    <xsl:apply-templates select="$pubplace"/>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates select="$publisher"/>
    <xsl:text>.</xsl:text>
  </xsl:template>
  <xsl:template name="in-collection">
    <xsl:param name="authors"/>
    <xsl:param name="editors"/>
    <xsl:param name="title"/>
    <xsl:param name="booktitle"/>
    <xsl:param name="pages"/>
    <xsl:param name="publisher"/>
    <xsl:param name="pubplace"/>
    <xsl:param name="year"/>
    <xsl:variable name="authorstring">
      <xsl:call-template name="lastnamefirst">
	<xsl:with-param name="names" select="$authors"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$authorstring"/>
    <xsl:if test="substring($authorstring,string-length($authorstring),1) != '.'">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="$year"/>
    <xsl:text>. “</xsl:text>
    <xsl:apply-templates select="$title"/>
    <xsl:if test="not(contains('?!',substring($title,string-length($title),1)))">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text>” </xsl:text>
    <xsl:text>In </xsl:text>
    <xsl:if test="$editors">
      <xsl:call-template name="firstnamefirst">
	<xsl:with-param name="names" select="$editors"/>
      </xsl:call-template>
      <xsl:text> (ed</xsl:text>
      <xsl:if test="count($editors) > 1">
	<xsl:text>s</xsl:text>
      </xsl:if>
      <xsl:text>.), </xsl:text>
    </xsl:if>
    <xsl:element name="em">
      <xsl:apply-templates select="$booktitle"/>
    </xsl:element>
    <xsl:if test="$pages">
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$pages"/>
    </xsl:if>
    <xsl:text>. </xsl:text>
    <xsl:apply-templates select="$pubplace"/>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates select="$publisher"/>
    <xsl:text>.</xsl:text>
  </xsl:template>
  <xsl:template name="journal-article">
    <xsl:param name="title"/>
    <xsl:param name="journal"/>
    <xsl:param name="volume"/>
    <xsl:param name="issue"/>
    <xsl:param name="pages"/>
    <xsl:param name="year"/>
    <xsl:apply-templates select="$year"/>
    <xsl:text>. “</xsl:text>
    <xsl:apply-templates select="$title"/>
    <xsl:if test="not(contains('?!',substring($title,string-length($title),1)))">
      <xsl:text>.</xsl:text>
    </xsl:if>
    <xsl:text>” </xsl:text>
    <xsl:element name="em">
      <xsl:apply-templates select="$journal"/>
    </xsl:element>
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="$volume"/>
    <xsl:choose>
      <xsl:when test="not($issue)"/>
      <xsl:otherwise>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="$issue"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates select="$pages"/>
    <xsl:text>.</xsl:text>
  </xsl:template>
  <xsl:template name="monograph">
    <xsl:param name="title"/>
    <xsl:param name="publisher"/>
    <xsl:param name="pubplace"/>
    <xsl:param name="year"/>
    <xsl:param name="authoreditor"/>
    <xsl:choose>
      <xsl:when test="$authoreditor = 'true'">
	<xsl:apply-templates select="$year"/>
	<xsl:text>. </xsl:text>
	<xsl:element name="em">
	  <xsl:apply-templates select="$title"/>
	</xsl:element>
	<xsl:if test="not(contains('?!',substring($title,string-length($title),1)))">
	  <xsl:text>.</xsl:text>
	</xsl:if>
	<xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="em">
	  <xsl:apply-templates select="$title"/>
	</xsl:element>
	<xsl:text>. </xsl:text>
	<xsl:apply-templates select="$year"/>
	<xsl:text>. </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="$pubplace"/>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates select="$publisher"/>
    <xsl:text>.</xsl:text>
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
