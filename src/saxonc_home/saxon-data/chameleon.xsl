<!-- Transformation to implement chameleon include -->
<!-- Copied from Appendix F.1 of the XSD 1.1 Candidate Recommendation dated 21 July 2011 -->
<!-- Modified to make it non-schema-aware, and to fix bug 14448 -->

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:f="http://www.w3.org/2008/05/XMLSchema-misc">

    <xsl:param name="newTargetNamespace" as="xs:anyURI" required="yes"/>
    <xsl:param name="prefixForTargetNamespace" as="xs:NCName" select="f:generateUniquePrefix(., 0)"/>
    <xsl:param name="xmlBase" as="xs:anyURI" select="base-uri(/)"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xs:include | xs:import | xs:redefine | xs:override">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="xml:base" select="$xmlBase"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xs:schema">
        <xsl:copy>
            <xsl:namespace name="{$prefixForTargetNamespace}" select="$newTargetNamespace"/>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="targetNamespace" select="$newTargetNamespace"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@ref | @type | @base | @refer | @itemType | @defaultAttributes">
        <xsl:choose>
            <xsl:when test=". castable as xs:NCName">
                <xsl:attribute name="{name()}"
                               select="concat($prefixForTargetNamespace, ':', .)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@memberTypes | @substitutionGroup | @notQName">
        <xsl:variable name="context" select=".."/>
        <xsl:variable name="values" as="xs:string+">
            <xsl:for-each select="tokenize(., '\s+')">
                <xsl:choose>
                    <xsl:when test=". castable as xs:NCName">
                        <xsl:sequence select="concat($prefixForTargetNamespace, ':', .)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="{name()}" select="$values"/>
    </xsl:template>


    <xsl:function name="f:generateUniquePrefix" as="xs:NCName">
        <xsl:param name="xsd"/>
        <xsl:param name="try" as="xs:integer"/>
        <xsl:variable name="disallowed" select="distinct-values($xsd//*/in-scope-prefixes(.))"/>
        <xsl:variable name="candidate" select="xs:NCName(concat('p', $try))"/>
        <xsl:sequence select="if ($candidate = $disallowed)
                             then f:generateUniquePrefix($xsd, $try+1)
                             else $candidate"/>
    </xsl:function>

</xsl:transform>