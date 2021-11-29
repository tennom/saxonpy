////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014 Saxonica Limited.
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
// This Source Code Form is "Incompatible With Secondary Licenses", as defined by the Mozilla Public License, v. 2.0.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////#ifndef PHP_SAXON_H

#ifndef PHP_SAXON_H
#define PHP_SAXON_H

#ifdef __cplusplus
extern "C" {
#endif

    #include "php.h"
	//#include "php_ini.h"
	#include "ext/standard/info.h"
	#include "Zend/zend_exceptions.h"
	


#ifdef PHP_WIN32
	#define _ALLOW_KEYWORD_MACROS
#endif

#ifdef PHP_WIN32
	#define PHP_SAXON_API __declspec(dllexport)
	#define PHP_SAXON __declspec(dllimport)
//#elif define(__GNUC__) && __GNUC__ >= 4
//#define PHP_SAXON __attribute__ ((visibility("default")))
//#else
//#define PHP_SAXON_API
#endif

#ifdef ZTS
#include "TSRM.h"
#endif
#ifdef __cplusplus
}
#endif
#include "SaxonProcessor.h"
#include "XdmValue.h"
#include "XdmItem.h"
#include "XdmNode.h"
#include "XdmAtomicValue.h"
/*class SaxonProcessor;
class XQueryProcessor;
class XsltProcessor;
class XdmValue;*/

extern zend_module_entry saxon_module_entry;
#define phpext_saxon_ptr &saxon_module_entry;

struct zvalArr {
    zval * _val;
};

struct saxonProcessor_object {
    zend_object std;
    SaxonProcessor * saxonProcessor;
};

struct xsltProcessor_object {
    zend_object std;
    XsltProcessor *xsltProcessor;
};

struct xslt30Processor_object {
    zend_object std;
    Xslt30Processor *xslt30Processor;
};

struct xqueryProcessor_object {
    zend_object std;
    XQueryProcessor *xqueryProcessor;
};

struct xpathProcessor_object {
    zend_object std;
    XPathProcessor *xpathProcessor;
};

struct schemaValidator_object {
    zend_object std;
    SchemaValidator * schemaValidator;
};

struct xdmValue_object {
    zend_object std;
    XdmValue * xdmValue;
};

struct xdmItem_object {
    zend_object std;
    XdmItem * xdmItem;
};

struct xdmNode_object {
    zend_object std;
    XdmNode * xdmNode;
};

struct xdmAtomicValue_object {
    zend_object std;
    XdmAtomicValue * xdmAtomicValue;
};


#define PHP_SAXON_EXTNAME  "Saxon/C"
#define PHP_SAXON_EXTVER   "1.2.0"

/*
 * Class:     com_saxonica_functions_extfn_PhpCall_PhpFunctionCall
 * Method:    _phpCall
 * Signature: ([Ljava/lang/String;[Ljava/lang/String;)Ljava/lang/Object;
 */

jobject JNICALL phpNativeCall
  (JNIEnv *env, jobject object, jstring funcName, jobjectArray arguments, jobjectArray arrayTypes);
	
	PHP_MSHUTDOWN_FUNCTION(saxon);
	PHP_MINFO_FUNCTION(saxon);
	PHP_MINIT_FUNCTION(saxon);

    PHP_METHOD(SaxonProcessor,  __construct);
    PHP_METHOD(SaxonProcessor,  __destruct);

    PHP_METHOD(SaxonProcessor,  createAtomicValue);
    PHP_METHOD(SaxonProcessor,  parseXmlFromString);
    PHP_METHOD(SaxonProcessor,  parseXmlFromFile);
    PHP_METHOD(SaxonProcessor,  setcwd);
//    PHP_METHOD(SaxonProcessor,  importDocument);
    PHP_METHOD(SaxonProcessor,  setResourcesDirectory);
    PHP_METHOD(SaxonProcessor,  setCatalog);
    PHP_METHOD(SaxonProcessor,  registerPHPFunction);
 //   PHP_METHOD(SaxonProcessor,  getXslMessages);
    PHP_METHOD(SaxonProcessor, setConfigurationProperty);
    PHP_METHOD(SaxonProcessor, newXsltProcessor);
    PHP_METHOD(SaxonProcessor, newXslt30Processor);
    PHP_METHOD(SaxonProcessor, newXQueryProcessor);
    PHP_METHOD(SaxonProcessor, newXPathProcessor);
    PHP_METHOD(SaxonProcessor, newSchemaValidator);
    PHP_METHOD(SaxonProcessor,  version);
    PHP_METHOD(SaxonProcessor,  isSchemaAware);




    //PHP_METHOD(XsltProcessor,  __construct);
    PHP_METHOD(XsltProcessor,  __destruct);
    PHP_METHOD(XsltProcessor,  transformFileToFile);
    PHP_METHOD(XsltProcessor,  transformFileToString);
    PHP_METHOD(XsltProcessor,  transformFileToValue);
    PHP_METHOD(XsltProcessor,  transformToString);
    PHP_METHOD(XsltProcessor,  transformToValue);
    PHP_METHOD(XsltProcessor,  transformToFile);
    PHP_METHOD(XsltProcessor, compileFromFile);
    PHP_METHOD(XsltProcessor, compileFromValue);
    PHP_METHOD(XsltProcessor, compileFromString);
    PHP_METHOD(XsltProcessor, compileFromFileAndSave);
    PHP_METHOD(XsltProcessor, compileFromStringAndSave);
    PHP_METHOD(XsltProcessor,  setOutputFile);
    PHP_METHOD(XsltProcessor,  setSourceFromFile);
    PHP_METHOD(XsltProcessor,  setSourceFromXdmValue);
    PHP_METHOD(XsltProcessor,  setJustInTimeCompilation);
    PHP_METHOD(XsltProcessor,  setParameter);
    PHP_METHOD(XsltProcessor,  setProperty);
    PHP_METHOD(XsltProcessor,  clearParameters);
    PHP_METHOD(XsltProcessor,  clearProperties);
    PHP_METHOD(XsltProcessor,  exceptionClear);
    PHP_METHOD(XsltProcessor,  exceptionOccurred);
    PHP_METHOD(XsltProcessor,  getErrorCode);
    PHP_METHOD(XsltProcessor,  getErrorMessage);
    PHP_METHOD(XsltProcessor,  getExceptionCount);
    PHP_METHOD(XsltProcessor,  getXslMessages);

    //PHP_METHOD(Xslt30Processor,  __construct);
    PHP_METHOD(Xslt30Processor, callFunctionReturningValue);
    PHP_METHOD(Xslt30Processor, callFunctionReturningString);
    PHP_METHOD(Xslt30Processor, callFunctionReturningFile);
    PHP_METHOD(Xslt30Processor, callTemplateReturningValue);
    PHP_METHOD(Xslt30Processor, callTemplateReturningString);
    PHP_METHOD(Xslt30Processor, callTemplateReturningFile);
    PHP_METHOD(Xslt30Processor, applyTemplateReturningValue);
    PHP_METHOD(Xslt30Processor, applyTemplateReturningString);
    PHP_METHOD(Xslt30Processor, applyTemplateReturningFile);
    PHP_METHOD(Xslt30Processor, addPackages);
    PHP_METHOD(Xslt30Processor,setInitialTemplateParameters);
    PHP_METHOD(Xslt30Processor, setInitialMatchSelection);
    PHP_METHOD(Xslt30Processor, setInitialMatchSelectionAsFile);
    PHP_METHOD(Xslt30Processor, setGlobalContextItem);
    PHP_METHOD(Xslt30Processor, setGlobalContextFromFile);
    PHP_METHOD(Xslt30Processor,  __destruct);
    PHP_METHOD(Xslt30Processor,  transformFileToFile);
    PHP_METHOD(Xslt30Processor,  transformFileToString);
    PHP_METHOD(Xslt30Processor,  transformFileToValue);
    PHP_METHOD(Xslt30Processor,  transformToString);
    PHP_METHOD(Xslt30Processor,  transformToValue);
    PHP_METHOD(Xslt30Processor,  transformToFile);
    PHP_METHOD(Xslt30Processor, compileFromFile);
    PHP_METHOD(Xslt30Processor, compileFromValue);
    PHP_METHOD(Xslt30Processor, compileFromString);
    PHP_METHOD(Xslt30Processor, compileFromFileAndSave);
    PHP_METHOD(Xslt30Processor, compileFromStringAndSave);
    PHP_METHOD(Xslt30Processor,  setOutputFile);
    PHP_METHOD(Xslt30Processor,  setSourceFromFile);
    PHP_METHOD(Xslt30Processor,  setSourceFromXdmValue);
    PHP_METHOD(Xslt30Processor,  setJustInTimeCompilation);
    PHP_METHOD(Xslt30Processor,  setParameter);
    PHP_METHOD(Xslt30Processor,  setProperty);
    PHP_METHOD(Xslt30Processor,  clearParameters);
    PHP_METHOD(Xslt30Processor,  clearProperties);
    PHP_METHOD(Xslt30Processor,  exceptionClear);
    PHP_METHOD(Xslt30Processor,  exceptionOccurred);
    PHP_METHOD(Xslt30Processor,  getErrorCode);
    PHP_METHOD(Xslt30Processor,  getErrorMessage);
    PHP_METHOD(Xslt30Processor,  getExceptionCount);
    PHP_METHOD(Xslt30Processor,  getXslMessages);




   // PHP_METHOD(XQueryProcesor,  __construct);
    PHP_METHOD(XQueryProcesor,  __destruct);
    PHP_METHOD(XQueryProcessor,  setQueryContent);
    PHP_METHOD(XQueryProcessor,  setContextItem);
    PHP_METHOD(XQueryProcessor,  setContextItemFromFile);
    PHP_METHOD(XQueryProcessor,  setParameter);
    PHP_METHOD(XQueryProcessor,  setProperty);
    PHP_METHOD(XQueryProcessor,  clearParameters);
    PHP_METHOD(XQueryProcessor,  clearProperties);
   // PHP_METHOD(XQueryProcessor, setOutputFile);
    PHP_METHOD(XQueryProcessor, runQueryToValue);
    PHP_METHOD(XQueryProcessor, runQueryToString);
    PHP_METHOD(XQueryProcessor, runQueryToFile);
    PHP_METHOD(XQueryProcessor, setQueryFile);
    PHP_METHOD(XQueryProcessor, setQueryBaseURI);
    PHP_METHOD(XQueryProcessor, declareNamespace);
    PHP_METHOD(XQueryProcessor,  exceptionClear);
    PHP_METHOD(XQueryProcessor,  exceptionOccurred);
    PHP_METHOD(XQueryProcessor,  getErrorCode);
    PHP_METHOD(XQueryProcessor,  getErrorMessage);
    PHP_METHOD(XQueryProcessor,  getExceptionCount);

   // PHP_METHOD(XPathProcessor,  __construct);
    PHP_METHOD(XPathProcessor,  __destruct);
    PHP_METHOD(XPathProcessor,  setContextItem);
    PHP_METHOD(XPathProcessor,  setContextFile);
    PHP_METHOD(XQueryProcessor, setBaseURI);
    PHP_METHOD(XPathProcessor,  effectiveBooleanValue);
    PHP_METHOD(XPathProcessor,  evaluate);
    PHP_METHOD(XPathProcessor,  evaluateSingle);
    PHP_METHOD(XPathProcessor, declareNamespace);
    PHP_METHOD(XPathProcessor, setBackwardsCompatible);
    PHP_METHOD(XPathProcessor, setCaching);
    PHP_METHOD(XPathProcessor, importSchemaNamespace);
    PHP_METHOD(XPathProcessor,  setParameter);
    PHP_METHOD(XPathProcessor,  setProperty);
    PHP_METHOD(XPathProcessor,  clearParameters);
    PHP_METHOD(XPathProcessor,  clearProperties);
    PHP_METHOD(XPathProcessor,  exceptionClear);
    PHP_METHOD(XPathProcessor,  exceptionOccurred);
    PHP_METHOD(XPathProcessor,  getErrorCode);
    PHP_METHOD(XPathProcessor,  getErrorMessage);
    PHP_METHOD(XPathProcessor,  getExceptionCount);


   // PHP_METHOD(SchemaValidator,  __construct);
    PHP_METHOD(SchemaValidator,  __destruct);
    PHP_METHOD(SchemaValidator,  setSourceNode);
    PHP_METHOD(SchemaValidator,  setOutputFile);
    PHP_METHOD(SchemaValidator, registerSchemaFromFile);
    PHP_METHOD(SchemaValidator, registerSchemaFromString);
    PHP_METHOD(SchemaValidator, validate); 
    PHP_METHOD(SchemaValidator, validateToNode);
    PHP_METHOD(SchemaValidator, getValidationReport);
    PHP_METHOD(SchemaValidator,  setParameter);
    PHP_METHOD(SchemaValidator,  setProperty);
    PHP_METHOD(SchemaValidator,  clearParameters);
    PHP_METHOD(SchemaValidator,  clearProperties);
    PHP_METHOD(SchemaValidator,  exceptionClear);
    PHP_METHOD(SchemaValidator,  exceptionOccurred);
    PHP_METHOD(SchemaValidator,  getErrorCode);
    PHP_METHOD(SchemaValidator,  getErrorMessage);
    PHP_METHOD(SchemaValidator,  getExceptionCount); 
	

/*     ============== PHP Interface of   XdmValue =============== */

    PHP_METHOD(XdmValue,  __construct);
    PHP_METHOD(XdmValue,  __destruct);
    PHP_METHOD(XdmValue,  __toString);
    PHP_METHOD(XdmValue,  getHead);
    PHP_METHOD(XdmValue,  itemAt);
    PHP_METHOD(XdmValue,  size);
    PHP_METHOD(XdmValue, addXdmItem);


/*     ============== PHP Interface of   XdmItem =============== */

    PHP_METHOD(XdmItem,  __construct);
    PHP_METHOD(XdmItem,  __destruct);
    PHP_METHOD(XdmItem,  __toString);
    PHP_METHOD(XdmItem,  getStringValue);
    PHP_METHOD(XdmItem,  isAtomic);
    PHP_METHOD(XdmItem,  isNode);
    PHP_METHOD(XdmItem,  getAtomicValue);
    PHP_METHOD(XdmItem,  getNodeValue);	

/*     ============== PHP Interface of   XdmNode =============== */

    PHP_METHOD(XdmNode,  __construct);
    PHP_METHOD(XdmNode,  __destruct);
    PHP_METHOD(XdmNode,  __toString);
    PHP_METHOD(XdmNode,  getStringValue);
    PHP_METHOD(XdmNode, getNodeKind);
    PHP_METHOD(XdmNode, getNodeName);
    PHP_METHOD(XdmNode,  isAtomic);
    PHP_METHOD(XdmNode,  getChildCount);   
    PHP_METHOD(XdmNode,  getAttributeCount); 
    PHP_METHOD(XdmNode,  getChildNode);
    PHP_METHOD(XdmNode,  getParent);
    PHP_METHOD(XdmNode,  getAttributeNode);
    PHP_METHOD(XdmNode,  getAttributeValue);
    PHP_METHOD(XdmNode,  getTypedValue);
    

/*     ============== PHP Interface of   XdmAtomicValue =============== */

    PHP_METHOD(XdmAtomicValue,  __construct);
    PHP_METHOD(XdmAtomicValue,  __destruct);
    PHP_METHOD(XdmAtomicValue,  __toString);
    PHP_METHOD(XdmAtomicValue,  getStringValue);
    PHP_METHOD(XdmAtomicValue,  getBooleanValue);
    PHP_METHOD(XdmAtomicValue,  getDoubleValue);
    PHP_METHOD(XdmAtomicValue,  getLongValue);
    PHP_METHOD(XdmAtomicValue,  isAtomic);


#endif /* PHP_SAXON_H */

















