<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:f='http://localhost/' version='3.0'> 
	<xsl:function name='f:add' visibility='public'>    
		<xsl:param name='a'/>
		<xsl:param name='b'/> 
		<xsl:sequence select='$a + $b'/>
	</xsl:function>
</xsl:stylesheet>
