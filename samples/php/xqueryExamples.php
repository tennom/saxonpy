<!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Saxon/C API design use cases</title>
    </head>
    <body>
        <?php 
            
            /* simple example to show transforming to string */   
            function exampleSimple1($proc, $xmlfile, $queryFile){
		echo '<b>exampleSimple1:</b><br/>';
                $proc->setContextItemFromFile($xmlfile);
echo '<b>exampleSimple cp1:</b><br/>';
                $proc->setQueryFile($queryFile);
echo '<b>exampleSimple cp2:</b><br/>';
  	        //$proc->setProperty('base', '/');      
                $result = $proc->runQueryToString();  
echo '<b>exampleSimple cp3:</b><br/>';                       
		if($result != null) {               
				
		echo 'Output:'.$result;
		} else {
			echo "Result is null";
		}
		$proc->clearParameters();
		$proc->clearProperties();            
            }
            
            /* simple example to show transforming to file */
            function exampleSimple2($proc, $xqueryProc){
		$sourceNode = $proc->parseXmlFromString("<foo xmlns='http://one.uri/'><bar><b>text node in example</b></bar></foo>");
		if($sourceNode !=null){
			/*echo "Name of Class " , get_class($sourceNode) , "\n"; 			
			$str = $sourceNode->getStringValue();
			if($str!=null) {
				echo "XdmValue:".$str;
			} */
			$xqueryProc->setContextItem($sourceNode);
		} else {
			echo "Xdmvalue is null";
		}
                $xqueryProc->setQueryContent("declare default element namespace 'http://one.uri/'; /foo");
                $result = $xqueryProc->runQueryToString();
		echo '<b>exampleSimple2:</b><br/>';		
		if($result != null) {               
		  echo 'Output:'.$result;
		} else {
			echo "Result is null";
		}
       		$xqueryProc->clearParameters();
		$xqueryProc->clearProperties();
            }

 /* Test that the XQuery compiler can compile two queries without interference */
            function exampleSimple3($saxonProc){
		echo '<b>exampleSimple3:</b><br/>';
		$queryProc = $saxonProc->newXQueryProcessor();
		//$queryProc2 = $saxonProc->newXQueryProcessor();

		$sourceNode = $saxonProc->parseXmlFromString("<foo xmlns='http://one.uri/'><bar xmlns='http://two.uri'>12</bar></foo>");
		if($sourceNode !=null){
			
			$queryProc->setContextItem($sourceNode);
		} else {
			echo "Xdmvalue is null";
		}
                $queryProc->declareNamespace("", "http://one.uri/");
	        $queryProc->setQueryContent("declare variable \$p as xs:boolean external; exists(/foo) = \$p");

		//$queryProc2->declareNamespace("", "http://two.uri");
		//$queryProc2->setQueryContent("declare variable \$p as xs:integer external; /*/bar + \$p");

		$value1 = $saxonProc->createAtomicValue(true);

		$queryProc->setParameter("p",$value1);
		$resultVal = $queryProc->runQueryToValue();

		if($resultVal != NULL ){
			$itemi =  $resultVal->itemAt(0);
			$isAtomic = $itemi->isAtomic();
			if($isAtomic) {
				$valueb = $itemi->getAtomicValue();
				$resultBool = $valueb->getBooleanValue();
				echo "Test3: Result is atomic, valueStr=".$valueb->getStringValue().", Bool=".strval($resultBool)."<br/>";
	
			} else {
				echo "Test3: Result is not atomic";
			}
	
			unset($itemi);
	        } else {
		    echo "result value is null";
		}
		unset($value1);
		unset($sourceNode);
		//unset($queryProc2);
		unset($queryProc);

	    }

            
            
            $books_xml = "query/books.xml";
            $books_to_html_xq = "query/books-to-html.xq";
            $baz_xml = "xml/baz.xml";
            $cities_xml = "xml/cities.xml";
            $embedded_xml = "xml/embedded.xml";
            
            $proc = new Saxon\SaxonProcessor();
	    $xqueryProc = $proc->newXQueryProcessor();
		
            $version = $proc->version();
   	    echo '<b>PHP XQuery examples</b><br/>';
            echo 'Saxon Processor version: '.$version;
            echo '<br/>';        
            exampleSimple1($xqueryProc, $books_xml, $books_to_html_xq);
            echo '<br/>';
            exampleSimple2($proc, $xqueryProc);
            echo '<br/>';
	    exampleSimple3($proc); //give seg error
            echo '<br/>';               

	    unset($xqueryProc);            
            unset($proc);
	
        
        ?>
    </body>
</html>
