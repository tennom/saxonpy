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
    int propLen=0, propCap;
    propCap = cap;
    sxnc_environment * environi;
    sxnc_processor * processor;

    initSaxonc(&environi, &processor, &parameters, &properties, parCap, propCap);

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
    //initJavaRT (environi->myDllHandle, &(environi->jvm), &(environi->env));
    const char *verCh = version(*environi);
    printf("XPath Tests\n\nSaxon version: %s \n", verCh);
    setProperty(&properties, &propLen, &propCap, "s", "cat.xml");
    

    sxnc_value * result = evaluate(environi,&processor, NULL, "/out/person", 0, properties, 0, propLen);

 bool resultBool = effectiveBooleanValue(environi,&processor, NULL, "count(/out/person)>0", 0, properties, 0, propLen);
 
    if(!result) {
      printf("result is null");
    }else {
      printf("%s", getStringValue(environi, *result));
    }

   if(resultBool==1) {
      printf("Boolean result is as expected: true");
    }else {
      printf("Boolean result is incorrectly: false");
    }
      fflush(stdout);   

    finalizeJavaRT (environi->jvm);
    freeSaxonc(&environi, &processor, &parameters, &properties);
    return 0;

}
