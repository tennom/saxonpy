<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     version="2.0">
<!--<xsl:import-schema schema-location="schema_1.xsd" />-->
        <xsl:param name="numParam" select="2" />
	<xsl:output method="xml" indent="yes" />

  <xsl:template match="*">
	<output>
	<!--<xsl:value-of select="normalize-unicode('Eisbär', 'NFKD')" />-->
    <xsl:for-each select="person" >
	<out><xsl:value-of select="."/></out>
    </xsl:for-each>
      <out><xsl:value-of select="$numParam*2"/></out>
    </output>
	<xsl:message>Testing message1</xsl:message>
	<xsl:message>Testing message2</xsl:message>
  </xsl:template>

</xsl:stylesheet>
