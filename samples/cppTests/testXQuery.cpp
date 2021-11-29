#include "../../Saxon.C.API/SaxonProcessor.h"
#include "../../Saxon.C.API/XdmValue.h"
#include "../../Saxon.C.API/XdmItem.h"
#include "../../Saxon.C.API/XdmNode.h"
#include "../../Saxon.C.API/XdmAtomicValue.h"
#include <string>

using namespace std;

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


/*
* Test1: 
*/
void testxQuery1(SaxonProcessor * processor, XQueryProcessor * queryProc){
 cout<<endl<<"Test testXQuery1:"<<endl;
	queryProc->clearProperties();
	queryProc->clearParameters(true);
   queryProc->setProperty("s", "cat.xml");

    queryProc->setProperty("qs", "<out>{count(/out/person)}</out>");

    const char * result = queryProc->runQueryToString();
    if(result != NULL){
    	cout<<"Result :"<<result<<endl;
    } else {

	queryProc->checkException();
	
    }

return;
	queryProc->setcwd(".");
     queryProc->executeQueryToFile(NULL, "catOutput.xml", NULL);

		if (exists("catOutput.xml")) {
		    cout<<"The file $filename exists"<<endl;;
		} else {
		    cout<<"The file $filename does not exist"<<endl;
		    processor->exceptionClear();
		}
}

void testxQueryError(XQueryProcessor * queryProc){
 cout<<endl<<"Test testXQueryError-Test:"<<endl;
	queryProc->clearProperties();
	queryProc->clearParameters(true);
   queryProc->setProperty("s", "cat.xml");

    queryProc->setProperty("qs", "<out>{count(/out/person)}</out>");
queryProc->setcwd(".");
     queryProc->executeQueryToFile(NULL, "catOutput.xml", NULL);

		if (queryProc->exceptionOccurred()) {
		    cout<<"Exception found. Count="<<queryProc->exceptionCount()<<endl;
			for(int i=0;i<queryProc->exceptionCount();i++){
				const char * message = queryProc->getErrorMessage(i);
				if(message != NULL) {
					cout<<"Error Message = "<<message<<endl;		
				}		
			}
		
		}
}

void testxQueryError2(SaxonProcessor * processor, XQueryProcessor * queryProc){
 cout<<endl<<"Test testXQueryError-test2:"<<endl;
	queryProc->clearProperties();
	queryProc->clearParameters(true);
   queryProc->setProperty("s", "cat.xml");

    queryProc->setProperty("qs", "<out>{count(/out/person)}<out>");

    const char * result = queryProc->runQueryToString();
   if(result != NULL){
    	cout<<"Result :"<<result<<endl;
    } else {
	const char * message = queryProc->getErrorMessage(0);
	if(message != NULL) {
		cout<<"Error Message="<<message<<" Line number= "<<processor->getException()->getLineNumber(0)<<endl;
	} else {
		cout<<"Error Message - NULL check"<<endl;
	}
	
    }

}


void testDefaultNamespace(SaxonProcessor * processor, XQueryProcessor * queryProc) {
 cout<<endl<<"Test testXQuery2:"<<endl;
	queryProc->clearProperties();
	queryProc->clearParameters(true);	
	queryProc->declareNamespace("", "http://one.uri/");
	 XdmNode * input = processor->parseXmlFromString("<foo xmlns='http://one.uri/'><bar/></foo>");
	queryProc->setContextItem((XdmItem *)input);
	queryProc->setQueryContent("/foo");

	XdmValue * value = queryProc->runQueryToValue();

	if(value->size() == 1) {
		cout<<"Test1: Result is ok size is "<<value->size()<<endl;
	} else {
		cout<<"Test 1: Result failure"<<endl;
	}

}

// Test that the XQuery compiler can compile two queries without interference
void testReusability(SaxonProcessor * processor, XQueryProcessor * queryProc){
	cout<<endl<<"Test test XQuery reusability:"<<endl;
	XQueryProcessor * queryProc2 = processor->newXQueryProcessor();

	queryProc->clearProperties();
	queryProc->clearParameters(true);

 	XdmNode * input = processor->parseXmlFromString("<foo xmlns='http://one.uri/'><bar xmlns='http://two.uri'>12</bar></foo>");
	queryProc->declareNamespace("", "http://one.uri/");
	queryProc->setQueryContent("declare variable $p as xs:boolean external; exists(/foo) = $p");

	queryProc2->declareNamespace("", "http://two.uri");
	queryProc2->setQueryContent("declare variable $p as xs:integer external; /*/bar + $p");

	queryProc->setContextItem((XdmItem *)input);

	XdmAtomicValue * value1 = processor->makeBooleanValue(true);
  	queryProc->setParameter("p",(XdmValue *)value1);
	XdmValue * val = queryProc->runQueryToValue();

	if(val != NULL && ((XdmItem*)val->itemAt(0))->isAtomic()){
		cout<<"Test1: Result is atomic"<<endl;
		XdmAtomicValue* atomic = (XdmAtomicValue *)val->itemAt(0);
		bool result1 = atomic->getBooleanValue();
		cout<<"Test2: Result value="<<(result1 == true ? "true" : "false")<<endl;
cout<<"Test5: PrimitiveTypeName of  atomic="<<atomic->getPrimitiveTypeName()<<endl;
	}

	queryProc2->setContextItem((XdmItem *)input);

	XdmAtomicValue * value2 = processor->makeLongValue(6);
cout<<"Test5: PrimitiveTypeName of  value2="<<value2->getPrimitiveTypeName()<<endl;
	queryProc2->setParameter("p",(XdmValue *)value2);

	XdmValue * val2 = queryProc2->runQueryToValue();



cout<<"XdmValue size="<<val2->size()<<", "<<(val2->itemAt(0))->getStringValue()<<endl;

	if(val2 != NULL && ((XdmItem*)val2->itemAt(0))->isAtomic()){
		cout<<"Test3: Result is atomic"<<endl;
		XdmAtomicValue* atomic2 = (XdmAtomicValue *)(val2->itemAt(0));
		long result2 = atomic2->getLongValue();
		cout<<"Test4: Result value="<<result2<<endl;
		cout<<"Test5: PrimitiveTypeName of  atomic2="<<atomic2->getPrimitiveTypeName()<<endl;
	}

if (queryProc->exceptionOccurred()) {
		    cout<<"Exception found. Count="<<queryProc->exceptionCount()<<endl;
			for(int i=0;i<queryProc->exceptionCount();i++){
				const char * message = queryProc->getErrorMessage(i);
				if(message != NULL) {
					cout<<"Error Message = "<<message<<endl;		
				}		
			}
		
		}
	
}


//Test requirement of license file - Test should fail
void testXQueryLineNumberError(XQueryProcessor * queryProc){
 cout<<endl<<"Test testXQueryLineNumberError:"<<endl;
	queryProc->clearProperties();
	queryProc->clearParameters(true);
   queryProc->setProperty("s", "cat.xml");

    queryProc->setProperty("qs", "saxon:line-number((//person)[1])");

    const char * result = queryProc->runQueryToString();
    if(result != NULL){
    	cout<<"Result :"<<result<<endl;
    } else {
	cout<<"Some faiure"<<endl;
	if (queryProc->exceptionOccurred()) {
		    cout<<"Exception found. Count="<<queryProc->exceptionCount()<<endl;
			for(int i=0;i<queryProc->exceptionCount();i++){
				const char * message = queryProc->getErrorMessage(i);
				if(message != NULL) {
					cout<<"Error Message = "<<message<<endl;		
				}		
			}
		
		}
	
    }

}

//Test requirement of license file - Test should succeed
void testXQueryLineNumber(){
  SaxonProcessor * processor = new SaxonProcessor(true);
  processor->setConfigurationProperty("l", "on");
  XQueryProcessor * queryProc = processor->newXQueryProcessor();
 cout<<endl<<"testXQueryLineNumber:"<<endl;
	
   queryProc->setProperty("s", "cat.xml");
   queryProc->declareNamespace("saxon","http://saxon.sf.net/");

    queryProc->setProperty("qs", "saxon:line-number(doc('cat.xml')/out/person[1])"); ///out/person[1]

    const char * result = queryProc->runQueryToString();
    if(result != NULL){
    	cout<<"Result :"<<result<<endl;
    } else {
	cout<<"Some faiure"<<endl;
	if (queryProc->exceptionOccurred()) {
		    cout<<"Exception found. Count="<<queryProc->exceptionCount()<<endl;
			for(int i=0;i<queryProc->exceptionCount();i++){
				const char * message = queryProc->getErrorMessage(i);
				if(message != NULL) {
					cout<<"Error Message = "<<message<<endl;		
				}		
			}
		
		}
	
    }
	delete processor;

}

int main()
{

    SaxonProcessor * processor = new SaxonProcessor(false);
    cout<<"Test: XQueryProcessor with Saxon version="<<processor->version()<<endl<<endl;
    XQueryProcessor * query = processor->newXQueryProcessor();
    

    testxQuery1(processor, query);
    testxQueryError(query);
    testxQueryError2(processor, query);
    testDefaultNamespace(processor, query);
    testReusability(processor, query);
    testXQueryLineNumberError(query);
    testXQueryLineNumber();

    delete query;
     processor->release();
    return 0;
}
