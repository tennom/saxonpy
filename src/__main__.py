from saxonpy import *

print("hello from saxonpy ------------------->")

with PySaxonProcessor(license=False) as proc:

    print("Testing Python")
    print(proc.version)

    xsltproc = proc.new_xslt_processor()
    document = proc.parse_xml(xml_text="<out><person>text1</person><person>text2</person><person>text3</person></out>")
    xsltproc.set_source(xdm_node=document)
    xsltproc.compile_stylesheet(stylesheet_text="<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'> <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:value-of select='//person[1]'/><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out></xsl:for-each></output></xsl:template></xsl:stylesheet>")

    output2 = xsltproc.transform_to_string()
    print(output2)
    proc.release()