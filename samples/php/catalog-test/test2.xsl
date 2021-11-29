<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template name="main">
    <xsl:variable name="doc" select="doc('http://example.com/example.xml')"/>
    <out uri="{document-uri($doc)}" base="{base-uri($doc)}">
        <xsl:copy-of select="$doc"/>
    </out>
  </xsl:template>
</xsl:transform>  