<result xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xsl:version="2.0">
  <!-- Q12.   For each richer-than-average person, list the number of items 
      currently on sale whose price does not exceed 0.02% of the 
       person's income. -->
  
  

  <xsl:for-each select="doc('xmark100k.xml')/site/people/person">

    <xsl:variable name="p" select="." as="element(person)"/>

    <xsl:variable name="l" as="element(initial)*" select="doc('xmark100k.xml')/site/open_auctions/open_auction/initial[$p/profile/@income > (5000 * .)]" />  

    <xsl:if test="$p/profile/@income > 50000">
        <item person="{name}">
         <xsl:value-of select="count($l)"/>
        </item>
    </xsl:if>
  </xsl:for-each>

</result>
