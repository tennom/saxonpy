#include "../../Saxon.C.API/SaxonProcessor.h"
#include "../../Saxon.C.API/XdmValue.h"
#include "../../Saxon.C.API/XdmItem.h"
#include "../../Saxon.C.API/XdmNode.h"
#include <string>

using namespace std;



// Test case on the evaluate method in XPathProcessor. Here we test that we have morethan one XdmItem.
void testXPathSingle(SaxonProcessor * processor, XPathProcessor * xpath){

       cout<<endl<<"Test testXPathSingle:"<<endl; 
      XdmNode * input = processor->parseXmlFromString("<out><person>text1</person><person>text2</person><person>text3</person></out>");

	xpath->setContextItem((XdmItem *)input);
	XdmItem * result = xpath->evaluateSingle("//person[1]");
	
	if(result == NULL) {
		 printf("result is null \n");
	} else {
		cout<<"Number of items="<<result->size()<<endl;
		cout<<"String Value of result="<<result->getStringValue()<<endl;
	}
	delete result;

	

}

// Test case on the evaluate method in XPathProcessor. Here we test that we have morethan one XdmItem.
void testXPathValues(SaxonProcessor * processor, XPathProcessor * xpath){
     cout<<endl<<"Test testXPathValues:"<<endl; 
  	xpath->clearParameters(true);
  	xpath->clearProperties();
	 XdmNode * input = processor->parseXmlFromString("<out><person>text1</person><person>text2</person><person1>text3</person1></out>");
	if(input == NULL) {return;}
	XdmNode ** children = input->getChildren();
	XdmNode ** children0 = children[0]->getChildren();
	int num = children[0]->getChildCount();
	delete []children;
	cout<<"number of children: "<<num<<endl;
	for(int i=0; i<num;i++) {
		cout<<"node name:"<<children0[i]->getNodeName()<<endl;
	}
	delete [] children0;

	xpath->setContextItem((XdmItem *)input);
	XdmValue * resultValues = xpath->evaluate("//person");
	
	if(resultValues == NULL) {
		 printf("result is null \n");
	} else {
		cout<<"Number of items="<<resultValues->size()<<endl;
		for(int i =0; i< resultValues->size();i++){
			XdmItem * itemi = resultValues->itemAt(i);
			if(itemi == NULL) {
				cout<<"Item at position "<<i<<" should not be null"<<endl;
				break;
			}
			cout<<"Item at "<<i<<" ="<<itemi->getStringValue()<<endl;		
		}
	}
	delete resultValues;
	

}

// Test case on the evaluate method in XPathProcessor. Here we test that we have morethan one XdmItem.
void testXPathAttrValues(SaxonProcessor * processor, XPathProcessor * xpath){
     cout<<endl<<"Test testXPathValues1:"<<endl; 
  	xpath->clearParameters(true);
  	xpath->clearProperties();
	 XdmNode * input = processor->parseXmlFromString("<out attr='valuex'><person attr1='value1' attr2='value2'>text1</person><person>text2</person><person1>text3</person1></out>");
	if(input == NULL) {return;}

	//cout<<"Name of attr1= "<<input->getAttributeValue("attr")<<endl;


	xpath->setContextItem((XdmItem *)input);
	XdmItem * result = xpath->evaluateSingle("(//person)[1]");
	
	if(result == NULL) {
		 printf("result is null \n");
	} else {
		XdmNode *nodeValue = (XdmNode*)result;
		cout<<"Attribute Count= "<<nodeValue->getAttributeCount()<<endl;
		const char *attrVal = nodeValue->getAttributeValue("attr1");
		if(attrVal != NULL) {
			cout<<"Attribute value= "<<attrVal<<endl;
		}
		
		XdmNode ** attrNodes = nodeValue->getAttributeNodes();
		if(attrNodes == NULL) { return;}
	
		const char *name1 = attrNodes[0]->getNodeName();
		if(name1 != NULL) {
			cout<<"Name of attr1= "<<name1<<endl;
		}
		XdmNode * parent = attrNodes[0]->getParent();
		if(parent != NULL) {
			cout<<"Name of parent= "<<parent->getNodeName()<<endl;
		}
		XdmNode * parent1 = parent->getParent();
		if(parent1 != NULL) {
			cout<<"Name of parent= "<<parent1->getNodeName()<<endl;
		}
	//TODO test if attr value is not there
	}
	
	

}

// Test case on the evaluate method in XPathProcessor. Here we test that we have morethan one XdmItem.
void testXPathOnFile(SaxonProcessor * processor, XPathProcessor * xpath){
    	 cout<<endl<<"Test testXPath with file source:"<<endl;
  	xpath->clearParameters(true);
  	xpath->clearProperties(); 
	xpath->setContextFile("cat.xml");

	XdmValue * resultValues = xpath->evaluate("//person");
	
	if(resultValues == NULL) {
		 printf("result is null \n");
	} else {
		cout<<"Number of items="<<resultValues->size()<<endl;
		for(int i =0; i< resultValues->size();i++){
			XdmItem * itemi = resultValues->itemAt(i);
			if(itemi == NULL) {
				cout<<"Item at position "<<i<<" should not be null"<<endl;
				break;
			}
			cout<<"Item at "<<i<<" ="<<itemi->getStringValue()<<endl;		
		}
	}
	delete resultValues;
	

}

// Test case on the evaluate method in XPathProcessor. Here we test that we have morethan one XdmItem.
void testXPathOnFile2(XPathProcessor * xpath){
    	 cout<<endl<<"Test testXPath with file source:"<<endl;
  	xpath->clearParameters(true);
  	xpath->clearProperties(); 
	xpath->setContextFile("cat.xml");

	XdmItem * result = xpath->evaluateSingle("//person[1]");
	
	if(result == NULL) {
		 printf("result is null \n");
	} else {
		cout<<"Number of items="<<result->size()<<endl;
		if(result->isAtomic()) {
			cout<<"XdmItem is atomic - Error"<<endl;
		} else {
			cout<<"XdmItem is not atomic"<<endl;
		}
		XdmNode *node = (XdmNode*)result;
		if(node->getNodeKind() == ELEMENT){
		   cout<<"Result is a ELEMENT"<<endl;
		   cout<<"Node name: "<<node->getNodeName()<<endl;
		} else {
			cout<<"Node is of kind:"<<node->getNodeKind()<<endl;
		}
		const char * baseURI = node->getBaseUri();
		if(baseURI != NULL) {
			cout<<"baseURI of node: "<<baseURI<<endl;
		}
	}
	delete result;
	

}

int main()
{

    SaxonProcessor * processor = new SaxonProcessor(false);
    XPathProcessor * xpathProc = processor->newXPathProcessor();

    cout<<endl<<"Test: XPathProcessor with Saxon version="<<processor->version()<<endl; 
    testXPathSingle(processor, xpathProc);   
    testXPathValues(processor, xpathProc);
    testXPathAttrValues(processor, xpathProc);
    testXPathOnFile(processor, xpathProc);
    testXPathOnFile2(xpathProc);


     processor->release();
    return 0;
}
