<!DOCTYPE xsl:stylesheet [
<!ENTITY postamble SYSTEM "postamble.txt">
]>
<xsl:stylesheet 
      xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
    
  <!-- This stylesheet uses a user-written URI Resolver to load a text file both at compile time and at runtime -->  
  <xsl:template match="/">
    <out>
      <preamble><xsl:value-of select="document('preamble.txt')"/></preamble>
      <xsl:copy-of select="."/>
      <postamble>&postamble;</postamble>
    </out>
  </xsl:template>
      
  <xsl:template 
      match="@*|*|text()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates 
         select="@*|*|text()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>