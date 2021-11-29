"""@package saxonc
This documentation details the Python API for Saxon/C, which has been written in cython for Python3.

Saxon/C is a cross-compiled variant of Saxon from the Java platform to the C/C++ platform.
Saxon/C provides processing in XSLT 3.0, XQuery 3.0/3.1 and XPath 2.0/3.0/3.1, and Schema validation 1.0/1.1.
Main classes in Saxon/C Python API: PySaxonProcessor, PyXsltProcessor, PyXslt30Processor, PyXQueryProcessor, PySchemaValidator, PyXdmValue, PyXdmItem, PyXdmNode and PyXdmAtomicValue."""


# distutils: language = c++

cimport saxoncClasses

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map
from nodekind import *
from os.path import isfile

cdef const char * make_c_str(str str_value):
    if str_value is None:
        return NULL
    else:
        c_string = str_value.encode('UTF-8')
        return c_string

cdef str make_py_str(const char * c_value):
    ustring = c_value.decode('UTF-8') if c_value is not NULL else None
    return ustring    
   

cdef class PySaxonProcessor:
    """An SaxonProcessor acts as a factory for generating XQuery, XPath, Schema and XSLT compilers.
    This class is itself the context that needs to be managed (i.e. allocation & release)

    Example:
          with saxonc.PySaxonProcessor(license=False) as proc:
             print("Test Saxon/C on Python")
             print(proc.version)
             xdmAtomicval = proc.make_boolean_value(False)
             xslt30proc = proc.new_xslt30_processor()
    """
    cdef saxoncClasses.SaxonProcessor *thisptr      # hold a C++ instance which we're wrapping

    ##
    # The Constructor
    # @param license Flag that a license is to be used
    # @contextlib.contextmanager
    def __cinit__(self, config_file= None, license=False):
        """
        __cinit__(self, license=False)
        The constructor.

        Args:
            config_file (str): Construct a Saxon processor based upon an configuration file
            license(bool): Flag that a license is to be used. The Default is false.
            
        """
        self.thisptr = new saxoncClasses.SaxonProcessor(license)
            
    def __dealloc__(self):
        """The destructor."""
        del self.thisptr

    def __enter__(self):
      """enter method for use with the keyword 'with' context"""
      return self

    def __exit__(self, exception_type, exception_value, traceback):
        """The exit method for the context PySaxonProcessor. Here we release the Jet VM resources.
        If we have more than one live PySaxonProcessor object the release() method has no effect.
        """
        self.thisptr.release()

    property version:
        """
        Get the Saxon Version.

        Getter:
            str: The Saxon version
        """
        def __get__(self):        
            cdef const char* c_string = self.thisptr.version()
            ustring = c_string.decode('UTF-8')
            return ustring


    def release(self):
        """
        release(self) 
        Clean up and destroy Java VM to release memory used."""

        self.thisptr.release()


    @property
    def cwd(self):
        """
        cwd Property represents the current working directorty

        :str: Get or set the current working directory"""
        cdef const char* c_string = self.thisptr.getcwd()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring


    def set_cwd(self, cwd):
         py_value_string = cwd.encode('UTF-8') if cwd is not None else None
         cdef char * c_str_ = py_value_string if cwd is not None else ""
         self.thisptr.setcwd(c_str_)
    

    def set_resources_directory(self, dir_):
        """
        Property to set or get resources directory 
        
        :str: A string of the resources directory which Saxon will use

        """
        py_value_string = dir_.encode('UTF-8') if dir_ is not None else None
        cdef char * c_str_ = py_value_string if dir_ is not None else ""
        self.thisptr.setResourcesDirectory(c_str_)

    @property
    def resources_directory(self):
        cdef const char* c_string = self.thisptr.getResourcesDirectory()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring
    
    def set_configuration_property(self, name, value):
        """
        set_configuration_property(self, name, value)
        Set configuration property specific to the processor in use.
        Properties set here are common across all processors. 

        Args:
            name (str): The name of the property
            value (str): The value of the property

        Example:
          'l': 'on' or 'off' - to enable the line number

        """
        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_str_ = py_name_string if name is not None else ""
        py_value_string = value.encode('UTF-8') if value is not None else None
        cdef char * c_value_str_ = py_value_string if value is not None else ""
        self.thisptr.setConfigurationProperty(c_str_, c_value_str_)

    def clear_configuration_properties(self):
        """
        clear_configuration_properties(self)
        Clear the configurations properties in use by the processor 

        """
        self.thisptr.clearConfigurationProperties()

    @property
    def is_schema_aware(self):
        """
        is_schema_aware(self)
        Property to check if the processor is Schema aware. A licensed Saxon-EE/C product is schema aware 

        :bool: Indicate if the processor is schema aware, True or False otherwise
        """
        return self.thisptr.isSchemaAwareProcessor()


    def new_xslt_processor(self):
        """
        new_xslt_processor(self)
        Create an PyXsltProcessor. A PyXsltProcessor is used to compile and execute XSLT stylesheets. 

        Returns: 
            PyXsltProcessor: a newly created PyXsltProcessor

        """
        cdef PyXsltProcessor val = PyXsltProcessor()
        val.thisxptr = self.thisptr.newXsltProcessor()
        return val

    def new_xslt30_processor(self):
        """
        new_xslt30_processor(self)
        Create an PyXslt30Processor. A PyXslt30Processor is used to compile and execute XSLT 3.0 stylesheets. 

        Returns: 
            PyXslt30Processor: a newly created PyXslt30Processor

        """
        cdef PyXslt30Processor val = PyXslt30Processor()
        val.thisxptr = self.thisptr.newXslt30Processor()
        return val

    def new_xquery_processor(self):
        """
        new_xquery_processor(self)
        Create an PyXqueryProcessor. A PyXQueryProcessor is used to compile and execute XQuery queries. 

        Returns: 
            PyXQueryProcessor: a newly created PyXQueryProcessor

        """
        cdef PyXQueryProcessor val = PyXQueryProcessor()
        val.thisxqptr = self.thisptr.newXQueryProcessor()
        return val

    def new_xpath_processor(self):
        """
        new_xpath_processor(self)
        Create an PyXPathProcessor. A PyXPathProcessor is used to compile and execute XPath expressions. 

        Returns: 
            PyXPathProcessor: a newly created XPathProcessor

        """
        cdef PyXPathProcessor val = PyXPathProcessor()
        val.thisxpptr = self.thisptr.newXPathProcessor()
        return val

    def new_schema_validator(self):
        """
        new_schema_validator(self)
        Create a PySchemaValidator which can be used to validate instance documents against the schema held by this 

        Returns: 
            PySchemaValidator: a newly created PySchemaValidator

        """
        cdef PySchemaValidator val = PySchemaValidator()
        val.thissvptr = self.thisptr.newSchemaValidator()
        if val.thissvptr is NULL:
            raise Exception("Error: Saxon Processor is not licensed for schema processing!")
        return val

    def make_string_value(self, str_):
        """
        make_string_value(self, str_)
        Factory method. Unlike the constructor, this avoids creating a new StringValue in the case
        of a zero-length string (and potentially other strings, in future)
        
        Args:
            str_ (str): the String value. Null is taken as equivalent to "".

        Returns:
            PyXdmAtomicValue: The corresponding Xdm StringValue

        """
        py_value_string = str_.encode('UTF-8') if str_ is not None else None
        cdef char * c_str_ = py_value_string if str_ is not None else ""
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeStringValue(c_str_)
        return val

    def make_integer_value(self, value):
        """
        make_integer_value(self, value)
        Factory method: makes either an Int64Value or a BigIntegerValue depending on the value supplied
        
        Args:
            value (int): The supplied primitive integer value

        Returns:
            PyXdmAtomicValue: The corresponding Xdm value which is a BigIntegerValue or Int64Value as appropriate

        """
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeIntegerValue(value)
        return val

    def make_double_value(self, value):
        """
        make_double_value(self, value)
        Factory method: makes a double value

        Args:
            value (double): The supplied primitive double value 

        Returns:
            PyXdmAtomicValue: The corresponding Xdm Value
        """
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeDoubleValue(value)
        return val

    def make_float_value(self, value):
        """
        make_float_value(self, value)
        Factory method: makes a float value

        Args:
            value (float): The supplied primitive float value 

        Returns:
            PyXdmAtomicValue: The corresponding Xdm Value
        """

        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeFloatValue(value)
        return val

    def make_long_value(self, value):
        """
        make_long_value(self, value)
        Factory method: makes either an Int64Value or a BigIntegerValue depending on the value supplied

        Args:
            value (long): The supplied primitive long value 

        Returns:
            PyXdmAtomicValue: The corresponding Xdm Value
        """
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeLongValue(value)
        return val

    def make_boolean_value(self, value):
        """
        make_boolean_value(self, value)
        Factory method: makes a XdmAtomicValue representing a boolean Value

        Args:
            value (boolean): True or False, to determine which boolean value is required

        Returns:
            PyAtomicValue: The corresonding XdmValue
        """
        cdef bool c_b = value
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeBooleanValue(c_b)
        return val

    def make_qname_value(self, str_):
        """
        make_qname_value(self, str_)
        Create an QName Xdm value from string representation in clark notation

        Args:
            str_ (str): The value given in a string form in clark notation. {uri}local

        Returns:
            PyAtomicValue: The corresonding value

        """
        py_value_string = str_.encode('UTF-8') if str_ is not None else None
        cdef char * c_str_ = py_value_string if str_ is not None else ""
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeQNameValue(c_str_)
        return val

    def make_atomic_value(self, value_type, value):
        """
        make_atomic_value(self, value_type, value)
        Create an QName Xdm value from string representation in clark notation

        Args:
            str_ (str): The value given in a string form in clark notation. {uri}local

        Returns:
            PyAtomicValue: The corresonding value

        """

        py_valueType_string = value_type.encode('UTF-8') if value_type is not None else None
        cdef char * c_valueType_string = py_valueType_string if value_type is not None else ""
        cdef PyXdmAtomicValue val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = val.thisvptr = self.thisptr.makeAtomicValue(c_valueType_string, value)
        return val

    def get_string_value(self, PyXdmItem item):
        """
        get_string_value(self, PyXdmItem item)
        Create an QName Xdm value from string representation in clark notation

        Args:
            str_ (str): The value given in a string form in clark notation. {uri}local

        Returns:
            PyAtomicValue: The corresonding value

        """
        return self.thisptr.getStringValue(item.derivedptr)

    def parse_xml(self, **kwds):
        """
        parse_xml(self, **kwds)
        Parse a lexical representation, source file or uri of the source document and return it as an Xdm Node

        Args:
            **kwds : The possible keyword arguments must be one of the follow (xml_file_name|xml_text|xml_uri)

        Returns:
            PyXdmNode: The Xdm Node representation of the XML document

        Raises:
            Exception: Error if the keyword argument is not one of xml_file_name|xml_text|xml_uri.
        """
        py_error_message = "Error: parseXml should only contain one of the following keyword arguments: (xml_file_name|xml_text|xml_uri)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef PyXdmNode val = None
        cdef py_value = None
        cdef char * c_xml_string = NULL
        if "xml_text" in kwds:
          py_value = kwds["xml_text"]
          py_xml_text_string = py_value.encode('UTF-8') if py_value is not None else None
          c_xml_string = py_xml_text_string if py_value is not None else "" 
          val = PyXdmNode()
          val.derivednptr = val.derivedptr = val.thisvptr = self.thisptr.parseXmlFromString(c_xml_string)
          return val
        elif "xml_file_name" in kwds:
          py_value = kwds["xml_file_name"]
          py_filename_string = py_value.encode('UTF-8') if py_value is not None else None
          if py_filename_string  is None or isfile(py_filename_string) == False:
            raise Exception("XML file does not exist")
          c_xml_string = py_filename_string if py_value is not None else ""
          val = PyXdmNode()
          val.derivednptr = val.derivedptr = val.thisvptr = self.thisptr.parseXmlFromFile(c_xml_string)
          return val 
        elif "xml_uri" in kwds:
          py_value = kwds["xml_uri"]
          py_uri_string = py_value.encode('UTF-8') if py_value is not None else None
          c_xml_string = py_uri_string if py_value is not None else ""
          val = PyXdmNode()
          val.derivednptr = val.derivedptr = val.thisvptr = self.thisptr.parseXmlFromUri(c_xml_string)
          return val
        else:
           raise Exception(py_error_message)

    def exception_occurred(self):
        """
        exception_occurred(self)
        Check if an exception has occurred internally within Saxon/C

        Returns:
            boolean: True or False if an exception has been reported internally in Saxon/C
        """
        return self.thisptr.exceptionOccurred()

    def exception_clear(self):
        """
        exceltion_clear(self)
        Clear any exception thrown internally in Saxon/C.


        """
        self.thisptr.exceptionClear()


cdef class PyXsltProcessor:
     """An PyXsltProcessor represents factory to compile, load and execute a stylesheet.
     It is possible to cache the context and the stylesheet in the PyXsltProcessor """

     cdef saxoncClasses.XsltProcessor *thisxptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        """Default constructor """
        self.thisxptr = NULL
     def __dealloc__(self):
        if self.thisxptr != NULL:
           del self.thisxptr
     def set_cwd(self, cwd):
        """
        set_cwd(self, cwd)
        Set the current working directory.

        Args:
            cwd (str): current working directory
        """
        py_cwd_string = cwd.encode('UTF-8') if cwd is not None else None
        cdef char * c_cwd = py_cwd_string if cwd is not None else "" 
        self.thisxptr.setcwd(c_cwd)

     def set_source(self, **kwds):
        """Set the source document for the transformation.

        Args:
            **kwds: Keyword argument can only be one of the following: file_name|xdm_node
        Raises:
            Exception: Exception is raised if keyword argument is not one of file_name or node.
        """

        py_error_message = "Error: setSource should only contain one of the following keyword arguments: (file_name|xdm_node)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmNode xdm_node = None
        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else "" 
            self.thisxptr.setSourceFromFile(c_source)
        elif "xdm_node" in kwds:
            xdm_node = kwds["xdm_node"]
            self.thisxptr.setSourceFromXdmNode(xdm_node.derivednptr)
        else:
          raise Exception(py_error_message)

     def set_output_file(self, output_file):
        """
        set_output_file(self, output_file)
        Set the output file where the output of the transformation will be sent

        Args:
            output_file (str): The output file supplied as a str

        """
        py_filename_string = output_file.encode('UTF-8') if output_file is not None else None
        cdef char * c_outputfile = py_filename_string if output_file is not None else ""
        self.thisxptr.setOutputFile(c_outputfile)

     def set_jit_compilation(self, bool jit):
        """
        set_jit_compilation(self, jit)
        Say whether just-in-time compilation of template rules should be used.

        Args:
            jit (bool): True if just-in-time compilation is to be enabled. With this option enabled,
                static analysis of a template rule is deferred until the first time that the
                template is matched. This can improve performance when many template
                rules are rarely used during the course of a particular transformation; however,
                it means that static errors in the stylesheet will not necessarily cause the
                compile(Source) method to throw an exception (errors in code that is
                actually executed will still be notified but this may happen after the compile(Source)
                method returns). This option is enabled by default in Saxon-EE, and is not available
                in Saxon-HE or Saxon-PE.
                Recommendation: disable this option unless you are confident that the
                stylesheet you are compiling is error-free. 

        """
        cdef bool c_jit
        c_jit = jit
        self.thisxptr.setJustInTimeCompilation(c_jit)
        #else:
        #raise Warning("setJustInTimeCompilation: argument must be a boolean type. JIT not set")
     def set_parameter(self, name, PyXdmValue value):
        """
        set_parameter(self, PyXdmValue value)
        Set the value of a stylesheet parameter

        Args:
            name (str): the name of the stylesheet parameter, as a string. For namespaced parameter use the JAXP solution i.e. "{uri}name
            value (PyXdmValue): the value of the stylesheet parameter, or null to clear a previously set value

        """
        cdef const char * c_str = make_c_str(name)
        if c_str is not NULL:
            value.thisvptr.incrementRefCount()
            self.thisxptr.setParameter(c_str, value.thisvptr)

     def get_parameter(self, name):
        """
        get_parameter(self, name)
        Get a parameter value by a given name

        Args:
            name (str): The name of the stylesheet parameter

        Returns:
            PyXdmValue: The Xdm value of the parameter  


        """
        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_name_string if name is not None else ""
        cdef PyXdmValue val = PyXdmValue()
        val.thisvptr = self.thisxptr.getParameter(c_name)
        return val

     def remove_parameter(self, name):
        """
        remove_parameter(self, name)
        Remove the parameter given by name from the PyXsltProcessor. The parameter will not have any affect on the stylesheet if it has not yet been executed

        Args:
            name (str): The name of the stylesheet parameter

        Returns:
            bool: True if the removal of the parameter has been successful, False otherwise.

        """

        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_name_string if name is not None else ""
        return self.thisxptr.removeParameter(c_name)

     def set_property(self, name, value):
        """
        set_property(self, name, value)
        Set a property specific to the processor in use.
 
        Args:
            name (str): The name of the property
            value (str): The value of the property

        Example:
            XsltProcessor: set serialization properties (names start with '!' i.e. name "!method" -> "xml")\r
            'o':outfile name,\r
            'it': initial template,\r 
            'im': initial mode,\r
            's': source as file name\r
            'm': switch on message listener for xsl:message instructions,\r
            'item'| 'node' : source supplied as an XdmNode object,\r
            'extc':Set the native library to use with Saxon for extension functions written in C/C++/PHP\r

        """

        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_name_string if name is not None else ""
        py_value_string = value.encode('UTF-8') if value is not None else None
        cdef char * c_value = py_value_string if value is not None else ""
        self.thisxptr.setProperty(c_name, c_value)

     def clear_parameters(self):
        """
        clear_parameter(self)
        Clear all parameters set on the processor for execution of the stylesheet
        """

        self.thisxptr.clearParameters()
     def clear_properties(self):
        """
        clear_properties(self)
        Clear all properties set on the processor
        """

        self.thisxptr.clearProperties()
     def get_xsl_messages(self):
        """
        Get the messages written using the <code>xsl:message</code> instruction
        get_xsl_message(self)
        
        Returns:
            PyXdmValue: Messages returned as an XdmValue. 

        """

        cdef PyXdmValue val = PyXdmValue()
        val.thisvptr = self.thisxptr.getXslMessages()
        return val

     def transform_to_string(self, **kwds):
        """
        transform_to_string(self, **kwds)
        Execute transformation to string.

        Args:
            **kwds: Possible arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str)


        Example:

            1) result = xsltproc.transform_to_string(source_file="cat.xml", stylesheet_file="test1.xsl")

            2) xsltproc.set_source("cat.xml")\r
               result = xsltproc.transform_to_string(stylesheet_file="test1.xsl")


            3) node = saxon_proc.parse_xml(xml_text="<in/>")\r
               result = xsltproc.transform_to_string(stylesheet_file="test1.xsl", xdm_node= node)
        """

        cdef char * c_sourcefile
        cdef char * c_stylesheetfile
        py_source_string = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              py_source_string = value.encode('UTF-8') if value is not None else None
              if py_source_string  is None or isfile(py_source_string) == False:
                raise Exception("source file name does not exist")
              c_sourcefile = py_source_string if value is not None else "" 
            if key == "stylesheet_file":
              py_stylesheet_string = value.encode('UTF-8') if value is not None else None
              if py_stylesheet_string  is None or isfile(py_stylesheet_string) == False:
                raise Exception("Stylesheet file does not exist")
              c_stylesheetfile = py_stylesheet_string if value is not None else ""
          elif key == "xdm_node":
            if isinstance(value, PyXdmNode):
              self.setSourceFromXdmNode(value)
          elif len(kwds) > 0:
            raise Warning("Warning: transform_to_string should only the following keyword arguments: (source_file, stylesheet_file, xdm_node)")

        cdef const char* c_string            
        if len(kwds) == 0:
          c_string = self.thisxptr.transformToString()
        else:     
          c_string = self.thisxptr.transformFileToString(c_sourcefile if py_source_string is not None else NULL, c_stylesheetfile if py_stylesheet_string is not None else NULL)

        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def transform_to_file(self, **kwds):
        """
        transform_to_file(self, **kwds)
        Execute transformation to a file. It is possible to specify the as an argument or using the set_output_file method.       
        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str), output_file (str)


        Example:

            1) xsltproc.transform_to_file(source_file="cat.xml", stylesheet_file="test1.xsl", output_file="result.xml")

            2) xsltproc.set_source("cat.xml")\r
               xsltproc.setoutput_file("result.xml")\r
               xsltproc.transform_to_file(stylesheet_file="test1.xsl")


            3) node = saxon_proc.parse_xml(xml_text="<in/>")\r
               xsltproc.transform_to_file(output_file="result.xml", stylesheet_file="test1.xsl", xdm_node= node)        
        """
        cdef char * c_sourcefile
        cdef char * c_outputfile
        cdef char * c_stylesheetfile
        py_source_string = None
        py_stylesheet_string = None
        py_output_string = None
        cdef PyXdmNode node_
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              py_source_string = value.encode('UTF-8') if value is not None else None
              c_sourcefile = py_source_string if value is not None else ""
            if key == "output_file":
              py_output_string = value.encode('UTF-8') if value is not None else None
              c_outputfile = py_output_string if value is not None else ""  
            if key == "stylesheet_file":
              py_stylesheet_string = value.encode('UTF-8') if value is not None else None
              c_stylesheetfile = py_stylesheet_string if value is not None else ""
          elif key == "xdm_node":
            if isinstance(value, PyXdmNode):
              node_ = value
              self.thisxptr.setSourceFromXdmNode(node_.derivednptr)
            
        if len(kwds) == 0:
          self.thisxptr.transformToFile()
        else:     
          self.thisxptr.transformFileToFile(c_sourcefile if py_source_string is not None else NULL, c_stylesheetfile if py_stylesheet_string is not None else NULL, c_outputfile if py_output_string is not None else NULL)


     def transform_to_value(self, **kwds):
        """
        transform_to_value(self, **kwds)
        Execute transformation to an Xdm Node

        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmNode: Result of the transformation as an PyXdmNode object


        Example:

            1) node = xsltproc.transform_to_value(source_file="cat.xml", stylesheet_file="test1.xsl")

            2) xsltproc.set_source("cat.xml")\r
               node = xsltproc.transform_to_value(stylesheet_file="test1.xsl")


            3) node = saxon_proc.parse_xml(xml_text="<in/>")\r
               node = xsltproc.transform_tovalue(stylesheet_file="test1.xsl", xdm_node= node)        
        """
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        py_source_string = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)  
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_node":
            if isinstance(value, PyXdmNode):
              self.setSourceFromXdmNode(value)
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        if len(kwds) == 0:
          xdmValue = self.thisxptr.transformToValue()
        else:     
          xdmValue = self.thisxptr.transformFileToValue(c_sourcefile, c_stylesheetfile)

        if xdmValue is NULL:
            return None        
        cdef type_ = xdmValue.getType()
        if type_== 4:
            aval = PyXdmAtomicValue()
            aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
            return aval        
        elif type_ == 3:
            nval = PyXdmNode()        
            nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
            return nval
        else:
            val = PyXdmValue()
            val.thisvptr = xdmValue
            return val

     def compile_stylesheet(self, **kwds):
        """
        compile_stylesheet(self, **kwds)
        Compile a stylesheet  received as text, uri or as a node object. The compiled stylesheet is cached and available for execution
        later. It is also possible to save the compiled stylesheet (SEF file) given the option 'save' and 'output_file'
   
        Args:
            **kwds: Possible keyword arguments stylesheet_text (str), stylesheet_file (str) or stylsheetnode (PyXdmNode). Also possible
                    to add the options save (boolean) and output_file, which creates an exported stylesheet to file (SEF).

        Example:
            1. xsltproc.compile_stylesheet(stylesheet_text="<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
            <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output>
              <xsl:value-of select='//person[1]'/>
              <xsl:for-each select='$values' >
                <out><xsl:value-of select='. * 3'/></out>
              </xsl:for-each></output></xsl:template>
            </xsl:stylesheet>")

            2. xsltproc.compile_stylesheet(stylesheet_file="test1.xsl", save=True, output_file="test1.sef")
        """
        py_error_message = "CompileStylesheet should only be one of the keyword option: (stylesheet_text|stylesheet_file|stylesheet_node), also in allowed in addition the optional keyword 'save' boolean with the keyword 'outputfile' keyword"
        if len(kwds) >3:
          raise Exception(py_error_message)
        cdef char * c_outputfile
        cdef char * c_stylesheet
        py_output_string = None
        py_stylesheet_string = None
        py_save = False
        cdef int option = 0
        cdef PyXdmNode py_xdmNode = None
        if kwds.keys() >= {"stylesheet_text", "stylesheet_file"}:
          raise Exception(py_error_message)
        if kwds.keys() >= {"stylesheet_text", "stylesheet_node"}:
          raise Exception(py_error_message)
        if kwds.keys() >= {"stylesheet_node", "stylesheet_file"}:
          raise Exception(py_error_message)

        if ("save" in kwds) and kwds["save"]==True:
          del kwds["save"]
          if "output_file" not in kwds:
            raise Exception("Output file option not in keyword arugment for compile_stylesheet")
          py_output_string = kwds["output_file"].encode('UTF-8')
          c_outputfile = py_output_string
          if "stylesheet_text" in kwds:
            py_stylesheet_string = kwds["stylesheet_text"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromStringAndSave(c_stylesheet, c_outputfile)
          elif "stylesheet_file" in kwds:
            py_stylesheet_string = kwds["stylesheet_file"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromFileAndSave(c_stylesheet, c_outputfile)
          elif "stylesheet_node" in kwds:
            py_xdmNode = kwds["stylesheet_node"]
            #if not isinstance(py_value, PyXdmNode):
              #raise Exception("StylesheetNode keyword arugment is not of type XdmNode")
            #value = PyXdmNode(py_value)
            self.thisxptr.compileFromXdmNodeAndSave(py_xdmNode.derivednptr, c_outputfile)
          else:
            raise Exception(py_error_message)
        else:
          if "stylesheet_text" in kwds:
            py_stylesheet_string = kwds["stylesheet_text"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromString(c_stylesheet)
          elif "stylesheet_file" in kwds:
            py_stylesheet_string = kwds["stylesheet_file"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromFile(c_stylesheet)
          elif "stylesheet_node" in kwds:
            py_xdmNode = kwds["stylesheet_node"]
            #if not isinstance(py_value, PyXdmNode):
              #raise Exception("StylesheetNode keyword arugment is not of type XdmNode")
            #value = PyXdmNode(py_value)
            self.thisxptr.compileFromXdmNode(py_xdmNode.derivednptr)
          else:
            raise Exception(py_error_message)

     def release_stylesheet(self):
        """
        release_stylesheet(self)
        Release cached stylesheet

        """
        self.thisxptr.releaseStylesheet()

     def exception_occurred(self):
        """
        exception_occurred(self)
        Checks for pending exceptions without creating a local reference to the exception object
        Returns:
            boolean: True when there is a pending exception; otherwise return False        

        """
        return self.thisxptr.exceptionCount() >0

     def check_exception(self):
        """
        check_exception(self)
        Check for exception thrown and get message of the exception.
  
        Returns:
            str: Returns the exception message if thrown otherwise return None

        """
        cdef const char* c_string = self.thisxptr.checkException()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def exception_clear(self):
        """
        exception_clear(self)
        Clear any exception thrown

        """
        self.thisxptr.exceptionClear()

     def exception_count(self):
        """
        excepton_count(self)
        Get number of errors reported during execution.

        Returns:
            int: Count of the exceptions thrown during execution
        """
        return self.thisxptr.exceptionCount()

     def get_error_message(self, index):
        """
        get_error_message(self, index)
        A transformation may have a number of errors reported against it. Get the ith error message if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The message of the i'th exception. Return None if the i'th exception does not exist.
        """
        cdef const char* c_string = self.thisxptr.getErrorMessage(index)
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def get_error_code(self, index):
        """
        get_error_code(self, index)
        A transformation may have a number of errors reported against it. Get the i'th error code if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The error code associated with the i'th exception. Return None if the i'th exception does not exist.

        """
        cdef const char* c_string = self.thisxptr.getErrorCode(index)
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

parametersDict = None

cdef class PyXslt30Processor:
     """An PyXslt30Processor represents factory to compile, load and execute a stylesheet.
     It is possible to cache the context and the stylesheet in the PyXslt30Processor """

     cdef saxoncClasses.Xslt30Processor *thisxptr      # hold a C++ instance which we're wrapping


     def __cinit__(self):
        """Default constructor """
        self.thisxptr = NULL
     def __dealloc__(self):
        if self.thisxptr != NULL:
           del self.thisxptr
     def set_cwd(self, cwd):
        """
        set_cwd(self, cwd)
        Set the current working directory.

        Args:
            cwd (str): current working directory
        """
        py_cwd_string = cwd.encode('UTF-8') if cwd is not None else None
        cdef char * c_cwd = py_cwd_string if cwd is not None else ""
        self.thisxptr.setcwd(c_cwd)

     def set_global_context_item(self, **kwds):
        """Set the global context item for the transformation.

        Args:
            **kwds: Keyword argument can only be one of the following: file_name|xdm_item
        Raises:
            Exception: Exception is raised if keyword argument is not one of file_name or an Xdm item.
        """

        py_error_message = "Error: set_global_context_item should only contain one of the following keyword arguments: (file_name|xdm_item)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmItem xdm_item = None
        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else ""
            self.thisxptr.setGlobalContextFromFile(c_source)
        elif "xdm_item" in kwds:
            if isinstance(kwds["xdm_item"], PyXdmItem):
                xdm_item = kwds["xdm_item"]
                self.thisxptr.setGlobalContextItem(xdm_item.derivedptr)
            else:
                raise Exception("xdm_item value must be of type PyXdmItem")
        else:
          raise Exception(py_error_message)

     def set_initial_match_selection(self, **kwds):
        """
        set_initial_match_selection(self, **kwds)
        The initial filename to which templates are to be applied (equivalent to the <code>select</code> attribute of <code>xsl:apply-templates</code>).

        Args:
            **kwds: Keyword argument can only be one of the following: file_name|xdm_value
        Raises:
            Exception: Exception is raised if keyword argument is not one of file_name or XdmValue.
        """

        py_error_message = "Error: set_initial_match_selection should only contain one of the following keyword arguments: (file_name|xdm_value)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmValue xdm_value = None
        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else ""
            self.thisxptr.setInitialMatchSelectionAsFile(c_source)
        elif "xdm_value" in kwds:
            xdm_value = kwds["xdm_value"]
            self.thisxptr.setInitialMatchSelection(xdm_value.thisvptr)
        else:
          raise Exception(py_error_message)

     def set_output_file(self, output_file):
        """
        set_output_file(self, output_file)
        Set the output file where the output of the transformation will be sent

        Args:
            output_file (str): The output file supplied as a str

        """
        py_filename_string = output_file.encode('UTF-8') if output_file is not None else None
        cdef char * c_outputfile = py_filename_string if output_file is not None else ""
        self.thisxptr.setOutputFile(c_outputfile)

     def set_jit_compilation(self, bool jit):
        """
        set_jit_compilation(self, jit)
        Say whether just-in-time compilation of template rules should be used.

        Args:
            jit (bool): True if just-in-time compilation is to be enabled. With this option enabled,
                static analysis of a template rule is deferred until the first time that the
                template is matched. This can improve performance when many template
                rules are rarely used during the course of a particular transformation; however,
                it means that static errors in the stylesheet will not necessarily cause the
                compile(Source) method to throw an exception (errors in code that is
                actually executed will still be notified but this may happen after the compile(Source)
                method returns). This option is enabled by default in Saxon-EE, and is not available
                in Saxon-HE or Saxon-PE.
                Recommendation: disable this option unless you are confident that the
                stylesheet you are compiling is error-free.

        """
        cdef bool c_jit
        c_jit = jit
        self.thisxptr.setJustInTimeCompilation(c_jit)
        #else:
        #raise Warning("setJustInTimeCompilation: argument must be a boolean type. JIT not set")


     def set_result_as_raw_value(self, bool is_raw):
        """
        set_result_as_raw_value(self, is_raw)
        Set true if the return type of callTemplate, applyTemplates and transform methods is to return XdmValue, otherwise return XdmNode object with root Document node

        Args:
            is_raw (bool): True if returning raw result, i.e. XdmValue, otherwise return XdmNode

        """
        cdef bool c_raw
        c_raw = is_raw
        self.thisxptr.setResultAsRawValue(c_raw)
        #else:
        #raise Warning("setJustInTimeCompilation: argument must be a boolean type. JIT not set")

     def set_parameter(self, name, PyXdmValue value):
        """
        set_parameter(self, PyXdmValue value)
        Set the value of a stylesheet parameter

        Args:
            name (str): the name of the stylesheet parameter, as a string. For namespaced parameter use the JAXP solution i.e. "{uri}name
            value (PyXdmValue): the value of the stylesheet parameter, or null to clear a previously set value

        """
        cdef const char * c_str = make_c_str(name)
        if c_str is not NULL:
            '''value.thisvptr.incrementRefCount()
            print("set_parameter called")'''
            self.thisxptr.setParameter(c_str, value.thisvptr, False)

     def get_parameter(self, name):
        """
        get_parameter(self, name)
        Get a parameter value by a given name

        Args:
            name (str): The name of the stylesheet parameter

        Returns:
            PyXdmValue: The Xdm value of the parameter


        """
        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_name_string if name is not None else ""
        cdef PyXdmValue val = PyXdmValue()
        val.thisvptr = self.thisxptr.getParameter(c_name)
        return val

     def remove_parameter(self, name):
        """
        remove_parameter(self, name)
        Remove the parameter given by name from the PyXslt30Processor. The parameter will not have any affect on the stylesheet if it has not yet been executed

        Args:
            name (str): The name of the stylesheet parameter

        Returns:
            bool: True if the removal of the parameter has been successful, False otherwise.

        """

        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_name_string if name is not None else ""
        return self.thisxptr.removeParameter(c_name)

     def set_property(self, name, value):
        """
        set_property(self, name, value)
        Set a property specific to the processor in use.

        Args:
            name (str): The name of the property
            value (str): The value of the property

        Example:
            XsltProcessor: set serialization properties (names start with '!' i.e. name "!method" -> "xml")\r
            'o':outfile name,\r
            'it': initial template,\r
            'im': initial mode,\r
            's': source as file name\r
            'm': switch on message listener for xsl:message instructions,\r
            'item'| 'node' : source supplied as an XdmNode object,\r
            'extc':Set the native library to use with Saxon for extension functions written in C/C++/PHP\r

        """

        py_name_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_name_string if name is not None else ""
        py_value_string = value.encode('UTF-8') if value is not None else None
        cdef char * c_value = py_value_string if value is not None else ""
        self.thisxptr.setProperty(c_name, c_value)

     def clear_parameters(self):
        """
        clear_parameter(self)
        Clear all parameters set on the processor for execution of the stylesheet
        """

        self.thisxptr.clearParameters()
     def clear_properties(self):
        """
        clear_properties(self)
        Clear all properties set on the processor
        """

        self.thisxptr.clearProperties()


     def set_initial_template_parameters(self, bool tunnel, dict kwds):
        """
        set_initial_template_parameters(self, bool tunnel, **kwds)
        Set parameters to be passed to the initial template. These are used
        whether the transformation is invoked by applying templates to an initial source item,
        or by invoking a named template. The parameters in question are the xsl:param elements
        appearing as children of the xsl:template element.

        TODO: To fix issue where we pass XdmValue object created directly in the function argument. This causes seg error
        e.g. set_initial_template_parameter(False, {a:saxonproc.make_integer_value(12)})
        Do the following instead:
        paramArr = {a:saxonproc.make_integer_value(12)}
        set_initial_template_parameter(False, paramArr)

        Args:
        	tunnel (bool): True if these values are to be used for setting tunnel parameters;
        	**kwds: the parameters to be used for the initial template supplied as an key-value pair.
        	False if they are to be used for non-tunnel parameters. The default is false.

        Example:

        	1)paramArr = {'a':saxonproc.make_integer_value(12), 'b':saxonproc.make_integer_value(5)} 
                  xsltproc.set_initial_template_parameters(False, paramArr)
        """
        cdef map[string, saxoncClasses.XdmValue * ] parameters
        cdef bool c_tunnel
        cdef string key_str
        c_tunnel = tunnel
        cdef PyXdmAtomicValue value_
        global parametersDict
        if kwds is not None:
                parametersDict = kwds
        for (key, value) in kwds.items():
                if isinstance(value, PyXdmAtomicValue):
                        value_ = value
                        key_str = key.encode('UTF-8')
                        value_.derivedptr.incrementRefCount()
                        parameters[key_str] = <saxoncClasses.XdmValue *> value_.derivedaptr
                else:
                        raise Exception("Initial template parameters can only be of type PyXdmValue")
        if len(kwds) > 0:
            self.thisxptr.setInitialTemplateParameters(parameters, c_tunnel);

     def get_xsl_messages(self):
        """
        Get the messages written using the <code>xsl:message</code> instruction
        get_xsl_message(self)

        Returns:
            PyXdmValue: Messages returned as an XdmValue.

        """

        cdef PyXdmValue val = PyXdmValue()
        val.thisvptr = self.thisxptr.getXslMessages()
        return val

     def transform_to_string(self, **kwds):
        """
        transform_to_string(self, **kwds)
        Execute transformation to string.

        Args:
            **kwds: Possible arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str)


        Example:

            1) result = xsltproc.transform_to_string(source_file="cat.xml", stylesheet_file="test1.xsl")

            2) xsltproc.set_source("cat.xml")\r
               result = xsltproc.transform_to_string(stylesheet_file="test1.xsl")


            3) node = saxon_proc.parse_xml(xml_text="<in/>")\r
               result = xsltproc.transform_to_string(stylesheet_file="test1.xsl", xdm_node= node)
        """

        cdef char * c_sourcefile
        cdef char * c_stylesheetfile
        py_source_string = None
        py_stylesheet_string = None
        cdef PyXdmNode node_ = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              py_source_string = value.encode('UTF-8') if value is not None else None
              c_sourcefile = py_source_string if value is not None else ""
            if key == "stylesheet_file":
              py_stylesheet_string = value.encode('UTF-8') if value is not None else None
              c_stylesheetfile = py_stylesheet_string if value is not None else ""
          elif key == "xdm_node":
            if isinstance(value, PyXdmNode):
              node_ = value
          elif len(kwds) > 0:
            raise Warning("Warning: transform_to_string should only contain the following keyword arguments: (source_file|xdm_node, stylesheet_file)")

        cdef const char* c_string
        if node_ is not None:
          if py_stylesheet_string is not None:
            self.thisxptr.compileFromFile(c_stylesheetfile)
          c_string = self.thisxptr.transformToString(node_.derivednptr)
        else:
          c_string = self.thisxptr.transformFileToString(c_sourcefile if py_source_string is not None else NULL, c_stylesheetfile if py_stylesheet_string is not None else NULL)

        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def transform_to_file(self, **kwds):
        """
        transform_to_file(self, **kwds)
        Execute transformation to a file. It is possible to specify the as an argument or using the set_output_file method.
        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str), output_file (str)


        Example:

            1) xsltproc.transform_to_file(source_file="cat.xml", stylesheet_file="test1.xsl", output_file="result.xml")

            2) xsltproc.set_source("cat.xml")\r
               xsltproc.setoutput_file("result.xml")\r
               xsltproc.transform_to_file(stylesheet_file="test1.xsl")


            3) node = saxon_proc.parse_xml(xml_text="<in/>")\r
               xsltproc.transform_to_file(output_file="result.xml", stylesheet_file="test1.xsl", xdm_node= node)
        """
        cdef char * c_sourcefile
        cdef char * c_outputfile
        cdef char * c_stylesheetfile
        py_source_string = None
        py_stylesheet_string = None
        py_output_string = None
        cdef PyXdmNode node_ = None
        for key, value in kwds.items():
                if isinstance(value, str):
                        if key == "source_file":
                                py_source_string = value.encode('UTF-8') if value is not None else None
                                c_sourcefile = py_source_string if value is not None else ""
                        if key == "output_file":
                                py_output_string = value.encode('UTF-8') if value is not None else None
                                c_outputfile = py_output_string if value is not None else ""
                        if key == "stylesheet_file":
                                py_stylesheet_string = value.encode('UTF-8') if value is not None else None
                                c_stylesheetfile = py_stylesheet_string if value is not None else ""
                        elif key == "xdm_node":
                                if isinstance(value, PyXdmNode):
                                        node_ = value
              
        if node_ is not None:
                if py_output_string is not None:
                        self.thisxptr.setOutputFile(c_outputfile);
                self.thisxptr.transformToFile(node_.derivednptr)
        else:
                self.thisxptr.transformFileToFile(c_sourcefile if py_source_string is not None else NULL, c_stylesheetfile if py_stylesheet_string is not None else NULL, c_outputfile if py_output_string is not None else NULL)


     def transform_to_value(self, **kwds):
        """
        transform_to_value(self, **kwds)
        Execute transformation to an Xdm Node

        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmNode: Result of the transformation as an PyXdmNode object


        Example:

            1) node = xsltproc.transform_to_value(source_file="cat.xml", stylesheet_file="test1.xsl")

            2) xsltproc.set_source("cat.xml")\r
               node = xsltproc.transform_to_value(stylesheet_file="test1.xsl")


            3) node = saxon_proc.parse_xml(xml_text="<in/>")\r
               node = xsltproc.transform_tovalue(stylesheet_file="test1.xsl", xdm_node= node)
        """
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmNode node_ = None
        py_source_string = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_node":
            if isinstance(value, PyXdmNode):
              node_ = value
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        if len(kwds) == 1 and node_ is not None:
          xdmValue = self.thisxptr.transformToValue(node_.derivednptr)
        else:
          xdmValue = self.thisxptr.transformFileToValue(c_sourcefile, c_stylesheetfile)

        if xdmValue is NULL:
            return None
        cdef type_ = xdmValue.getType()
        if type_== 4:
            aval = PyXdmAtomicValue()
            aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
            return aval
        elif type_ == 3:
            nval = PyXdmNode()
            nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
            return nval
        else:
            val = PyXdmValue()
            val.thisvptr = xdmValue
            return val

     def apply_templates_returning_value(self, **kwds):
        """
        apply_templates_returning_value(self, **kwds)
        Invoke the stylesheet by applying templates to a supplied input sequence, Saving the results as an XdmValue.

        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:

            1) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               node = xsltproc.apply_templates_returning_value(stylesheet_file="test1.xsl")


            2) xsltproc.compile_stylesheet(stylesheet_file="test1.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               node = xsltproc.apply_templates_returning_value()

        """
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        xdmValue = self.thisxptr.applyTemplatesReturningValue(c_stylesheetfile)

        if xdmValue is NULL:
            return None
        cdef type_ = xdmValue.getType()
        if type_== 4:
            aval = PyXdmAtomicValue()
            aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
            return aval
        elif type_ == 3:
            nval = PyXdmNode()
            nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
            return nval
        else:
            val = PyXdmValue()
            val.thisvptr = xdmValue
            return val


     def apply_templates_returning_string(self, **kwds):
        """
        apply_templates_returning_string(self, **kwds)
        Invoke the stylesheet by applying templates to a supplied input sequence, Saving the results as a str.

        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:

            1) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               content = xsltproc.apply_templates_returning_str(stylesheet_file="test1.xsl")
			   print(content)

        """
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)
        cdef const char* c_string  = self.thisxptr.applyTemplatesReturningString(c_stylesheetfile) 
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def apply_templates_returning_file(self, **kwds):
        """
        apply_templates_returning_file(self, **kwds)
        Invoke the stylesheet by applying templates to a supplied input sequence, Saving the 
        results to file.

        Args:
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). 
            Other allowed argument: stylesheet_file (str) and the required argument output_file (str)


        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:

            1) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               content = xsltproc.apply_templates_returning_file(stylesheet_file="test1.xsl", output_file="result.xml")
			   print(content)

        """
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef const char * c_outputfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_stylesheet_string = None
        py_output_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "output_file":
              py_output_string = value.encode('UTF-8') if value is not None else None
              c_outputfile = py_output_string if value is not None else ""
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_value":
            if isinstance(value, PyXdmNode):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)
        self.thisxptr.applyTemplatesReturningFile(c_stylesheetfile, c_outputfile) 
        

     def call_template_returning_value(self, str template_name=None, **kwds):
        """
        call_template_returning_value(self, str template_name, **kwds)
        Invoke a transformation by calling a named template and return result as an PyXdmValue.

        Args:
			template_name(str): The name of the template to invoke. If None is supplied then call the initial-template
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:
            1) node = xsltproc.call_template_returning_value("main", stylesheet_file="test1.xsl")


            2) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               node = xsltproc.call_template_returning_value("main", stylesheet_file="test1.xsl")


            3) xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               node = xsltproc.call_template_returning_value("go")

        """
        cdef const char * c_templateName = NULL
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_template_name_str = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_node":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)

        c_templateName = make_c_str(template_name)
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        xdmValue = self.thisxptr.callTemplateReturningValue(c_stylesheetfile, c_templateName)

        if xdmValue is NULL:
            return None
        cdef type_ = xdmValue.getType()
        if type_== 4:
            aval = PyXdmAtomicValue()
            aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
            return aval
        elif type_ == 3:
            nval = PyXdmNode()
            nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
            return nval
        else:
            val = PyXdmValue()
            val.thisvptr = xdmValue
            return val



     def call_template_returning_string(self, str template_name=None, **kwds):
        """
        call_template_returning_string(self, str template_name, **kwds)
        Invoke a transformation by calling a named template and return result as a string.

        Args:
			template_name(str): The name of the template to invoke. If None is supplied then call the initial-template
            **kwds: Possible optional arguments: source_file (str) or xdm_Value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:
            1) result = xsltproc.call_template_returning_string("main", stylesheet_file="test1.xsl")


            2) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               result = xsltproc.call_template_returning_string("main", stylesheet_file="test1.xsl")

        cdef const char * c_templateName = NULL

            3) xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               result = xsltproc.call_template_returning_string("go")
			   print(result)
        """
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmNode value_ = None
        py_source_string = None
        py_template_name_str = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)

        c_templateName = make_c_str(template_name)
        cdef const char* c_string  = self.thisxptr.callTemplateReturningString(c_stylesheetfile, c_templateName) 
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring


     def call_template_returning_file(self, str template_name=None, **kwds):
        """
        call_template_returning_file(self, str template_name, **kwds)
        Invoke a transformation by calling a named template and save result in a specified file.

        Args:
			template_name(str): The name of the template to invoke. If None is supplied then call the initial-template
            **kwds: Possible optional arguments: source_file (str) or xdm_node (PyXdmNode). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:
            1) xsltproc.call_template_returning_file("main", stylesheet_file="test1.xsl",  output_file="result.xml")


            2) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               xsltproc.call_template_returning_file("main", stylesheet_file="test1.xsl", output_file="result.xml")


            3) xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               xsltproc.call_template_returning_file("go", output_file="result.xml")
			   print(result)
        """
        cdef char * c_outputfile = NULL       
        cdef const char * c_templateName = NULL
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_template_name_str = None
        py_stylesheet_string = None
        py_output_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "output_file":
              py_output_string = value.encode('UTF-8') if value is not None else None
              c_outputfile = py_output_string if value is not None else ""
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)

        c_templateName = make_c_str(template_name)
        self.thisxptr.callTemplateReturningFile(c_stylesheetfile, c_templateName, c_outputfile)



     def call_function_returning_value(self, str function_name, list args, **kwds):
        """
        call_function_returning_value(self, str function_name, list args, **kwds)
        Invoke a transformation by calling a named template and return result as an PyXdmValue.

        Args:
			function_name(str): The name of the template to invoke. If None is supplied then call the initial-template
			list args: Pointer array of XdmValue object - he values of the arguments to be supplied to the function.
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:
            1) node = xsltproc.call_function_returning_value("{http://localhost/example}func", stylesheet_file="test1.xsl")


            2) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               value = xsltproc.call_function_returning_value("{http://localhost/test}add", stylesheet_file="test1.xsl")


            3) xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               value = xsltproc.call_function_returning_value("{http://exmaple.com}func1")

        """
        cdef const char * c_functionName = NULL
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_template_name_str = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)
        cdef int len_= 0;
        len_ = len(args)
        """ TODO handle memory when finished with XdmValues """
        cdef saxoncClasses.XdmValue ** argumentV = self.thisxptr.createXdmValueArray(len_)
        
        for x in range(len(args)):
          if isinstance(args[x], PyXdmValue):
            value_ = args[x];
            argumentV[x] = value_.thisvptr
          else:
            raise Exception("Argument value at position " , x , " is not an PyXdmValue. The following object found: ", type(args[x]))

        c_functionName = make_c_str(function_name)
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        xdmValue = self.thisxptr.callFunctionReturningValue(c_stylesheetfile, c_functionName, argumentV, len(args))

        if xdmValue is NULL:
          return None
        cdef type_ = xdmValue.getType()
        if type_== 4:
          aval = PyXdmAtomicValue()
          aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
          return aval
        elif type_ == 3:
          nval = PyXdmNode()
          nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
          return nval
        else:
          val = PyXdmValue()
          val.thisvptr = xdmValue
          return val



     def call_function_returning_string(self, str function_name, list args, **kwds):
        """
        call_function_returning_string(self, str function_name, list args, **kwds)
        Invoke a transformation by calling a named template and return result as a serialized string.

        Args:
			function_name(str): The name of the template to invoke. If None is supplied then call the initial-template
			list args: Pointer array of XdmValue object - he values of the arguments to be supplied to the function.
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            str: Result of the transformation as an str value


        Example:
            1) result = xsltproc.call_function_returning_string("{http://localhost/example}func", stylesheet_file="test1.xsl")


            2) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               result = xsltproc.call_function_returning_string("{http://localhost/test}add", stylesheet_file="test1.xsl")


            3) xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               result = xsltproc.call_function_returning_string("{http://exmaple.com}func1")

        """
        cdef const char * c_functionName = NULL
        cdef const char * c_sourcefile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        py_source_string = None
        py_template_name_str = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
              if isfile(value) == False:
                raise Exception("Stylesheet file does not exist")
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)
        cdef int _len = len(args)
        """ TODO handle memory when finished with XdmValues """
        cdef saxoncClasses.XdmValue ** argumentV = self.thisxptr.createXdmValueArray(_len)

        for x in range(len(args)):
          if isinstance(args[x], PyXdmValue):
            value_ = args[x]
            argumentV[x] = value_.thisvptr
          else:
            raise Exception("Argument value at position ",x," is not an PyXdmValue")

        c_functionName = make_c_str(function_name)
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        cdef const char* c_string = self.thisxptr.callFunctionReturningString(c_stylesheetfile, c_functionName, argumentV, len(args))
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring


     def call_function_returning_file(self, str function_name, list args, **kwds):
        """
        call_function_returning_file(self, str function_name, list args, **kwds)
        Invoke a transformation by calling a named template and return result as an PyXdmValue.

        Args:
			function_name(str): The name of the template to invoke. If None is supplied 
                        then call the initial-template
			list args: Pointer array of XdmValue object - he values of the arguments to be supplied to the function.
            **kwds: Possible optional arguments: source_file (str) or xdm_value (PyXdmValue). Other allowed argument: stylesheet_file (str)



        Returns:
            PyXdmValue: Result of the transformation as an PyXdmValue object


        Example:
            1)  xsltproc.set_output_file("result.xml")
				xsltproc.call_function_returning_file("{http://localhost/example}func", stylesheet_file="test1.xsl")


            2) xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               xsltproc.call_function_returning_file("{http://localhost/test}add", stylesheet_file="test1.xsl", output_file="result.xml")


            3) xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
			   xsltproc.set_initial_match_selection(file_name="cat.xml")\r
               xsltproc.call_function_returning_file("{http://exmaple.com}func1", output_file="result.xml")

        """
        cdef const char * c_functionName = NULL
        cdef const char * c_sourcefile = NULL
        cdef const char * c_outputfile = NULL
        cdef const char * c_stylesheetfile = NULL
        cdef PyXdmValue value_ = None
        cdef PyXdmValue valueArgs_ = None
        py_source_string = None
        py_template_name_str = None
        py_stylesheet_string = None
        for key, value in kwds.items():
          if isinstance(value, str):
            if key == "source_file":
              c_sourcefile = make_c_str(value)
              self.thisxptr.setInitialMatchSelectionAsFile(c_sourcefile)
            if key == "output_file":
              py_output_string = value.encode('UTF-8') if value is not None else None
              c_outputfile = py_output_string if value is not None else ""
            if key == "stylesheet_file":
              c_stylesheetfile = make_c_str(value)
              if isfile(value) == False:
                raise Exception("Stylesheet file does not exist")
          elif key == "xdm_value":
            if isinstance(value, PyXdmValue):
              value_ = value;
              self.thisxptr.setInitialMatchSelection(value_.thisvptr)
        cdef int _len = len(args)
        """ TODO handle memory when finished with XdmValues """
        cdef saxoncClasses.XdmValue ** argumentV = self.thisxptr.createXdmValueArray(_len)

        for x in range(len(args)):
          if isinstance(args[x], PyXdmValue):
            value_ = args[x]
            argumentV[x] = value_.thisvptr
          else:
            raise Exception("Argument value at position ",x," is not an PyXdmValue")

        c_functionName = make_c_str(function_name)
        cdef PyXdmValue val = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmNode nval = None
        cdef saxoncClasses.XdmValue * xdmValue = NULL
        self.thisxptr.callFunctionReturningFile(c_stylesheetfile, c_functionName, argumentV, len(args), c_outputfile)


     def add_package(self, *file_names):
        """
        add_package(self, file_name)
        Add an XSLT 3.0 package to the library.

        Args:
            file_name (str): The file name of the XSLT package

        """
        """cdef const char* c_string
        c_String = make_c_str(file_name)"""
        """TODO: add addPackages on array of file names self.thisxptr.addPackages(c_string)"""

     def clearPackages(self):
        """
        clear_packages(self)
        Clear saved XSLT 3.0 package in the library.

        """
        self.thisxptr.clearPackages()
	

        
     def compile_stylesheet(self, **kwds):
        """
        compile_stylesheet(self, **kwds)
        Compile a stylesheet  received as text, uri or as a node object. The compiled stylesheet 
        is cached and available for execution later. It is also possible to save the compiled 
        stylesheet (SEF file) given the option 'save' and 'output_file'.

        Get the stylesheet associated via the xml-stylesheet processing instruction (see
        http://www.w3.org/TR/xml-stylesheet/) with the document
        document specified in the source parameter, and that match
        the given criteria.  If there are several suitable xml-stylesheet
        processing instructions, then the returned Source will identify
        a synthesized stylesheet module that imports all the referenced
        stylesheet module.

        Args:
            **kwds: Possible keyword arguments stylesheet_text (str), stylesheet_file (str), 
            associated_file (str) or stylsheet_node (PyXdmNode). Also possible to add the options 
            save (boolean) and output_file, which creates an exported stylesheet to file (SEF).

        Example:
            1. xsltproc.compile_stylesheet(stylesheet_text="<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'>
                                             <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' />
                                             <xsl:template match='*'><output><xsl:value-of select='//person[1]'/>
                                             <xsl:for-each select='$values' >
                                               <out><xsl:value-of select='. * 3'/></out>
                                             </xsl:for-each></output></xsl:template></xsl:stylesheet>")

            2. xsltproc.compile_stylesheet(stylesheet_file="test1.xsl", save=True, output_file="test1.sef")
            3. xsltproc.compile(associated_file="foo.xml")  
        """
        py_error_message = "CompileStylesheet should only be one of the keyword option: (associated_file|stylesheet_text|stylesheet_file|stylesheet_node), also in allowed in addition the optional keyword 'save' boolean with the keyword 'outputfile' keyword"
        if len(kwds) >3:
          raise Exception(py_error_message)
        cdef char * c_outputfile
        cdef char * c_stylesheet
        py_output_string = None
        py_stylesheet_string = None
        py_save = False
        cdef int option = 0
        cdef PyXdmNode py_xdmNode = None
        if kwds.keys() >= {"stylesheet_text", "stylesheet_file"}:
          raise Exception(py_error_message)
        if kwds.keys() >= {"stylesheet_text", "stylesheet_node"}:
          raise Exception(py_error_message)
        if kwds.keys() >= {"stylesheet_node", "stylesheet_file"}:
          raise Exception(py_error_message)

        if ("save" in kwds) and kwds["save"]==True:
          del kwds["save"]
          if "output_file" not in kwds:
            raise Exception("Output file option not in keyword arugment for compile_stylesheet")
          py_output_string = kwds["output_file"].encode('UTF-8')
          c_outputfile = py_output_string
          if "stylesheet_text" in kwds:
            py_stylesheet_string = kwds["stylesheet_text"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromStringAndSave(c_stylesheet, c_outputfile)
          elif "stylesheet_file" in kwds:
            py_stylesheet_string = kwds["stylesheet_file"].encode('UTF-8')
            if py_stylesheet_string  is None or isfile(py_stylesheet_string) == False:
              raise Exception("Stylesheet file does not exist")
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromFileAndSave(c_stylesheet, c_outputfile)
          elif "stylesheet_node" in kwds:
            py_xdmNode = kwds["stylesheet_node"]
            #if not isinstance(py_value, PyXdmNode):
              #raise Exception("StylesheetNode keyword arugment is not of type XdmNode")
            #value = PyXdmNode(py_value)
            self.thisxptr.compileFromXdmNodeAndSave(py_xdmNode.derivednptr, c_outputfile)
          else:
            raise Exception(py_error_message)
        else:
          if "stylesheet_text" in kwds:
            py_stylesheet_string = kwds["stylesheet_text"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromString(c_stylesheet)
          elif "stylesheet_file" in kwds:
            py_stylesheet_string = kwds["stylesheet_file"].encode('UTF-8')
            c_stylesheet = py_stylesheet_string
            if py_stylesheet_string  is None or isfile(py_stylesheet_string) == False:
              raise Exception("Stylesheet file does not exist")
            self.thisxptr.compileFromFile(c_stylesheet)
          elif "associated_file" in kwds:
            py_stylesheet_string = kwds["associated_file"].encode('UTF-8')
            if py_stylesheet_string  is None or isfile(py_stylesheet_string) == False:
              raise Exception("Stylesheet file does not exist")
            c_stylesheet = py_stylesheet_string
            self.thisxptr.compileFromAssociatedFile(c_stylesheet)
          elif "stylesheet_node" in kwds:
            py_xdmNode = kwds["stylesheet_node"]
            #if not isinstance(py_value, PyXdmNode):
              #raise Exception("StylesheetNode keyword arugment is not of type XdmNode")
            #value = PyXdmNode(py_value)
            self.thisxptr.compileFromXdmNode(py_xdmNode.derivednptr)
          else:
            raise Exception(py_error_message)


  
     def release_stylesheet(self):
        """
        release_stylesheet(self)
        Release cached stylesheet

        """
        self.thisxptr.releaseStylesheet()

     def exception_occurred(self):
        """
        exception_occurred(self)
        Checks for pending exceptions without creating a local reference to the exception object
        Returns:
            boolean: True when there is a pending exception; otherwise return False

        """
        return self.thisxptr.exceptionCount() >0

     def check_exception(self):
        """
        check_exception(self)
        Check for exception thrown and get message of the exception.

        Returns:
            str: Returns the exception message if thrown otherwise return None

        """
        cdef const char* c_string = self.thisxptr.checkException()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def exception_clear(self):
        """
        exception_clear(self)
        Clear any exception thrown

        """
        self.thisxptr.exceptionClear()

     def exception_count(self):
        """
        excepton_count(self)
        Get number of errors reported during execution.

        Returns:
            int: Count of the exceptions thrown during execution
        """
        return self.thisxptr.exceptionCount()

     def get_error_message(self, index):
        """
        get_error_message(self, index)
        A transformation may have a number of errors reported against it. Get the ith error message if there are any errors

        Args:
            index (int): The i'th exception

        Returns:
            str: The message of the i'th exception. Return None if the i'th exception does not exist.
        """
        cdef const char* c_string = self.thisxptr.getErrorMessage(index)
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def get_error_code(self, index):
        """
        get_error_code(self, index)
        A transformation may have a number of errors reported against it. Get the i'th error code if there are any errors

        Args:
            index (int): The i'th exception

        Returns:
            str: The error code associated with the i'th exception. Return None if the i'th exception does not exist.

        """
        cdef const char* c_string = self.thisxptr.getErrorCode(index)
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring




cdef class PyXQueryProcessor:
     """An PyXQueryProcessor object represents factory to compile, load and execute queries. """

     cdef saxoncClasses.XQueryProcessor *thisxqptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        """
        __cinit__(self)
        Constructor for PyXQueryProcessor

        """
        self.thisxqptr = NULL

     def __dealloc__(self):
        """
        dealloc(self)


        """
        if self.thisxqptr != NULL:
           del self.thisxqptr

     def set_context(self, ** kwds):
        """
        set_context(self, **kwds)
        Set the initial context for the query
   
        Args:
            **kwds : Possible keyword argument file_name (str) or xdm_item (PyXdmItem)

        """
        py_error_message = "Error: set_context should only contain one of the following keyword arguments: (file_name|xdm_item)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmItem xdm_item = None
        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else "" 
            self.thisxqptr.setContextItemFromFile(c_source)
        elif "xdm_item" in kwds:
            xdm_item = kwds["xdm_item"]
            xdm_item.derivedptr.incrementRefCount()
            self.thisxqptr.setContextItem(xdm_item.derivedptr)
        else:
          raise Exception(py_error_message)

     def set_output_file(self, output_file):
        """
        set_output_file(self, output_file)
        Set the output file where the result is sent

        Args:
            output_file (str): Name of the output file
        """
        py_value_string = output_file.encode('UTF-8') if output_file is not None else None
        c_outfile = py_value_string if output_file is not None else ""
        self.thisxqptr.setOutputFile(c_outfile)

     def set_parameter(self, name, PyXdmValue value):
        """
        set_parameter(self, name, PyXdmValue value)
        Set the value of a query parameter

        Args:
            name (str): the name of the stylesheet parameter, as a string. For namespaced parameter use the JAXP solution i.e. "{uri}name
            value (PyXdmValue): the value of the query parameter, or None to clear a previously set value

        """
        cdef const char * c_str = make_c_str(name)
        if c_str is not NULL:
            value.thisvptr.incrementRefCount()
            self.thisxqptr.setParameter(c_str, value.thisvptr)

     def remove_parameter(self, name):
        """
        remove_parameter(self, name)
        Remove the parameter given by name from the PyXQueryProcessor. The parameter will not have any affect on the query if it has not yet been executed

        Args:
            name (str): The name of the query parameter

        Returns:
            bool: True if the removal of the parameter has been successful, False otherwise.

        """
        py_value_string = name.encode('UTF-8') if name is not None else None
        c_name = py_value_string if name is not None else ""
        self.thisxqptr.removeParameter(c_name)

     def set_property(self, name, str value):
        """
        set_property(self, name, value)
        Set a property specific to the processor in use.
 
        Args:
            name (str): The name of the property
            value (str): The value of the property

        Example:
            PyXQueryProcessor: set serialization properties (names start with '!' i.e. name "!method" -> "xml")\r
            'o':outfile name,\r
            'dtd': Possible values 'on' or 'off' to set DTD validation,\r 
            'resources': directory to find Saxon data files,\r 
            's': source as file name,\r
        """

        py_name_string = name.encode('UTF-8') if name is not None else None
        c_name = py_name_string if name is not None else ""

        py_value_string = value.encode('UTF-8') if value is not None else None
        c_value = py_value_string if value is not None else ""
        self.thisxqptr.setProperty(c_name, c_value)

     def clear_parameters(self):
        """
        clear_parameter(self)
        Clear all parameters set on the processor
        """
        self.thisxqptr.clearParameters()

     def clear_properties(self):
        """
        clear_parameter(self)
        Clear all properties set on the processor
        """
        self.thisxqptr.clearProperties()

     def set_updating(self, updating):
        """
        set_updating(self, updating)
        Say whether the query is allowed to be updating. XQuery update syntax will be rejected during query compilation unless this
        flag is set. XQuery Update is supported only under Saxon-EE/C.


        Args:
            updating (bool): true if the query is allowed to use the XQuery Update facility (requires Saxon-EE/C). If set to false,
                             the query must not be an updating query. If set to true, it may be either an updating or a non-updating query.


        """
        self.thisxqptr.setUpdating(updating)

     def run_query_to_value(self, ** kwds):
        """
        run_query_to_value(self, **kwds)
        Execute query and output result as an PyXdmValue object 

        Args:
            **kwds: Keyword arguments with the possible options input_file_name (str) or input_xdm_item (PyXdmItem). Possible to supply
                    query with the arguments 'query_file' or 'query_text', which are of type str.

        Returns:
            PyXdmValue: Output result as an PyXdmValue
        """
        cdef PyXdmNode nval = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmValue val = None
        if not len(kwds) == 0:
          
            if "input_file_name" in kwds:
                self.set_context(kwds["input_file_name"])
            elif "input_xdm_item" in kwds:
                self.set_context(xdm_item=(kwds["xdm_item"]))

            if "query_file" in kwds:
                self.set_query_file(kwds["output_file_name"])
            elif "query_text" in kwds:
                self.set_query_content(kwds["query_text"])
        
        cdef saxoncClasses.XdmValue * xdmValue = self.thisxqptr.runQueryToValue()
        if xdmValue is NULL:
            return None        
        cdef type_ = xdmValue.getType()
        if type_== 4:
            aval = PyXdmAtomicValue()
            aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
            return aval        
        elif type_ == 3:
            nval = PyXdmNode()        
            nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
            return nval
        else:
            val = PyXdmValue()
            val.thisvptr = xdmValue
            return val

     def run_query_to_string(self, ** kwds):
        """
        run_query_to_string(self, **kwds)
        Execute query and output result as a string 

        Args:
            **kwds: Keyword arguments with the possible options input_file_name (str) or input_xdm_item (PyXdmItem). Possible to supply
                    query with the arguments 'query_file' or 'query_text', which are of type str.

        Returns:
            str: Output result as a string
        """
        cdef const char * c_string
        if len(kwds) == 0:
          ustring = make_py_str(self.thisxqptr.runQueryToString())
          return ustring

        if "input_file_name" in kwds:
          self.set_context(kwds["input_file_name"])
        elif "input_xdm_item" in kwds:
          self.set_context(xdm_item=(kwds["xdm_item"]))
        if "query_file" in kwds:
          self.set_query_file(kwds["output_file_name"])
        elif "query_text" in kwds:
          self.set_query_content(kwds["query_text"])
    
        ustring = make_py_str(self.thisxqptr.runQueryToString())
        return ustring
        

     def run_query_to_file(self, ** kwds):
        """
        run_query_to_file(self, **kwds)
        Execute query with the result saved to file

        Args:
            **kwds: Keyword arguments with the possible options input_file_name (str) or input_xdm_item (PyXdmItem). The Query can be
                    supplied with the arguments 'query_file' or 'query_text', which are of type str. The name of the output file is
                    specified as the argument output_file_name.


        """
        if len(kwds) == 0:
          self.thisxqptr.runQueryToFile()
        if "input_file_name" in kwds:
          self.set_context(file_name=(kwds["input_file_name"]))
        elif "input_xdm_item" in kwds:
          self.set_context(xdm_item=(kwds["xdm_item"]))
        if "output_file_name" in kwds:
          self.set_output_file(kwds["output_file_name"])
        else:
          raise Exception("Error: output_file_name required in method run_query_to_file")

        if "query_file" in kwds:
          self.set_query_file(kwds["output_file_name"])
        elif "query_text" in kwds:
          self.set_query_content(kwds["query_text"])
        self.thisxqptr.runQueryToFile()

     def declare_namespace(self, prefix, uri):
        """
        declare_namespace(self, prefix, uri)
        Declare a namespace binding part of the static context for queries compiled using this.
        This binding may be overridden by a binding that appears in the query prolog.
        The namespace binding will form part of the static context of the query, but it will
        not be copied into result trees unless the prefix is actually used in an element or attribute name.

        Args:
            prefix (str): The namespace prefix. If the value is a zero-length string, this method sets the default namespace for elements and types.
            uri (uri) : The namespace URI. It is possible to specify a zero-length string to "undeclare" a namespace; in this case the prefix will not be available for use,
            except in the case where the prefix is also a zero length string, in which case the absence of a prefix implies that the name is in no namespace.

        """
        c_prefix = make_c_str(prefix)
        c_uri = make_c_str(uri)
        self.thisxqptr.declareNamespace(c_prefix, c_uri)

     def set_query_file(self, file_name):
        """
        set_query_file(self, file_name)
        Set the query to be executed as a file

        Args:
            file_name (str): The file name for the query


        """
        c_filename = make_c_str(file_name)
        self.thisxqptr.setQueryFile(c_filename)

     def set_query_content(self, content):
        """
        set_query_content(self)
        Set the query to be executed as a string

        Args:
            content (str): The query content suplied as a string

        """
        if content is not None:
            c_content = make_c_str(content)
            self.thisxqptr.setQueryContent(c_content)

     def set_query_base_uri(self, base_uri):
        """
        set_query_base_uri(self, base_uri)
        Set the static base query for the query     

        Args:
            base_uri (str): The static base URI; or None to indicate that no base URI is available
        """
        py_content_string = base_uri.encode('UTF-8') if base_uri is not None else None
        c_content = py_content_string if base_uri is not None else ""
        self.thisxqptr.setQueryBaseURI(base_uri)

     def set_cwd(self, cwd):
        """
        set_cwd(self, cwd)
        Set the current working directory.

        Args:
            cwd (str): current working directory
        """
        py_cwd_string = cwd.encode('UTF-8') if cwd is not None else None
        c_cwd = py_cwd_string if cwd is not None else ""
        self.thisxqptr.setcwd(c_cwd)

     def check_exception(self):
        """
        check_exception(self)
        Check for exception thrown and get message of the exception.
  
        Returns:
            str: Returns the exception message if thrown otherwise return None

        """
        return self.thisxqptr.checkException()

     def exception_occurred(self):
        """
        exception_occurred(self)
        Checks for pending exceptions without creating a local reference to the exception object

        Returns:
            boolean: True when there is a pending exception; otherwise return False

        """
        return self.thisxqptr.exceptionCount() >0

     def exception_clear(self):
        """
        exception_clear(self)
        Clear any exception thrown

        """
        self.thisxqptr.exceptionClear()

     def exception_count(self):
        """
        excepton_count(self)
        Get number of errors reported during execution.

        Returns:
            int: Count of the exceptions thrown during execution
        """
        return self.thisxqptr.exceptionCount()

     def get_error_message(self, index):
        """
        get_error_message(self, index)
        A transformation may have a number of errors reported against it. Get the ith error message if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The message of the i'th exception. Return None if the i'th exception does not exist.
        """
        return make_py_str(self.thisxqptr.getErrorMessage(index))

     def get_error_code(self, index):
        """
        get_error_code(self, index)
        A transformation may have a number of errors reported against it. Get the i'th error code if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The error code associated with the i'th exception. Return None if the i'th exception does not exist.

        """
        return make_py_str(self.thisxqptr.getErrorCode(index))

cdef class PyXPathProcessor:
     """An XPathProcessor represents factory to compile, load and execute the XPath query. """
     cdef saxoncClasses.XPathProcessor *thisxpptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        """
        cinit(self)
        Constructor for PyXPathProcessor 

        """
        self.thisxpptr = NULL
     def __dealloc__(self):
        """
        dealloc(self)


        """
        if self.thisxpptr != NULL:
           del self.thisxpptr

     def set_base_uri(self, uri):
        """
        set_base_uri(self, uri)
        Set the static base URI for XPath expressions compiled using this PyXPathCompiler. The base URI is part of the static context,
        and is used to resolve any relative URIs appearing within an XPath expression, for example a relative URI passed as an argument
        to the doc() function. If no static base URI is supplied, then the current working directory is used.


        Args:
            uri (str): This string will be used as the static base URI

        """
        
        self.thisxpptr.setBaseURI(make_c_str(uri))

     def evaluate(self, xpath_str):
        """
        evaluate(self, xpath_str)

        Args:
            xpath_str (str): The XPath query suplied as a string

        Returns:
            PyXdmValue: 

        """
        py_string = xpath_str.encode('UTF-8') if xpath_str is not None else None
        c_xpath = py_string if xpath_str is not None else ""
        cdef PyXdmNode nval = None
        cdef PyXdmAtomicValue aval = None
        cdef PyXdmValue val = None
        cdef type_ = 0
        cdef saxoncClasses.XdmValue * xdmValue = self.thisxpptr.evaluate(c_xpath)
        if xdmValue == NULL:
            return None
        else:
            type_ = xdmValue.getType()        
            if type_ == 4:
                aval = PyXdmAtomicValue()
                aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmValue
                return aval        
            elif type_ == 3:
                nval = PyXdmNode()
                nval.derivednptr = nval.derivedptr = nval.thisvptr = <saxoncClasses.XdmNode*>xdmValue
                return nval
            else:
                val = PyXdmValue()
                val.thisvptr = xdmValue
                return val

     def evaluate_single(self, xpath_str):
        """
        evaluate_single(self, xpath_str)

        Args:
            xpath_str (str): The XPath query suplied as a string

        Returns:
            PyXdmItem: A single Xdm Item is returned 

        """
        cdef PyXdmNode val = None
        cdef PyXdmAtomicValue aval = None
        py_string = xpath_str.encode('UTF-8') if xpath_str is not None else None
        c_xpath = py_string if xpath_str is not None else ""

        cdef saxoncClasses.XdmItem * xdmItem = self.thisxpptr.evaluateSingle(c_xpath)
        if xdmItem == NULL:
            return None
        cdef type_ = xdmItem.getType()        
        if type_ == 4:
            aval = PyXdmAtomicValue()
            aval.derivedaptr = aval.derivedptr = aval.thisvptr = <saxoncClasses.XdmAtomicValue *>xdmItem
            return aval        
        elif type_ == 3:
            val = PyXdmNode()
            val.derivednptr = val.derivedptr = val.thisvptr = <saxoncClasses.XdmNode*>xdmItem
            return val
        else:
            return None
        

     def set_context(self, **kwds):
        """
        set_context(self, **kwds)
        Set the context for the XPath query
   
        Args:
            **kwds : Possible keyword argument file_name (str) or xdm_item (PyXdmItem)

        """
        py_error_message = "Error: set_context should only contain one of the following keyword arguments: (file_name|xdm_item)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmItem xdm_item = None
        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else "" 
            self.thisxpptr.setContextFile(c_source)
        elif "xdm_item" in kwds:
            xdm_item = kwds["xdm_item"]
            xdm_item.derivedptr.incrementRefCount()
            self.thisxpptr.setContextItem(xdm_item.derivedptr)
        else:
          raise Exception(py_error_message)

     def set_cwd(self, cwd):
        """
        set_cwd(self, cwd)
        Set the current working directory.

        Args:
            cwd (str): current working directory
        """
        py_cwd_string = cwd.encode('UTF-8') if cwd is not None else None
        cdef char * c_cwd = py_cwd_string if cwd is not None else "" 
        self.thisxpptr.setcwd(c_cwd)

     def effective_boolean_value(self, xpath_str):
        """
        effective_boolean_value(self, xpath_str)
        Evaluate the XPath expression, returning the effective boolean value of the result.
    
        Args:
            xpath_str (str): Supplied as a string

        Returns:
            boolean: The result is a boolean value.
        """

        py_value_string = xpath_str.encode('UTF-8') if xpath_str is not None else None
        c_xpath = py_value_string if xpath_str is not None else "" 

        return self.thisxpptr.effectiveBooleanValue(c_xpath)

     def set_parameter(self, name, PyXdmValue value):
        """
        set_parameter(self, name, PyXdmValue value)
        Set the value of a XPath parameter

        Args:
            name (str): the name of the XPath parameter, as a string. For namespaced parameter use the JAXP solution i.e. "{uri}name
            value (PyXdmValue): the value of the query parameter, or None to clear a previously set value

        """
        cdef const char * c_str = make_c_str(name)
        if c_str is not NULL:
            self.thisxpptr.setParameter(c_str, value.thisvptr)

     def remove_parameter(self, name):
        """
        remove_parameter(self, name)
        Remove the parameter given by name from the PyXPathProcessor. The parameter will not have any affect on the XPath if it has not yet been executed

        Args:
            name (str): The name of the XPath parameter

        Returns:
            bool: True if the removal of the parameter has been successful, False otherwise.

        """
        self.thisxpptr.removeParameter(name)
     def set_property(self, name, value):
        """
        set_property(self, name, value)
        Set a property specific to the processor in use.
 
        Args:
            name (str): The name of the property
            value (str): The value of the property

        Example:
            PyXPathProcessor: set serialization properties (names start with '!' i.e. name "!method" -> "xml")\r
            'resources': directory to find Saxon data files,\r 
            's': source as file name,\r
            'extc': REgister native library to be used with extension functions
        """

        py_name_string = name.encode('UTF-8') if name is not None else None
        c_name = py_name_string if name is not None else ""

        py_value_string = value.encode('UTF-8') if value is not None else None
        c_value = py_value_string if value is not None else ""
        self.thisxpptr.setProperty(c_name, c_value)
     def declare_namespace(self, prefix, uri):
        """
        declare_namespace(self, prefix, uri)
        Declare a namespace binding as part of the static context for XPath expressions compiled using this compiler
        Args:
            prefix (str): The namespace prefix. If the value is a zero-length string, this method sets the default namespace
                          for elements and types.
            uri (uri) : The namespace URI. It is possible to specify a zero-length string to "undeclare" a namespace;
                        in this case the prefix will not be available for use, except in the case where the prefix is also a
                        zero length string, in which case the absence of a prefix implies that the name is in no namespace.

        """
        py_prefix_string = prefix.encode('UTF-8') if prefix is not None else None
        c_prefix = py_prefix_string if prefix is not None else ""
        py_uri_string = uri.encode('UTF-8') if uri is not None else None
        c_uri = py_uri_string if uri is not None else ""
        self.thisxpptr.declareNamespace(c_prefix, c_uri)

     def set_backwards_compatible(self, option):
        cdef bool c_option
        c_option = option
        self.thisxpptr.setBackwardsCompatible(c_option)

     def set_caching(self, is_caching):
         cdef bool c_is_caching
         c_is_caching = is_caching
         self.thisxpptr.setCaching(c_is_caching)

     def import_schema_namespace(self, uri):
         py_uri_string = uri.encode('UTF-8') if uri is not None else None
         c_name = py_uri_string if uri is not None else ""
         self.thisxpptr.importSchemaNamespace(c_name)

     def clear_parameters(self):
        """
        clear_parameter(self)
        Clear all parameters set on the processor
        """
        self.thisxpptr.clearParameters()
     def clear_properties(self):
        """
        clear_parameter(self)
        Clear all properties set on the processor
        """
        self.thisxpptr.clearProperties()
     def check_exception(self):
        """
        check_exception(self)
        Check for exception thrown and get message of the exception.
  
        Returns:
            str: Returns the exception message if thrown otherwise return None

        """
        return self.thisxpptr.checkException()
     def exception_occurred(self):
        """
        exception_occurred(self)
        Check if an exception has occurred internally within Saxon/C

        Returns:
            boolean: True or False if an exception has been reported internally in Saxon/C
        """

        return self.thisxpptr.exceptionCount() >0

     def exception_clear(self):
        """
        exception_clear(self)
        Clear any exception thrown

        """
        self.thisxpptr.exceptionClear()
     def exception_count(self):
        """
        excepton_count(self)
        Get number of errors reported during execution.

        Returns:
            int: Count of the exceptions thrown during execution
        """
        return self.thisxpptr.exceptionCount()
     def get_error_message(self, index):
        """
        get_error_message(self, index)
        A transformation may have a number of errors reported against it. Get the ith error message if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The message of the i'th exception. Return None if the i'th exception does not exist.
        """
        return make_py_str(self.thisxpptr.getErrorMessage(index))
     def get_error_code(self, index):
        """
        get_error_code(self, index)
        A transformation may have a number of errors reported against it. Get the i'th error code if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The error code associated with the i'th exception. Return None if the i'th exception does not exist.

        """
        return make_py_str(self.thisxpptr.getErrorCode(index))


cdef class PySchemaValidator:
     """An PySchemaValidator represents factory for validating instance documents against a schema."""
     
     cdef saxoncClasses.SchemaValidator *thissvptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        self.thissvptr = NULL
     def __dealloc__(self):
        if self.thissvptr != NULL:
           del self.thissvptr

     def set_cwd(self, cwd):
        """
        set_cwd(self, cwd)
        Set the current working directory.

        Args:
            cwd (str): current working directory
        """
        py_cwd_string = cwd.encode('UTF-8') if cwd is not None else None
        cdef char * c_cwd = py_cwd_string if cwd is not None else "" 
        self.thissvptr.setcwd(c_cwd)

     def register_schema(self, **kwds):
        """
        Register schema given as file name or schema text. (xsd_text|xsd_file)

        Args:
            **kwds: Keyword argument options only one of 'xsd_text' or 'xsd_file'

        """
        py_error_message = "Error: register_schema should only contain one of the following keyword arguments: (xsd_text|xsd_file)"
        if len(kwds) != 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        
        if "xsd_text" in kwds:
            py_value = kwds["xsd_text"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else "" 
            self.thissvptr.registerSchemaFromString(c_source)
        elif "xsd_file" in kwds:
            py_value = kwds["xsd_file"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else "" 
            self.thissvptr.registerSchemaFromFile(c_source)
        else:
          raise Exception(py_error_message)
        
     def set_output_file(self, output_file):
        """
        set_output_file(self, output_file)        
        Set the name of the output file that will be used by the valida tor.

        Args:
            output_file (str):The output file name for use by the validator
    
        """
        py_value_string = output_file.encode('UTF-8') if output_file is not None else None
        c_source = py_value_string 
        if output_file is not None:
            self.thissvptr.setOutputFile(c_source)
        else:
            raise Warning("Unable to set output_file. output_file has the value None")
     def validate(self, **kwds):
        """
        validate(self, **kwds)
        Validate an instance document by a registered schema.
        
        Args:
            **kwds: The possible keyword arguments must be one of the follow (file_name|xml_text|xdm_node).
                    The source file to be validated. Allow None when source document is supplied using the set_source method
        """
        py_error_message = "Error: validate should only contain one of the following keyword arguments: (file_name|xdm_node|xml_text)"
        if len(kwds) > 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmNode xdm_node = None
        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else ""
            self.thissvptr.validate(c_source)
        elif "xdm_node" in kwds:
            xdm_node = kwds["xdm_node"]
            if isinstance(xdm_node, PyXdmNode):
               self.thissvptr.setSourceNode(xdm_node.derivednptr)
               self.thissvptr.validate(NULL)
        else:
            self.thissvptr.validate(NULL)


     def validate_to_node(self, **kwds):
        """
        validate_to_node(self, **kwds)
        Validate an instance document by a registered schema.
        

        Args:
            **kwds: The possible keyword arguments must be one of the follow (file_name|xml_text|xdm_node).
                    The source file to be validated. Allow None when source document is supplied using the set_source method

        Returns:
            PyXdmNode: The validated document returned to the calling program as an PyXdmNode    
        """
        py_error_message = "Error: validate should only contain one of the following keyword arguments: (file_name|xdm_node|xml_text)"
        if len(kwds) > 1:
          raise Exception(py_error_message)
        cdef py_value = None
        cdef py_value_string = None
        cdef char * c_source
        cdef PyXdmNode xdm_node = None
        cdef PyXdmNode val = None
        cdef saxoncClasses.XdmNode * xdmNode = NULL

        if "file_name" in kwds:
            py_value = kwds["file_name"]
            py_value_string = py_value.encode('UTF-8') if py_value is not None else None
            c_source = py_value_string if py_value is not None else ""
            if isfile(py_value_string) == False:
                raise Exception("Source file with name "+py_value_string+" does not exist")
            xdmNode = self.thissvptr.validateToNode(c_source)
        elif "xdm_node" in kwds:
            xdm_node = kwds["xdm_node"]
            if isinstance(xdm_node, PyXdmNode):
                self.thissvptr.setSourceNode(xdm_node.derivednptr)
                xdmNode = self.thissvptr.validateToNode(NULL)
        else:
            xdmNode = self.thissvptr.validateToNode(NULL)
            
        if xdmNode == NULL:
            return None
        else:
            val = PyXdmNode()
            val.derivednptr = val.derivedptr = val.thisvptr =  xdmNode
            return val

     def set_source_node(self, PyXdmNode source):
        """
        set_source_node(self, source)
        Set the source as an PyXdmNode object that will be validated

        Args:
            source (PyXdmNode) :
        """
        self.thissvptr.setSourceNode(source.derivednptr)

     @property
     def validation_report(self):
        """
        validation_report
        The validation report Property

        :PyXdmNode: The Validation report result from the Schema validator

        """
        cdef PyXdmNode val = None
        cdef saxoncClasses.XdmNode * xdmNode = NULL             
        xdmNode = self.thissvptr.getValidationReport()
        if xdmNode == NULL:
            return None
        else:
            val = PyXdmNode()
            val.derivednptr = val.derivedptr = val.thisvptr = xdmNode
            return val

     def set_parameter(self, name, PyXdmValue value):
        """
        set_parameter(self, name, PyXdmValue value)
        Set the value of the parameter for the Schema validator

        Args:
            name (str): the name of the schema parameter, as a string. For namespaced parameter use the JAXP solution i.e. "{uri}name
            value (PyXdmValue): the value of the parameter, or None to clear a previously set value

        """
        cdef const char * c_str = make_c_str(name)
        if c_str is not NULL:
            value.thisvptr.incrementRefCount()
            self.thissvptr.setParameter(c_str, value.thisvptr)

     def remove_parameter(self, name):
        """
        remove_parameter(self, name)
        Remove the parameter given by name from the PySchemaValidator. The parameter will not have any affect on the SchemaValidator if it has not yet been executed

        Args:
            name (str): The name of the schema parameter

        Returns:
            bool: True if the removal of the parameter has been successful, False otherwise.

        """
        cdef const char * c_str = make_c_str(name)
        if c_str is not NULL:
            self.thissvptr.removeParameter(c_str)
     def set_property(self, name, value):
        """
        set_property(self, name, value)
        Set a property specific to the processor in use.
 
        Args:
            name (str): The name of the property
            value (str): The value of the property

        Example:
            PySchemaValidator: set serialization properties (names start with '!' i.e. name "!method" -> "xml")\r
            'o':outfile name,\r
            'dtd': Possible values 'on' or 'off' to set DTD validation,\r 
            'resources': directory to find Saxon data files,\r 
            's': source as file name,\r
            'string': Set the source as xml string for validation. Parsing will take place in the validate method\r
            'report-node': Boolean flag for validation reporting feature. Error validation failures are represented in an XML
                           document and returned as an PyXdmNode object\r
            'report-file': Specifcy value as a file name string. This will switch on the validation reporting feature, which will be
                           saved to the file in an XML format\r
            'verbose': boolean value which sets the verbose mode to the output in the terminal. Default is 'on'
            'element-type': Set the name of the required type of the top-lelvel element of the doucment to be validated.
                            The string should be in the Clark notation {uri}local\r
            'lax': Boolean to set the validation mode to strict (False) or lax ('True')
        """

        cdef const char * c_name = make_c_str(name)
        cdef const char * c_value = make_c_str(value)
        if c_name is not NULL:
            if c_value is not NULL:
                self.thissvptr.setProperty(c_name, c_value)

     def clear_parameters(self):
        """
        clear_parameter(self)
        Clear all parameters set on the processor
        """
        self.thissvptr.clearParameters()
     def clear_properties(self):
        """
        clear_parameter(self)
        Clear all properties set on the processor
        """
        self.thissvptr.clearProperties()
     def exception_occurred(self):
        """
        exception_occurred(self)
        Check if an exception has occurred internally within Saxon/C

        Returns:
            boolean: True or False if an exception has been reported internally in Saxon/C
        """
        return self.thissvptr.exceptionCount()>0

     def exception_clear(self):
        """
        exception_clear(self)
        Clear any exception thrown

        """
        self.thissvptr.exceptionClear()
     def exception_count(self):
        """
        excepton_count(self)
        Get number of errors reported during execution of the schema.

        Returns:
            int: Count of the exceptions thrown during execution
        """
        return self.thissvptr.exceptionCount()
     def get_error_message(self, index):
        """
        get_error_message(self, index)
        A transformation may have a number of errors reported against it. Get the ith error message if there are any errors

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The message of the i'th exception. Return None if the i'th exception does not exist.
        """
        return make_py_str(self.thissvptr.getErrorMessage(index))

     def get_error_code(self, index):
        """
        get_error_code(self, index)
        A transformation may have a number of errors reported against it. Get the i'th error code if there are any errors.

        Args:
            index (int): The i'th exception
        
        Returns:
            str: The error code associated with the i'th exception. Return None if the i'th exception does not exist.

        """
        return make_py_str(self.thissvptr.getErrorCode(index))

     def set_lax(self, lax):
        """
        set_lax(self, lax)
        The validation mode may be either strict or lax. \r
        The default is strict; this method may be called to indicate that lax validation is required. With strict validation,
        validation fails if no element declaration can be located for the outermost element. With lax validation,
        the absence of an element declaration results in the content being considered valid.
        
        Args:
            lax (boolean): lax True if validation is to be lax, False if it is to be strict

        """
        self.thissvptr.setLax(lax)

cdef class PyXdmValue:
     """Value in the XDM data model. A value is a sequence of zero or more items, each item being either an atomic value or a node. """    
     cdef saxoncClasses.XdmValue *thisvptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        """
        cinit(self)
        Constructor for PyXdmValue

        """
        if type(self) is PyXdmValue:
            self.thisvptr = new saxoncClasses.XdmValue() 
     def __dealloc__(self):
        if type(self) is PyXdmValue and self.thisvptr != NULL:    
            if self.thisvptr.getRefCount() < 1:
                del self.thisvptr            
            else:
                self.thisvptr.decrementRefCount()


     def add_xdm_item(self, PyXdmItem value):
        """
        add_xdm_tem(self, PyXdmItem value)
        Add PyXdmItem to the Xdm sequence

        Args:
            value (PyXdmItem): The PyXdmItem object
        """
        self.thisvptr.addXdmItem(value.derivedptr)

     @property
     def head(self):
        """
        head(self)
        Property to get the first item in the sequence

        Returns:
            PyXdmItem: The PyXdmItem or None if the sequence is empty

        """
        cdef PyXdmItem val = PyXdmItem()
        val.derivedptr = val.thisvptr = self.thisvptr.getHead()
        if val.derivedptr == NULL :
            return None
        else:
            val.derivedptr.incrementRefCount()
            return val

     def item_at(self, index):
        """
        item_at(self, index)
        Get the n'th item in the value, counting from zero.
        
        Args:
            index (int): the index of the item required. Counting from zero
        Returns:
            PyXdmItem: Get the item indicated at the index. If the item does not exist return None.
        

        """
        cdef PyXdmItem val = PyXdmItem()
        val.derivedptr = val.thisvptr = self.thisvptr.itemAt(index)
        if val.derivedptr == NULL:
            return None
        else:
            val.derivedptr.incrementRefCount()
            return val

     @property
     def size(self):
        """
        size(self)
        Property - Get the number of items in the sequence
        
        Returns:
            int: The count of items in the sequence
        """
        return self.thisvptr.size()

     def __repr__(self):
        """
        __repr__(self)
        The string representation of PyXdmItem

        """
        cdef const char* c_string = self.thisvptr.toString()
        if c_string == NULL:
            raise Warning('Empty string returned')
        else:
            ustring = c_string.decode('UTF-8') if c_string is not NULL else None
            return ustring

     def __str__(self):
        """
        __str__(self)
        The string representation of PyXdmItem

        """
        cdef const char* c_string = self.thisvptr.toString()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring 

cdef class PyXdmItem(PyXdmValue):
     cdef saxoncClasses.XdmItem *derivedptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        if type(self) is PyXdmItem:
            self.derivedptr = self.thisvptr = new saxoncClasses.XdmItem()
     def __dealloc__(self):
        if type(self) is PyXdmItem and self.derivedptr != NULL:
            if self.derivedptr.getRefCount() < 1:
                del self.derivedptr            
            else:
                self.derivedptr.decrementRefCount()

        '''if type(self) is PyXdmItem:
            del self.derivedptr'''

     @property
     def string_value(self):
        """
        string_value(self)
        Property to get the the strign value of the XdmItem 
        """
        cdef const char* c_string = self.derivedptr.getStringValue()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring


     def __repr__(self):
        return make_py_str(self.derivedptr.getStringValue())

     def __str__(self):
        return make_py_str(self.derivedptr.getStringValue())

     @property
     def is_atomic(self):
        """
        is_atomic(self)
        Property to check if the current PyXdmItem is an atomic value
    
        Returns:
            bool: Check of is atomic value 
        """
        return self.derivedptr.isAtomic()

     def get_node_value(self):
        """
        get_node_value(self)
        Get the subclass PyXdmNode for this PyXdmItem object current object is an atomic value
    
        Returns:
            PyXdmNode: Subclass this object to PyXdmNode or error 
        """
        cdef PyXdmNode val = None
        if self.is_atomic:
          raise Exception("The PyXdmItem is an PyXdmAtomicValue therefore cannot be sub-classed to an PyXdmNode")
        val = PyXdmNode()
        val.derivednptr = val.derivedptr = <saxoncClasses.XdmNode*> self.derivedptr
        '''val.derivednptr.incrementRefCount()'''
        return val

     @property
     def head(self):
        """
        head(self)
        Property to get the first item in the sequence. This would be the PyXdmItem itself as there is only one item in the sequence

        Returns:
            PyXdmItem: The PyXdmItem or None if the sequence is empty

        """
        return self

     def get_atomic_value(self):
        """
        get_atomic_value(self)
        Get the subclass PyXdmAtomicValue for this PyXdmItem object current object is an atomic value
    
        Returns:
            PyXdmAtomicValue: Subclass this object to PyXdmAtomicValue or error 
        """
        if self.is_atomic == False:
          raise Exception("The PyXdmItem is not an PyXdmAtomicValue")
        val = PyXdmAtomicValue()
        val.derivedaptr = val.derivedptr = <saxoncClasses.XdmAtomicValue*>self.derivedptr
        val.derivedaptr.incrementRefCount()
        return val

cdef class PyXdmNode(PyXdmItem):
     cdef saxoncClasses.XdmNode *derivednptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        self.derivednptr = self.derivedptr = self.thisvptr = NULL
    
     def __dealloc__(self):
        if type(self) is PyXdmNode and self.derivednptr != NULL:
                 if self.derivednptr.getRefCount() < 1:
                     del self.derivednptr
                 else:
                     self.derivednptr.decrementRefCount()

     @property
     def head(self):
        """
        head(self)
        Property to get the first item in the sequence. This would be the PyXdmNode itself as there is only one item in the sequence

        Returns:
            PyXdmItem: The PyXdmItem or None if the sequence is empty

        """
        return self
                   

     @property
     def node_kind(self):
        """
        node_kind(self)
        Node Kind property. This will be a value such as {@link net.sf.saxon.type.Type#ELEMENT} or {@link net.sf.saxon.type.Type#ATTRIBUTE}.
        There are seven kinds of node: documents, elements, attributes, text, comments, processing-instructions, and namespaces.

        Returns:
            int: an integer identifying the kind of node. These integer values are the same as those used in the DOM 
        """
        cdef int kind
        return self.derivednptr.getNodeKind()

     @property
     def node_kind_str(self):
        """
        node_kind(self)
        Node Kind property string. This will be a value such as {@link net.sf.saxon.type.Type#ELEMENT} or {@link net.sf.saxon.type.Type#ATTRIBUTE}.
        There are seven kinds of node: documents, elements, attributes, text, comments, processing-instructions, and namespaces.

        Returns:
            int: an integer identifying the kind of node. These integer values are the same as those used in the DOM 
        """
        cdef str kind
        cdef int nk = self.derivednptr.getNodeKind()
        if nk == DOCUMENT:
            kind = 'document'
        elif nk == ELEMENT:
            kind = 'element'
        elif nk == ATTRIBUTE:
            kind = 'attribute'
        elif nk == TEXT:
            kind = 'text'
        elif nk == COMMENT:
            kind = 'comment'
        elif nk == PROCESSING_INSTRUCTION:
            kind = 'processing-instruction'
        elif nk == NAMESPACE:
            kind = 'namespace'
        elif nk == UNKNOWN:
            kind = 'unknown'
        else:
            raise ValueError('Unknown node kind: %d' % nk)
        return kind

     @property
     def name(self):
        """
        name(self)
        Get the name of the node, as a string in the form of a EQName
        Returns:
            str: the name of the node. In the case of unnamed nodes (for example, text and comment nodes) return None       
        """
        cdef const char* c_string = self.derivednptr.getNodeName()
        if c_string == NULL:
            return None
        else:
            ustring = c_string.decode('UTF-8')
            return ustring 

     @property
     def typed_value(self):
        """ 
        typed_value(self)
        Property - get the typed value of this node, as defined in XDM
        Returns:
            PyXdmValue:the typed value. If the typed value is a single atomic value, this will be returne as an instance of {@link XdmAtomicValue}                
        """
        cdef PyXdmValue val = None
        cdef saxoncClasses.XdmValue * xdmValue = self.derivednptr.getTypedValue()
        if xdmValue == NULL:
            return None
        else:
            val = PyXdmValue()
            val.thisvptr = xdmValue
            return val

     @property
     def base_uri(self):
        """ 
        base_uri(self)
        Base uri Property. Get the Base URI for the node, that is, the URI used for resolving a relative URI contained in the node.
        This will be the same as the System ID unless xml:base has been used. Where the node does not have a base URI of its own,
        the base URI of its parent node is returned.
        Returns:
            str: String value of the base uri for this node. This may be null if the base URI is unknown, including the case
                 where the node has no parent.
        """
        return make_py_str(self.derivednptr.getBaseUri())

     @property
     def string_value(self):
        """
        get_String_value(self)
        Property to get the string value of the node as defined in the XPath data model.

        Returns:
            str: The string value of this node

        """
        cdef const char* c_string = self.derivednptr.getStringValue()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring


     def __str__(self):
        """
        __str__(self)
        The string value of the node as defined in the XPath data model
        Returns:
            str: String value of this node
        """
        cdef const char* c_string = self.derivednptr.toString()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring

     def __repr__(self):
        """
        ___repr__ 
        """
        cdef const char* c_string = self.derivednptr.toString()
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
        return ustring



     def get_parent(self):
        """
        get_parent(self)
        Get the current node's parent

        Returns:
            PyXdmNode: The parent node as PyXdmNode object
        """

        cdef PyXdmNode val = PyXdmNode()
        val.derivednptr = val.derivedptr = val.thisvptr = self.derivednptr.getParent()
        return val

     def get_attribute_value(self, name):
        """
        getAttribute_value(self, name)
        The name of the required attribute
        
        Args:
            name(str): the eqname of the required attribute

        """
        py_value_string = name.encode('UTF-8') if name is not None else None
        cdef char * c_name = py_value_string if name is not None else ""
         
        cdef const char* c_string = self.derivednptr.getAttributeValue(c_name)
        ustring = c_string.decode('UTF-8') if c_string is not NULL else None
                
        return ustring

     @property
     def attribute_count(self):
        """
        attribute_count(self)
        Property to get the count of attribute nodes on this XdmNode object. If this current node is not an element node then return 0

        Returns:
            int: Count of attribute nodes

        """
        return self.derivednptr.getAttributeCount()

     @property
     def attributes(self):
        """
        attribute_nodes(self)
        Property to get the attribute nodes as a list of PyXdmNode objects

        Returns:
            list[PyXdmNode]: List of PyXdmNode objects
        """
        cdef list nodes = []
        cdef saxoncClasses.XdmNode **n
        cdef int count, i
        cdef PyXdmNode val = None
        count = self.derivednptr.getAttributeCount()
        if count > 0:
            n = self.derivednptr.getAttributeNodes()
            for i in range(count):
                val = PyXdmNode()
                val.derivednptr = val.derivedptr = val.thisvptr = n[i]
                val.derivednptr.incrementRefCount()
                nodes.append(val)

        return nodes


     @property
     def children(self):
        """
        children(self)
        Property to get children of this current node. List of child nodes

        Returns:
            list[PyXdmNode]: List of PyXdmNode objects
        """
        cdef list nodes = []
        cdef saxoncClasses.XdmNode **n
        cdef int count, i
        cdef PyXdmNode val = None
        count = self.derivednptr.getChildCount()
        if count > 0:
            n = self.derivednptr.getChildren()
            for i in range(count):
                val = PyXdmNode()
                val.derivednptr = val.derivedptr = val.thisvptr = n[i]
                val.derivednptr.incrementRefCount()
                nodes.append(val)

        return nodes

      # def getChildCount(self):


cdef class PyXdmAtomicValue(PyXdmItem):
     """
     The class PyXdmAtomicValue represents an item in an Xath sequence that is an atomic value. The value may belong to any of the
     19 primitive types defined in XML Schema, or to a type derived from these primitive types, or the XPath type xs:untypedAtomic.
     """

     cdef saxoncClasses.XdmAtomicValue *derivedaptr      # hold a C++ instance which we're wrapping

     def __cinit__(self):
        if type(self) is PyXdmAtomicValue:
            self.derivedaptr = self.derivedptr = self.thisvptr = new saxoncClasses.XdmAtomicValue()
     def __dealloc__(self):
        if self.derivedaptr != NULL and self.derivedaptr != NULL:
            if self.derivedaptr.getRefCount() < 1:
                del self.derivedaptr
            else:
                self.derivedaptr.decrementRefCount()
            

     @property
     def primitive_type_name(self):
        """
        get_primitive_type_name()
        Property - Get the primitive type name of the PyXdmAtomicValue
        Returns:
            str: String of the primitive type name

        """      
        cdef const char* c_string = self.derivedaptr.getPrimitiveTypeName()
        ustring = c_string.decode('UTF-8')
        return ustring


     @property
     def boolean_value(self):
        """
        Property which returns the boolean value of the PyXdmAtomicValue

        Returns:
            bool: boolean value.


        """
        return self.derivedaptr.getBooleanValue()

     @property
     def double_value(self):
        """
        Property which is returns the double value of the PyXdmAtomicValue if it can be converted.

        Returns:
            double: Double value of the Xdm object

        """
        
        return self.derivedaptr.getDoubleValue()

     @property
     def head(self):
        """
        head(self)
        Property to get the first item in the sequence. This would be the PyXdmAtomicValue itself as there is only one item in the sequence

        Returns:
            PyXdmAtomicValue: The PyXdmAtomic or None if the sequence is empty

        """
        return self
    

     @property
     def integer_value(self):
        """
        Property which is returns the int value of the PyXdmAtomicValue if it can be converted.

        Returns:
            int: Int value of the Xdm object

        """
        
        return self.derivedaptr.getLongValue()


     @property
     def string_value(self):
        """
        Property which returns the string value of the PyXdmAtomicValue
        Returns:
            str: String value of the Xdm object
        """
        cdef const char* c_string = self.derivedaptr.getStringValue()
        ustring = c_string.decode('UTF-8')
        return ustring


     def __str__(self):
        """
        __str__(self)
        The string value of the node as defined in the XPath data model
        Returns:
            str: String value of this node
        """
        cdef const char* c_string = self.derivedaptr.getStringValue()
        ustring = c_string.decode('UTF-8')
        return ustring

     def __repr__(self):
        """
        ___repr__ 
        """
        cdef const char* c_string = self.derivedaptr.getStringValue()
        ustring = c_string.decode('UTF-8')
        return ustring

