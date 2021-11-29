<xsl:stylesheet 
      xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='3.0'
      xmlns:bar="http://apache.org/bar"
      exclude-result-prefixes="bar"
      >
      
  <xsl:include href="inc1/inc1.xsl"/>
  <xsl:variable name="doc" select="doc('../xml/foo.xml')"/>
      
  <xsl:param name="a-param">default param value</xsl:param>

  <xsl:output encoding="iso-8859-1"/>
  
  <xsl:template match="/">
    <xsl:comment><xsl:value-of select="system-property('xsl:product-version')"/></xsl:comment>
    <xsl:next-match/>
  </xsl:template>  
  
  <xsl:template name="xsl:initial-template">
    <bar>
      <param-val>
        <xsl:value-of select="$a-param"/><xsl:text>, </xsl:text>
        <out>testing</out>
      </param-val>
      
      <data><xsl:apply-templates select="$doc"/></data>
      
    </bar>
  </xsl:template>
      
  <xsl:template 
      match="@*|*|text()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates 
         select="@*|*|text()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>