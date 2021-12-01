<?xml version="1.0" encoding="UTF-8"?>


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:j="http://www.w3.org/2005/xpath-functions/json"
    exclude-result-prefixes="xs j"
    version="3.0">
    
    <xsl:import href="xml-to-json.xsl"/>
    
    <xsl:param name="j:indent-spaces" as="xs:integer" select="3"/>
    
    <xsl:param name="j:colon" as="xs:string"> : </xsl:param>
    
    <xsl:template name="j:start-array">
        <xsl:text> </xsl:text><xsl:value-of select="$j:start-array"/><xsl:text>&#xa;</xsl:text>
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:for-each select="1 to ($depth + 1) * $j:indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
    <xsl:template name="j:end-array">
        <xsl:text> </xsl:text><xsl:value-of select="$j:end-array"/><xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template name="j:start-map">
        <xsl:text> </xsl:text><xsl:value-of select="$j:start-map"/><xsl:text>&#xa;</xsl:text>
       <!-- <xsl:text> {&#xa;</xsl:text>-->
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:for-each select="1 to ($depth + 1) * $j:indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
    <xsl:template name="j:end-map">
        <xsl:text> </xsl:text><xsl:value-of select="$j:end-map"/><xsl:text> </xsl:text>
        <!--<xsl:text> } </xsl:text>-->
    </xsl:template>
    
    <xsl:template name="j:map-separator">
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:value-of select="$j:map-separator"/><xsl:text>&#xa;</xsl:text>
        <!--<xsl:text>,&#xa;</xsl:text>-->
        <xsl:for-each select="1 to $depth * $j:indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
    <xsl:template name="j:array-separator">
        <xsl:variable name="depth" select="count(ancestor::*)"/>
        <xsl:value-of select="$j:array-separator"/><xsl:text>&#xa;</xsl:text>
        <!--<xsl:text>,&#xa;</xsl:text>-->
        <xsl:for-each select="1 to $depth * $j:indent-spaces"><xsl:text> </xsl:text></xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>