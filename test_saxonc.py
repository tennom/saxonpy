from tempfile import mkstemp
import pytest
from saxonpy import *
import os
from os.path import isfile


@pytest.fixture
def saxonproc():
    return PySaxonProcessor()


@pytest.fixture
def files_dir():
    return "samples/php"

@pytest.fixture
def data_dir():
    return "samples/data/"

def test_create_bool():
    """Create SaxonProcessor object with a boolean argument"""
    sp1 = PySaxonProcessor(True)
    sp2 = PySaxonProcessor(False)
    assert isinstance(sp1, PySaxonProcessor)
    assert isinstance(sp2, PySaxonProcessor)


@pytest.mark.skip('Error: SaxonDll.processor is NULL in constructor(configFile)')
def test_create_config():
    """Create SaxonProcessor object with a configuration file argument"""
    conf_xml = b"""\
    <configuration xmlns="http://saxon.sf.net/ns/configuration" edition="HE">
    <global
        allowExternalFunctions="true"
        allowMultiThreading="true"
        allowOldJavaUriFormat="false"
        collationUriResolver="net.sf.saxon.lib.StandardCollationURIResolver"
        collectionUriResolver="net.sf.saxon.lib.StandardCollectionURIResolver"
        compileWithTracing="false"
       defaultCollation="http://www.w3.org/2005/xpath-functions/collation/codepoint"
       defaultCollection="file:///e:/temp"
        dtdValidation="false"
        dtdValidationRecoverable="true"
        errorListener="net.sf.saxon.StandardErrorListener"
        expandAttributeDefaults="true"
        lazyConstructionMode="false"
        lineNumbering="true"
        optimizationLevel="10"
        preEvaluateDocFunction="false"
        preferJaxpParser="true"
        recognizeUriQueryParameters="true"
        schemaValidation="strict"
        serializerFactory=""
        sourceParser=""
        sourceResolver=""
        stripWhitespace="all"
        styleParser=""
        timing="false"
        traceExternalFunctions="true"
        traceListener="net.sf.saxon.trace.XSLTTraceListener"
        traceOptimizerDecisions="false"
        treeModel="tinyTreeCondensed"
        uriResolver="net.sf.saxon.StandardURIResolver"
        usePiDisableOutputEscaping="false"
        useTypedValueCache="true"
        validationComments="false"
        validationWarnings="true"
        versionOfXml="1.0"
        xInclude="false"
      />
      <xslt
        initialMode=""
        initialTemplate=""
        messageReceiver=""
        outputUriResolver=""
        recoveryPolicy="recoverWithWarnings"
        schemaAware="false"
        staticErrorListener=""
        staticUriResolver=""
        styleParser=""
        version="2.1"
        versionWarning="false">
        <extensionElement namespace="http://saxon.sf.net/sql"
            factory="net.sf.saxon.option.sql.SQLElementFactory"/>
      </xslt>
      <xquery
        allowUpdate="true"
        constructionMode="preserve"
       defaultElementNamespace=""
       defaultFunctionNamespace="http://www.w3.org/2005/xpath-functions"
        emptyLeast="true"
        inheritNamespaces="true"
        moduleUriResolver="net.sf.saxon.query.StandardModuleURIResolver"
        preserveBoundarySpace="false"
        preserveNamespaces="true"
        requiredContextItemType="document-node()"
        schemaAware="false"
        staticErrorListener=""
        version="1.1"
        />
      <xsd
        occurrenceLimits="100,250"
        schemaUriResolver="com.saxonica.sdoc.StandardSchemaResolver"
        useXsiSchemaLocation="false"
        version="1.1"
      />
      <serialization
        method="xml"
        indent="yes"
        saxon:indent-spaces="8"
        xmlns:saxon="http://saxon.sf.net/"/>
      <localizationsdefaultLanguage="en"defaultCountry="US">
        <localization lang="da" class="net.sf.saxon.option.local.Numberer_da"/>
        <localization lang="de" class="net.sf.saxon.option.local.Numberer_de"/>
      </localizations>
      <resources>
        <externalObjectModel>net.sf.saxon.option.xom.XOMObjectModel</externalObjectModel>
        <extensionFunction>s9apitest.TestIntegrationFunctions$SqrtFunction</extensionFunction>
        <schemaDocument>file:///c:/MyJava/samples/data/books.xsd</schemaDocument>
        <schemaComponentModel/>
      </resources>
      <collations>
        <collation uri="http://www.w3.org/2005/xpath-functions/collation/codepoint"
                   class="net.sf.saxon.sort.CodepointCollator"/>
        <collation uri="http://www.microsoft.com/collation/caseblind"
                   class="net.sf.saxon.sort.CodepointCollator"/>
        <collation uri="http://example.com/french" lang="fr" ignore-case="yes"/>
      </collations>
    </configuration>
    """
    try:
        fd, fname = mkstemp(suffix='.xml')
        os.write(fd, conf_xml)
        os.close(fd)
        if not os.path.exists(fname):
            raise IOError('%s does not exist' % fname)

        with open(fname, 'r') as f:
            print(f.read())

        sp = SaxonProcessor(fname.encode('utf-8'))
        assert isinstance(sp, SaxonProcessor)
    finally:
        os.unlink(fname)


def test_create_procs():
    """Create XPathProcessor, XsltProcessor from SaxonProcessor object"""
    sp = PySaxonProcessor()
    xp = sp.new_xpath_processor()
    xsl = sp.new_xslt_processor()
    xsl30 = sp.new_xslt30_processor()
    assert isinstance(xp, PyXPathProcessor)
    assert isinstance(xsl, PyXsltProcessor)
    assert isinstance(xsl30, PyXslt30Processor)


def test_version():
    """SaxonProcessor version string content"""
    sp = PySaxonProcessor()
    ver = sp.version
    
    assert ver.startswith('Saxon/C ')
    assert ver.endswith('from Saxonica')

def test_schema_aware(saxonproc):

    assert saxonproc.is_schema_aware == False

@pytest.mark.skip(reason="Feature not available in the HE version.")
def test_schema_aware2():
    ''' This unit test requires a valid license - Saxon-EE/C '''
    sp = PySaxonProcessor(license=True)
    assert sp.is_schema_aware == True


'''PyXsltProcessor test cases '''

def test_xslt_processor(data_dir):
    sp = PySaxonProcessor()
    xsltproc = sp.new_xslt_processor()
    xmlFile = data_dir + "cat.xml"
    node_ = sp.parse_xml(xml_file_name=xmlFile)
    xsltproc.set_source(xdm_node=node_)
    xsltproc.compile_stylesheet(stylesheet_text="<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>       <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:value-of select='//person[1]'/><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out></xsl:for-each></output></xsl:template></xsl:stylesheet>")
    output2 = xsltproc.transform_to_string()
    assert 'text1' in output2

def test_Xslt_from_file(saxonproc, data_dir):
    xsltproc = saxonproc.new_xslt_processor()
    xmlFile = data_dir+'cat.xml'
    result = xsltproc.transform_to_string(source_file=data_dir+'cat.xml', stylesheet_file=data_dir+'test.xsl')
    assert result is not None
    assert 'text3' in result


def test_Xslt_from_file2(saxonproc, data_dir):
    xsltproc = saxonproc.new_xslt_processor()
    xmlFile = data_dir+'cat.xml'
    result = xsltproc.transform_to_string(source_file=data_dir+'cat.xml', stylesheet_file=data_dir+'test.xsl')
    assert result is not None
    assert 'text3' in result


def test_Xslt_from_file_error(saxonproc, data_dir):
    xsltproc = saxonproc.new_xslt_processor()
    result = xsltproc.transform_to_value(source_file=data_dir+'cat.xml', stylesheet_file=data_dir+'test-error.xsl')
    assert result is None
    assert xsltproc.exception_occurred()
    assert xsltproc.exception_count() == 1

def test_xslt_parameter(saxonproc, data_dir):
    input_ = saxonproc.parse_xml(xml_text="<out><person>text1</person><person>text2</person><person>text3</person></out>")
    value1 = saxonproc.make_integer_value(10)
    trans = saxonproc.new_xslt_processor()
    trans.set_parameter("numParam",value1)
    assert value1 is not None

    trans.set_source(xdm_node=input_)
    output_ = trans.transform_to_string(stylesheet_file=data_dir+"test.xsl")
    assert 'text2' in output_




'''PyXslt30Processor test cases '''

def testContextNotRoot(saxonproc):
    node = saxonproc.parse_xml(xml_text="<doc><e>text</e></doc>")
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template match='e'>[<xsl:value-of select='name($x)'/>]</xsl:template></xsl:stylesheet>")
    assert node is not None
    assert isinstance(node, PyXdmNode)
    assert len(node.children)>0
    eNode = node.children[0].children[0]
    assert eNode is not None
    trans.set_global_context_item(xdm_item=node)
    trans.set_initial_match_selection(xdm_value=eNode)
    result = trans.apply_templates_returning_string()
    assert result is not None
    assert "[" in result


def testResolveUri(saxonproc):
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="<xsl:stylesheet version='3.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:err='http://www.w3.org/2005/xqt-errors'><xsl:template name='go'><xsl:try><xsl:variable name='uri' as='xs:anyURI' select=\"resolve-uri('notice trailing space /out.xml')\"/> <xsl:message select='$uri'/><xsl:result-document href='{$uri}'><out/></xsl:result-document><xsl:catch><xsl:sequence select=\"'\$err:code: ' || $err:code  || ', $err:description: ' || $err:description\"/></xsl:catch></xsl:try></xsl:template></xsl:stylesheet>")

    value = trans.call_template_returning_value("go")
    assert value is not None
    item = value.head
    assert "code" in item.string_value

@pytest.mark.skip(reason="No stylesheet file is provided in the path.")
def testEmbeddedStylesheet(saxonproc, data_dir):
    trans = saxonproc.new_xslt30_processor()
    input_ = saxonproc.parse_xml(xml_file_name=data_dir+"books.xml")
    path = "/processing-instruction(xml-stylesheet)[matches(.,'type\\s*=\\s*[''\"\"]text/xsl[''\" \"]')]/replace(., '.*?href\\s*=\\s*[''\" \"](.*?)[''\" \"].*', '$1')"

    print(data_dir+"books.xml")

    xPathProcessor = saxonproc.new_xpath_processor()
    xPathProcessor.set_context(xdm_item=input_)
    hrefval = xPathProcessor.evaluate_single(path)
    assert hrefval is not None
    href = hrefval.string_value
    print("href="+href)
    assert href != ""
    styles_dir = "../../samples/styles/"
    trans.compile_stylesheet(stylesheet_file=styles_dir+href)

    assert isinstance(input_, PyXdmNode)
    node = trans.transform_to_value(xdm_node=input_)
    assert node is not None

def testContextNotRootNamedTemplate(saxonproc, files_dir):

    trans = saxonproc.new_xslt30_processor()
    input_ = saxonproc.parse_xml(xml_text="<doc><e>text</e></doc>")
    trans.compile_stylesheet(stylesheet_text="<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template name='main'>[<xsl:value-of select='name($x)'/>]</xsl:template></xsl:stylesheet>")      
    trans.set_global_context_item(xdm_item=input_)
    result = trans.call_template_returning_value("main")
    assert result is not None
    assert "[]" in result.head.string_value
    result2 = trans.call_template_returning_string("main")
    assert result2 is not None
    assert "[]" in result2


  
def testUseAssociated(saxonproc, files_dir):

    trans = saxonproc.new_xslt30_processor()
    foo_xml = files_dir+"/trax/xml/foo.xml"
    trans.compile_stylesheet(associated_file=foo_xml)
    trans.set_initial_match_selection(file_name=foo_xml)
    result = trans.apply_templates_returning_string()
    assert result is not None


def testNullStylesheet(saxonproc):

    trans = saxonproc.new_xslt30_processor()
    result = trans.apply_templates_returning_string()
    assert result is None


def testXdmDestination(saxonproc):
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template name='go'><a/></xsl:template></xsl:stylesheet>")

    root = trans.call_template_returning_value("go")
    assert root is not None
    assert root.head is not None
    assert root.head.is_atomic == False
    node  = root.head
    assert node is not None
    assert isinstance(node, PyXdmNode)
    assert node.node_kind == 9

def testXdmDestinationWithItemSeparator(saxonproc):
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template name='go'><xsl:comment>A</xsl:comment><out/><xsl:comment>Z</xsl:comment></xsl:template><xsl:output method='xml' item-separator='§'/></xsl:stylesheet>")

    root = trans.call_template_returning_value("go")
    node  = root
    
    assert "<!--A-->§<out/>§<!--Z-->" == node.__str__()
    assert node.node_kind == 9



def testPipeline(saxonproc):
    stage1 = saxonproc.new_xslt30_processor()        
    xsl = "<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>"
    xml = "<z/>"
    stage1.compile_stylesheet(stylesheet_text=xsl)
    in_ = saxonproc.parse_xml(xml_text=xml)

    stage2 = saxonproc.new_xslt30_processor()
    stage2.compile_stylesheet(stylesheet_text=xsl)
    stage3 = saxonproc.new_xslt30_processor()
    stage3.compile_stylesheet(stylesheet_text=xsl)
    stage4 = saxonproc.new_xslt30_processor()
    stage4.compile_stylesheet(stylesheet_text=xsl)

    stage5 = saxonproc.new_xslt30_processor()
    stage5.compile_stylesheet(stylesheet_text=xsl)
    assert in_ is not None
    stage1.set_property("!omit-xml-declaration", "yes")
    stage1.set_property("!indent", "no")
    stage1.set_initial_match_selection(xdm_value=in_)
    d1 = stage1.apply_templates_returning_value()

    assert d1 is not None    
    stage2.set_property("!omit-xml-declaration", "yes")
    stage2.set_property("!indent", "no")
    stage2.set_initial_match_selection(xdm_value=d1)
    d2 = stage2.apply_templates_returning_value()
    assert d2 is not None
    stage3.set_property("!omit-xml-declaration", "yes")
    stage3.set_property("!indent", "no")
    stage3.set_initial_match_selection(xdm_value=d2)
    d3 = stage3.apply_templates_returning_value()

    assert d3 is not None
    stage4.set_property("!omit-xml-declaration", "yes")
    stage4.set_property("!indent", "no")
    stage4.set_initial_match_selection(xdm_value=d3)
    d4 = stage4.apply_templates_returning_value()
    assert d3 is not None
    stage5.set_property("!indent", "no")
    stage5.set_property("!omit-xml-declaration", "yes")
    stage5.set_initial_match_selection(xdm_value=d4)
    sw = stage5.apply_templates_returning_string()
    assert sw is not None
    assert "<a><a><a><a><a><z/></a></a></a></a></a>" in sw


def testPipelineShort(saxonproc):
    
    xsl = "<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>"
    xml = "<z/>"
    stage1 = saxonproc.new_xslt30_processor()
    stage2 = saxonproc.new_xslt30_processor()

    stage1.compile_stylesheet(stylesheet_text=xsl)
    stage2.compile_stylesheet(stylesheet_text=xsl)

    stage1.set_property("!omit-xml-declaration", "yes")
    stage2.set_property("!omit-xml-declaration", "yes")
    in_ = saxonproc.parse_xml(xml_text=xml)
    assert in_ is not None
    stage1.set_initial_match_selection(xdm_value=in_)
    out = stage1.apply_templates_returning_value()
    assert out is not None
    stage2.set_initial_match_selection(xdm_value=out)
    sw = stage2.apply_templates_returning_string()
    assert "<a><a><z/></a></a>" in sw

def testCallFunction(saxonproc):
  
    source = "<?xml version='1.0'?><xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  xmlns:f='http://localhost/'  version='3.0'>  <xsl:function name='f:add' visibility='public'>    <xsl:param name='a'/><xsl:param name='b'/>   <xsl:sequence select='$a + $b'/></xsl:function>  </xsl:stylesheet>"
    trans = saxonproc.new_xslt30_processor()

    trans.compile_stylesheet(stylesheet_text=source)
    paramArr = [saxonproc.make_integer_value(2), saxonproc.make_integer_value(3)]
    v = trans.call_function_returning_value("{http://localhost/}add", paramArr)
    assert isinstance(v.head, PyXdmItem)
    assert v.head.is_atomic		
    assert v.head.get_atomic_value().integer_value ==5
    trans.clear_parameters()
        
  
def testCallFunctionArgConversion(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?><xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:f='http://localhost/'  version='3.0'>  <xsl:function name='f:add' visibility='public'> <xsl:param name='a' as='xs:double'/>  <xsl:param name='b' as='xs:double'/>  <xsl:sequence select='$a + $b'/> </xsl:function> </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)

    v = trans.call_function_returning_value("{http://localhost/}add", [saxonproc.make_integer_value(2), saxonproc.make_integer_value(3)])
    assert isinstance(v.head, PyXdmItem)
    assert v.head.is_atomic		
    assert v.head.get_atomic_value().double_value == 5.0e0
    ''' assert ("double", $v.head.get_atomic_value()->getPrimitiveTypeName()
    '''


def testCallFunctionWrapResults(saxonproc):
       
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?><xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema'  xmlns:f='http://localhost/'  version='3.0'> <xsl:param name='x' as='xs:integer'/>  <xsl:param name='y' select='.+2'/>  <xsl:function name='f:add' visibility='public'>  <xsl:param name='a' as='xs:double'/> <xsl:param name='b' as='xs:double'/> <xsl:sequence select='$a + $b + $x + $y'/> </xsl:function> </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)

    trans.set_property("!omit-xml-declaration", "yes")
    trans.set_parameter("x",  saxonproc.make_integer_value(30))
    trans.set_global_context_item(xdm_item=saxonproc.make_integer_value(20))

    sw = trans.call_function_returning_string("{http://localhost/}add", [saxonproc.make_integer_value(2), saxonproc.make_integer_value(3)])
    assert sw is not None
    assert "57" in sw
    trans.clear_parameters()
    



def testCallFunctionArgInvalid(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:f='http://localhost/'  version='2.0'><xsl:function name='f:add'> <xsl:param name='a' as='xs:double'/>  <xsl:param name='b' as='xs:double'/>  <xsl:sequence select='$a + $b'/> </xsl:function> </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    argArr = [saxonproc.make_integer_value(2), saxonproc.make_integer_value(3)]
    v = trans.call_function_returning_value("{http://localhost/}add", argArr)
            
    assert trans.exception_count()==1
    assert "Cannot invoke function add#2 externally" in trans.get_error_message(0)
    assert v is None
    trans.clear_parameters()
    


def testCallNamedTemplateWithTunnelParams(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?> <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' version='3.0'>  <xsl:template name='t'> <xsl:call-template name='u'/>  </xsl:template>  <xsl:template name='u'> <xsl:param name='a' as='xs:double' tunnel='yes'/>  <xsl:param name='b' as='xs:float' tunnel='yes'/>   <xsl:sequence select='$a + $b'/> </xsl:template> </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_property("!omit-xml-declaration", "yes")
    trans.set_property("tunnel", "true")
    aVar = saxonproc.make_double_value(12)
    paramArr = {"a":aVar, "b":saxonproc.make_integer_value(5)}
    trans.set_initial_template_parameters(True, paramArr)
    sw = trans.call_template_returning_string("t")
    assert sw is not None
    assert "17" in sw
        

def testCallTemplateRuleWithParams(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?> <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0'> <xsl:template match='*'>  <xsl:param name='a' as='xs:double'/>  <xsl:param name='b' as='xs:float'/>  <xsl:sequence select='name(.), $a + $b'/> </xsl:template>  </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_property("!omit-xml-declaration", "yes")
    paramArr = {"a":saxonproc.make_integer_value(12), "b":saxonproc.make_integer_value(5)}
    trans.set_initial_template_parameters(False, paramArr)
    in_ = saxonproc.parse_xml(xml_text="<e/>")
    trans.set_initial_match_selection(xdm_value=in_)
    sw = trans.apply_templates_returning_string()
    sw is not None
    assert "e 17" in sw
   

def testApplyTemplatesToXdm(saxonproc):
    source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0'>  <xsl:template match='*'>     <xsl:param name='a' as='xs:double'/>     <xsl:param name='b' as='xs:float'/>     <xsl:sequence select='., $a + $b'/>  </xsl:template>  </xsl:stylesheet>"
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_property("!omit-xml-declaration", "yes")
    paramArr = {"a":saxonproc.make_integer_value(12), "b":saxonproc.make_integer_value(5)}
    trans.set_initial_template_parameters(False, paramArr)
    trans.set_result_as_raw_value(True)
    in_put = saxonproc.parse_xml(xml_text="<e/>")
    trans.set_initial_match_selection(xdm_value=in_put)
    result = trans.apply_templates_returning_value()
    assert result is not None
    assert result.size == 2
    first = result.item_at(0)
    assert first.is_atomic == False
    assert "e" in first.get_node_value().name
    second = result.item_at(1)
    assert second.is_atomic            
    assert second.get_atomic_value().double_value == 17.0
    


def testResultDocument(saxonproc):
    xsl = "<xsl:stylesheet version='3.0'  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'> <xsl:template match='a'>   <c>d</c> </xsl:template> <xsl:template match='whatever'>   <xsl:result-document href='out.xml'>     <e>f</e>   </xsl:result-document> </xsl:template></xsl:stylesheet>"
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text=xsl)
    in_put = saxonproc.parse_xml(xml_text="<a>b</a>")
    trans.set_initial_match_selection(xdm_value=in_put)
    xdmValue = trans.apply_templates_returning_value()

    assert xdmValue.size == 1
    



@pytest.mark.skip(reason="This will raise permission error in root environment which is true for some docker containers.")
def testApplyTemplatesToFile(saxonproc):

    xsl = "<xsl:stylesheet version='3.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>  <xsl:template match='a'> <c>d</c>  </xsl:template></xsl:stylesheet>"
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text=xsl)
    in_put = saxonproc.parse_xml(xml_text="<a>b</a>")
    trans.set_output_file("output123.xml")
    trans.set_initial_match_selection(xdm_value=in_put)
    trans.apply_templates_returning_file(output_file="output123.xml")
    assert isfile("output123.xml") == True


@pytest.mark.skip('Test can only run with a license file present')
def testCallTemplateWithResultValidation(files_dir):
    saxonproc2 =  PySaxonProcessor(True)
    saxonproc2.set_cwd(files_dir)
    trans = saxonproc2.new_xslt30_processor()

    source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0' exclude-result-prefixes='#all'>  <xsl:import-schema><xs:schema><xs:element name='x' type='xs:int'/></xs:schema></xsl:import-schema>  <xsl:template name='main'>     <xsl:result-document validation='strict'>       <x>3</x>     </xsl:result-document>  </xsl:template>  </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_property("!omit-xml-declaration", "yes")
    sw = trans.call_template_returning_string("main")
    assert sw is not None 
    assert "<x>3</x>" == sw
     



def testCallTemplateNoParamsRaw(saxonproc):
    trans = saxonproc.new_xslt30_processor()
    trans.compile_stylesheet(stylesheet_text="<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template name='xsl:initial-template'><xsl:sequence select='42'/></xsl:template></xsl:stylesheet>")

    trans.set_result_as_raw_value(True)
    result = trans.call_template_returning_value()
    assert result is not None
    assert result.head is not None
    assert result.head.is_atomic == True
    assert result.head.get_atomic_value().integer_value == 42
        



def testCallNamedTemplateWithParamsRaw(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0'>  <xsl:template name='t'>     <xsl:param name='a' as='xs:double'/>     <xsl:param name='b' as='xs:float'/>     <xsl:sequence select='$a+1, $b+1'/>  </xsl:template>  </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_result_as_raw_value(True)
    paramArr = {"a":saxonproc.make_integer_value(12), "b":saxonproc.make_integer_value(5)}
    trans.set_initial_template_parameters(False, paramArr)
    val = trans.call_template_returning_value("t")
    assert val is not None
    assert val.size == 2
    assert val.item_at(0).is_atomic
    assert val.item_at(0).get_atomic_value().integer_value == 13
    assert val.item_at(1).get_atomic_value().integer_value == 6
       

def testApplyTemplatesRaw(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0'>  <xsl:template match='*'>     <xsl:param name='a' as='xs:double'/>     <xsl:param name='b' as='xs:float'/>     <xsl:sequence select='., $a + $b'/>  </xsl:template>  </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    node = saxonproc.parse_xml(xml_text="<e/>")

    trans.set_result_as_raw_value(True)
    paramArr = {"a":saxonproc.make_integer_value(12), "b":saxonproc.make_integer_value(5)}
    trans.set_initial_template_parameters(False, paramArr)
    trans.set_initial_match_selection(xdm_value=node)
    result = trans.apply_templates_returning_value()
    assert result is not None
    assert result.size ==2
    first = result.item_at(0)
    assert first is not None
    assert first.is_atomic == False
    assert first.get_node_value().name == "e"
    second = result.item_at(1)
    assert second is not None
    assert second.is_atomic
    assert second.get_atomic_value().double_value == 17.0
        


def testApplyTemplatesToSerializer(saxonproc):
    trans = saxonproc.new_xslt30_processor()

    source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0'>  <xsl:output method='text' item-separator='~~'/>  <xsl:template match='.'>     <xsl:param name='a' as='xs:double'/>     <xsl:param name='b' as='xs:float'/>     <xsl:sequence select='., $a + $b'/>  </xsl:template>  </xsl:stylesheet>"

    trans.compile_stylesheet(stylesheet_text=source)
    trans.set_property("!omit-xml-declaration", "yes")
    trans.set_result_as_raw_value(True)
    paramArr = {"a":saxonproc.make_integer_value(12), "b":saxonproc.make_integer_value(5)}
    trans.set_initial_template_parameters(False, paramArr)
  
    trans.set_initial_match_selection(xdm_value=saxonproc.make_integer_value(16))
    sw = trans.apply_templates_returning_string()

    assert "16~~17" == sw
 


    
''' PyXQueryProcessor '''

def test_return_document_node(saxonproc):
    node = saxonproc.parse_xml(xml_text='<foo/>')
    xqc = saxonproc.new_xquery_processor()
    xqc.set_query_content('document{.}')
    xqc.set_context(xdm_item=node)
    result = xqc.run_query_to_value()
    if isinstance(result, PyXdmNode):
        assert result.node_kind == DOCUMENT

def testxQuery1(saxonproc, data_dir):
    query_proc = saxonproc.new_xquery_processor()
    query_proc.clear_properties()
    query_proc.clear_parameters()
    xmlFile = data_dir+"cat.xml"
    query_proc.set_property("s", xmlFile)

    query_proc.set_property("qs", "<out>{count(/out/person)}</out>")

    result = query_proc.run_query_to_string()
    assert not result == None

    query_proc.set_cwd(".")
    query_proc.run_query_to_file(output_file_name="catOutput.xml")
    assert os.path.exists("catOutput.xml")
    node = saxonproc.parse_xml(xml_file_name='catOutput.xml')
    xp = saxonproc.new_xpath_processor()
    xp.set_context(xdm_item=node)
    assert xp.effective_boolean_value("/out/text()=3")    
    if os.path.exists('catOutput.xml'):
        os.remove("catOutput.xml")


def test_default_namespace(saxonproc):
    query_proc = saxonproc.new_xquery_processor()
    query_proc.declare_namespace("", "http://one.uri/")
    node = saxonproc.parse_xml(xml_text="<foo xmlns='http://one.uri/'><bar/></foo>")
    query_proc.set_context(xdm_item=node)
    query_proc.set_query_content("/foo")

    value = query_proc.run_query_to_value()

    assert value.size == 1 


def test_XQuery_line_number():
    ''' No license file given therefore result will return None'''
    proc = PySaxonProcessor(True)
    proc.set_configuration_property("l", "on")
    query_proc = proc.new_xquery_processor()
    
    query_proc.set_property("s", "cat.xml")
    query_proc.declare_namespace("saxon","http://saxon.sf.net/")

    query_proc.set_property("qs", "saxon:line-number(doc('cat.xml')/out/person[1])")

    result = query_proc.run_query_to_string()
    assert result == None
    

def testReusability(saxonproc):
    queryproc = saxonproc.new_xquery_processor()
    queryproc.clear_properties()
    queryproc.clear_parameters()

    input_ =  saxonproc.parse_xml(xml_text="<foo xmlns='http://one.uri/'><bar xmlns='http://two.uri'>12</bar></foo>")
    queryproc.declare_namespace("", "http://one.uri/")
    queryproc.set_query_content("declare variable $p as xs:boolean external; exists(/foo) = $p")

    queryproc.set_context(xdm_item=input_)

    value1 = saxonproc.make_boolean_value(True)
    queryproc.set_parameter("p",value1)
    result = queryproc.run_query_to_value()
       
    assert result is not None
    assert result.is_atomic
    assert result.boolean_value

    queryproc.clear_parameters()
    queryproc.clear_properties()    
    
    queryproc.declare_namespace("", "http://two.uri")
    queryproc.set_query_content("declare variable $p as xs:integer external; /*/bar + $p")
    
    queryproc.set_context(xdm_item=input_)

    value2 = saxonproc.make_long_value(6)
    queryproc.set_parameter("p",value2)
        
    result2 = queryproc.run_query_to_value()
    assert result2.integer_value == 18

def test_make_string_value(saxonproc):

    xdm_string_value = saxonproc.make_string_value('text1')
    
    print(xdm_string_value)

    xquery_processor = saxonproc.new_xquery_processor()

    xquery_processor.set_parameter('s1', xdm_string_value)

    result = xquery_processor.run_query_to_value(query_text = 'declare variable $s1 external; $s1')

    assert result is not None
    assert isinstance(result, PyXdmAtomicValue)
    assert result.string_value == "text1"



'''PyXPathProcessor test cases'''


def test_xpath_proc(saxonproc, data_dir):

    sp = saxonproc
    xp = saxonproc.new_xpath_processor()
    xmlFile = data_dir+"cat.xml"
    assert isfile(xmlFile)
    xp.set_context(file_name=xmlFile)
    assert xp.effective_boolean_value('count(//person) = 3')
    assert not xp.effective_boolean_value("/out/person/text() = 'text'")


def test_atomic_values():
    sp = PySaxonProcessor()
    value = sp.make_double_value(3.5)
    boolVal = value.boolean_value
    assert boolVal == True
    assert value.string_value == '3.5'
    assert value.double_value == 3.5
    assert value.integer_value == 3
    primValue = value.primitive_type_name
    assert primValue == 'Q{http://www.w3.org/2001/XMLSchema}double'


def test_node_list():
    xml = """\
    <out>
        <person att1='value1' att2='value2'>text1</person>
        <person>text2</person>
        <person>text3</person>
    </out>
    """
    sp = PySaxonProcessor()
    
    node = sp.parse_xml(xml_text=xml)
    outNode = node.children[0]
    children = outNode.children
    personData = str(children)    
    assert ('<person att1' in personData)



def parse_xml_file():

    sp = PySaxonProcessor()
    
    node = sp.parse_xml(xml_file_name='cat.xml')
    outNode = node.children[0]
    assert outNode.name == 'out'


def test_node():
    xml = """\
    <out>
        <person att1='value1' att2='value2'>text1</person>
        <person>text2</person>
        <person>text3</person>
    </out>
    """
    sp = PySaxonProcessor()
    
    node = sp.parse_xml(xml_text=xml)
    assert node.node_kind == 9    
    assert node.size == 1
    outNode = node.children[0]
    assert outNode.name == 'out'
    assert outNode.node_kind == ELEMENT
    children = outNode.children    
    attrs = children[1].attributes
    assert len(attrs) == 2
    assert children[1].get_attribute_value('att2') == 'value2'
    assert 'value2' in attrs[1].string_value 


def test_evaluate():
    xml = """\
    <out>
        <person att1='value1' att2='value2'>text1</person>
        <person>text2</person>
        <person>text3</person>
    </out>
    """
    sp = PySaxonProcessor()
    xp = sp.new_xpath_processor()
    
    node = sp.parse_xml(xml_text=xml)
    assert isinstance(node, PyXdmNode)
    xp.set_context(xdm_item=node)
    value = xp.evaluate('//person')
    assert isinstance(value, PyXdmValue)
    assert value.size == 3
    

def test_single():
    xml = """\
    <out>
        <person>text1</person>
        <person>text2</person>
        <person>text3</person>
    </out>
    """
    sp = PySaxonProcessor()
    xp = sp.new_xpath_processor()
    
    node = sp.parse_xml(xml_text=xml)
    assert isinstance(node, PyXdmNode)
    xp.set_context(xdm_item=node)
    item = xp.evaluate_single('//person[1]')
    assert isinstance(item, PyXdmItem)
    assert item.size == 1
    assert not item.is_atomic
    assert item.__str__() == '<person>text1</person>'

def test_declare_variable_value(saxonproc):
    s1 = 'This is a test.'
    xdm_string_value = saxonproc.make_string_value(s1)

    xpath_processor = saxonproc.new_xpath_processor()
    xpath_processor.set_parameter('s1', xdm_string_value)
    result = xpath_processor.evaluate('$s1')

    assert result is not None
    assert'test.' in result.head.string_value


def test_declare_variable_value2(saxonproc):
    s1 = 'This is a test.'
    xdm_string_value = saxonproc.make_string_value(s1)

    xpath_processor = saxonproc.new_xpath_processor()
    result = xpath_processor.evaluate('$s1')

    assert result is None



'''Test case should be run last to test release() '''
def test_release():
    with PySaxonProcessor(license=False) as proc:
        xsltproc = proc.new_xslt_processor()
        document = proc.parse_xml(xml_text="<out><person>text1</person><person>text2</person><person>text3</person></out>")
        xsltproc.set_source(xdm_node=document)
        xsltproc.compile_stylesheet(stylesheet_text="<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>       <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:value-of select='//person[1]'/><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out></xsl:for-each></output></xsl:template></xsl:stylesheet>")
        output2 = xsltproc.transform_to_string()
        assert output2.startswith('<?xml version="1.0" encoding="UTF-8"?>\n<output>text1<out>6</out')

def release(saxonproc):
   saxonproc.release()

