<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class XSLT30Test extends TestCase
{

    protected static $saxonProc;

    public static function setUpBeforeClass(): void
    {
        self::$saxonProc = new Saxon\SaxonProcessor(False);
    }


    public function testCreateXslt30ProcessorObject(): void
    {


        $proc = self::$saxonProc->newXslt30Processor();


        $this->assertInstanceOf(
            Saxon\Xslt30Processor::class,
            $proc
        );
    }

    /*  public function testCannotBeCreatedFromInvalidEmailAddress(): void
      {
          $this->expectException(InvalidArgumentException::class);

          Email::fromString('invalid');
      }*/

    public function testVersion(): void
    {
        $this->assertStringContainsString(
            'Saxon/C 1.2.1 running',
            self::$saxonProc->version()
        );
        $this->assertStringContainsString('9.9.1.5C from Saxonica', self::$saxonProc->version());
    }


    public function testSchemaAware(): void
    {
        $this->assertFalse(
            self::$saxonProc->isSchemaAware()
        );
    }


    public function testSchemaAware2(): void
    {

        $saxonProc2 = new Saxon\SaxonProcessor(True);

        $this->assertFalse($saxonProc2->isSchemaAware());
    }

    public function testContextNotRoot(): void
    {

        $trans = self::$saxonProc->newXslt30Processor();
        $node = self::$saxonProc->parseXmlFromString("<doc><e>text</e></doc>");

        $trans->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template match='e'>[<xsl:value-of select='name(\$x)'/>]</xsl:template></xsl:stylesheet>");
        $this->assertNotNull($node);
        $this->assertInstanceOf(
            Saxon\XdmNode::class,
            $node
        );
        $this->assertTrue($node->getChildCount() > 0);
        $this->assertNotNull($node);
        $eNode = $node->getChildNode(0)->getChildNode(0);
        $this->assertNotNull($eNode);
        $trans->setGlobalContextItem($node);
        $trans->setInitialMatchSelection($eNode);
        $result = $trans->applyTemplatesReturningString();

        $this->assertStringContainsString("[", $result);


    }


    public function testResolveUri(): void
    {

        $transformer = self::$saxonProc->newXslt30Processor();

        $transformer->compileFromString("<xsl:stylesheet version='3.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:err='http://www.w3.org/2005/xqt-errors'><xsl:template name='go'><xsl:try><xsl:variable name='uri' as='xs:anyURI' select=\"resolve-uri('notice trailing space /out.xml')\"/> <xsl:message select='\$uri'/><xsl:result-document href='{\$uri}'><out/></xsl:result-document><xsl:catch><xsl:sequence select=\"'\$err:code: ' || \$err:code  || ', \$err:description: ' || \$err:description\"/></xsl:catch></xsl:try></xsl:template></xsl:stylesheet>");


        $value = $transformer->callTemplateReturningValue("go");

        $item = $value->getHead();
        $this->assertStringContainsString("code", $item->getStringValue());

    }


    public function testEmbeddedStylesheet(): void
    {

        $transformer = self::$saxonProc->newXslt30Processor();

        // Load the source document
        $input = self::$saxonProc->parseXmlFromFile("../data/books.xml");
        //Console.WriteLine("=============== source document ===============");
        //Console.WriteLine(input.OuterXml);
        //Console.WriteLine("=========== end of source document ============");

        // Navigate to the xml-stylesheet processing instruction having the pseudo-attribute type=text/xsl;
        // then extract the value of the href pseudo-attribute if present

        $path = "/processing-instruction(xml-stylesheet)[matches(.,'type\\s*=\\s*[''\"\"]text/xsl[''\" \"]')]/replace(., '.*?href\\s*=\\s*[''\" \"](.*?)[''\" \"].*', '$1')";

        $xPathProcessor = self::$saxonProc->newXPathProcessor();
        $xPathProcessor->setContextItem($input);
        $hrefval = $xPathProcessor->evaluateSingle($path);
        $this->assertNotNull($hrefval);
	echo "test cp0";
        $this->assertInstanceOf(Saxon\XdmItem::class, $hrefval);
	$this->assertTrue($hrefval->isAtomic());
        $href = $hrefval->getAtomicValue()->getStringValue();
        $this->assertNotEquals($href, "");
        // The stylesheet is embedded in the source document and identified by a URI of the form "#id"

        $transformer->compileFromFile("../styles/".$href);


        $this->assertInstanceOf(Saxon\XdmNode::class, $input);
        // Run it
        $node = $transformer->transformToValue($input);
        if ($transformer->getExceptionCount() > 0) {
            echo $transformer->getErrorMessage(0);
        }
        $this->assertNotNull($node);

        if ($transformer->getExceptionCount() > 0) {
            echo $transformer->getErrorMessage(0);
        }

    }


    public function testContextNotRootNamedTemplate(): void
    {

        $transformer = self::$saxonProc->newXslt30Processor();
        $node = self::$saxonProc->parseXmlFromString("<doc><e>text</e></doc>");


        $transformer->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template name='main'>[<xsl:value-of select='name(\$x)'/>]</xsl:template></xsl:stylesheet>");
        $transformer->setGlobalContextItem($node);
        $result = $transformer->callTemplateReturningValue("main");
        if ($transformer->getExceptionCount() > 0) {
            echo $transformer->getErrorMessage(0);
        }

        $this->assertNotNull($result);
        if ($result->getHead() != NULL) {
            $this->assertStringContainsString("[]", $result->getHead()->getStringValue());
        }


        $result2 = $transformer->callTemplateReturningString("main");
        if ($transformer->getExceptionCount() > 0) {
            echo $transformer->getErrorMessage(0);
        }

        $this->assertNotNull($result2);
        $this->assertStringContainsString("[]", $result2);

    }


    public function testUseAssociated(): void
    {

        $transformer = self::$saxonProc->newXslt30Processor();


        $foo_xml = "trax/xml/foo.xml";
        $transformer->compileFromAssociatedFile($foo_xml);
        $transformer->setInitialMatchSelectionAsFile($foo_xml);
        $result = $transformer->applyTemplatesReturningString();

        $this->assertNotNull($result);

    }


    public function testNullStylesheet(): void
    {

        $transformer = self::$saxonProc->newXslt30Processor();
        $result = $transformer->applyTemplatesReturningString();

        $this->assertNull($result);
    }


    public function testXdmDestination(): void
    {
        $transformer = self::$saxonProc->newXslt30Processor();
        $transformer->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" .
            "<xsl:template name='go'><a/></xsl:template>" .
            "</xsl:stylesheet>");

        $root = $transformer->callTemplateReturningValue("go");
        $this->assertNotNull($root);
        $this->assertNotNull($root->getHead());
        $node = $root->getHead()->getNodeValue();
        $this->assertTrue($node->getNodeKind() == 9, "result is document node");
    }

    public function testXdmDestinationWithItemSeparator(): void
    {
        $transformer = self::$saxonProc->newXslt30Processor();
        $transformer->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" .
            "<xsl:template name='go'><xsl:comment>A</xsl:comment><out/><xsl:comment>Z</xsl:comment></xsl:template>" .
            "<xsl:output method='xml' item-separator='§'/>" .
            "</xsl:stylesheet>");

        $root = $transformer->callTemplateReturningValue("go");
        $node = $root->getHead()->getNodeValue();
        $this->assertEquals("<!--A-->§<out/>§<!--Z-->", $node);
        $this->assertTrue($node->getNodeKind() == 9, "result is document node");


    }


    public function testPipeline(): void
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $xsl = "<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" .
            "<xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template>" .
            "</xsl:stylesheet>";
        $xml = "<z/>";
        $stage1 = self::$saxonProc->newXslt30Processor();
        $stage1->compileFromString($xsl);
        $in = self::$saxonProc->parseXmlFromString($xml);

        $stage2 = self::$saxonProc->newXslt30Processor();
        $stage2->compileFromString($xsl);
        $stage3 = self::$saxonProc->newXslt30Processor();
        $stage3->compileFromString($xsl);

        $stage4 = self::$saxonProc->newXslt30Processor();
        $stage4->compileFromString($xsl);

        $stage5 = self::$saxonProc->newXslt30Processor();
        $stage5->compileFromString($xsl);

        $this->assertNotNull($xsl, "\$xsl check");
        $this->assertNotNull($in, "\$in check");
        $stage1->setProperty("!omit-xml-declaration", "yes");
        $stage1->setProperty("!indent", "no");
        $stage1->setInitialMatchSelection($in);

        $d1 = $stage1->applyTemplatesReturningValue();
        if ($stage1->getExceptionCount() > 0) {
            echo $stage1->getErrorMessage(0);
        }
        $this->assertNotNull($d1, "\$d1 check");
        $stage2->setProperty("!omit-xml-declaration", "yes");
        $stage2->setProperty("!indent", "no");
        $stage2->setInitialMatchSelection($d1);
        $d2 = $stage2->applyTemplatesReturningValue();
        $this->assertNotNull($d2, "\$d2");
        $stage3->setProperty("!omit-xml-declaration", "yes");
        $stage3->setProperty("!indent", "no");
        $stage3->setInitialMatchSelection($d2);
        $d3 = $stage3->applyTemplatesReturningValue();
        $this->assertNotNull($d3, "\$d3 check");
        $stage4->setProperty("!omit-xml-declaration", "yes");
        $stage4->setProperty("!indent", "no");
        $stage4->setInitialMatchSelection($d3);
        $d4 = $stage4->applyTemplatesReturningValue();
        $this->assertNotNull($d3, "\$d4 check");
        $stage5->setProperty("!indent", "no");
        $stage5->setProperty("!omit-xml-declaration", "yes");
        $stage5->setInitialMatchSelection($d4);
        $sw = $stage5->applyTemplatesReturningString();
        $this->assertNotNull($sw, "\$sw check");
        $this->assertStringContainsString($sw, "<a><a><a><a><a><z/></a></a></a></a></a>");

    }


    public function testPipelineShort(): void
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $xsl = "<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" .
            "<xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template>" .
            "</xsl:stylesheet>";
        $xml = "<z/>";
        $stage1 = self::$saxonProc->newXslt30Processor();
        $stage2 = self::$saxonProc->newXslt30Processor();


        $stage1->compileFromString($xsl);
        $stage2->compileFromString($xsl);

        $this->assertNotNull($xsl);
        $stage1->setProperty("!omit-xml-declaration", "yes");
        $stage2->setProperty("!omit-xml-declaration", "yes");
        $in = self::$saxonProc->parseXmlFromString($xml);
        $this->assertNotNull($in, "\$sin check");
        $stage1->setInitialMatchSelection($in);
        $out = $stage1->applyTemplatesReturningValue();
        $this->assertNotNull($out, "\$out check");
        $stage2->setInitialMatchSelection($out);
        $sw = $stage2->applyTemplatesReturningString();

        $this->assertStringContainsString($sw, "<a><a><z/></a></a>");

    }

    /*
        public function testSchemaAware11(): void {
            // Create a Processor instance.
            try {

                Processor proc = new Processor(true);
                proc.setConfigurationProperty(FeatureKeys.XSD_VERSION, "1.1");
                Xslt30Processor transformer = new Xslt30Processor(proc);
                transformer.compileFromString(null,
                        "<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" +
                                "<xsl:import-schema><xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema'>" +
                                "<xs:element name='e'><xs:complexType><xs:sequence><xs:element name='p'/></xs:sequence><xs:assert test='exists(p)'/></xs:complexType></xs:element>" +
                                "</xs:schema></xsl:import-schema>" +
                                "<xsl:variable name='v'><e><p/></e></xsl:variable>" +
                                "<xsl:template name='main'><xsl:copy-of select='$v' validation='strict'/></xsl:template>" +
                                "</xsl:stylesheet>", null, null);


                String[] params = new String[]{"!indent"};
                Object[] values = new Object[]{"no"};

                String sw = transformer.callTemplateReturningString(null, null,  "main", params, values);
                assertTrue(sw.contains("<e>"));
            } catch (SaxonApiException e) {
                e.printStackTrace();
                fail(e.getMessage());
            }

        }
    */

    public function testCallFunction()
    {

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                xmlns:f='http://localhost/'" .
            "                version='3.0'>" .
            "                <xsl:function name='f:add' visibility='public'>" .
            "                  <xsl:param name='a'/><xsl:param name='b'/>" .
            "                  <xsl:sequence select='\$a + \$b'/></xsl:function>" .
            "                </xsl:stylesheet>";
        $transformer = self::$saxonProc->newXslt30Processor();

        $transformer->compileFromString($source);
        $paramArr = array(self::$saxonProc->createAtomicValue(2), self::$saxonProc->createAtomicValue(3));
        $v = $transformer->callFunctionReturningValue("{http://localhost/}add", $paramArr);
        $this->assertInstanceOf(Saxon\XdmItem::class, $v->getHead());
        $this->assertTrue($v->getHead()->isAtomic());
        $this->assertEquals($v->getHead()->getAtomicValue()->getLongValue(), 5);

    }


    public function testCallFunctionArgConversion()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                xmlns:f='http://localhost/'" .
            "                version='3.0'>" .
            "                <xsl:function name='f:add' visibility='public'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:double'/>" .
            "                   <xsl:sequence select='\$a + \$b'/>" .
            "                </xsl:function>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);

        $v = $transformer->callFunctionReturningValue("{http://localhost/}add", array(self::$saxonProc->createAtomicValue(2), self::$saxonProc->createAtomicValue(3)));
        $this->assertInstanceOf(Saxon\XdmItem::class, $v->getHead());
        $this->assertTrue($v->getHead()->isAtomic());
        $this->assertEquals($v->getHead()->getAtomicValue()->getDoubleValue(), 5.0e0);
        $this->assertStringContainsString("double", $v->getHead()->getAtomicValue()->getPrimitiveTypeName());

    }


    public function testCallFunctionWrapResults()
    {

        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                xmlns:f='http://localhost/'" .
            "                version='3.0'>" .
            "                <xsl:param name='x' as='xs:integer'/>" .
            "                <xsl:param name='y' select='.+2'/>" .
            "                <xsl:function name='f:add' visibility='public'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:double'/>" .
            "                   <xsl:sequence select='\$a + \$b + \$x + \$y'/>" .
            "                </xsl:function>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);

        $transformer->setProperty("!omit-xml-declaration", "yes");
        $transformer->setParameter("x", self::$saxonProc->createAtomicValue(30));
        $transformer->setGlobalContextItem(self::$saxonProc->createAtomicValue(20));

        $sw = $transformer->callFunctionReturningString("{http://localhost/}add", array(self::$saxonProc->createAtomicValue(2), self::$saxonProc->createAtomicValue(3)));

        $this->assertEquals("57", $sw);
    }


    public function testCallFunctionArgInvalid()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                xmlns:f='http://localhost/'" .
            "                version='2.0'>" .
            "                <xsl:function name='f:add'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:double'/>" .
            "                   <xsl:sequence select='\$a + \$b'/>" .
            "                </xsl:function>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $v = $transformer->callFunctionReturningValue("{http://localhost/}add", array(self::$saxonProc->createAtomicValue(2), self::$saxonProc->createAtomicValue(3)));

        $this->assertTrue($transformer->getExceptionCount() == 1);
        $this->assertStringContainsString("Cannot invoke function add#2 externally", $transformer->getErrorMessage(0));
        $this->assertNull($v);
    }


    public function testCallNamedTemplateWithTunnelParams()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0'>" .
            "                <xsl:template name='t'>" .
            "                   <xsl:call-template name='u'/>" .
            "                </xsl:template>" .
            "                <xsl:template name='u'>" .
            "                   <xsl:param name='a' as='xs:double' tunnel='yes'/>" .
            "                   <xsl:param name='b' as='xs:float' tunnel='yes'/>" .
            "                   <xsl:sequence select='\$a + \$b'/>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $transformer->setProperty("!omit-xml-declaration", "yes");
        $transformer->setProperty("tunnel", "true");
        $transformer->setInitialTemplateParameters(array("a" => self::$saxonProc->createAtomicValue(12), "b" => self::$saxonProc->createAtomicValue(5)));
        $sw = $transformer->callTemplateReturningString("t");
        $this->assertNotNull($sw);
        $this->assertEquals("17", $sw);

    }

    public function testCallTemplateRuleWithParams()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0'>" .
            "                <xsl:template match='*'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:float'/>" .
            "                   <xsl:sequence select='name(.), \$a + \$b'/>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $transformer->setProperty("!omit-xml-declaration", "yes");
        $transformer->setInitialTemplateParameters(array("a" => self::$saxonProc->createAtomicValue(12), "b" => self::$saxonProc->createAtomicValue(5)));
        $in = self::$saxonProc->parseXmlFromString("<e/>");
        $transformer->setInitialMatchSelection($in);
        $sw = $transformer->applyTemplatesReturningString();

        $this->assertEquals("e 17", $sw);
    }


    public function testApplyTemplatesToXdm()
    {
        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0'>" .
            "                <xsl:template match='*'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:float'/>" .
            "                   <xsl:sequence select='., \$a + \$b'/>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";
        $transformer = self::$saxonProc->newXslt30Processor();
        $transformer->compileFromString($source);
        $transformer->setProperty("!omit-xml-declaration", "yes");
        $transformer->setInitialTemplateParameters(array("a" => self::$saxonProc->createAtomicValue(12), "b" => self::$saxonProc->createAtomicValue(5)));
        $transformer->setResultAsRawValue(True);
        $input = self::$saxonProc->parseXmlFromString("<e/>");
        $transformer->setInitialMatchSelection($input);
        $result = $transformer->applyTemplatesReturningValue();
        $this->assertNotNull($result);
        $this->assertEquals(2, $result->size());
        $first = $result->itemAt(0);
        $this->assertTrue($first->isNode());
        $this->assertEquals("e", $first->getNodeValue()->getNodeName());
        $second = $result->itemAt(1);
        $this->assertTrue($second->isAtomic());
        $this->assertEquals(17e0, $second->getAtomicValue()->getDoubleValue());

    }


    public function testResultDocument(): void
    {
        // bug 2771
        $xsl = "<xsl:stylesheet version=\"3.0\" \n" .
            "  xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">\n" .
            "\n" .
            "  <xsl:template match='a'>\n" .
            "    <c>d</c>\n" .
            "  </xsl:template>\n" .
            "\n" .
            "  <xsl:template match='whatever'>\n" .
            "    <xsl:result-document href='out.xml'>\n" .
            "      <e>f</e>\n" .
            "    </xsl:result-document>\n" .
            "  </xsl:template>\n" .
            "\n" .
            "</xsl:stylesheet>";
        $transformer = self::$saxonProc->newXslt30Processor();
        $transformer->compileFromString($xsl);
        $input = self::$saxonProc->parseXmlFromString("<a>b</a>");
        $transformer->setInitialMatchSelection($input);
        $xdmValue = $transformer->applyTemplatesReturningValue();

        $this->assertEquals(1, $xdmValue->size());

    }


    public function testApplyTemplatesToFile()
    {

        $xsl = "<xsl:stylesheet version=\"3.0\" \n" .
            "  xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">\n" .
            "\n" .
            "  <xsl:template match='a'>\n" .
            "    <c>d</c>\n" .
            "  </xsl:template>\n" .
            "</xsl:stylesheet>";
        $transformer = self::$saxonProc->newXslt30Processor();
        $transformer->compileFromString($xsl);
        $input = self::$saxonProc->parseXmlFromString("<a>b</a>");
        $transformer->setOutputFile("output123.xml");
        $transformer->setInitialMatchSelection($input);
        $transformer->applyTemplatesReturningFile("output123.xml");
        $this->assertTrue(file_exists("output123.xml"));

        if (file_exists("output123.xml")) {
            unlink("output123.xml");
        }
    }


    public function testCallTemplateWithResultValidation(): void
    {
        $saxonProc2 = new Saxon\SaxonProcessor(True);
        $saxonProc2->setcwd("/home/ond1/work/svn/latest9.9-saxonc/samples/php/");
        $transformer = $saxonProc2->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0' exclude-result-prefixes='#all'>" .
            "                <xsl:import-schema><xs:schema><xs:element name='x' type='xs:int'/></xs:schema></xsl:import-schema>" .
            "                <xsl:template name='main'>" .
            "                   <xsl:result-document validation='strict'>" .
            "                     <x>3</x>" .
            "                   </xsl:result-document>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $transformer->setProperty("!omit-xml-declaration", "yes");
        $sw = $transformer->callTemplateReturningString("main");
        $this->assertNotNull($sw);
        $this->assertEquals($sw, "<x>3</x>");

    }

    /*    public function testCallTemplateWithResultValidationFailure(): void {
            try {
                Xslt30Processor transformer = new Xslt30Processor(true);

                String source = "<?xml version='1.0'?>" +
                        "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" +
                        "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" +
                        "                version='3.0' expand-text='yes' exclude-result-prefixes='#all'>" +
                        "                <xsl:import-schema><xs:schema><xs:element name='x' type='xs:int'/></xs:schema></xsl:import-schema>" +
                        "                <xsl:param name='p'>zzz</xsl:param>" +
                        "                <xsl:template name='main'>" +
                        "                   <xsl:result-document validation='strict'>" +
                        "                     <x>{$p}</x>" +
                        "                   </xsl:result-document>" +
                        "                </xsl:template>" +
                        "                </xsl:stylesheet>";

                transformer.compileFromString(null, source, null, null);

                String[] params = new String[]{"!omit-xml-declaration"};
                Object[] pvalues = new Object[]{"yes"};
                String sw = transformer.callTemplateReturningString(null, null, "main", params, pvalues);
                fail("unexpected success");

            } catch (SaxonApiException e) {
                System.err.println("Failed as expected: " + e.getMessage());
            }
        }

    */

    public function testCallTemplateNoParamsRaw(): void
    {
        $transformer = self::$saxonProc->newXslt30Processor();
        $transformer->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" .
            "<xsl:template name='xsl:initial-template'><xsl:sequence select='42'/></xsl:template>" .
            "</xsl:stylesheet>");

        $transformer->setResultAsRawValue(True);
        $result = $transformer->callTemplateReturningValue();
        $this->assertNotNull($result);
        $this->assertNotNull($result->getHead());
        $this->assertTrue($result->getHead()->isAtomic());
        $this->assertEquals($result->getHead()->getAtomicValue()->getLongValue(), 42);


    }


    public function testCallNamedTemplateWithParamsRaw()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0'>" .
            "                <xsl:template name='t'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:float'/>" .
            "                   <xsl:sequence select='\$a+1, \$b+1'/>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $transformer->setResultAsRawValue(True);
        $transformer->setInitialTemplateParameters(array("a" => self::$saxonProc->createAtomicValue(12), "b" => self::$saxonProc->createAtomicValue(5)));
        $val = $transformer->callTemplateReturningValue("t");
        $this->assertNotNull($val);
        $this->assertEquals(2, $val->size());
        $this->assertTrue($val->itemAt(0)->isAtomic());
        $this->assertEquals(13, $val->itemAt(0)->getAtomicValue()->getLongValue());
        $this->assertTrue($val->itemAt(0)->isAtomic());
        $this->assertEquals(6, $val->itemAt(1)->getAtomicValue()->getLongValue());

    }

    /*
        public function testCatalog(){

            $transformer = self::$saxonProc->newXslt30Processor();
            Processor proc = transformer.getProcessor();


            try {
                XmlCatalogResolver.setCatalog(CWD_DIR+"../../catalog-test/catalog.xml", proc.getUnderlyingConfiguration(), true);

                transformer.applyTemplatesReturningValue(CWD_DIR+"../../catalog-test/", "example.xml","test1.xsl",null, null);
            } catch (XPathException e) {
                e.printStackTrace();
                fail();
            } catch (SaxonApiException e) {
                e.printStackTrace();
                fail();
            }

        }

    */

    public function testApplyTemplatesRaw()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0'>" .
            "                <xsl:template match='*'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:float'/>" .
            "                   <xsl:sequence select='., \$a + \$b'/>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $node = self::$saxonProc->parseXmlFromString("<e/>");

        $transformer->setResultAsRawValue(True);
        $transformer->setInitialTemplateParameters(array("a" => self::$saxonProc->createAtomicValue(12), "b" => self::$saxonProc->createAtomicValue(5)));
        $transformer->setInitialMatchSelection($node);
        $result = $transformer->applyTemplatesReturningValue();


        $this->assertEquals(2, $result->size());
        $first = $result->itemAt(0);
        $this->assertNotNull($first);
        $this->assertTrue($first->isNode());
        $this->assertEquals($first->getNodeValue()->getNodeName(), "e");
        $second = $result->itemAt(1);
        $this->assertNotNull($second);
        $this->assertTrue($second->isAtomic());
        $this->assertEquals($second->getAtomicValue()->getDoubleValue(), "17e0");

    }


    public function testApplyTemplatesToSerializer()
    {
        $transformer = self::$saxonProc->newXslt30Processor();

        $source = "<?xml version='1.0'?>" .
            "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" .
            "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" .
            "                version='3.0'>" .
            "                <xsl:output method='text' item-separator='~~'/>" .
            "                <xsl:template match='.'>" .
            "                   <xsl:param name='a' as='xs:double'/>" .
            "                   <xsl:param name='b' as='xs:float'/>" .
            "                   <xsl:sequence select='., \$a + \$b'/>" .
            "                </xsl:template>" .
            "                </xsl:stylesheet>";

        $transformer->compileFromString($source);
        $transformer->setProperty("!omit-xml-declaration", "yes");
        $transformer->setResultAsRawValue(True);
        $transformer->setInitialTemplateParameters(array("a" => self::$saxonProc->createAtomicValue(12), "b" => self::$saxonProc->createAtomicValue(5)));

        $transformer->setInitialMatchSelection(self::$saxonProc->createAtomicValue(16));
        $sw = $transformer->applyTemplatesReturningString();

        $this->assertEquals("16~~17", $sw);

    }


    /*  public function testItemSeparatorToSerializer(): void {
          try {

              String sr =
                      "<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" +
                              "  <xsl:template name='go'>"
                              + "<xsl:comment>start</xsl:comment><a><b/><c/></a><xsl:comment>end</xsl:comment>"
                              + "</xsl:template>" +
                              "</xsl:stylesheet>";
              $transformer = self::$saxonProc->newXslt30Processor();
              transformer.compileFromString(null, sr, null, null);
              String[] params = new String[]{"!method", "!indent", "!item-separator"};
              Object[] pvalues = new Object[]{"xml", "no", "+++"};
              String sw = transformer.callTemplateReturningString(null, null, "go", params, pvalues);
              System.err.println(sw);
              assertTrue(sw.contains("<!--start-->+++"));
              assertTrue(sw.contains("+++<!--end-->"));
              assertTrue(sw.contains("<a><b/><c/></a>"));
          } catch (Exception e) {
              e.printStackTrace();
              fail(e.getMessage());
          }

      }

      public function testSequenceResult() throws SaxonApiException {
          try {

              String source = "<?xml version='1.0'?>" +
                      "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'" +
                      "                xmlns:xs='http://www.w3.org/2001/XMLSchema'" +
                      "                version='3.0'>" +
                      "                <xsl:template name='xsl:initial-template' as='xs:integer+'>" +
                      "                     <xsl:sequence select='(1 to 5)' />        " +
                      "                </xsl:template>" +
                      "                </xsl:stylesheet>";

              $transformer = self::$saxonProc->newXslt30Processor();
              transformer.compileFromString(null, source, null, null);
              String[] params = new String[]{"outvalue"};
              Object[] pvalues = new Object[]{true};
              XdmValue res = transformer.callTemplateReturningValue(null, null, null, params, pvalues);
              int count = res.size();
              XdmAtomicValue value = (XdmAtomicValue) res.itemAt(0);
          } catch (SaxonApiException e) {
              e.printStackTrace();
              fail();
          }
      }

  */


}
