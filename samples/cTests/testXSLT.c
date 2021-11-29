#include "../../Saxon.C.API/SaxonCProcessor.h"
#include "../../Saxon.C.API/SaxonCXPath.h"


int main()
{
    HANDLE myDllHandle;
    //JNIEnv *(environi.env);
    //JavaVM *jvm;
    jclass  myClassInDll;
    int cap = 10;
    sxnc_parameter * parameters; /*!< array of paramaters used for the transformation as (string, value) pairs */
    parameters;
    int parLen=0, parCap;
    parCap = cap;
    sxnc_property * properties; /*!< array of properties used for the transformation as (string, string) pairs */
    properties;
    int propLen=0;
    parCap = cap;
    sxnc_environment * environi;
    sxnc_processor * processor;

    initSaxonc(&environi, &processor, &parameters, &properties, parCap, parCap);

    /*
     * First of all, load required component.
     * By the time of JET initialization, all components should be loaded.
     */
    environi->myDllHandle = loadDefaultDll ();
	
    /*
     * Initialize JET run-time.
     * The handle of loaded component is used to retrieve Invocation API.
     */
    initDefaultJavaRT (&environi);

    const char *verCh = version(*environi);
    printf("XSLT Tests\n\nSaxon version: %s \n", verCh);	
    jobject num = integerValue(*environi, 5);
    setParameter(&parameters, &parLen, &parCap,"", "numParam", num);
  

    const char *result = xsltApplyStylesheet(environi, &processor, NULL, "cat.xml","test.xsl", 0 ,0, 0, 0);
  
	

    if(!result) {
      printf("result is null \n");
    }else {
      printf("%s", result);
    }
      fflush(stdout);

    /*
     * Finalize JET run-time.
     */
    finalizeJavaRT (environi->jvm);
    freeSaxonc(&environi, &processor, &parameters, &properties);
    return 0;
}
