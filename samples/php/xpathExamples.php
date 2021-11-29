<!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Saxon/C API design use cases</title>
    </head>
    <body>
        <?php 
            
            /* simple example to show xpath singleton evaluation */
            function exampleSimple1($proc, $xpathEngine, $xmlfile){
		 echo '<b>Simple Example - 1 </b><br/>';
                $xpathEngine->setContextFile($xmlfile);
                $resultValue = $xpathEngine->evaluateSingle("/BOOKLIST/BOOKS/ITEM[1]/TITLE/text()");      
                            
		if($resultValue != null) {               
		echo '<b>exampleSimple1:</b><br/>';		
		echo 'Book Title:'.$resultValue->getStringValue();
		} else {
			echo "Result is null";
		}
		$xpathEngine->clearParameters();
		$xpathEngine->clearProperties();            
            }
            
              /* simple example to show xpath singleton evaluation */
           function exampleSimple2($proc, $xpathEngine, $xmlfile){
		 echo '<b>Simple Example - 2 </b><br/>';
                $xpathEngine->setContextFile($xmlfile);
                $resultValue = $xpathEngine->evaluate("/BOOKLIST/BOOKS/ITEM/TITLE/text()");    
                            
		if($resultValue != null) {  
			$count = $resultValue->size();
			echo 'Number of items = '.$count.'<br/>';
			for($i = 0; $i < $count; $i++) {   
				$valuei = $resultValue->itemAt($i+0);          
				echo '<b>Book Title :</b> '.$valuei->getStringValue().'<br/>';		
		
			} 
		}
		$xpathEngine->clearParameters();
		$xpathEngine->clearProperties();            
            }

  /* simple example to show xpath singleton evaluation and conversion to a XdmNode. */
       function exampleSimple3($proc, $xpathEngine){
		 echo '<b>Simple Example - 3 </b><br/>';
		 $sourceNode = $proc->parseXmlFromString("<out attr='valuex'><person attr1='value1' attr2='value2'>text1</person><person>text2</person><person1>text3</person1></out>");
		if($sourceNode == NULL) {
			echo "SourceNode is NULL<br />";
		}
                $xpathEngine->setContextItem($sourceNode);
                $resultValue = $xpathEngine->evaluateSingle("(//person)[1]");      
                            
		if($resultValue != null) {               
			if($resultValue->isNode()) {
				echo "Result is a node <br/>";
				$nodeValue = $resultValue->getNodeValue();
				$nodeKind = $nodeValue->getNodeKind();
				$nodeName = $nodeValue->getNodeName();
				echo "NodeKind : ".$nodeKind." nodeName=".$nodeName;
			} else if($resultValue->isAtomic()) {
				echo "Error: Result is an atomic <br/>";
			}

		} else {
			echo "Result is null";
		}
		$xpathEngine->clearParameters();
		$xpathEngine->clearProperties();            
            }

       /* simple example to show xpath singleton evaluation. Here we test the API on Attributes */
       function exampleSimple4($proc, $xpathEngine){
		 echo '<b>Simple Example - 4 </b><br/>';
		 $sourceNode = $proc->parseXmlFromString("<out attr='valuex'><person firstname='Adam' surname='Jakes'>text1</person><person>text2</person><person1>text3</person1></out>");
		if($sourceNode == NULL) {
			echo "SourceNode is NULL<br />";
		}
                $xpathEngine->setContextItem($sourceNode);
                $resultValue = $xpathEngine->evaluateSingle("(//person)[1]");      
                            
		if($resultValue != null) {               
			if($resultValue->isNode()) {
				echo " Result is a node";
				$nodeValue = $resultValue->getNodeValue();
				$nodeKind = $nodeValue->getNodeKind();
				echo " NodeKind : ".$nodeKind."<br/>";

				$attCount = $nodeValue->getAttributeCount();
				for($i = 0; $i < $attCount; $i++) {
					$attNode = $nodeValue->getAttributeNode($i);
					$attName = $attNode->getNodeName();
					$attVal = $nodeValue->getAttributeValue($attName);
					$nodeKindi = $attNode->getNodeKind();
					echo ' Attribute name='.$attName.' value='.$attVal.', nodeKind='.$nodeKindi.' <br/>';

				}
			} else if($resultValue->isAtomic()) {
				echo "Error: Result is an atomic <br/>";
			}

		} else {
			echo "Result is null";
		}
		$xpathEngine->clearParameters();
		$xpathEngine->clearProperties();            
            }
 
 /* simple example to show xpath singleton evaluation. Convert XdmItem to a XdmNode and test tree navigation */
      function exampleSimple5($proc, $xpathEngine){
		 echo '<b>Simple Example - 5 </b><br/>';
		 $sourceNode = $proc->parseXmlFromString("<out attr='valuex'><person attr1='value1' attr2='value2'>text1</person><person>text2</person><person1>text3</person1></out>");
		if($sourceNode == NULL) {
			echo "SourceNode is NULL<br />";
		}
                $xpathEngine->setContextItem($sourceNode);
                $resultValue = $xpathEngine->evaluateSingle("(/out)");      
                            
		if($resultValue != null) {               
			if($resultValue->isNode()) {
				echo "Result is a node <br/>";
				$nodeValue = $resultValue->getNodeValue();
				$nodeKind = $nodeValue->getNodeKind();
				echo "NodeKind : ".$nodeKind;

				$childCount = $nodeValue->getChildCount();
				for($i = 0; $i < $childCount; $i++) {
					$nodei = $nodeValue->getChildNode($i);
					$namei = $nodei->getNodeName();
					echo ' Node name='.$namei;

				}
			} else if($resultValue->isAtomic()) {
				echo "Error: Result is an atomic <br/>";
			}

		} else {
			echo "Result is null";
		}
		$xpathEngine->clearParameters();
		$xpathEngine->clearProperties();            
            }

 /* simple example to show xpath evaluation and conversion to a XdmNode. */
       function exampleSimple6($proc, $xpathEngine){
		 echo '<b>Simple Example - 6 </b><br/>';
		 $sourceNode = $proc->parseXmlFromString("<out attr='valuex'><person attr1='value1' attr2='value2'>text1</person><person>text2</person><person/><person1>text3</person1></out>");
		if($sourceNode == NULL) {
			echo "SourceNode is NULL<br />";
		}
                $xpathEngine->setContextItem($sourceNode);
                $resultValue = $xpathEngine->evaluate("(//person)");      
                            
		if($resultValue != null) { 
			$nodeCount = $resultValue->size(); 
			for($i = 0; $i<$nodeCount; $i++) {
				$item = $resultValue->itemAt($i);
				if($item->isNode()) {
					$node = $item->getNodeValue();
					
				  if($node->getChildCount()>0) {
						$childNode = $node->getChildNode(0);
					if($childNode instanceof Saxon\XdmNode) {
						echo "child node XdmNode";					
					}
					
					if($childNode == NULL) {
						echo "child node is null XXXX <br/>";					
					}
					$strValue = $childNode->getStringValue();
					if($childNode->isAtomic()) {
						echo 'Child node is Atomic. Value='.$strValue."<br/>";
					} else {				
						echo 'Node Value:'.$strValue.", NodeKind=".$childNode->getNodeKind()."<br/>";
					}
						//Test NodeName
					$nodeNamei = $childNode->getNodeName();
					if($nodeNamei != NULL) {
						echo 'Child node name='.$nodeNamei;				
					} else {
						echo 'Child node is null';			
					}	
				}
					
				}

			}             
			

		} else {
			echo "Result is null";
		}
		$xpathEngine->clearParameters();
		$xpathEngine->clearProperties();            
            }
            
            
            $books_xml = "query/books.xml";
            $books_to_html_xq = "query/books-to-html.xq";
            $baz_xml = "xml/baz.xml";
            $cities_xml = "xml/cities.xml";
            $embedded_xml = "xml/embedded.xml";
            
            $proc = new Saxon\SaxonProcessor(true);
	    $xpath = $proc->newXPathProcessor();
		
            $version = $proc->version();
   	    echo '<b>PHP XPath Examples</b><br/>';
            echo 'Saxon Processor version: '.$version;
            echo '<br/>';        
            exampleSimple1($proc, $xpath, $books_xml);
            echo '<br/>';
            exampleSimple2($proc, $xpath, $books_xml);
            echo '<br/>';
	   exampleSimple3($proc, $xpath);
            echo '<br/>';         
	   exampleSimple4($proc, $xpath);
            echo '<br/>';
	   exampleSimple5($proc, $xpath);
            echo '<br/>';
	    exampleSimple6($proc, $xpath);
            echo '<br/>';
      

//	    $proc->close();
	    unset($xpath);            
            unset($proc);
	
        
        ?>
    </body>
</html>

