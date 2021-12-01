<?xml version="1.0" encoding="UTF-8"?>

<xsl:package name="http://www.w3.org/2013/XSLT/xml-to-json.xsl"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:j="http://www.w3.org/2005/xpath-functions/json" exclude-result-prefixes="xs j"
    default-mode="j:xml-to-json" version="3.0" package-version="3.0">

    <xsl:stylesheet>

        <!-- The delimiter to be used before and after keys in a map -->
        <xsl:param name="j:key-delimiter" as="xs:string">"</xsl:param>

        <!-- The delimiter to be used before and after string values -->
        <xsl:param name="j:string-delimiter" as="xs:string">"</xsl:param>

        <!-- The separator to be used between keys and values -->
        <xsl:param name="j:key-value-separator" as="xs:string">:</xsl:param>

        <!-- The separator to be used between entries in a map -->
        <xsl:param name="j:map-separator" as="xs:string">,</xsl:param>

        <!-- The opening delimiter of an array -->
        <xsl:param name="j:start-array" as="xs:string">[</xsl:param>

        <!-- The closing delimiter of an array -->
        <xsl:param name="j:end-array" as="xs:string">]</xsl:param>

        <!-- The opening delimiter of a map -->
        <xsl:param name="j:start-map" as="xs:string">{</xsl:param>

        <!-- The closing delimiter of a map -->
        <xsl:param name="j:end-map" as="xs:string">}</xsl:param>

        <!-- The separator to be used between members of an array -->
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

        <!-- Entry point: function to convert a supplied XML node to a JSON string -->
        <xsl:function name="j:xml-to-json" as="xs:string" visibility="public">
            <xsl:param name="xml" as="node()"/>
            <xsl:variable name="parts" as="xs:string*">
                <xsl:apply-templates select="$xml"/>
            </xsl:variable>
            <xsl:value-of select="string-join($parts,'')"/>
        </xsl:function>
        <!-- Entry point: named template to convert a supplied XML node to a JSON string -->
        <xsl:template name="j:xml-to-json" as="xs:string" visibility="public">
            <xsl:param name="xml" as="node()" select="."/>
            <xsl:value-of select="j:xml-to-json($xml)"/>
        </xsl:template>

        <!-- Conversion of XML to JSON can be achieved by applying templates to the XML root in this mode -->
        <xsl:mode name="j:xml-to-json" streamable="yes" visibility="public"
            on-no-match="shallow-copy"/>

        <!-- Template rule for j:map elements, representing JSON objects -->
        <xsl:template match="j:map">
            <xsl:call-template name="j:start-map"/>
            <xsl:for-each select="*">
                <xsl:if test="position() gt 1">
                    <xsl:call-template name="j:map-separator"/>
                </xsl:if>
                <xsl:apply-templates select="@key"/>
                <xsl:call-template name="j:key-value-separator"/>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:call-template name="j:end-map"/>
        </xsl:template>

        <!-- Template rule for j:array elements, representing JSON arrays -->
        <xsl:template match="j:array">
            <xsl:call-template name="j:start-array"/>
            <xsl:for-each select="*">
                <xsl:if test="position() gt 1">
                    <xsl:call-template name="j:array-separator"/>
                </xsl:if>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
            <xsl:call-template name="j:end-array"/>
        </xsl:template>

        <!-- Template rule for j:string elements in which special characters are already escaped -->
        <xsl:template match="j:string[@escaped='true']">
            <xsl:value-of select="concat($j:string-delimiter, ., $j:string-delimiter)"/>
        </xsl:template>

        <!-- Template rule for j:string elements in which special characters need to be escaped -->
        <xsl:template match="j:string[not(@escaped='true')]">
            <xsl:value-of select="concat($j:string-delimiter, j:escape(.), $j:string-delimiter)"/>
        </xsl:template>

        <!-- Template rule for j:number and j:boolean elements (representing JSON numbers and booleans) -->
        <xsl:template match="j:number | j:boolean">
            <xsl:value-of select="."/>
        </xsl:template>

        <!-- Template rule for JSON null elements (representing JSON null values) -->
        <xsl:template match="j:null">
            <xsl:text>null</xsl:text>
        </xsl:template>

        <!-- Template rule matching a key within a map where special characters in the key are already escaped -->
        <xsl:template match="j:*/@key[../@key-escaped='true']">
            <xsl:value-of select="concat($j:key-delimiter, ., $j:key-delimiter)"/>
        </xsl:template>

        <!-- Template rule matching a key within a map where special characters in the key need to be escaped -->
        <xsl:template match="j:*/@key[not(../@key-escaped='true')]">
            <xsl:value-of select="concat($j:key-delimiter, j:escape(.), $j:key-delimiter)"/>
        </xsl:template>

        <!-- Template rule matching (and discarding) text nodes in the XML: typically ignorable whitespace -->
        <xsl:template match="text()"/>

        <!-- Function to escape special characters -->
        <xsl:function name="j:escape" as="xs:string">
            <xsl:param name="in" as="xs:string"/>
            <xsl:value-of>
                <xsl:for-each select="string-to-codepoints($in)">
                    <xsl:choose>
                        <xsl:when test=". gt 65535">
                            <xsl:value-of
                                select="concat('\u', j:hex4((. - 65536) idiv 1024 + 55296))"/>
                            <xsl:value-of
                                select="concat('\u', j:hex4((. - 65536) mod 1024 + 56320))"/>
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

        <!-- Function to convert a UTF16 codepoint into a string of four hex digits -->
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

</xsl:package>
