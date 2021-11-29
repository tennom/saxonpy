<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="http://www.saxonica.com/myfunction"
  xmlns:php="http://php.net/xsl"
  version="3.0">
  <!--<xsl:import-schema schema-location="schema_1.xsd" />-->
  <xsl:param name="numParam" select="2" />
  <xsl:param name="testdoc">
    <testdoc name="attr-data">testdoc-data</testdoc>
  </xsl:param>
  <xsl:output method="xml" indent="yes" />
  
 <!-- <xsl:function name="f:is-licensed-EE" as="xs:boolean">
    ﻿  <xsl:variable name="v" select="system-property('xsl:product-version')"/>
    <xsl:sequence select="starts-with($v, 'EE') and not(contains($v, '(unlicensed)'))"/>
  </xsl:function> -->
  
  
  <xsl:template match="*">
    <output>
    <!--  <b>Is licensed=<xsl:value-of select="f:is-licensed-EE()"/></b>-->
      <xsl:variable name="args" select="['param1-data', .]"/>
      <xsl:variable name="phpCall" select="php:function('userFunction', $args)" />
     <extension-function-test>Call to saxon:php-call:
           <xsl:if test="not(empty($phpCall))">
		Result from phpCall:
                ﻿<xsl:value-of select="$phpCall/*" /> 
            </xsl:if>
	    <xsl:if test="empty($phpCall)">
		Empty result FOUND-----:
                ﻿<xsl:value-of select="$phpCall" /> 
            </xsl:if>
</extension-function-test>
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

