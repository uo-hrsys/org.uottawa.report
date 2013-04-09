<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xs xsl ditaarch" version="2.0">

  <xsl:param name="outdir" select="''"/>

  <xsl:output name="dita-concept" method="xml" doctype-public="-//OASIS//DTD DITA Concept//EN"
    doctype-system="technicalContent/dtd/concept.dtd"/>

  <xsl:output name="dita-ditamap" method="xml" doctype-public="-//OASIS//DTD DITA Map//EN"
    doctype-system="technicalContent/dtd/map.dtd"/>

  <xsl:template match="/">

    <xsl:variable name="audiences">
      <audiences>
        <xsl:apply-templates select="." mode="generate-audience-list"/>
      </audiences>
    </xsl:variable>

    <xsl:apply-templates select="." mode="generate-content">
      <xsl:with-param name="audiences" select="$audiences" tunnel="yes"/>
    </xsl:apply-templates>

    <xsl:apply-templates select="." mode="generate-report-map">
      <xsl:with-param name="audiences" select="$audiences" tunnel="yes"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="*" mode="generate-audience-list">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/audience ')]" mode="generate-audience-list">
    <xsl:sequence select="."/>
  </xsl:template>

  <xsl:template match="*[contains(@class, 'map/map')]" mode="generate-report-map">
    <xsl:result-document format="dita-ditamap" href="main.ditamap">
      <map xml:lang="{@xml:lang}">
        <title>Documentation Report</title>
        <topicmeta>
          <xsl:sequence select="topicmeta/*"/>
        </topicmeta>
        <topicref href="audience-report.xml" type="concept"/>
      </map>

    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*[contains(@class, 'map/map')]" mode="generate-content">

    <xsl:param name="audiences" tunnel="yes"/>

    <xsl:variable name="countOfAudience" select="count($audiences/*)"/>
    <xsl:variable name="resultUri" select="'audience-report.xml'"/>

    <xsl:result-document format="dita-concept" href="{$resultUri}">
      <concept id="concept_v1g_vb4_pj">
        <title>Audience applicability report</title>
        <conbody>
          <table frame="all" id="table_audiences" outputclass="table-fixed-header">
            <title>Audiences Information</title>
            <tgroup cols="{$countOfAudience}">
              <xsl:for-each select="$audiences/audiences/audience">
                <xsl:variable name="colNum" select="count(./preceding::*)"/>
                <colspec colname="{concat('C', $colNum)}" colnum="{$countOfAudience}" colwidth="1.0*"/>
              </xsl:for-each>
              <thead outputclass="header">
                <row>
                  <entry>Topic title</entry>
                  <xsl:for-each select="$audiences/audiences/audience">
                    <entry>
                      <xsl:value-of select="@name"/>
                    </entry>
                  </xsl:for-each>
                </row>
              </thead>

              <tbody>
                <xsl:apply-templates select="*" mode="generate-report-content"/>
              </tbody>
            </tgroup>
          </table>
        </conbody>
      </concept>
    </xsl:result-document>

  </xsl:template>

  <xsl:template match="*" mode="generate-report-content">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>

  <xsl:template
    match="*[contains(@class, ' map/topicref ')][not(contains(@class, ' mapgroup-d/keydef '))][not(@toc='no')]"
    mode="generate-report-content">
    <xsl:param name="audiences" tunnel="yes"/>

    <xsl:variable name="topicAudience" select="ancestor-or-self::*[exists(@audience)][1]/@audience"/>
    <xsl:variable name="level"
      select="count(ancestor::*[contains(@class, ' map/topicref ')][not(contains(@class, ' mapgroup-d/topicgroup '))])"/>

    <xsl:variable name="audience" as="xs:string">
      <xsl:choose>
        <xsl:when test="$topicAudience">
          <xsl:value-of select="$topicAudience"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="./topicmeta/navtitle">
      <xsl:call-template name="dita-table-row">
        <xsl:with-param name="audience" select="$audience"/>
        <xsl:with-param name="level" select="$level"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*" mode="#current"/>

  </xsl:template>

  <xsl:template name="dita-table-row">
    <xsl:param name="audiences" tunnel="yes"/>
    <xsl:param name="audience" as="xs:string"/>
    <xsl:param name="level"/>
    <xsl:param name="topic"/>
    <row>
      <entry>
        <xsl:choose>
          <xsl:when test="$level=0">
            <b>
              <xsl:choose>
                <xsl:when test="./topicmeta/navtitle">
                  <xsl:value-of select="./topicmeta/navtitle"/>
                </xsl:when>
                <xsl:when test="./topicmeta/linktext">
                  <xsl:value-of select="./topicmeta/linktext"/>
                </xsl:when>
                <xsl:otherwise> <xsl:value-of select="'-'"/> </xsl:otherwise>
                </xsl:choose>
            </b>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="1 to $level">-</xsl:for-each>
            <xsl:value-of select="./topicmeta/navtitle"/>
          </xsl:otherwise>
        </xsl:choose>
      </entry>
      <xsl:for-each select="$audiences/audiences/audience">
        <entry>

          <xsl:choose>
            <xsl:when test="$audience='' or contains($audience, @name)">
              <ph outputclass="ui-icon ui-icon-check">
                <xsl:value-of select="'Yes'"/>
              </ph>
            </xsl:when>
            <xsl:otherwise>

              <ph outputclass="ui-icon ui-icon-closethick">
                <xsl:value-of select="'No'"/>
              </ph>

            </xsl:otherwise>
          </xsl:choose>
        </entry>
      </xsl:for-each>
    </row>
  </xsl:template>


</xsl:stylesheet>
