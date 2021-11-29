<?php

	    $saxonProc = new Saxon\SaxonProcessor(True);
	  //  $saxonProc->setConfigurationProperty("http://saxon.sf.net/feature/licenseFileLocation", "/home/ond1/work/svn/latest9.9-saxonc/samples/php/saxon-license.lic");
		$saxonProc->setcwd("/home/ond1/work/svn/latest9.9-saxonc/samples/php");
            $transformer = $saxonProc->newXslt30Processor();
   
      echo "TEST-0\n";        
         $xsl = "<?xml version='1.0'?>".
                    "                <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'".
                    "                xmlns:xs='http://www.w3.org/2001/XMLSchema'".
                    "                version='3.0' exclude-result-prefixes='#all'>".
                    "                <xsl:import-schema><xs:schema><xs:element name='x' type='xs:int'/></xs:schema></xsl:import-schema>".
                    "                <xsl:template name='main'>".
                    "                   <xsl:result-document validation='strict'>".
                    "                     <x>3</x>".
                    "                   </xsl:result-document>".
                    "                </xsl:template>".
                    "                </xsl:stylesheet>";

          $transformer->compileFromString($xsl);
          $transformer->setProperty("!omit-xml-declaration", "yes");
	  //$transformer->setProperty("tunnel", "true");
	    $sw = $transformer->callTemplateReturningString("main");
	        
	echo "TEST-1\n";
	if($sw != NULL){        
		echo "Value=".$sw." ---------";
	
	} else {
		/*echo "value is null";
		
		if($transformer->getExceptionCount()>0){
			echo "Error message = ".$transformer->getErrorMessage(0);

		}*/
	}

	echo "\n";

    


?>
