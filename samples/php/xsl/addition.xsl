<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
		xmlns:xs='http://www.w3.org/2001/XMLSchema' version='3.0'>
	<xsl:template name='t'>
		<xsl:param name='a' as='xs:double'/>
		<xsl:param name='b' as='xs:float'/>
                <xsl:sequence select='$a + $b'/>
	</xsl:template>
</xsl:stylesheet>
