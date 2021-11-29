<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
<xsl:variable name='x' select='.'/>
<xsl:template match='/'>
	errorA
</xsl:template>
<xsl:template match='main'>[<xsl:value-of select='name($x)'/>]</xsl:template>
</xsl:stylesheet>
