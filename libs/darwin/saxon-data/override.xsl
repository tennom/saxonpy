<!-- Transformation for handling xs:override in schema processor -->
<!-- Copied from Appendix F.2 of the XSD 1.1 Candidate Recommendation dated 21 July 2011 -->
<!-- Modified to remove schema-awareness, and to take the source document as principal input -->
<!-- Modified to set @xml:base on new xs:override elements -->

<xsl:transform version="2.0"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:f="http://www.w3.org/2008/05/XMLSchema-misc"
               exclude-result-prefixes="f">

    <xsl:param name="overrideElement" as="element(xs:override)"/>
    <xsl:param name="overriddenSchema" as="element(xs:schema)" select="/*"/>
    <xsl:param name="xmlBase" as="xs:anyURI" select="base-uri(/)"/>

    <xsl:template match="/">
        <xsl:apply-templates select="$overriddenSchema"/>
    </xsl:template>

    <xsl:template match="element(xs:schema)">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- MHK addition (bug 17574: add import declarations from the overriding stylesheet if necessary -->
            <xsl:apply-templates
                    select="$overrideElement/../xs:import[not(@namespace = current()/xs:import/@namespace)]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="element(xs:redefine)">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="element(xs:import)" priority="5">
        <xsl:copy>
            <xsl:copy-of select="@* except @schemaLocation"/>
            <!-- MHK addition: make schemaLocation absolute -->
            <xsl:if test="exists(@schemaLocation)">
                <xsl:attribute name="schemaLocation" select="resolve-uri(@schemaLocation, base-uri(.))"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>


    <!--* replace children of xs:schema, xs:redefine, and xs:override
    * which match children of $overrideElement.  Retain others.
    *-->
    <xsl:template match="element(xs:schema)/* | element(xs:redefine)/* | element(xs:override)/*"
                  priority="3">
        <xsl:variable name="original" select="."/>
        <xsl:variable name="replacement"
                      select="$overrideElement/*
                [node-name(.)=node-name($original) 
                 and 
                 f:componentName(.)=f:componentName($original)]"/>
        <xsl:copy-of select="($replacement, $original)[1]"/>
    </xsl:template>

    <!--* replace xs:include elements with overrides
    *-->
    <xsl:template match="element(xs:include)" priority="5">
        <xsl:element name="xs:override">
            <xsl:attribute name="xml:base" select="(@xml:base, $xmlBase)[1]"/>
            <xsl:copy-of select="@schemaLocation, $overrideElement/*"/>
        </xsl:element>
    </xsl:template>

    <!--* change xs:override elements:  children which match
    * children of $overrideElement are replaced, others are
    * kept, and at the end all children of $overrideElement
    * not already inserted are added.
    *-->
    <xsl:template match="element(xs:override)"
                  priority="5">
        <xsl:element name="xs:override">
            <xsl:attribute name="schemaLocation" select="@schemaLocation"/>
            <xsl:attribute name="xml:base" select="(@xml:base, $xmlBase)[1]"/>
            <xsl:apply-templates/>
            <xsl:apply-templates select="$overrideElement/*" mode="copy-unmatched">
                <xsl:with-param name="overriddenOverride" select="."/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*" mode="copy-unmatched">
        <xsl:param name="overriddenOverride"></xsl:param>
        <xsl:variable name="overriding" select="."/>
        <xsl:variable name="overridden" select="$overriddenOverride/*[
	    node-name(.) = node-name($overriding) and
	    f:componentName(.) = f:componentName($overriding) ]"/>
        <xsl:choose>
            <xsl:when test="count($overridden) > 0">
                <!--* do nothing; this element has already been copied *-->
            </xsl:when>
            <xsl:when test="count($overridden) = 0">
                <!--* copy this element, it isn't already there *-->
                <xsl:copy-of select="."/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:componentName" as="xs:QName?">
        <xsl:param name="component" as="element()"/>
        <xsl:sequence
                select="if ($component/@name) then QName($component/ancestor::xs:schema/@targetNamespace, $component/@name) else ()"/>
    </xsl:function>

</xsl:transform>