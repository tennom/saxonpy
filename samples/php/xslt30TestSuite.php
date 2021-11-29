<?php 
/*error_reporting(E_ALL|E_STRICT);
ini_set('display_errors', 'on');*/
ini_set('max_execution_time', 300);
$root=pathinfo($_SERVER['SCRIPT_FILENAME']);
define ('BASE_FOLDER', basename($root['dirname']));
define ('SITE_ROOT',    realpath(dirname(__FILE__)));
define ('SITE_URL',    'http://'.$_SERVER['HTTP_HOST'].'/'.BASE_FOLDER);


echo 'BASE_FOLDER'. basename($root['dirname']);
echo '<br/>';
echo 'SITE_ROOT'.    realpath(dirname(__FILE__));
echo '<br/>';
echo 'SITE_URL'.    'http://'.$_SERVER['HTTP_HOST'].'/'.BASE_FOLDER;
echo '<br/>';


 $saved = getenv("LD_LIBRARY_PATH");        // save old value
 $newld = "/usr/local/jet9.0-pro-x86/lib/x86/shared";  // extra paths to add
 if ($saved) { $newld .= ":$saved"; }           // append old paths if any
 putenv("LD_LIBRARY_PATH=$newld");        // set new value

                        // mycommand is loaded using
                        // libs in the new path list
 putenv("LD_LIBRARY_PATH=$saved");  

 $saved = getenv("PATH");        // save old value
 $newld = "/usr/local/jet9.0-pro-x86/bin:/usr/local/jet9.0-pro-x86/profile1.7.0_40/jre";  // extra paths to add
 if ($saved) { $newld .= ":$saved"; }           // append old paths if any
putenv("PATH=$newld");        // set new value
 
                        // mycommand is loaded using
                        // libs in the new path list
 //putenv("PATH=$saved"); 
//phpinfo();



$path = "xslt30-test/";
$catalog = $path."catalog.xml";
$saxon_version = "";

$proc = new SaxonProcessor();
$start = microtime(true);
              $proc->setSourceFile("cat.xml");
                $proc->importStylesheetFile("test.xsl");
                $result = $proc->transformToValue();
 $end = microtime(true);


    echo "Time : " . ($end-$start) . "s\n";
if($result == NULL) {
                      $errCount = $proc->getExceptionCount();
       echo $errCount;    
if($errCount>0){ 
                      echo 'Error: '.$proc->getErrorMessage(0)." code:".$proc->getErrorCode(0);        
                           }
    
   } else {
echo $result;
}
//$proc->clear();
//$proc->close();


function test_set_files ($catalog){ 
	
	$array = array();  
	$attName;
	$attFile;
	if (file_exists($catalog)) {
    	  $xml = simplexml_load_file($catalog);
    	  foreach ($xml->{'test-set'} as $value) {
//	echo "________________".$value->attributes()->name."_________".$value->attributes()->file;
	$attName = $value->attributes()->name;
	$attFile = $value->attributes()->file;
	$array["".$attName] = $attFile;	
      }	
      } else {
        exit('Failed to open '.$catalog);
      }
   return $array;
}

function check_dependency($xml){
	foreach ($xml->children() as $child)
	{
	  $var1 = $child->getName();
	  switch($var1) {
	    case "feature":
		return false;
	    case "spec":
		if(strpos($child->attributes()->{'value'},"XSLT30")!== false){
			return false;			
		}
	  }
	}
	return true;
}

function parse_environment($xml, $path){
	$array = array();
    	  foreach ($xml->{'environment'} as $value) {
		$envName = $value->attributes()->name;
		$source = $value->{'source'};
		if($source->attributes()->file and !($source->attributes()->validation)) {
		//  echo $path.$source->attributes()->file." ";
		  $array["".$envName] = $path.$source->attributes()->file;
		}
      	  }
	echo "<br/>";
	echo "<br/>";
	return $array;
} 

function test_case($test_set) {
	$env;
	$xml;
	$test_path = pathinfo($test_set)['dirname']."/";
	echo $test_path;
	if (file_exists($test_set)) {
    	  $xml = simplexml_load_file($test_set);
	  $env = parse_environment($xml, $test_path);
echo "<table border='1' style='width:60%'>
<tr>
  <th>Test Case Name </th>
  <th style='width:80%'>Result </th>
</tr>";

$check = check_dependency($xml->dependencies);
if($check){
	  foreach($xml->{'test-case'} as $value){
		$testCaseName = $value->attributes()->name;
		echo "<tr><td>$testCaseName</td>";
		$result = run_test_case($value, $env, $test_path);
		echo "<td>".$result."</td>";
		echo "</tr>";
	 	//$test = $value->{'test'}->{'stylesheet'};
		//echo "____test:".$test_path."tests".$test->attributes()->file;
	  }
}else {
echo "<tr><td>No tests run</td><td></td></tr>";
}
echo "</table>";
		
      } else {
        exit('Failed to open '.$test_set);
      }	
}

function run_test_case($testcase, $env, $path){
	global $proc;
	$errorTest = FALSE;
	$t_env = $testcase->{'environment'};
	$testDirValue = new XdmValue(strval($path));
	$t_env_ref = $t_env->attributes()->ref;
	$checkDependency = check_dependency($testcase->dependencies);
	if($checkDependency){
		
			$test = $path.$testcase->{'test'}->{'stylesheet'}->attributes()->file;
			//echo $test;
			if (file_exists($test)) {
				try{
					if($t_env) {
					if($env[$t_env_ref.""]){
						$proc->clear();
						//error_log("before apply source:".$env[$t_env_ref.""]);
						//error_log("before apply stylesheet:".$test);
						$init_template = $testcase->{'test'}->{'initial-template'};
						if($init_template){
							$proc->setProperty('it', strval($testcase->{'test'}->{'initial-template'}->attributes()->{'name'}));
						}
						$result = $proc->xsltApplyStylesheet($env[$t_env_ref.""], $test);
						if($result == NULL) {
							echo 'Error: '.$proc->getErrorMessage(0)." code:".$proc->getErrorCode(0);		
							$errCount = $proc->getExceptionCount();
							$result= "";
							if($errCount > 0 ){
							$result= "<out>";
							  for ($i = 0; $i < $errCount; $i++) {
 							    $errC = $proc->getErrorCode(intval(i));
							     if($errC != NULL) {
							       $result = $result.$errC." ";	
							     }
							  $result= $result."</out>";
						    	  $errorTest = TRUE;
							  }
							}

													
						}

						$asserts= $testcase->{'result'};
						$xdmValue = $proc->parseString(strval($asserts->asXML()));
						/*if($testcase->attributes()->{'name'}=='import-0502b'){
						 	echo "result:".$result;
						 	echo "assert:".($asserts->asXML());
							exit('import-0502b');					
						}*/
						if($xdmValue == NULL){
							error_log("NULL FOUND IN ASSERT");
							if($proc->getExceptionCount() > 0){
								error_log(" assert exception: ".$proc->getErrorMessage(0));
								return "NO ASSERTION".($asserts->asXML());
							}

						}
						$proc->setParameter('', 'assertion', $xdmValue);
						error_log("before result : ");
						$resulti  = $proc->parseString(''.$result);
						if($resulti== NULL) {	
							error_log(" assert exception: ".$proc->getErrorMessage(0));
							return "NULL result";
						}									
						$proc->setParameter('', 'result', $resulti);
						$proc->setParameter('', 'testDir', $testDirValue);
						$proc->setProperty('it', 'main');
						$proc->exceptionClear();
						$outcome = $proc->xsltApplyStylesheet1("TestOutcome.xsl");
						$proc->clear();
						if($outcome==NULL){
							error_log("Assert:".($asserts->asXML()));
							echo "Assert:".($asserts->asXML());
							echo "Assert:".($result);
							$errCount = $proc->getExceptionCount();
							error_log("Error Count".$errCount);
							if($errCount > 0 ){

							$result= "<out>";
							  for ($i = 0; $i < $errCount; $i++) {
 							    $errC = $proc->getErrorMessage(intval(i));
							     if($errC != NULL) {
							       $result = $result.$errC." ";	
							     }
						    	  $errorTest = TRUE;
							  $result= $result."</out>";
							  }

							echo "Error count: ".$errCount.", ". ($result);
							}
							return "false";						
						}
						if($errorTest){
							return 'assert-Error: '.$outcome;						
						}
						$proc->clear();
						return $outcome;						
					}else {
						return 	$t_env_ref." not found";				
					}
					} else { 
						$proc->clear();
						$proc->exceptionClear();
						$init_template = $testcase->{'test'}->{'initial-template'};
						if($init_template){
							$proc->setProperty('it', strval($testcase->{'test'}->{'initial-template'}->attributes()->{'name'}));
						}
						$result = $proc->transformToString($test);
						if($result == NULL) {
							
							$errCount = $proc->getExceptionCount();
							$result= "";
							if($errCount > 0 ){
							$result= "<out>";
							  for ($i = 0; $i < $errCount; $i++) {
 							    $errC = $proc->getErrorCode(intval(i));
							     if($errC != NULL) {
							       $result = $result.$errC." ";	
							     }
							  $result= $result."</out>";
							  }
							}

													
						}
						$asserts= $testcase->{'result'};
						$xdmValue = $proc->parseString(''.$asserts->asXML());
						/*if($testcase->attributes()->{'name'}=='import-0502b'){
						 	echo "result:".$result;
						 	echo "assert:".($asserts->asXML());
							exit('import-0502b');					
						}*/
						if($xdmValue == NULL){	
								error_log(" assert exception: ".$proc->getErrorMessage(0));
								return "NO ASSERTION";
						}					
						$proc->setParameter('', 'assertion', $xdmValue);
						$resulti  = $proc->parseString(''.$result);
						if($resulti== NULL) {
							return "NULL result";		
						}
						$proc->setParameter('', 'result', $resulti);
						$proc->setParameter('', 'testDir',$testDirValue);
						$proc->setProperty('it', 'main');
						$outcome = $proc->transformToString("TestOutcome.xsl");
						$proc->clear();
						if($outcome==NULL){
							echo "Assert:".($asserts->asXML());
							$errCount = $proc->getExceptionCount();
							if($errCount > 0 ){
							$result= "<out>";
							  for ($i = 0; $i < $errCount; $i++) {
 							    $errC = $proc->getErrorMessage(intval(i));
							     if($errC != NULL) {
							       $result = $result.$errC." ";	
							     }
							  $result= $result."</out>";
							  }

							echo "Error count: ".$errCount.", ". ($result);
							}
							return "false";						
						}
						$proc->clear();
						if($outcome== FALSE){
							$resulti = '|| Assertion: '.($asserts->asXML()).'|||| result: '.$resulti.' ||| ';
							return 'assert-Error: '.$outcome;						
						}
						
						return $outcome.'';
					
					}
				}catch(Exception $ex){
					return "Fail - error: ".$ex->getMessage();			
				}
			return "Fail";			
			} else {
				return $test." not found";			
			}		
							
	}

	return "Not Run";
}


$saxon_version = $proc->version();
echo "<a name='top'></a>";
echo "<h1>W3 XSLT 3.0 Test Suite</h1>
<h4>(PHP Test Harness. Version: 1.0. Saxon c++ plugin, Saxon product version: $saxon_version)</h4>
<br/>";
$testFiles = test_set_files($catalog);
echo "<b>Test sets: ".count($testFiles)."<b/>";
echo "<table border='1'>
<tr>
  <th>Test Name </th>
  <th>File Name </th>
  <th> #Test cases </th>
</tr>";

foreach ($testFiles as $key => $test_set) {
 $testSet_xml = simplexml_load_file("xslt30-test/".$test_set);
echo "<tr>";
	echo "<td><a href='#".$key."'>".$key . "</a></td>";
	echo "<td>".$test_set."</td>";
	echo "<td>".count($testSet_xml->{'test-case'})."</td>";
echo "</tr>";
}
echo "</table>";

foreach ($testFiles as $key => $test_set) {
echo "<div style='width:70%'><h4><a name='".$key."'>".$key . "</a></h4></div><div style='width:30%;float:right'><a href='#top'>Back to top</a></div>";
//if($key == 'copy-of'){
 test_case("xslt30-test/".$test_set);}
//}
echo "<br/>";
//$test1 = $proc->xsltApplyStylesheet("cat.xml","test.xsl");

//$proc->xsltSaveResultToFile("cat.xml", "test.xsl", "output/output.html");
                $proc->setSourceFile("cat.xml");
                $proc->importStylesheetFile("test.xsl");
echo $proc->transformToString();
echo "This link is using Html: ";

$proc->close();

?>
