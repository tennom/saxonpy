#include <sstream>
#include <stdio.h>
#include "../../Saxon.C.API/SaxonProcessor.h"
#include "../../Saxon.C.API/XdmValue.h"
#include "../../Saxon.C.API/XdmItem.h"
#include "../../Saxon.C.API/XdmNode.h"
#include "cppExtensionFunction.cpp"
#include "cppTestUnits.h"
#include <string>

// TODO: write test case for checking parameters which are null


using namespace std;
char fname[] = "_nativeCall";
char funcParameters[] = "(Ljava/lang/String;[Ljava/lang/Object;[Ljava/lang/String;)Ljava/lang/Object;";

JNINativeMethod cppMethods[] =
{
    {
         fname,
         funcParameters,
         (void *)&cppNativeCall
    }
};


/*
* Test transform to String. Source and stylesheet supplied as arguments
*/
void testApplyTemplatesString1(Xslt30Processor * trans, sResultCount *sresult){
	
  cout<<endl<<"Test: TransformToString1:"<<endl;
   trans->setInitialMatchSelectionAsFile("cat.xml");
    const char * output = trans->applyTemplatesReturningString("test.xsl");
   if(output == NULL) {
      printf("result is null ====== FAIL ====== \n");
      sresult->failure++;
	 fflush(stdout);
	delete output;
	sresult->failureList.push_back("testApplyTemplatesString1-0");
	return;
    }else if (string(output).find(string("<out>text2</out>")) != std::string::npos) {
      //printf("%s", output);
      printf("result is OK \n");
      sresult->success++;
    } else {
      printf("result is null ====== FAIL ====== \n");
      sresult->failure++;
      sresult->failureList.push_back("testApplyTemplatesString1-1");
//	std::cout<<"output="<<output<<std::endl;
	}
      fflush(stdout);
	delete output;

}

/*
* Test transform to String. Source and stylesheet supplied as arguments
*/
void testTransformToStringExtensionFunc(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){
	
  cout<<endl<<"Test: TransformToStringExtensionFunc:"<<endl;
trans->setProperty("extc", "home/ond1/work/svn/latest9.9-saxonc/samples/cppTests/cppExtensionFunction");

bool nativeFound = processor->registerNativeMethods(SaxonProcessor::sxn_environ->env, "com/saxonica/functions/extfn/cpp/NativeCall",
    cppMethods, sizeof(cppMethods) / sizeof(cppMethods[0]));
if(nativeFound) {
    const char * output = trans->transformFileToString("cat.xml", "testExtension.xsl");
//XdmValue* output = trans->transformFileToValue("cat.xml", "testExtension.xsl");
   if(output == NULL) {
	SaxonProcessor::sxn_environ->env->ExceptionDescribe();
      printf("result is null ====== FAIL ======  \n");
     sresult->failureList.push_back("testTransformToStringExnteionFunc");
    }else {
      //printf("%s", output);
      printf("result is OK \n");
    }
      fflush(stdout);
	delete output;
} else{
    printf("native Class not foun ====== FAIL ====== ");
    sresult->failureList.push_back("testTransformToStringExtensionFunc");
}
}



/*
* Test transform to String. stylesheet supplied as argument. Source supplied as XdmNode
*/
void testApplyTemplatesString2(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){

  cout<<endl<<"Test: TransformToString2:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * input = processor->parseXmlFromFile("cat.xml");

   if(input == NULL) {
	cout<<"Source document is null."<<endl;

    }

     trans->setInitialMatchSelection((XdmValue*)input);
    const char * output = trans->applyTemplatesReturningString("test.xsl");
   if(output == NULL) {
      printf("result is null ====== FAIL ======  \n");
	sresult->failureList.push_back("testApplyTemplatesString2");
    }else {
      printf("%s", output);
      printf("result is OK \n");
    }
      fflush(stdout);
    delete output;
}

/*
* Test transform to String. stylesheet supplied as argument. Source supplied as XdmNode
Should be error. Stylesheet file does not exist
*/
void testApplyTemplates2a(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){

  cout<<endl<<"Test: TransformToString2a:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * input = processor->parseXmlFromFile("cat.xml");

   if(input == NULL) {
	cout<<"Source document is null. ====== FAIL ======"<<endl;
	sresult->failure++;
	sresult->failureList.push_back("testApplyTemplates2a");
	return;
    } else {

     trans->setInitialMatchSelection((XdmValue*)input);
    }  
  const char * output = trans->applyTemplatesReturningString("test-error.xsl");
   if(output == NULL) {
      printf("result is null \n");
      sresult->success++;
    }else {
      printf("%s", output);
      printf("result is OK - ======= FAIL ======= \n");
	sresult->failure++;
	sresult->failureList.push_back("testApplyTemplates2a");
    }
      fflush(stdout);
    delete output;
	
	

}

/*
* Test transform to String. stylesheet supplied as argument. Source supplied as XdmNode
Should be error. Source file does not exist
*/
void testTransformToString2b(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){

  cout<<endl<<"Test: TransformToString2b:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * input = processor->parseXmlFromFile("cat-error.xml");

   if(input == NULL) {
	cout<<"Source document is null. ====== FAIL ====== "<<endl;
	sresult->failureList.push_back("testTransformToString2b");
	return;
    }

     trans->setInitialMatchSelection((XdmNode*)input);
    const char * output = trans->transformFileToString(NULL, "test-error.xsl");
   if(output == NULL) {
      printf("result is null ====== FAIL ======  \nCheck For errors:");
	sresult->failureList.push_back("testTransformToString2b");
      if(trans->exceptionCount()>0) {
	cout<<trans->getErrorMessage(0)<<endl;
      }	
    }else {
      printf("%s", output);
      printf("result is OK \n");
    }
      fflush(stdout);
    delete output;
	
    trans->exceptionClear();

}


/*
* Test transform to String. stylesheet supplied as argument. Source supplied as xml string
and integer parmater created and supplied
*/
void testTransformToString3(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){

  cout<<endl<<"Test: TransformToString3:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * inputi = processor->parseXmlFromString("<out><person>text1</person><person>text2</person><person>text3</person></out>");

   XdmAtomicValue * value1 = processor->makeIntegerValue(10);

   trans->setParameter("numParam",(XdmValue *)value1);

   if(inputi == NULL) {
	cout<<"Source document inputi is null. ====== FAIL ====== "<<endl;
	sresult->failureList.push_back("testTransformToString3");
	return;
    }

    trans->setInitialMatchSelection((XdmNode*)inputi);
    const char * output = trans->applyTemplatesReturningString("test.xsl");
   if(output == NULL) {
      printf("result is null ====== FAIL ====== \n");
	sresult->failureList.push_back("testTransformToString3");
    }else {
      printf("%s", output);
      printf("result is OK \n");
    }
      fflush(stdout);
   delete output;

}

/*
* Test transform to String. stylesheet supplied as argument. Source supplied as xml string
and integer parmater created and supplied
*/
void testTransformToString4(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){

  cout<<endl<<"Test: TransformToString4:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * input = processor->parseXmlFromString("<out><person>text1</person><person>text2</person><person>text3</person></out>");

   XdmValue * values = new XdmValue(processor);
   values->addXdmItem((XdmItem*)processor->makeIntegerValue(10));
  values->addXdmItem((XdmItem*)processor->makeIntegerValue(5));
  values->addXdmItem((XdmItem*)processor->makeIntegerValue(6));
  values->addXdmItem((XdmItem*)processor->makeIntegerValue(7));
   
   trans->setParameter("values",(XdmValue *)values);

   if(input == NULL) {
	cout<<"Source document is null. ====== FAIL ====== "<<endl;
sresult->failureList.push_back("testTransformToString4");
    }
XdmNode * sheet = processor->parseXmlFromFile("test2.xsl");
    trans->setInitialMatchSelection((XdmNode*)input);
	trans->compileFromXdmNode(sheet);
    const char * output = trans->applyTemplatesReturningString(NULL/*"test2.xsl"*/);
   if(output == NULL) {
      printf("result is null \n");
	sresult->failureList.push_back("testTransformToString4");
    }else {
      printf("%s", output);
      printf("result is OK \n");
    }
      fflush(stdout);
    delete output;

}

void testTransformFromstring(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){
cout<<endl<<"Test: testTransfromFromstring:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * input = processor->parseXmlFromString("<out><person>text1</person><person>text2</person><person>text3</person></out>");

   trans->compileFromString("<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>       <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out></xsl:for-each></output></xsl:template></xsl:stylesheet>");

 const char * output = trans->transformToString((XdmNode*)input);
   if(output == NULL) {
      printf("result is null ====== FAIL ====== \n");
sresult->failureList.push_back("testTransformFromString");
    }else {
      printf("%s", output);
      printf("result is OK \n");

    }
      fflush(stdout);
    delete output;


}

//Test case has error in the stylesheet
void testTransformFromstring2Err(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){
cout<<endl<<"Test: testTransfromFromstring2-Error:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();
    XdmNode * input = processor->parseXmlFromString("<out><person>text1</person><person>text2</person><person>text3</person></out>");

   trans->compileFromString("<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>       <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out><xsl:for-each></output></xsl:template><xsl:stylesheet>");
trans->setInitialMatchSelection((XdmValue*)input);
 const char * output = trans->applyTemplatesReturningString();
  if(output == NULL) {
      printf("result is null ====== FAIL ======  \n\nCheck For errors:\n");
	sresult->failureList.push_back("testTransformFromstring2Err");
      if(trans->exceptionCount()>0) {
	cout<<"Error count="<<trans->exceptionCount()<<", "<<trans->getErrorMessage(0)<<endl;
     }	
    }else {
      printf("%s", output);
      printf("result is OK \n");
    }
    fflush(stdout);
    delete output;

   trans->exceptionClear();


}

void testTrackingOfValueReference(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){
  trans->clearParameters(true);
  trans->clearProperties();
 cout<<endl<<"Test: TrackingOfValueReference:"<<endl;
ostringstream test;
ostringstream valStr;
ostringstream name;
	for(int i=0; i<10; i++){
		test<<"v"<<i;
		valStr<<"<out><person>text1</person><person>text2</person><person>text3</person><value>"<<test.str()<<"</value></out>";
		name<<"value"<<i;
		
		XdmValue * values = (XdmValue*)processor->parseXmlFromString(valStr.str().c_str());
		//cout<<"Name:"<<name.str()<<", Value:"<<values->getHead()->getStringValue()<<endl;
		trans->setParameter(name.str().c_str(), values);
		test.str("");
		valStr.str("");
		name.str("");
	}
	
	std::map<std::string,XdmValue*> parMap = trans->getParameters();
	if(parMap.size()>0) {
cout<<"Parameter size: "<<parMap.size()<<endl;
	cout<<"Parameter size: "<<parMap.size()<<endl;//", Value:"<<trans->getParameters()["value0"]->getHead()->getStringValue()<<endl;
ostringstream name1;
	for(int i =0; i < 10;i++){
		name1<<"param:value"<<i;
		cout<<" i:"<<i<<" Map size:"<<parMap.size()<<", ";
		XdmValue * valuei = parMap[name1.str()];
		if(valuei != NULL ){
			cout<<name1.str();
			if(valuei->itemAt(0) != NULL)
				cout<<"= "<<valuei->itemAt(0)->getStringValue();
			cout<<endl;
		} else {
			sresult->failure++;
			std::cerr<<"trackingValueReference ====== FAIL ======"<<std::endl;
			sresult->failureList.push_back("testTrackingOfValueReference");
		}
		name1.str("");
	}
	}
	sresult->success++;
}

/*Test case should be error.*/
void testTrackingOfValueReferenceError(SaxonProcessor * processor, Xslt30Processor * trans, sResultCount * sresult){
  trans->clearParameters(true);
  trans->clearProperties();
 cout<<endl<<"Test: TrackingOfValueReference-Error:"<<endl;
cout<<"Parameter Map size: "<<(trans->getParameters().size())<<endl;
ostringstream test;
ostringstream valStr;
ostringstream name;
	for(int i=0; i<10; i++){
		test<<"v"<<i;
		valStr<<"<out><person>text1</person><person>text2</person><person>text3</person><value>"<<test.str()<<"<value></out>";
		name<<"value"<<i;
		
		XdmValue * values = (XdmValue*)processor->parseXmlFromString(valStr.str().c_str());
		trans->setParameter(name.str().c_str(), values);
		test.str("");
		valStr.str("");
		name.str("");
	}
	std::map<std::string,XdmValue*> parMap = trans->getParameters();
cout<<"Parameter Map size: "<<parMap.size()<<endl;
	
ostringstream name1;
	bool errorFound = false;
	for(int i =0; i < 10;i++){
		name1<<"param:value"<<i;
		cout<<" i:"<<i<<" Map size:"<<parMap.size()<<", ";
		 try {
		XdmValue * valuei = parMap.at(name1.str());
		if(valuei != NULL ){
			cout<<name1.str();
			if(valuei->itemAt(0) != NULL)
				cout<<"= "<<valuei->itemAt(0)->getStringValue();
			cout<<endl;
		}
		} catch(const std::out_of_range& oor) {
			cout<< "Out of range exception occurred. Exception no. "<<endl;	
			if(!errorFound){
				sresult->success++;
				errorFound = true;
					
				return;		
			}
		}
		name1.str("");
	}
	sresult->failure++;
	sresult->failureList.push_back("testTrackingOfValueReferenceError");
	
}

void testValidation(Xslt30Processor * trans, sResultCount * sresult){
 trans->clearParameters(true);
  trans->clearProperties();


trans->compileFromString("<?xml version='1.0'?><xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'                 xmlns:xs='http://www.w3.org/2001/XMLSchema' version='3.0' exclude-result-prefixes='#all'>     <xsl:import-schema><xs:schema><xs:element name='x' type='xs:int'/></xs:schema></xsl:import-schema> <xsl:template name='main'>          <xsl:result-document validation='strict'> <x>3</x>   </xsl:result-document>    </xsl:template>    </xsl:stylesheet>");

	  const char * rootValue = trans->callTemplateReturningString(NULL, "main");


	if(rootValue == NULL) {
		std::cout<<"NULL found"<<std::endl;
		sresult->failure++;
		sresult->failureList.push_back("testValidation");
		return;

	} else {
		std::cout<<"Result="<<rootValue<<endl;
		sresult->success++;
	}
}


void testXdmNodeOutput(Xslt30Processor * trans, sResultCount * sresult){
 trans->clearParameters(true);
  trans->clearProperties();

	std::cout<<"testXdmNodeOutput"<<std::endl;
  trans->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template name='go'><a/></xsl:template></xsl:stylesheet>");
	  XdmValue * rootValue = trans->callTemplateReturningValue(NULL, "go");
	if(rootValue == NULL){
			cout<<"Result is null ====== FAIL ====== "<<endl;
			sresult->failure++;
			sresult->failureList.push_back("testXdmNodeOutput-0.0");
			return;
	}
            XdmItem * rootItem = rootValue->getHead();
	     if(rootItem == NULL) {  
		             
			cout<<"Result is null ====== FAIL ====== "<<endl;
			sresult->failure++;
			sresult->failureList.push_back("testXdmNodeOutput-0");
			return;
		} 
		XdmNode *root = (XdmNode*)rootItem; 
               if(root->getNodeKind() == DOCUMENT){
		   cout<<"Result is a Document"<<endl;
		} else {
			cout<<"Node is of kind:"<<root->getNodeKind()<<endl;
		}
		const char * result = trans->callTemplateReturningString(NULL, "go");
		if(string(result).find(string("<a/>")) != std::string::npos) {
			sresult->success++;
		} else {
			//TODO - this test case prints the XML declaration. Check if this correct
			sresult->failure++;
			cout<<"testXdmNodeOutputAndString ======= FAIL========"<<endl;
			sresult->failureList.push_back(result);
		}
  trans->clearProperties();
		
}

void exampleSimple1(Xslt30Processor  *proc, sResultCount *sresult){
		cout<<"ExampleSimple1 taken from PHP:"<<endl;
                proc->setInitialMatchSelectionAsFile("../php/xml/foo.xml");
                proc->compileFromFile("../php/xsl/foo.xsl");
  	              
                const char *result = proc->applyTemplatesReturningString();               
		if(result != NULL) {               
			cout<<result<<endl;
			sresult->success++;
		} else {
			cout<<"Result is null ====== FAIL ====== "<<endl;
			sresult->failure++;
		}
		proc->clearParameters(true);
		proc->clearProperties();            
            }

void exampleSimple1Err(Xslt30Processor  *proc, sResultCount *sresult){
		cout<<"ExampleSimple1 taken from PHP:"<<endl;
                proc->setInitialMatchSelectionAsFile("cat.xml");
                proc->compileFromFile("err.xsl");
  	              
                const char *result = proc->applyTemplatesReturningString();               
		if(result != NULL) {               
			cout<<result<<endl;
			sresult->failure++;
			sresult->failureList.push_back("exampleSimple1Err");
		} else {
			cout<<"Result expected as null "<<endl;
			sresult->success++;
		}
		proc->clearParameters(true);
		proc->clearProperties();            
            }

int exists(const char *fname)
{
    FILE *file;
    file = fopen(fname, "r");
    if (file)
    {
        fclose(file);
        return 1;
    }
    return 0;
}


  void exampleSimple2(Xslt30Processor  *proc, sResultCount *sresult){
		cout<<"<b>exampleSimple2:</b><br/>"<<endl;
		//proc->setcwd("");
                proc->setInitialMatchSelectionAsFile("../php/xml/foo.xml");
		
                proc->compileFromFile("../php/xsl/foo.xsl");
                const char * filename = "output1.xml";
		proc->setOutputFile(filename);
                proc->applyTemplatesReturningFile(NULL, "output1.xml");
				
		if (exists("output1.xml")) {
		    cout<<"The file $filename exists"<<endl;
		   remove("output1.xml");
		   sresult->success++;
		} else {
		    cout<<"The file "<<filename<<" does not exist"<<endl;
		    if(proc->exceptionCount()>0) {
            		cout<<proc->getErrorMessage(0)<<endl;
             	    }
		    sresult->failure++;
			sresult->failureList.push_back("exampleSimple2");
		}
       		proc->clearParameters(true);
		proc->clearProperties();
            }

void exampleSimple3(SaxonProcessor * saxonProc, Xslt30Processor  *proc, sResultCount *sresult){
		cout<<"<b>exampleSimple3:</b><br/>"<<endl;
		proc->clearParameters(true);
		proc->clearProperties();
                XdmNode * xdmNode = saxonProc->parseXmlFromString("<doc><b>text value of out</b></doc>");
		if(xdmNode == NULL) {
			cout<<"Error: xdmNode is null'"<<endl;
			sresult->failure++;
			sresult->failureList.push_back("exampleSimple3");
			return;	
		}            
		proc->setInitialMatchSelection((XdmNode*)xdmNode);
		cout<<"end of exampleSimple3"<<endl;
		proc->clearParameters(true);
		proc->clearProperties();
		sresult->success++;
}

void exampleParam(SaxonProcessor * saxonProc, Xslt30Processor  *proc, sResultCount *sresult){
                cout<< "\nExampleParam:</b><br/>"<<endl;
		proc->setInitialMatchSelectionAsFile("../php/xml/foo.xml");
                proc->compileFromFile("../php/xsl/foo.xsl");
            
		XdmAtomicValue * xdmvalue = saxonProc->makeStringValue("Hello to you");
		if(xdmvalue !=NULL){
			
			proc->setParameter("a-param", (XdmValue*)xdmvalue);
			sresult->failure++;
			sresult->failureList.push_back("examplePara-0");
		} else {
			cout<< "Xdmvalue is null - ====== FAIL ====="<<endl;
			sresult->failure++;
			sresult->failureList.push_back("exampleParam-1");
		}
                const char * result = proc->applyTemplatesReturningString();
		if(result != NULL) {                
			cout<<"Output:"<<result<<endl;
			sresult->success++;
		} else {
			cout<<"Result is NULL<br/>  ======= fail ====="<<endl;
			sresult->failure++;
			sresult->failureList.push_back("exampleParam-2");
		}
               
                //proc->clearParameters();                
                //unset($result);
                //echo 'again with a no parameter value<br/>';
		
		proc->setProperty("!indent", "yes"); 
                const char *result2 = proc->applyTemplatesReturningString();
               
                proc->clearProperties();
		if(result2 != NULL) {                
			cout<<result2<<endl;
			sresult->success++;
		}
               
              //  unset($result);
               // echo 'again with no parameter and no properties value set. This should fail as no contextItem set<br/>';
                XdmAtomicValue * xdmValue2 = saxonProc->makeStringValue("goodbye to you");
		proc->setParameter("a-param", (XdmValue*)xdmValue2);
		
                const char *result3 = proc->applyTemplatesReturningString();   
		if(result3 != NULL) {             
                	cout<<"Output ="<<result3<<endl;
			sresult->success++;
		} else {
			cout<<"Error in result ===== FAIL ======="<<endl;
			sresult->failure++;
			sresult->failureList.push_back("exampleParam");
		}
		proc->clearParameters();
		proc->clearProperties(); 
                        
            }


/* XMarkbench mark test q12.xsl with just-in-time=true*/
void xmarkTest1(Xslt30Processor  *proc, sResultCount * sresult){
		cout<<"XMarkbench mark test q12.xsl (JIT=true):"<<endl;

        proc->setJustInTimeCompilation(true);

        XdmValue *result = proc->transformFileToValue("xmark100k.xml", "q12.xsl");
		if(result != NULL) {
			cout<<"XdmNode returned"<<endl;
			sresult->success++;
		} else {
			 printf("result is null \nCheck For errors:");
			sresult->failure++;
			sresult->failureList.push_back("xmarkTest1");
             if(proc->exceptionCount()>0) {
            	cout<<proc->getErrorMessage(0)<<endl;
             }
		}
		proc->clearParameters(true);
		proc->clearProperties();

 }



 /* XMarkbench mark test q12.xsl with just-in-time=true*/
 void xmarkTest2(Xslt30Processor  *proc, sResultCount *sresult){
 		cout<<"XMarkbench mark test q12.xsl (JIT=true):"<<endl;


         XdmValue *result = proc->transformFileToValue("xmark100k.xml", "q12.xsl");
 		if(result != NULL) {
 			cout<<"XdmNode returned"<<endl;
 		} else {
 			 printf("result is null \nCheck For errors:");
			sresult->failure++;
			sresult->failureList.push_back("xmarkTest2");
              if(proc->exceptionCount()>0) {
             	cout<<proc->getErrorMessage(0)<<endl;
              }
 		}
 		proc->clearParameters(true);
 		proc->clearProperties();

  }

/* XMarkbench mark test q12.xsl with just-in-time=true*/
void exampleSimple_xmark(Xslt30Processor  *proc, sResultCount *sresult){
		cout<<"XMarkbench mark test q12.xsl:"<<endl;

        proc->setJustInTimeCompilation(true);

        XdmValue *result = proc->transformFileToValue("xmark100k.xml", "q12.xsl");
		if(result != NULL) {
			cout<<"XdmNode returned"<<endl;
		} else {
			 printf("result is null \nCheck For errors:");
             if(proc->exceptionCount()>0) {
            	cout<<proc->getErrorMessage(0)<<endl;
             }
		}
		proc->clearParameters(true);
		proc->clearProperties();

 }


/*
* Test saving nd loading a Xslt package
*/
void testPackage1(Xslt30Processor * trans, sResultCount *sresult){

  cout<<endl<<"Test: Saving and loading Packages:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();

    trans->compileFromFileAndSave("test.xsl", "test1.sef");
     const char * output = trans->transformFileToString("cat.xml","test1.sef");	
   if(output == NULL) {
      printf("result is null \n");
	const char * message = trans->checkException();
        if(message != NULL) {
		cout<<"Error message =" << message<< endl;
	}
	sresult->failure++;
	sresult->failureList.push_back("testPackage1");

    }else {
      printf("%s", output);
      printf("result is OK \n");
      sresult->success++;
    }
      fflush(stdout);
    delete output;
}


/*
* Test saving and loading a Xslt package
*/
void testPackage2(Xslt30Processor * trans, sResultCount * sresult){

  cout<<endl<<"Test: Saving and loading Packages2 - Error:"<<endl;
  trans->clearParameters(true);
  trans->clearProperties();

	const char * stylesheet = "<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>       <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out><xsl:for-each></output></xsl:template><xsl:stylesheet>";

    trans->compileFromStringAndSave(stylesheet, "test2.sef");
     const char * output = trans->transformFileToString("cat.xml","test2.sef");	
   if(output == NULL) {
      printf("result is null as expected \n");
	const char * message = trans->checkException();
        if(message != NULL) {
		cout<<"Error message =" << message<< endl;
	}
	sresult->success++;
    }else {
      printf("%s", output);
      printf("result is OK \n");
      sresult->failure++;
      sresult->failureList.push_back("testPackage2");
    }
      fflush(stdout);
    delete output;
}

 void testCallFunction(SaxonProcessor * proc, Xslt30Processor * trans, sResultCount * sresult){ 
           
           const char* source = "<?xml version='1.0'?> <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:f='http://localhost/' version='3.0'> <xsl:function name='f:add' visibility='public'>    <xsl:param name='a'/><xsl:param name='b'/> <xsl:sequence select='$a + $b'/></xsl:function></xsl:stylesheet>";
	    cout<<endl<<"Test: testCallFunction:"<<endl;
            trans->compileFromString(source);
		XdmValue ** valueArray =new XdmValue*[2];

		valueArray[0] = (XdmValue*)(proc->makeIntegerValue(2));
		valueArray[1] = (XdmValue*)(proc->makeIntegerValue(3));
            XdmValue *v = NULL;//TODO fix trans->callFunctionReturningValue(NULL, "{http://localhost/}add", valueArray);
		
            if(v != NULL && (v->getHead())->isAtomic() && ((XdmAtomicValue*) (v->getHead()))->getLongValue()==5){
		sresult->success++;
	    } else {
		if(v!= NULL && !(v->getHead())->isAtomic()) {
			cout<<"Value in callFunction is not atomic - but expected as atomic value"<<endl;
		}
		cout<<"testCallFunction ======= FAIL ======"<<endl;
		const char * message = trans->checkException();
        	if(message != NULL) {
		  cout<<"Error message =" << message<< endl;
		}
		sresult->failure++;
		sresult->failureList.push_back("testCallFunction");
		}
		delete valueArray[0];
		delete valueArray[1];
		delete valueArray;
    }

void testInitialTemplate(SaxonProcessor * proc, Xslt30Processor * trans, sResultCount * sresult) {


    const char* source = "<?xml version='1.0'?>  <xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'  xmlns:xs='http://www.w3.org/2001/XMLSchema'  version='3.0'>  <xsl:template match='*'>     <xsl:param name='a' as='xs:double'/>     <xsl:param name='b' as='xs:float'/>     <xsl:sequence select='., $a + $b'/>  </xsl:template>  </xsl:stylesheet>";
cout<<endl<<"Test:testInitialTemplate"<<endl;
    trans->compileFromString(source);
    XdmNode * node = proc->parseXmlFromString("<e/>");

    trans->setResultAsRawValue(false);
std::map<std::string,XdmValue*> parameterValues;
 parameterValues["a"] = proc->makeIntegerValue(12);
parameterValues["b"] = proc->makeIntegerValue(5);
    trans->setInitialTemplateParameters(parameterValues, false);
    trans->setInitialMatchSelection(node);
    XdmValue * result = trans->applyTemplatesReturningValue();
 if(result != NULL){
	sresult->success++;
	cout<<"Result="<<result->getHead()->getStringValue()<<endl;
} else {
	sresult->failure++;
}

}

void testResolveUri(SaxonProcessor * proc, Xslt30Processor * trans, sResultCount * sresult) {
 cout<<endl<<"Test: testResolveUri:"<<endl;
 
trans->compileFromString("<xsl:stylesheet version='3.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:err='http://www.w3.org/2005/xqt-errors'><xsl:template name='go'><xsl:try><xsl:variable name='uri' as='xs:anyURI' select=\"resolve-uri('notice trailing space /out.xml')\"/> <xsl:message select='$uri'/><xsl:result-document href='{$uri}'><out/></xsl:result-document><xsl:catch><xsl:sequence select=\"'$err:code: ' || $err:code  || ', $err:description: ' || $err:description\"/></xsl:catch></xsl:try></xsl:template></xsl:stylesheet>");


            XdmValue * value = trans->callTemplateReturningValue(NULL, "go");


		if(value == NULL) {

			sresult->failure++;
			sresult->failureList.push_back("testResolveUri");
		} else {
		            	
		const char * svalue = value->itemAt(0)->getStringValue();
		cout<<"testResolveUri = "<<svalue<<endl;
		sresult->success++;
		}

	

}

void testContextNotRoot(SaxonProcessor * proc, Xslt30Processor * trans, sResultCount * sresult) {
        cout<<endl<<"Test: testContextNotRoot"<<endl;
 
     XdmNode * node = proc->parseXmlFromString("<doc><e>text</e></doc>");

     trans->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template match='e'>[<xsl:value-of select='name($x)'/>]</xsl:template></xsl:stylesheet>");
	trans->setGlobalContextItem(node);				
    if(node->getChildCount()>0){
      	    XdmNode * eNode = node->getChildren()[0]->getChildren()[0];
		cout<<"Node content = "<<eNode->toString()<<endl;
	    trans->setInitialMatchSelection(eNode);
            const char* result = trans->applyTemplatesReturningString();
		
            if(result == NULL) {

		cout<<"testCallFunction ======= FAIL ======"<<endl;
		const char * message = trans->checkException();
        	if(message != NULL) {
		  cout<<"Error message =" << message<< endl;
		}
			sresult->failure++;
			sresult->failureList.push_back("testContextNotRoot");
		} else {
		            	
		cout<<"testContextNotRoot = "<<result<<endl;
		sresult->success++;
		}
       }
    }




void testContextNotRootNamedTemplate(SaxonProcessor * proc, Xslt30Processor * trans, sResultCount * sresult) {
        cout<<endl<<"Test: testContextNotRootNamedTemplate"<<endl;
 
     XdmNode * node = proc->parseXmlFromString("<doc><e>text</e></doc>");

     trans->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template name='main'>[<xsl:value-of select='name($x)'/>]</xsl:template></xsl:stylesheet>");
	trans->setGlobalContextItem(node);				
            const char* result = trans->callTemplateReturningString(NULL, "main");
		
            if(result == NULL) {

		cout<<"testCallFunction ======= FAIL ======"<<endl;
		const char * message = trans->checkException();
        	if(message != NULL) {
		  cout<<"Error message =" << message<< endl;
		}
			sresult->failure++;
			sresult->failureList.push_back("testContextNotRootNamedTemplate");
		} else {
		            	
		cout<<"testContextNotRoot = "<<result<<endl;
		sresult->success++;
		}
       
    }



void testContextNotRootNamedTemplateValue(SaxonProcessor * proc, Xslt30Processor * trans, sResultCount * sresult) {
        cout<<endl<<"Test: testContextNotRootNamedTemplateValue"<<endl;
 
     XdmNode * node = proc->parseXmlFromString("<doc><e>text</e></doc>");

     trans->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:variable name='x' select='.'/><xsl:template match='/'>errorA</xsl:template><xsl:template name='main'>[<xsl:value-of select='name($x)'/>]</xsl:template></xsl:stylesheet>");
	trans->setGlobalContextItem(node);				
            XdmValue * result = trans->callTemplateReturningValue(NULL, "main");
		
            if(result == NULL) {

		cout<<"testCallFunction ======= FAIL ======"<<endl;
		const char * message = trans->checkException();
        	if(message != NULL) {
		  cout<<"Error message =" << message<< endl;
		}
			sresult->failure++;
			sresult->failureList.push_back("testContextNotRootNamedTemplateValue");
		} else {
		            	
		cout<<"testContextNotRoot = "<<result->getHead()->getStringValue()<<endl;
		sresult->success++;
		}
       
    }


void testPipeline(SaxonProcessor * proc, sResultCount * sresult){
  cout<<endl<<"Test: testPipeline"<<endl;
 
	 Xslt30Processor * stage1 = proc->newXslt30Processor();
          stage1->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>");
          XdmNode * inn = proc->parseXmlFromString("<z/>");

          Xslt30Processor * stage2 = proc->newXslt30Processor();
          stage2->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>");


	if(stage2->exceptionCount()>0){
		const char * message = stage2->getErrorMessage(0);
		cout<<"exception-CP0="<< message<<endl;
	    }
/*
	  Xslt30Processor * stage3 = proc->newXslt30Processor();
          stage3->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>");

	  Xslt30Processor * stage4 = proc->newXslt30Processor();
	  stage4->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>");

	  Xslt30Processor * stage5 = proc->newXslt30Processor();
          stage5->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'><xsl:template match='/'><a><xsl:copy-of select='.'/></a></xsl:template></xsl:stylesheet>");
*/
	  stage1->setProperty("!indent", "no");
	  stage1->setInitialMatchSelection(inn);

          XdmValue * d1 = stage1->applyTemplatesReturningValue();
	   if(stage1->exceptionCount()>0){
		cout<<"Exception message="<<(stage1->getErrorMessage(0))<<endl;
		return;
	    }
		
	  if(d1==NULL){
		cout<<"ERROR1"<<endl;;
		return;
	    }
	XdmItem * d11 = d1->getHead();
	if(d11 == NULL)	{

		cout<<"d11 is NULL\n"<<endl;
	}
	const char *data = d1->getHead()->toString();

	if(data != NULL){
	cout<<"d1 result="<<data<<endl;
	}else {
	cout<<"checkpoint\n"<<endl;

	return;
	}
	  stage2->setProperty("!indent", "no");
	  stage2->setInitialMatchSelection(d1->getHead());
          XdmValue * d2 = stage2->applyTemplatesReturningValue();
	  if(d2==NULL){
		cout<<"ERROR-11\n"<<endl;
	   if(stage2->exceptionCount()>0){
		const char * message = stage2->getErrorMessage(0);
		cout<<"exception="<< message<<endl;
	    }
		return;
	    } else {
		cout<<"d2 result = "<<d2->getHead()->toString()<<endl;
		}
	  /*$stage3->setProperty("!indent", "no");
	  $stage3->setInitialMatchSelection($d2);
          $d3 = $stage3->applyTemplatesReturningValue();
	  if($d3==NULL){
		echo "ERROR2";		
		exit(1);
	    }
	  $stage4->setProperty("!indent", "no");
	  $stage4->setInitialMatchSelection($d3);
          $d4 = $stage4->applyTemplatesReturningValue();
	 if($d3==NULL){
		echo "ERROR3";
		exit(1);
	    }
	  $stage5->setProperty("!indent", "no");
	  $stage4->setInitialMatchSelection($d4);
          $sw = $stage5->applyTemplatesReturningString();
	  if($sw==NULL){
		echo "ERROR4";
		exit(1);
	    }
          cout<<sw<<endl;
*/

}

int main()
{

    
    SaxonProcessor * processor = new SaxonProcessor(true);
    cout<<"Test: Xslt30Processor with Saxon version="<<processor->version()<<endl<<endl; 
    //processor->setcwd("/home");
   if(processor->isSchemaAwareProcessor()) {

    std::cerr<<"Processor is Schema Aware"<<std::endl;
  } else {
	std::cerr<<"Processor is not Schema Aware"<<std::endl;
 }
   processor->setConfigurationProperty("http://saxon.sf.net/feature/generateByteCode","false");
   sResultCount *sresult = new sResultCount();
    Xslt30Processor * trans = processor->newXslt30Processor();
	//testValidation(trans,sresult);
testInitialTemplate(processor, trans, sresult);
   exampleSimple1Err(trans, sresult);
    exampleSimple1(trans, sresult);
    exampleSimple_xmark(trans, sresult);
    exampleSimple2(trans, sresult);
    exampleSimple3(processor, trans, sresult);

    testApplyTemplatesString1(trans, sresult);

    testApplyTemplatesString2(processor, trans, sresult);

    testApplyTemplates2a(processor, trans, sresult);

    testTransformToString4(processor, trans, sresult);



    /*testTransformToString2b(processor, trans, sresult);

    testTransformToString3(processor, trans, sresult);
	
    testTransformFromstring(processor, trans, sresult);

    testTransformFromstring2Err(processor, trans, sresult);      */

    testTrackingOfValueReference(processor, trans,sresult);

    testTrackingOfValueReferenceError(processor, trans, sresult);

    testPackage1(trans, sresult);

   testPackage2(trans, sresult);

    testXdmNodeOutput(trans, sresult);

    exampleParam(processor, trans, sresult);

    xmarkTest1(trans, sresult);

    xmarkTest2(trans, sresult);
   testCallFunction(processor, trans, sresult);
   testResolveUri(processor, trans, sresult);
    testContextNotRoot(processor, trans, sresult);
testContextNotRootNamedTemplate(processor, trans, sresult);
testContextNotRootNamedTemplateValue(processor, trans, sresult);
testPipeline(processor, sresult); 

  //Available in PE and EE
   //testTransformToStringExtensionFunc(processor, trans);

    delete trans;
delete processor;
    // processor->release();


 SaxonProcessor * processor2 = new SaxonProcessor(true);

    Xslt30Processor * trans2 = processor2->newXslt30Processor();
testApplyTemplatesString1(trans2, sresult);
  delete trans2;
     processor2->release();

   std::cout<<"\nTest Results - Number of tests= "<<(sresult->success+sresult->failure)<<", Successes = "<<sresult->success<<",  Failures= "<<sresult->failure<<std::endl;

std::list<std::string>::iterator it;
 std::cout<<"Failed tests:"<<std::endl;
// Make iterate point to begining and incerement it one by one till it reaches the end of list.
for (it = sresult->failureList.begin(); it != sresult->failureList.end(); it++)
{
	//Print the contents
	std::cout << it->c_str() << std::endl;
 
}



    return 0;
}
