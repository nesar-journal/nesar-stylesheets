<xsl:stylesheet version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">
  <xsl:output method="xml" indent="no"/>
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="tei:TEI tei:text tei:front tei:body tei:back tei:div tei:teiHeader tei:fileDesc tei:editionStmt tei:publicationStmt tei:sourceDesc tei:encodingDesc tei:revisionDesc tei:p tei:lg tei:head tei:listBibl"/>
  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="tei:text">
    <xsl:element name="text" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
      <xsl:element name="back" namespace="http://www.tei-c.org/ns/1.0">
	<xsl:apply-templates select=".//tei:div[./tei:head/text() = 'Bibliography']" mode="bypass"/> 
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!-- title and author  !-->
  <xsl:template match="tei:titleStmt/tei:title">
    <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:value-of select="/tei:TEI/tei:text/tei:front/tei:titlePage/tei:docTitle/tei:titlePart[@type='Title']/text()"/>
    </xsl:element>
  </xsl:template>

  <!-- default language tag !-->
  <xsl:template match="tei:hi[@rend='italic'][not(ancestor-or-self::tei:div[contains(tei:head/text()[1],'Sources')])]">
    <!-- if the first letter is capital, treat it as a title !-->
    <xsl:variable name="firstchar" select="substring(./text(),1,1)"/>
    <xsl:choose>
      <xsl:when test="$firstchar = upper-case($firstchar)">
	<xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
	  <xsl:attribute name="xml:lang">kan-Latn</xsl:attribute>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="foreign" namespace="http://www.tei-c.org/ns/1.0">
	  <xsl:attribute name="xml:lang">kan-Latn</xsl:attribute>
	  <xsl:apply-templates/>
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- get rid of front matter !-->
  <xsl:template match="tei:text/tei:front"/>

  <!-- Put bibliography elements at the end !-->
  <xsl:template match="tei:div[./tei:head/text() = 'Bibliography']"/>
  <xsl:template match="tei:div[./tei:head/text() = 'Bibliography']" mode="bypass">
    <xsl:element name="div" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[./tei:head/text() = 'Bibliography']/tei:div[./tei:head/text() = 'Primary Sources']">
    <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[./tei:head/text() = 'Bibliography']/tei:div[./tei:head/text() = 'Secondary Sources']">
    <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[./tei:head/text() = 'Bibliography']/tei:div/tei:p">
    <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="tei:div[./tei:head/text() = 'Bibliography']/tei:div/tei:p/tei:hi[@rend='italic']">
    <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- get rid of formatting attributes/elements !-->
  <xsl:template match="*/@xml:space"/>
  <xsl:template match="tei:hi[not(@rend)][@style[starts-with(.,'font-size')]]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:hi[@rend[starts-with(.,'color')]]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:hi[@rend[starts-with(.,'underline')]]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="*/@style[starts-with(.,'font-size')]"/>
  <xsl:template match="*/@style[starts-with(.,'font-family')]"/>
  <xsl:template match="*/@rend[starts-with(.,'color')]"/>
  <xsl:template match="tei:p/text()[1]">
    <xsl:value-of select="replace(., '^\s+', '')"/>
  </xsl:template>

</xsl:stylesheet>
