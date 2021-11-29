#include <sstream>

#include "../../Saxon.C.API/SaxonProcessor.h"
#include "../../Saxon.C.API/XdmValue.h"
#include "../../Saxon.C.API/XdmItem.h"
#include "../../Saxon.C.API/XdmNode.h"
#include "../../Saxon.C.API/XdmAtomicValue.h"
#include <string>

// TODO: write test case for checking parameters which are null


using namespace std;


/*
* Test transform to String. Source and stylesheet supplied as arguments
*/
jobject JNICALL cppNativeCall
  (jstring funcName, jobjectArray arguments, jobjectArray argTypes){


	JNIEnv *senv = SaxonProcessor::sxn_environ->env;
	
	if(funcName) {
		
        }
  	std::cerr<<"Testing CPP extension function"<<std::endl;
	jint argLength = 0;
	//XdmItem ** params[] = NULL;
	if(senv == NULL) {
		std::cerr<<"senv is null"<<std::endl;
	}
	if(arguments != NULL && argTypes) {
		argLength  = senv->GetArrayLength(arguments);
			
	//params = new XdmItem[argLength];
	}
	std::cerr<<"argLength"<<argLength<<std::endl;
	if(argLength>2){
		return NULL;
	}
	XdmItem ** params = new XdmItem*[argLength];

	std::map<std::string, saxonTypeEnum> typeMap;
	typeMap["node"] = enumNode;
	typeMap["string"] = enumString;
	typeMap["integer"] = enumInteger;
	typeMap["double"] = enumDouble;
	typeMap["float"] = enumFloat;
	typeMap["boolean"] = enumBool;
	typeMap["[xdmvalue"] = enumArrXdmValue;
	sxnc_value* sresult = (sxnc_value *)malloc(sizeof(sxnc_value));
	SaxonProcessor * nprocessor = new SaxonProcessor(true); //processor object created for XdmNode
	jclass xdmValueForCppClass = lookForClass(SaxonProcessor::sxn_environ->env, "net/sf/saxon/option/cpp/XdmValueForCpp");
	jmethodID procForNodeMID = SaxonProcessor::sxn_environ->env->GetStaticMethodID(xdmValueForCppClass, "getProcessor", "(Ljava/lang/Object;)Lnet/sf/saxon/s9api/Processor;");
	
	for(int i=0; i<argLength;i++){

		jstring argType = (jstring)senv->GetObjectArrayElement(argTypes, i);
		jobject argObj = senv->GetObjectArrayElement(arguments, i);

		const char * str = senv->GetStringUTFChars(argType,NULL);
		
		std::cerr<<str<<std::endl;
         
		const char * stri = NULL;
		long lnumber = 0;
		float fnumber = 0;
		bool bvalue = false;
		double dnumber = 0;

		std::map<std::string, saxonTypeEnum>::iterator it = typeMap.find(str);
		if (it != typeMap.end()){
			switch (it->second)
			{
				case enumNode:
					if(!nprocessor->proc){
						nprocessor->proc = (jobject)SaxonProcessor::sxn_environ->env->CallStaticObjectMethod(xdmValueForCppClass, procForNodeMID, argObj);
					}
					params[i] = new XdmNode(argObj);
					params[i]->setProcessor(nprocessor);
					
					
					break;
				case enumString:
					stri = senv->GetStringUTFChars((jstring)argObj, NULL);
					if(stri !=NULL){}
					break;
				case enumInteger:
					params[i] = new XdmAtomicValue(argObj, "");
					sresult->xdmvalue = argObj; 
					lnumber = getLongValue(SaxonProcessor::sxn_environ, *sresult, 0);
					if(lnumber == 0){}
										
					break;
				case enumDouble:
					sresult->xdmvalue = argObj; 
					dnumber = getDoubleValue(SaxonProcessor::sxn_environ, *sresult, 0);
					if(dnumber == 0){}
					break;
				case enumFloat:
					sresult->xdmvalue = argObj; 
					fnumber = getFloatValue(SaxonProcessor::sxn_environ, *sresult, 0);
					if(fnumber == 0){}				
					break;
				case enumBool:
					sresult->xdmvalue = argObj; 
					bvalue = getBooleanValue(SaxonProcessor::sxn_environ, *sresult);
					if(bvalue){}						
					break;
				case enumArrXdmValue:
					//TODO - not currently supported
					argLength--;
					break;
			}
			senv->ReleaseStringUTFChars(argType, str);

		}

		senv->DeleteLocalRef(argType);
		senv->DeleteLocalRef(argObj);
}
	return SaxonProcessor::sxn_environ->env->NewStringUTF("result from extension!!");
}

string nativeExtensionMethod(char * param1, int number){

	if(param1!=NULL) {
		//do nothing
	}
	if(number == 0) {
		//do nothing
	}
	string result = "native-extension " ;//+ param1;
	return result;
}


