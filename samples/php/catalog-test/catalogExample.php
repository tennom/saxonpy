<!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Saxon/C API design use cases</title>
    </head>
    <body>
        <?php 
 

 $saxonProcessor = new Saxon\SaxonProcessor();
$saxonProcessor->setcwd("/home/ond1/work/svn/latest9.9-saxonc/samples/php/catalog-test/");
 $trace = true;
    
 $processor = $saxonProcessor->newXsltProcessor();
 $saxonProcessor->setCatalog("/home/ond1/work/svn/latest9.9-saxonc/samples/php/catalog-test/catalog.xml", $trace); 


$errCount = $processor->getExceptionCount();
		if($errCount > 0 ){ 
			for($i = 0; $i < $errCount; $i++) {
			       $errCode = $processor->getErrorCode(intval($i));
			       $errMessage = $processor->getErrorMessage(intval($i));
			       echo 'Expected error: Code='.$errCode.' Message='.$errMessage;
					   }
			$trans->exceptionClear();	
		}
   
 $processor->setSourceFromFile('example.xml');
 $processor->compileFromFile('test1.xsl');
 $result = $processor->transformToString();


        ?>
    </body>
</html>
