#include <jni.h>

#ifdef __linux__
    #include <stdlib.h>
    #include <string.h>
    #include <dlfcn.h>
    #include <stdio.h>  
    #define HANDLE void*
    #define LoadLibrary(x) dlopen(x, RTLD_LAZY)
//    #define FreeLibrary(x) dlclose(x, RTLD_LAZY)
    #define GetProcAddress(x,y) dlsym(x,y)
#else
    #include <windows.h>
#endif

typedef int bool;
#define true 1
#define false 0


char dllname[] =
    #ifdef __linux__
#ifdef EEC
        "/usr/lib/libsaxoneec.so";
#elif defined PEC
	"/usr/lib/libsaxonpec.so";
#else
	"/usr/lib/libsaxonhec.so";
#endif
    #else
#ifdef EEC
        "Saxon-eec.dll";
#elif defined PEC
	"Saxon-pec.dll";
#else
	"Saxon-hec.dll";
#endif

#endif

//===============================================================================================//
/*! <code>Environment</code>. This struct captures the jni, JVM and handler to the cross compiled Saxon/C library.
 * <p/>
 */
typedef struct {
		JNIEnv *env;
		HANDLE myDllHandle;
		JavaVM *jvm;
	} Environment;


//===============================================================================================//

/*! <code>MyParameter</code>. This struct captures details of paramaters used for the transformation as (string, value) pairs.
 * <p/>
 */
typedef struct {
		char* name;
		jobject value;
	} MyParameter;

//===============================================================================================//

/*! <code>MyProperty</code>. This struct captures details of properties used for the transformation as (string, string) pairs.
 * <p/>
 */
typedef struct {
		char * name;
		char * value;
	} MyProperty;

jobject cpp;



const char * failure;
/*
 * Load dll.
 */
HANDLE loadDll(char* name)
{
    HANDLE hDll = LoadLibrary (name);

    if (!hDll) {
        printf ("Unable to load %s\n", name);
        exit(1);
    }
#ifdef DEBUG
    printf ("%s loaded\n", name);
#endif
    return hDll;
}


jint (JNICALL * JNI_GetDefaultJavaVMInitArgs_func) (void *args);
jint (JNICALL * JNI_CreateJavaVM_func) (JavaVM **pvm, void **penv, void *args);

/*
 * Initialize JET run-time.
 */
void initJavaRT(HANDLE myDllHandle, JavaVM** pjvm, JNIEnv** penv)
{
    int            result;
    JavaVMInitArgs args;

    JNI_GetDefaultJavaVMInitArgs_func = 
             (jint (JNICALL *) (void *args))
             GetProcAddress (myDllHandle, "JNI_GetDefaultJavaVMInitArgs");

    JNI_CreateJavaVM_func =
             (jint (JNICALL *) (JavaVM **pvm, void **penv, void *args))
             GetProcAddress (myDllHandle, "JNI_CreateJavaVM");

    if(!JNI_GetDefaultJavaVMInitArgs_func) {
        printf ("%s doesn't contain public JNI_GetDefaultJavaVMInitArgs\n", dllname);
        exit (1);
    }

    if(!JNI_CreateJavaVM_func) {
        printf ("%s doesn't contain public JNI_CreateJavaVM\n", dllname);
        exit (1);
    }

    memset (&args, 0, sizeof(args));

    args.version = JNI_VERSION_1_2;
    result = JNI_GetDefaultJavaVMInitArgs_func(&args);
    if (result != JNI_OK) {
        printf ("JNI_GetDefaultJavaVMInitArgs() failed with result %d\n", result);
        exit(1);
    }
  
    /*
     * NOTE: no JVM is actually created
     * this call to JNI_CreateJavaVM is intended for JET RT initialization
     */
    result = JNI_CreateJavaVM_func (pjvm, (void **)penv, &args);
    if (result != JNI_OK) {
        printf ("JNI_CreateJavaVM() failed with result %d\n", result);
        exit(1);
    }
#ifdef DEBUG
    printf ("JET RT initialized\n");
    fflush (stdout);
#endif
}


/*
 * Look for class.
 */
jclass lookForClass (JNIEnv* penv, char* name)
{
    jclass clazz = (*penv)->FindClass (penv, name);

    if (!clazz) {
        printf("Unable to find class %s\n", name);
	return NULL;
    }
#ifdef DEBUG
    printf ("Class %s found\n", name);
    fflush (stdout);
#endif

    return clazz;
}




jmethodID findConstructor (JNIEnv* penv, jclass myClassInDll, char* arguments)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)(*penv)->GetMethodID (penv, myClassInDll, "<init>", arguments);
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
	fflush (stdout);
        return 0;
    }

  return MID_init;
}

jobject createObject (JNIEnv* penv, jclass myClassInDll, const char * arguments)
{
    jmethodID MID_init, mID;
    jobject obj;

    MID_init = (jmethodID)(*(penv))->GetMethodID (penv, myClassInDll, "<init>", arguments);
    if (!MID_init) {
        printf("Error: MyClassInDll.<init>() not found\n");
        return NULL;
    }

      obj = (jobject)(*(penv))->NewObject(penv, myClassInDll, MID_init, (jboolean)true);
      if (!obj) {
        printf("Error: failed to allocate an object\n");
        return NULL;
      }
    return obj;
}

void checkForException(Environment environ, jclass callingClass,  jobject callingObject){

    if ((*(environ.env))->ExceptionCheck(environ.env)) {
	char *  result1;
	const char * errorCode = NULL;
	jthrowable exc = (*(environ.env))->ExceptionOccurred(environ.env);
	(*(environ.env))->ExceptionDescribe(environ.env); //comment code
	 jclass exccls = (jclass)(*(environ.env))->GetObjectClass(environ.env, exc);
        jclass clscls = (jclass)(*(environ.env))->FindClass(environ.env, "java/lang/Class");

        jmethodID getName = (jmethodID)(*(environ.env))->GetMethodID(environ.env, clscls, "getName", "()Ljava/lang/String;");
        jstring name =(jstring)((*(environ.env))->CallObjectMethod(environ.env, exccls, getName));
        char const* utfName = (char const*)(*(environ.env))->GetStringUTFChars(environ.env, name, 0);
	printf(utfName);

	 jmethodID  getMessage = (jmethodID)(*(environ.env))->GetMethodID(environ.env, exccls, "getMessage", "()Ljava/lang/String;");
	if(getMessage) {

		jstring message = (jstring)((*(environ.env))->CallObjectMethod(environ.env, exc, getMessage));
		if(message) {        	
			char const* utfMessage = (char const*)(*(environ.env))->GetStringUTFChars(environ.env, message, 0);
		}
	
	}

     }
	//return NULL;

}


void finalizeJavaRT (JavaVM* jvm)
{
    (*jvm)->DestroyJavaVM (jvm);
}





int transform(Environment environ, int argc, const char* argv[]) {


    jmethodID MID_foo;
    jclass transClass = lookForClass(environ.env, "net/sf/saxon/Transform");
    char methodName[] = "main";
    char args[] = "([Ljava/lang/String;)V";
    jobjectArray stringArray = NULL;
    MID_foo = (jmethodID)(*(environ.env))->GetStaticMethodID(environ.env, transClass, methodName, args);
    if (!MID_foo) {
	printf("\nError: MyClassInDll %s() not found\n",methodName);
	fflush (stdout);
        return -1;
    }
     if(argc < 2) {
	printf("\nError: Not enough arguments in Transform");
	return 0;
    }
	   jclass stringClass = lookForClass(environ.env, "java/lang/String");
	   stringArray = (*(environ.env))->NewObjectArray(environ.env, (jint)argc-1, stringClass, 0 );
	   if(!stringArray) { return 0;}
  int i, j;
  for(i=1, j=0; i< argc; i++, j++) {
	     (*(environ.env))->SetObjectArrayElement(environ.env, stringArray, j, (*(environ.env))->NewStringUTF(environ.env, argv[i]));
	   }

   (*(environ.env))->CallStaticVoidMethod(environ.env, transClass, MID_foo, stringArray);
   
  (*(environ.env))->DeleteLocalRef(environ.env, stringArray);
	return 0;
}




int main( int argc, const char* argv[] )
{
    HANDLE myDllHandle;
    //JNIEnv *(environ.env);
    //JavaVM *jvm;
    jclass  myClassInDll;

    Environment environ;
    /*
     * First of all, load required component.
     * By the time of JET initialization, all components should be loaded.
     */
    environ.myDllHandle = loadDll (dllname);
   

    /*
     * Initialize JET run-time.
     * The handle of loaded component is used to retrieve Invocation API.
     */
    initJavaRT (environ.myDllHandle, &environ.jvm, &environ.env);
    transform(environ, argc, argv);	

  
fflush(stdout);
    /*
     * Finalize JET run-time.
     */
    finalizeJavaRT (environ.jvm);

    return 0;
}
