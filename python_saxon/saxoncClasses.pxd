from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map



cdef extern from "../SaxonProcessor.h":
    cdef cppclass SaxonProcessor:
        SaxonProcessor(bool) except +
        #SaxonProcessor(const char * configFile) except +
        bool license
        char * version()
        void release()

        # set the current working directory
        void setcwd(char* cwd)
        const char* getcwd()

        #SaxonProcessor * getProcessor()

        #set saxon resources directory
        void setResourcesDirectory(const char* dir)
        
        #get saxon resources directory
        const char * getResourcesDirectory()

        #Set a configuration property specific to the processor in use. 
        #Properties specified here are common across all the processors.
        void setConfigurationProperty(char * name, char * value)

        #Clear configuration properties specific to the processor in use. 
        void clearConfigurationProperties()

        bool isSchemaAware()

        XsltProcessor * newXsltProcessor()

        Xslt30Processor * newXslt30Processor()

        XQueryProcessor * newXQueryProcessor()

        XPathProcessor * newXPathProcessor()

        SchemaValidator * newSchemaValidator()

        XdmAtomicValue * makeStringValue(const char* str1)

        XdmAtomicValue * makeIntegerValue(int i)

        XdmAtomicValue * makeDoubleValue(double d)

        XdmAtomicValue * makeFloatValue(float)

        XdmAtomicValue * makeLongValue(long l)

        XdmAtomicValue * make_boolean_value(bool b)

        XdmAtomicValue * makeBooleanValue(bool b)

        XdmAtomicValue * makeQNameValue(const char* str)

        XdmAtomicValue * makeAtomicValue(const char* type, const char* value)

        const char * getStringValue(XdmItem * item)

        XdmNode * parseXmlFromString(const char* source)

        XdmNode * parseXmlFromFile(const char* source)

        XdmNode * parseXmlFromUri(const char* source)

        bool isSchemaAwareProcessor()

        bool exceptionOccurred()

        void exceptionClear()


    cdef cppclass XsltProcessor:
        XsltProcessor() except +
        # set the current working directory
        void setcwd(const char* cwd)

        #Set the source document from an XdmNode for the transformation.
        void setSourceFromXdmNode(XdmNode * value)

        #Set the source from file for the transformation.
        void setSourceFromFile(const char * filename)

        #Set the output file of where the transformation result is sent
        void setOutputFile(const char* outfile)

        void setJustInTimeCompilation(bool jit)

        void setParameter(const char* name, XdmValue*value)

        XdmValue* getParameter(const char* name)

        bool removeParameter(const char* name)

        void setProperty(const char* name, const char* value)

        void clearParameters()

        void clearProperties()

        XdmValue * getXslMessages()

        void transformFileToFile(const char* sourcefile, const char* stylesheetfile, const char* outputfile)
        
        char * transformFileToString(const char* sourcefile, const char* stylesheetfile)

        XdmValue * transformFileToValue(const char* sourcefile, const char* stylesheetfile)

        void compileFromFile(const char* stylesheet)

        void compileFromString(const char* stylesheet)

        void compileFromStringAndSave(const char* stylesheet, const char* filename)

        void compileFromFileAndSave(const char* xslFilename, const char* filename)

        void compileFromXdmNodeAndSave(XdmNode * node, const char* outputfile)

        void compileFromXdmNode(XdmNode * node)

        void releaseStylesheet()

        char * transformToString()

        XdmValue * transformToValue()

        void transformToFile()

        bool exceptionOccurred()

        const char* checkException()

        void exceptionClear()
    
        int exceptionCount()

        const char * getErrorMessage(int)

        const char * getErrorCode(int)


    cdef cppclass Xslt30Processor:
        Xslt30Processor() except +
        # set the current working directory
        void setcwd(const char* cwd)

        void setGlobalContextItem(XdmItem * value)

        # Set the source from file for the transformation.
        void setGlobalContextFromFile(const char * filename)

        # The initial value to which templates are to be applied (equivalent to the <code>select</code> attribute of <code>xsl:apply-templates</code>)
        void setInitialMatchSelection(XdmValue * selection)

        # The initial filename to which templates are to be applied (equivalent to the <code>select</code> attribute of <code>xsl:apply-templates</code>).
        void setInitialMatchSelectionAsFile(const char * filename)

        # Set the output file of where the transformation result is sent
        void setOutputFile(const char* outfile)

        # Say whether just-in-time compilation of template rules should be used.
        void setJustInTimeCompilation(bool jit)

        void setResultAsRawValue(bool option)

        # Set the value of a stylesheet parameter
        void setParameter(const char* name, XdmValue*value, bool _static)

        # Get a parameter value by name
        XdmValue* getParameter(const char* name)

        # Remove a parameter (name, value) pair from a stylesheet
        bool removeParameter(const char* name)

        # Set a property specific to the processor in use.
        void setProperty(const char* name, const char* value)

        void setInitialTemplateParameters(map[string,XdmValue*] parameters, bool tunnel)

        XdmValue ** createXdmValueArray(int len)

        void deleteXdmValueArray(XdmValue** arr, int len)

        # Get a property value by name
        const char* getProperty(const char* name)

        # Get all parameters as a std::map
        map[string,XdmValue*]& getParameters()

        # Get all properties as a std::map
        map[string,string]& getProperties()

        # Clear parameter values set
        void clearParameters(bool deleteValues=false)

        # Clear property values set
        void clearProperties()

        # Get the messages written using the <code>xsl:message</code> instruction
        XdmValue * getXslMessages()

        # Perform a one shot transformation. The result is stored in the supplied outputfile.
        void transformFileToFile(const char* sourcefile, const char* stylesheetfile, const char* outputfile)

        # Perform a one shot transformation. The result is returned as a string
        const char * transformFileToString(const char* sourcefile, const char* stylesheetfile)

        # Perform a one shot transformation. The result is returned as an XdmValue
        XdmValue * transformFileToValue(const char* sourcefile, const char* stylesheetfile)

        # compile a stylesheet file.
        void compileFromFile(const char* stylesheet)

        # compile a stylesheet received as a string.
        void compileFromString(const char* stylesheet)

        # Get the stylesheet associated via the xml-stylesheet processing instruction
        void compileFromAssociatedFile(const char* sourceFile)

        # Compile a stylesheet received as a string and save to an exported file (SEF).
        void compileFromStringAndSave(const char* stylesheet, const char* filename)

        # Compile a stylesheet received as a file and save to an exported file (SEF).
        void compileFromFileAndSave(const char* xslFilename, const char* filename)

        # Compile a stylesheet received as an XdmNode. The compiled stylesheet is cached
        # and available for execution later.
        void compileFromXdmNodeAndSave(XdmNode * node, const char* filename)

        # compile a stylesheet received as an XdmNode.
        void compileFromXdmNode(XdmNode * node)

        # Invoke the stylesheet by applying templates to a supplied input sequence, Saving the results to file.
        void applyTemplatesReturningFile(const char * stylesheetFilename, const char* outfile)

        # Invoke the stylesheet by applying templates to a supplied input sequence, Saving the results as serialized string.
        const char* applyTemplatesReturningString(const char * stylesheetFilename)

        # Invoke the stylesheet by applying templates to a supplied input sequence, Saving the results as an XdmValue.
        XdmValue * applyTemplatesReturningValue(const char * stylesheetFilename)

        # Invoke a transformation by calling a named template and save result to file.
        void callTemplateReturningFile(const char * stylesheetFilename, const char* templateName, const char* outfile)

        # Invoke a transformation by calling a named template and return result as a string.
        const char* callTemplateReturningString(const char * stylesheetFilename, const char* templateName)

        # Invoke a transformation by calling a named template and return result as an XdmValue.
        XdmValue* callTemplateReturningValue(const char * stylesheetFilename, const char* templateName)

        # Call a public user-defined function in the stylesheet
        # Here we wrap the result in an XML document, and sending this document to a specified file
        void callFunctionReturningFile(const char * stylesheetFilename, const char* functionName, XdmValue ** arguments, int argument_length, const char* outfile)

        # Call a public user-defined function in the stylesheet
        # Here we wrap the result in an XML document, and serialized this document to string value
        const char * callFunctionReturningString(const char * stylesheetFilename, const char* functionName, XdmValue ** arguments, int argument_length)

        # Call a public user-defined function in the stylesheet
        # Here we wrap the result in an XML document, and return the document as an XdmVale
        XdmValue * callFunctionReturningValue(const char * stylesheetFilename, const char* functionName, XdmValue ** arguments, int argument_length)

        void addPackages(const char ** fileNames, int length)

        void clearPackages()

        # Internal method to release cached stylesheet
        void releaseStylesheet()

        # Execute transformation to string. Properties supplied in advance.
        const char * transformToString(XdmNode * source)

        # Execute transformation to Xdm Value. Properties supplied in advance.
        XdmValue * transformToValue(XdmNode * source)

        # Execute transformation to file. Properties supplied in advance.
        void transformToFile(XdmNode * source)

        # Checks for pending exceptions without creating a local reference to the exception object
        bool exceptionOccurred()

        # Check for exception thrown.
        const char* checkException()

        # Clear any exception thrown
        void exceptionClear()

        # Get number of errors reported during execution or evaluate of stylesheet
        int exceptionCount()

        # Get the ith error message if there are any error
        const char * getErrorMessage(int i)

        # Get the ith error code if there are any error
        const char * getErrorCode(int i)


    cdef cppclass SchemaValidator:
        SchemaValidator() except +

        void setcwd(const char* cwd)

        void registerSchemaFromFile(const char * xsd)

        void registerSchemaFromString(const char * schemaStr)

        void setOutputFile(const char * outputFile)

        void validate(const char * sourceFile) except +
   
        XdmNode * validateToNode(const char * sourceFile) except +

        void setSourceNode(XdmNode * source)

        XdmNode* getValidationReport()

        void setParameter(const char * name, XdmValue*value)

        bool removeParameter(const char * name)

        void setProperty(const char * name, const char * value)

        void clearParameters()

        void clearProperties()

        bool exceptionOccurred()

        const char* checkException()

        void exceptionClear()

        int exceptionCount()

    
        const char * getErrorMessage(int i)
     
        const char * getErrorCode(int i)

        void setLax(bool l)

    cdef cppclass XPathProcessor:
        XPathProcessor() except +

        void setBaseURI(const char * uriStr)

        XdmValue * evaluate(const char * xpathStr)
   
        XdmItem * evaluateSingle(const char * xpathStr)

        void setContextItem(XdmItem * item)
        
        void setcwd(const char* cwd)

        void setContextFile(const char * filename) 

        bool effectiveBooleanValue(const char * xpathStr)

        void setParameter(const char * name, XdmValue*value)

        bool removeParameter(const char * name)

        void setProperty(const char * name, const char * value)

        void declareNamespace(const char *prefix, const char * uri)

        void setBackwardsCompatible(bool option)

        void setCaching(bool caching)

        void importSchemaNamespace(const char * uri)

        void clearParameters()

        void clearProperties()

        bool exceptionOccurred()

        void exceptionClear()

        int exceptionCount()

        const char * getErrorMessage(int i)

        const char * getErrorCode(int i)

        const char* checkException()

    cdef cppclass XQueryProcessor:
        XQueryProcessor() except +

        void setContextItem(XdmItem * value) except +

        void setOutputFile(const char* outfile)

        void setContextItemFromFile(const char * filename) 

        void setParameter(const char * name, XdmValue*value)

        bool removeParameter(const char * name)

        void setProperty(const char * name, const char * value)

        void clearParameters()

        void clearProperties()

        void setUpdating(bool updating)

        XdmValue * runQueryToValue() except +
        const char * runQueryToString() except +

        void runQueryToFile() except +

        void declareNamespace(const char *prefix, const char * uri) except +

        void setQueryFile(const char* filename)

        void setQueryContent(const char* content)

        void setQueryBaseURI(const char * baseURI)

        void setcwd(const char* cwd)

        const char* checkException()

        bool exceptionOccurred()

        void exceptionClear()

        int exceptionCount()

        const char * getErrorMessage(int i)

        const char * getErrorCode(int i)


cdef extern from "../XdmValue.h":
    cdef cppclass XdmValue:
        XdmValue() except +

        void addXdmItem(XdmItem *val)
        #void releaseXdmValue()

        XdmItem * getHead()

        XdmItem * itemAt(int)

        int size()

        const char * toString()

        void incrementRefCount()

        void decrementRefCount()

        int getRefCount()

        int getType()

cdef extern from "../XdmItem.h":
    cdef cppclass XdmItem(XdmValue):
        XdmItem() except +
        const char * getStringValue()
        bool isAtomic()

cdef extern from "../XdmNode.h":
    cdef cppclass XdmNode(XdmItem):
        bool isAtomic()

        int getNodeKind()

        const char * getNodeName()

        XdmValue * getTypedValue()

        const char* getBaseUri()


        XdmNode* getParent()

        const char* getAttributeValue(const char *str)

        int getAttributeCount()

        XdmNode** getAttributeNodes()

        XdmNode** getChildren()

        int getChildCount()


cdef extern from "../XdmAtomicValue.h":
    cdef cppclass XdmAtomicValue(XdmItem):
        XdmAtomicValue() except +

        const char * getPrimitiveTypeName()

        bool getBooleanValue()

        double getDoubleValue()

        long getLongValue()

