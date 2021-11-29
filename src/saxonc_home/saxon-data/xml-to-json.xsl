<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:j="http://www.w3.org/2005/xpath-functions/json"
                exclude-result-prefixes="xs j"
                version="3.0">
   <xsl:param name="j:key-delimiter" as="xs:string">"</xsl:param>
   <xsl:param name="j:string-delimiter" as="xs:string">"</xsl:param>
   <xsl:param name="j:key-value-separator" as="xs:string">:</xsl:param>
   <xsl:param name="j:map-separator" as="xs:string">,</xsl:param>
   <xsl:param name="j:start-array" as="xs:string">[</xsl:param>
   <xsl:param name="j:end-array" as="xs:string">]</xsl:param>
   <xsl:param name="j:start-map" as="xs:string">{</xsl:param>
   <xsl:param name="j:end-map" as="xs:string">}</xsl:param>
   <xsl:param name="j:array-separator" as="xs:string">,</xsl:param>
   <xsl:template name="j:start-array">
            <xsl:value-of select="$j:start-array"/>
        </xsl:template>
   <xsl:template name="j:end-array">
            <xsl:value-of select="$j:end-array"/>
        </xsl:template>
   <xsl:template name="j:start-map">
            <xsl:value-of select="$j:start-map"/>
        </xsl:template>
   <xsl:template name="j:end-map">
            <xsl:value-of select="$j:end-map"/>
        </xsl:template>
   <xsl:template name="j:key-value-separator">
            <xsl:value-of select="$j:key-value-separator"/>
        </xsl:template>
   <xsl:template name="j:map-separator">
            <xsl:value-of select="$j:map-separator"/>
        </xsl:template>
   <xsl:template name="j:array-separator">
            <xsl:value-of select="$j:array-separator"/>
        </xsl:template>
   <xsl:function name="j:xml-to-json" as="xs:string">
            <xsl:param name="xml" as="node()"/>
            <xsl:variable name="parts" as="xs:string*">
                <xsl:apply-templates select="$xml" mode="j:xml-to-json"/>
            </xsl:variable>
            <xsl:value-of select="string-join($parts,'')"/>
        </xsl:function>
   <xsl:template name="j:xml-to-json" as="xs:string">
            <xsl:param name="xml" as="node()" select="."/>
            <xsl:value-of select="j:xml-to-json($xml)"/>
        </xsl:template>
   <xsl:mode name="j:xml-to-json" on-no-match="shallow-copy"/>
   <xsl:template match="j:map" mode="j:xml-to-json">
            <xsl:call-template name="j:start-map"/>
            <xsl:for-each select="*">
                <xsl:if test="position() gt 1">
                    <xsl:call-template name="j:map-separator"/>
                </xsl:if>
                <xsl:apply-templates select="@key" mode="j:xml-to-json"/>
                <xsl:call-template name="j:key-value-separator"/>
                <xsl:apply-templates select="." mode="j:xml-to-json"/>
            </xsl:for-each>
            <xsl:call-template name="j:end-map"/>
        </xsl:template>
   <xsl:template match="j:array" mode="j:xml-to-json">
            <xsl:call-template name="j:start-array"/>
            <xsl:for-each select="*">
                <xsl:if test="position() gt 1">
                    <xsl:call-template name="j:array-separator"/>
                </xsl:if>
                <xsl:apply-templates select="." mode="j:xml-to-json"/>
            </xsl:for-each>
            <xsl:call-template name="j:end-array"/>
        </xsl:template>
   <xsl:template match="j:string[@escaped='true']" mode="j:xml-to-json">
            <xsl:value-of select="concat($j:string-delimiter, ., $j:string-delimiter)"/>
        </xsl:template>
   <xsl:template match="j:string[not(@escaped='true')]" mode="j:xml-to-json">
            <xsl:value-of select="concat($j:string-delimiter, j:escape(.), $j:string-delimiter)"/>
        </xsl:template>
   <xsl:template match="j:number | j:boolean" mode="j:xml-to-json">
            <xsl:value-of select="."/>
        </xsl:template>
   <xsl:template match="j:null" mode="j:xml-to-json">
            <xsl:text>null</xsl:text>
        </xsl:template>
   <xsl:template match="j:*/@key[../@key-escaped='true']" mode="j:xml-to-json">
            <xsl:value-of select="concat($j:key-delimiter, ., $j:key-delimiter)"/>
        </xsl:template>
   <xsl:template match="j:*/@key[not(../@key-escaped='true')]" mode="j:xml-to-json">
            <xsl:value-of select="concat($j:key-delimiter, j:escape(.), $j:key-delimiter)"/>
        </xsl:template>
   <xsl:template match="text()" mode="j:xml-to-json"/>
   <xsl:function name="j:escape" as="xs:string">
            <xsl:param name="in" as="xs:string"/>
            <xsl:value-of>
                <xsl:for-each select="string-to-codepoints($in)">
                    <xsl:choose>
                        <xsl:when test=". gt 65535">
                            <xsl:value-of select="concat('\u', j:hex4((. - 65536) idiv 1024 + 55296))"/>
                            <xsl:value-of select="concat('\u', j:hex4((. - 65536) mod 1024 + 56320))"/>
                        </xsl:when>
                        <xsl:when test=". = 34">\"</xsl:when>
                        <xsl:when test=". = 92">\\</xsl:when>
                        <xsl:when test=". = 08">\b</xsl:when>
                        <xsl:when test=". = 09">\t</xsl:when>
                        <xsl:when test=". = 10">\n</xsl:when>
                        <xsl:when test=". = 12">\f</xsl:when>
                        <xsl:when test=". = 13">\r</xsl:when>
                        <xsl:when test=". lt 32 or (. ge 127 and . le 160)">
                            <xsl:value-of select="concat('\u', j:hex4(.))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="codepoints-to-string(.)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:value-of>
        </xsl:function>
   <xsl:function name="j:hex4" as="xs:string">
            <xsl:param name="ch" as="xs:integer"/>
            <xsl:variable name="hex" select="'0123456789abcdef'"/>
            <xsl:value-of>
                <xsl:value-of select="substring($hex, $ch idiv 4096 + 1, 1)"/>
                <xsl:value-of select="substring($hex, $ch idiv 256 mod 16 + 1, 1)"/>
                <xsl:value-of select="substring($hex, $ch idiv 16 mod 16 + 1, 1)"/>
                <xsl:value-of select="substring($hex, $ch mod 16 + 1, 1)"/>
            </xsl:value-of>
        </xsl:function>
</xsl:stylesheet>
