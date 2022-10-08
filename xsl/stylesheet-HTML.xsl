<xsl:stylesheet version="3.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:fn="http://www.w3.org/2005/xpath-functions">
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

  <xsl:template match="tei:ab" />
  <xsl:template match="tei:abbr">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:add" />
  <xsl:template match="tei:anchor" />
  <xsl:template match="tei:app">
    <xsl:element name="li">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:author" />
  <xsl:template match="tei:authority" />
  <xsl:template match="tei:availability" />
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
  <xsl:template match="tei:biblStruct" />
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
  <xsl:template match="tei:change" />
  <xsl:template match="tei:choice" />
  <xsl:template match="tei:cit" />
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
  <xsl:template match="tei:date" />
  <xsl:template match="tei:del" />
  <xsl:template match="tei:div[parent::tei:body]">
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
  <xsl:template match="tei:encodingDesc" />
  <xsl:template match="tei:expan" />
  <xsl:template match="tei:fileDesc" />
  <xsl:template match="tei:filiation" />
  <xsl:template match="tei:foreign">
    <xsl:element name="span">
      <xsl:attribute name="class">foreign</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
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
  <xsl:template match="tei:hi[@rend='bold']">
    <xsl:element name="b">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:hi">
    <xsl:element name="em">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:history" />
  <xsl:template match="tei:idno" />
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
  <xsl:template match="tei:label" />
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
  <xsl:template match="tei:license" />
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
  <xsl:template match="tei:list[not(@type='examples')]">
    <xsl:element name="ul">
      <xsl:apply-templates/>
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
      <xsl:apply-templates select="./tei:p" mode="endnotes"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:note[@place='foot']" mode="sidenotes">
    <xsl:element name="li">
      <xsl:apply-templates select="./tei:p" mode="sidenotes"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:notesStmt" />
  <xsl:template match="tei:num" />
  <xsl:template match="tei:objectDesc" />
  <xsl:template match="tei:origDate" />
  <xsl:template match="tei:origPlace" />
  <xsl:template match="tei:p[not(ancestor::tei:note)]">
    <xsl:element name="div">
      <xsl:attribute name="class">textandnotes</xsl:attribute>
      <xsl:if test=".//tei:note[@place='foot']">
	<xsl:element name="ul">
	  <xsl:attribute name="class">sidenotes</xsl:attribute>
	  <xsl:for-each select=".//tei:note[@place='foot']">
	    <xsl:apply-templates select="." mode="sidenotes"/>
	  </xsl:for-each>
	</xsl:element>
      </xsl:if>
      <xsl:element name="p">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:p[ancestor::tei:note]" mode="endnotes">
    <xsl:element name="p">
      <xsl:element name="a">
	<xsl:attribute name="href">
	  <xsl:value-of select="concat(concat('#','ret-'),ancestor::tei:note/@xml:id)"/>
	</xsl:attribute>
	<xsl:text>↑</xsl:text>
      </xsl:element>
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
  <xsl:template match="tei:q[@type='phonemic']">
    <xsl:element name="span">
      <xsl:attribute name="class">phonemic</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:quote">
    <xsl:element name="blockquote">
      <xsl:apply-templates/>
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
  <xsl:template match="tei:revisionDesc" />
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
  <xsl:template match="tei:surname" />
  <xsl:template match="tei:surplus" />
  <xsl:template match="tei:table">
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
  </xsl:template>
  <xsl:template match="tei:TEI">
    <xsl:element name="html">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:teiHeader" />
  <xsl:template match="tei:term"/>
  <xsl:template match="tei:text">
    <xsl:element name="body">
      <xsl:if test=".//tei:head[@type='toc']">
	<xsl:element name="div">
	  <xsl:attribute name="class">nesar-toc</xsl:attribute>
	  <xsl:element name="ul">
	    <xsl:apply-templates select=".//tei:head[@type='toc']" mode="toc"/>
	  </xsl:element>
	</xsl:element>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:textClass" />
  <xsl:template match="tei:textLang" />
  <xsl:template match="tei:title[not(ancestor-or-self::tei:titleStmt)]">
    <xsl:element name="i">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:titleStmt" />
  <xsl:template match="tei:unclear" />
  <xsl:template match="tei:variantEncoding" />
  <xsl:template match="tei:witDetail" />
  <xsl:template match="tei:witness" />

  <!-- WRAP ALL TEXT ELEMENTS WITH LANGUAGE AND SCRIPT ATTRIBUTES !-->
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
	    <xsl:element name="span">
	      <xsl:attribute name="class">scriptWrapper</xsl:attribute>
	      <xsl:call-template name="langScript">
		<xsl:with-param name="langScript" select="$recentLang"/>
	      </xsl:call-template>
	      <xsl:attribute name="data-original">
		<xsl:value-of select="."/>
	      </xsl:attribute>
	      <xsl:value-of select="."/>
	    </xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- NAMED TEMPLATES !-->
  <xsl:template name="langScript">
    <xsl:param name="langScript"/>
    <xsl:if test="contains($langScript,'-')">
      <xsl:attribute name="data-lang"><xsl:value-of select="substring-before($langScript,'-')"/></xsl:attribute>
      <xsl:attribute name="data-script"><xsl:value-of select="substring-after($langScript,'-')"/></xsl:attribute>
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
  
</xsl:stylesheet>
