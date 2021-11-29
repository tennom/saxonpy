<!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Saxon/C API design use cases</title>
</head>
<body>
<?php

function userFunction1()
{

    echo("userspace function called with no paramXXX\n");

}

// define a user space function
function userFunction($param, $param2)
{

    echo("userspace function called with two paramXXX\n");
    if (is_numeric($param2)) {
        echo("userspace function called cp1\n");
        $param32 = $param32 * 2;
        echo("PAram3 = " . $param2);
    }

    if (is_a($param2, "Saxon\\XdmNode")) {
        echo("userspace function called cp2\n");
        /*$proc = new Saxon\SaxonProcessor(true);
        $xpath = $proc->newXPathProcessor();
        $xpath->setContextItem($param3);
                $value = $xpath->evaluate("(//*)");*/
        $value = $param2->getStringValue();
        if ($value != null) {
            echo("XdmNode value= " . $value);
            return $param2;
        } else {
            echo("XdmNode value is null!!!");
        }
    }
    echo("userspace function called cp3\n");
    $resulti = "Result of userFunction+" . $param;

    return $resulti;
}

function userFunctionExample($saxon, $proc, $xmlfile, $xslFile)
{
    echo '<b>userFunctionExample:</b><br/>';
    global $resultg;

    $proc->setProperty("extc", "/path-to-module/saxon");
    $saxon->registerPHPFunction("/path-to-module/saxon");
    $proc->setInitialMatchSelectionAsFile($xmlfile);
    $proc->compileFromFile($xslFile);


    $result = $proc->transformToString();
    if ($result != null) {
        echo 'Output=======:' . $result;
    } else {
        echo "Result is null";
        if ($proc->exceptionOccurred()) {
            echo "Exception occurred";
        }
        $errCount = $proc->getExceptionCount();
        for ($i = 0; $i < $errCount; $i++) {
            echo 'Error Message=' . $proc->getErrorMessage($i);
        }
    }

    $proc->clearParameters();
    $proc->clearProperties();

}

/* simple example to show transforming to string */
function exampleSimple1($proc, $xmlfile, $xslFile)
{
    echo '<b>exampleSimple1:</b><br/>';
    $proc->setInitialMatchSelectionAsFile($xmlfile);
    $proc->compileFromFile($xslFile);

    $result = $proc->transformToString();
    if ($result != null) {

        echo 'Output:' . $result;
    } else {
        echo "Result is null";
    }
    $proc->clearParameters();
    $proc->clearProperties();
}

/* simple example to show transforming to file */
function exampleSimple2($proc, $xmlFile, $xslFile)
{
    echo '<b>exampleSimple2:</b><br/>';
    $proc->setInitialMatchSelectionAsFile($xmlFile);
    $proc->compileFromFile($xslFile);
    $filename = "/home/ond1/temp/output1.xml";
    $proc->setOutputFile($filename);
    $proc->transformToFile();

    if (file_exists($filename)) {
        echo "The file $filename exists";
        unlink($filename);
    } else {
        echo "The file $filename does not exist";
    }
    $proc->clearParameters();
    $proc->clearProperties();
}

/* simple example to show importing a document as string and stylesheet as a string */
function exampleSimple3($saxonProc, $proc)
{
    echo '<b>exampleSimple3:</b><br/>';
    $proc->clearParameters();
    $proc->clearProperties();
    $xdmNode = $saxonProc->parseXmlFromString("<doc><b>text value of out</b></doc>");
    if ($xdmNode == null) {
        echo 'xdmNode is null';
        return;
    }
    $proc->setInitialMatchSelection($xdmNode);
    $proc->compileFromString("<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
					    	<xsl:template match='/'>
					    	    <xsl:copy-of select='.'/>
					    	</xsl:template>
					    </xsl:stylesheet>");

    $result = $proc->transformToString();
    echo '<b>exampleSimple3</b>:<br/>';
    if ($result != null) {
        echo 'Output:' . $result;
    } else {
        echo "Result is null";
    }

    $proc->clearParameters();
    $proc->clearProperties();
    unset($xdmNode);
}

function exampleLoopVar($saxonProc, $proc, $xml, $xslt)
{
    $params = array(
        "testparam1" => "testvalue1",
        "testparam2" => "testvalue2",
        "testparam3" => "testvalue3",
    );
    echo '<b>exampleLoopVar:</b><br/>';
    $proc->setInitialMatchSelectionAsFile($xml);
    $proc->compileFromFile($xslt);

    foreach ($params as $name => $value) {
        echo "loop itr";
        $xdmValue = $saxonProc->createAtomicValue(strval($value));
        if ($xdmValue != null) {
            $proc->setParameter($name, $xdmValue);
        } else {
            echo "Xdmvalue is null";
        }
        //unset($xdmValue);
    }
    echo "Before transformToString";
    $result = $proc->transformToString();
    if ($result != null) {
        echo 'Output:' . $result;
    } else {
        echo "Result is null";
    }

    $proc->clearParameters();
    $proc->clearProperties();
}


function exampleParam($saxonProc, $proc, $xmlFile, $xslFile)
{
    echo "\n", '<b>ExampleParamXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxYYYYY:</b><br/>';

    $proc->setInitialMatchSelectionAsFile($xmlFile);
    $proc->compileFromFile($xslFile);
    $xdmvalue = $saxonProc->createAtomicValue(strval("Hello to you"));
    if ($xdmvalue != null) {
        echo "Name of Class ", get_class($xdmvalue), "\n";
        $str = $xdmvalue->getStringValue();
        if ($str != null) {
            echo "XdmValue:" . $str;
        }
        $proc->setParameter('a-param', $xdmvalue);
    } else {
        echo "Xdmvalue is null";
    }
    $result = $proc->transformToString();
    if ($result != null) {
        echo 'Output:' . $result . "<br/>";
    } else {
        echo "Result is NULL<br/>";
    }

    $proc->clearParameters();
    //unset($result);
    echo 'again with a no parameter value<br/>';
    $proc->setProperty('!indent', 'yes');
    $result = $proc->transformToString();

    $proc->clearProperties();
    echo $result;
    echo '<br/>';
    //  unset($result);
    echo 'again with no parameter and no properties value set. This should fail as no contextItem set<br/>';
    $xdmvalue = $saxonProc->createAtomicValue(strval("goodbye to you"));
    $proc->setParameter('a-param', $xdmvalue);

    $result = $proc->transformToString();
    if ($result != null) {
        echo 'Output =' . $result;
    } else {
        echo 'Error in result';
        $errCount = $proc->getExceptionCount();
        for ($i = 0; $i < $errCount; $i++) {
            echo 'Error Message=' . $proc->getErrorMessage($i);
        }
    }
    $proc->clearParameters();
    $proc->clearProperties();

}


function exampleXMLFilterChain($proc, $xmlFile, $xsl1File, $xsl2File, $xsl3File)
{
    echo '<b>XML Filter Chain using setSource</b><br/>';
    $proc->setInitialMatchSelectionAsFile($xmlFile);
    echo '<b>XML Filter Chain using setSource cp0</b><br/>';
    $proc->compileFromFile($xsl1File);
    echo '<b>XML Filter Chain using setSource cp1</b><br/>';
    $xdmValue1 = $proc->transformToValue();
    echo '<b>XML Filter Chain using setSource cp2</b><br/>';
    $proc->compileFromFile($xsl2File);

    $proc->setInitialMatchSelection($xdmValue1);

    unset($xdmValue1);
    $xdmValue1 = $proc->transformToValue();


    $proc->compileFromFile($xsl3File);
    $proc->setInitialMatchSelection($xdmValue1);
    $result = $proc->transformToString();
    if ($result != null) {
        echo 'Output:' . $result;
    } else {
        echo 'Result is null';
        $errCount = $proc->getExceptionCount();
        if ($errCount > 0) {
            for ($i = 0; $i < $errCount; $i++) {
                $errCode = $proc->getErrorCode(intval($i));
                $errMessage = $proc->getErrorMessage(intval($i));
                echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
            }
            $proc->exceptionClear();
        }
    }
    $proc->clearParameters();
    $proc->clearProperties();
}

function exampleXMLFilterChain2($saxonProc, $proc, $xmlFile, $xsl1File, $xsl2File, $xsl3File)
{
    echo '<b>XML Filter Chain using Parameters1</b><br/>';
    $xdmNode = $saxonProc->parseXmlFromFile($xmlFile);
    echo '<b>exampleXMLFilterChain2: XML Filter Chain using Parameters1 cp0</b><br/>';
    if ($xdmNode == NULL) {
        echo 'source node is NULLXXXXXXX';
    }
    $proc->setParameter('node', $xdmNode);
    echo '<b>XML Filter Chain using using Parameters1 cp1</b><br/>';
    $proc->compileFromFile($xsl1File);
    echo '<b>XML Filter Chain using using Parameters1 cp2</b><br/>';
    $xdmValue1 = $proc->transformToValue();
    if ($xdmValue1 == null) {
        echo '<b>XML Filter Chain using using Parameters1 cp3-0 nullYYYYYYY</b><br/>';
    }
    echo '<b>XML Filter Chain using using Parameters1 cp3</b><br/>';
    $errCount = $proc->getExceptionCount();
    if ($errCount > 0) {
        for ($i = 0; $i < $errCount; $i++) {
            $errCode = $proc->getErrorCode(intval($i));
            $errMessage = $proc->getErrorMessage(intval($i));
            echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
        }
        $proc->exceptionClear();
    }
    $proc->clearParameters();
    echo '<b>XML Filter Chain using using Parameters1 cp4</b><br/>';
    $proc->compileFromFile($xsl2File);
    echo '<b>XML Filter Chain using using Parameters1 cp5</b><br/>';
    $proc->setInitialMatchSelection($xdmValue1);
    echo '<b>XML Filter Chain using using Parameters1 cp6</b><br/>';
    $xdmValue1 = $proc->transformToValue();
    $errCount = $proc->getExceptionCount();
    if ($errCount > 0) {
        for ($i = 0; $i < $errCount; $i++) {
            $errCode = $proc->getErrorCode(intval($i));
            $errMessage = $proc->getErrorMessage(intval($i));
            echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
        }
        $proc->exceptionClear();
    }
    $proc->clearParameters();

    $proc->compileFromFile($xsl3File);
    $proc->setParameter('node', $xdmValue1);
    $result = $proc->transformToString();
    if ($result != null) {
        echo 'Output:' . $result;
    } else {
        echo 'Result is null';
        $errCount = $proc->getExceptionCount();
        if ($errCount > 0) {
            for ($i = 0; $i < $errCount; $i++) {
                $errCode = $proc->getErrorCode(intval($i));
                $errMessage = $proc->getErrorMessage(intval($i));
                echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
            }
            $proc->exceptionClear();
        }
    }
    $proc->clearParameters();
    $proc->clearProperties();
}

/* simple example to detect and handle errors from a transformation */
function exampleError1($proc, $xmlFile, $xslFile)
{
    echo '<br/><b>exampleError1:</b><br/>';
    $proc->setInitialMatchSelectionAsFile($xmlFile);
    $proc->compileFromFile($xslFile);
    $result = $proc->transformToString();
    if ($result == NULL) {

        $errCount = $proc->getExceptionCount();
        echo 'Error found. count=' . $errCount . " ";
        if ($errCount > 0) {
            for ($i = 0; $i < $errCount; $i++) {
                $errCode = $proc->getErrorCode(intval($i));
                $errMessage = $proc->getErrorMessage(intval($i));
                echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
            }
            $proc->exceptionClear();
        } else {
            echo '<b>Error not reported correctly</b>';
        }


    }
    echo $result;
    $proc->clearParameters();
    $proc->clearProperties();

}


/* simple example to test transforming without an stylesheet */
function exampleError2($proc, $xmlFile, $xslFile)
{
    echo '<b>exampleError2:</b><br/>';
    $proc->setInitialMatchSelectionAsFile($xmlFile);
    $proc->compileFromFile($xslFile);

    $result = $proc->transformToString();

    if ($result == NULL) {
        $errCount = $proc->getExceptionCount();
        if ($errCount > 0) {
            for ($i = 0; $i < $errCount; $i++) {
                $errCode = $proc->getErrorCode(intval($i));
                $errMessage = $proc->getErrorMessage(intval($i));
                echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
            }
            $proc->exceptionClear();
        }


    }
    echo $result;
    $proc->clearParameters();
    $proc->clearProperties();

}


function testCallFunction($proc, $trans)
{


    echo "Test: testCallFunction:";

    $valueArray = array($proc->createAtomicValue((int)2), $proc->createAtomicValue((int)3));

    $v = $trans->callFunctionReturningValue("/home/ond1/work/svn/latest9.9-saxonc/samples/php/CallFunctionExample.xsl", "{http://localhost/}add", $valueArray);
    if ($v != NULL) {

        $item = $v->getHead();
        if ($item != NULL) {
            if ($item->isAtomic() && ($item->getAtomicValue()->getLongValue() == 5)) {
                echo "Result is true";
            } else {
                echo "Result is false" . $item->getAtomicValue()->getLongValue();
            }

        } else {
            echo "Item is NULL";
            echo $v;
        }
    } else {

        echo "Value is null";


        echo "testCallFunction ======= FAIL ======";
        $errCount = $trans->getExceptionCount();
        if ($errCount > 0) {
            for ($i = 0; $i < $errCount; $i++) {
                $errCode = $trans->getErrorCode(intval($i));
                $errMessage = $trans->getErrorMessage(intval($i));
                echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
            }
            $trans->exceptionClear();
        }
    }


}


function testCallFunction1($proc, $trans)
{


    echo "Test: testCallFunction:";
    $trans->compileFromFile("/home/ond1/work/svn/latest9.9-saxonc/samples/php/CallFunctionExample.xsl");
    $valueArray = array($proc->createAtomicValue((int)2), $proc->createAtomicValue((int)3));

    $v = $trans->callFunctionReturningValue(NULL, "{http://localhost/}add", $valueArray);
    if ($v != NULL) {

        $item = $v->getHead();
        if ($item != NULL) {
            if ($item->isAtomic() && ($item->getAtomicValue()->getLongValue() == 5)) {
                echo "Result is true";
            }

        } else {
            echo "Item is NULL";
            echo $v;
        }
    } else {

        echo "Value is null";


        echo "testCallFunction ======= FAIL ======";
        $errCount = $trans->getExceptionCount();
        if ($errCount > 0) {
            for ($i = 0; $i < $errCount; $i++) {
                $errCode = $trans->getErrorCode(intval($i));
                $errMessage = $trans->getErrorMessage(intval($i));
                echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
            }
            $trans->exceptionClear();
        }
    }


}


function testCallTemplate1($proc, $trans)
{


    echo "Test: testCallTemplate:";
    $trans->compileFromString("/home/ond1/work/svn/latest9.9-saxonc/samples/php/xsl/addition.xsl");
    if ($trans->getExceptionCount() == 0) {
        $a = $proc->createAtomicValue((int)2);
        $b = $proc->createAtomicValue((int)3);
        $valueArray = array("a" => $a, "b" => $b);
        $valueArray["a"] = $a;
        $valueArray["b"] = $b;
        $trans->setProperty("omit-xml-declaration", "true");
        $trans->setInitialTemplateParameters($valueArray);

        $v = $trans->callTemplateReturningValue("/home/ond1/work/svn/latest9.9-saxonc/samples/php/xsl/addition.xsl", "t");
        if ($v != NULL) {

            $item = $v->getHead();
            if ($item != NULL) {
                if ($item->isAtomic() && ($item->getAtomicValue()->getLongValue() == 5)) {
                    echo "Result is true";
                }

            } else {
                echo "Item is NULL";
                echo $v;
            }
        } else {

            echo "Value is null";


            echo "testCallTemplate ======= FAIL ======";
            $errCount = $trans->getExceptionCount();
            if ($errCount > 0) {
                for ($i = 0; $i < $errCount; $i++) {
                    $errCode = $trans->getErrorCode(intval($i));
                    $errMessage = $trans->getErrorMessage(intval($i));
                    echo 'Expected error: Code=' . $errCode . ' Message=' . $errMessage;
                }
                $trans->exceptionClear();
            }
        }
    } else {

        echo "Error found in stylesheet";
    }


}


function testPerformance()
{

// output current PID and number of threads
    $pid = getmypid();
    $child_threads = trim(`ls /proc/{$pid}/task | wc -l`);

    echo "<pre>";
    echo "Process ID :$pid" . PHP_EOL;
    echo "Number of threads: $child_threads" . PHP_EOL;
    echo str_repeat("-", 20) . PHP_EOL;

    $sax = new Saxon\SaxonProcessor(false);
    unset($sax);
    // output number of threads again
    $child_threads = trim(`ls /proc/{$pid}/task | wc -l`) . PHP_EOL;
    echo "Number of threads: $child_threads" . PHP_EOL;


}


/*     $foo_xml = "xml/foo.xml";
     $foo_xsl = "xsl/foo.xsl";
     $baz_xml = "xml/baz.xml";
     $baz_xsl = "xsl/baz.xsl";
     $foo2_xsl = "xsl/foo2.xsl";
     $foo3_xsl = "xsl/foo3.xsl";
     $err_xsl = "xsl/err.xsl";
     $err1_xsl = "xsl/err1.xsl";
     $text_xsl = "xsl/text.xsl";
     $cities_xml = "xml/cities.xml";
     $embedded_xml = "xml/embedded.xml";
     $multidoc_xsl = "xsl/multidoc.xsl";
     $identity_xsl = "xsl/identity.xsl";

     $saxonProc = new Saxon\SaxonProcessor(true);

     $version = $saxonProc->version();
     echo 'Saxon Processor version: '.$version;
     echo '<br/>';
 $proc = $saxonProc->newXslt30Processor();   */
echo '<br/>';
// testCallFunction($saxonProc, $proc);
/*   testCallTemplate1($saxonProc, $proc);
     exampleSimple1($proc, $foo_xml, $foo_xsl);
      echo '<br/>';
       exampleSimple2($proc, "xml/foo.xml", $foo_xsl);
      echo '<br/>';
      exampleSimple3($saxonProc, $proc);
      echo '<br/>';
  exampleLoopVar($saxonProc, $proc, $foo_xml, $foo_xsl);
      exampleParam($saxonProc, $proc, $foo_xml, $foo_xsl);
      exampleError1($proc, $foo_xml, $err_xsl);
      echo '<br/>';
  exampleError2($proc, $foo_xml, $err1_xsl);
      echo '<br/>';
      exampleXMLFilterChain($proc, $foo_xml, $foo_xsl, $foo2_xsl, $foo3_xsl);
      echo '<br/>';
     exampleXMLFilterChain2($saxonProc, $proc, $foo_xml, $foo_xsl, $foo2_xsl, $foo3_xsl);
      echo '<br/>';
      unset($proc);
  unset($saxonproc);*/
testPerformance();


?>
</body>
</html>
