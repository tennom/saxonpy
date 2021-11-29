#include "../../Saxon.C.API/SaxonProcessor.h"
#include "../../Saxon.C.API/XdmValue.h"
#include "../../Saxon.C.API/XdmNode.h"
#include <string>

using namespace std;

void testValidator1(SchemaValidator * val){
	cout<<endl<<"Test Validate Schema from string"<<endl;	
 string invalid_xml = "<?xml version='1.0'?><request><a/><!--comment--></request>";
 const char* sch1 = "<xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema' elementFormDefault='qualified' attributeFormDefault='unqualified'><xs:element name='request'><xs:complexType><xs:sequence><xs:element name='a' type='xs:string'/><xs:element name='b' type='xs:string'/></xs:sequence><xs:assert test='count(child::node()) = 3'/></xs:complexType></xs:element></xs:schema>";


        string doc1 = "<Family xmlns='http://myexample/family'><Parent>John</Parent><Child>Alice</Child></Family>";
	
	val->registerSchemaFromString(sch1);

}

void testValidator2(){
  SaxonProcessor * processor = new SaxonProcessor(true);
  processor->setConfigurationProperty("xsdversion", "1.1");
  SchemaValidator * val = processor->newSchemaValidator();

  cout<<endl<<"Test 2: Validate Schema from string"<<endl;	
  string invalid_xml = "<?xml version='1.0'?><request><a/><!--comment--></request>";
  const char* sch1 = "<xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema' elementFormDefault='qualified' attributeFormDefault='unqualified'><xs:element name='request'><xs:complexType><xs:sequence><xs:element name='a' type='xs:string'/><xs:element name='b' type='xs:string'/></xs:sequence><xs:assert test='count(child::node()) = 3'/></xs:complexType></xs:element></xs:schema>";


        string doc1 = "<Family xmlns='http://myexample/family'><Parent>John</Parent><Child>Alice</Child></Family>";

	 XdmNode * input = processor->parseXmlFromString(doc1.c_str());

	val->setSourceNode(input);

	
	
	val->registerSchemaFromString(sch1);

	val->validate();
	if(val->exceptionOccurred()) {
		cout<<endl<<"Doc is not valid!"<<endl;
	}

	delete val;

}

void testValidator3(SaxonProcessor * processor, SchemaValidator * val){
  processor->exceptionClear();
  val->clearParameters(true);
  val->clearProperties();
  cout<<endl<<"Test 3: Validate Schema from string"<<endl;	
  const char* sch1 = "<?xml version='1.0' encoding='UTF-8'?><schema targetNamespace='http://myexample/family' xmlns:fam='http://myexample/family' xmlns='http://www.w3.org/2001/XMLSchema'><element name='FamilyMember' type='string' /><element name='Parent' type='string' substitutionGroup='fam:FamilyMember'/><element name='Child' type='string' substitutionGroup='fam:FamilyMember'/><element name='Family'><complexType><sequence><element ref='fam:FamilyMember' maxOccurs='unbounded'/></sequence></complexType></element>  </schema>";
	
	val->registerSchemaFromString(sch1);

	val->validate("family.xml");
	if(!val->exceptionOccurred()) {
		cout<<endl<<"Doc1 is OK"<<endl;
	} else {
		cout<<endl<<"Error: Doc reported as invalid!"<<endl;
	}
}

void testValidator4(SaxonProcessor * processor, SchemaValidator * val){
  processor->exceptionClear();
  val->clearParameters(true);
  val->clearProperties();
  cout<<endl<<"Test 4: Validate source file with schema file. i.e. family.xml and family.xsd"<<endl;	

	val->registerSchemaFromFile("family-ext.xsd");
       //val->registerSchema("family.xsd");
	val->registerSchemaFromFile("family.xsd");
	val->validate("family.xml");
	if(!val->exceptionOccurred()) {
		cout<<endl<<"Doc1 is OK"<<endl;
	} else {
	cout<<endl<<"Error: Doc reported as valid!"<<endl;
	}

}

void testValidator4a(SaxonProcessor * processor, SchemaValidator * val){
  processor->exceptionClear();
  val->clearParameters(true);
  val->clearProperties();
  cout<<endl<<"Test 4: Validate source file with schema file. i.e. family.xml and family.xsd to XdmNode"<<endl;	

	val->registerSchemaFromFile("family-ext.xsd");
       //val->registerSchema("family.xsd");
	val->registerSchemaFromFile("family.xsd");
	XdmNode * node = val->validateToNode("family.xml");
	if(node != NULL) {
		if(!val->exceptionOccurred()) {
			cout<<endl<<"Doc1 is OK:"<<node->toString()<<endl;
	 	} else {
			cout<<endl<<"Error: Doc reported as valid!"<<endl;
		}
	} else {
	cout<<endl<<"Error: node is NULL"<<endl;
	}

}

void testValidator5(SaxonProcessor * processor, SchemaValidator * val){
  processor->exceptionClear();
  val->clearParameters(true);
  val->clearProperties();
  cout<<endl<<"Test 5: Validate Schema from string"<<endl;	
  string invalid_xml = "<?xml version='1.0'?><request><a/><!--comment--></request>";
  const char* sch1 = "<xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema' elementFormDefault='qualified' attributeFormDefault='unqualified'><xs:element name='request'><xs:complexType><xs:sequence><xs:element name='a' type='xs:string'/><xs:element name='b' type='xs:string'/></xs:sequence><xs:assert test='count(child::node()) = 3'/></xs:complexType></xs:element></xs:schema>";


        string doc1 = "<request xmlns='http://myexample/family'><Parent>John</Parent><Child1>Alice</Child1></request>";

	 XdmNode * input = processor->parseXmlFromString(doc1.c_str());
	//val->setSourceNode(input);

	//val->setProperty("string", doc1.c_str());
	val->setProperty("xsdversion", "1.1");
	val->setParameter("node", (XdmValue *)input);

	val->registerSchemaFromString(sch1);

	val->setProperty("report-node", "true");
	//val->setProperty("report-file", "validation-report2.xml");	
	val->setProperty("verbose", "true");
	val->validate();
	XdmNode * node = val->getValidationReport(); 
	if(node != NULL) {
		cout<<endl<<node->size()<<"Validation Report"<<node->getStringValue()<<endl;
	} else {
		cout<<endl<<"Error: Validation Report is NULL - This should not be NULL. Probably no valid license file found."<<endl;
	}

	

}

int main()
{

	SaxonProcessor * processor = new SaxonProcessor(true);
       cout<<"Test: SchemaValidator with Saxon version="<<processor->version()<<endl<<endl;

	//processor->setConfigurationProperty("xsdversion", "1.1");
	
	 SchemaValidator * validator = processor->newSchemaValidator();
	testValidator1(validator);
	testValidator2();

	testValidator3(processor, validator);
	processor->setConfigurationProperty("http://saxon.sf.net/feature/multipleSchemaImports", "on");
	SchemaValidator * validator2 = processor->newSchemaValidator();
	testValidator4(processor, validator2);
	testValidator4a(processor, validator2);
	processor->setConfigurationProperty("xsdversion", "1.1");
	SchemaValidator * validator3 = processor->newSchemaValidator();
	testValidator5(processor, validator3);
	delete validator;
	delete validator2;
	delete validator3;
        processor->release();
	return 0;
}
