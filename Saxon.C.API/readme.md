[Back to web page](http://www.saxonica.com/saxon-c/index.xml)

# Table of Contents
1. [Installation](#Installation)
2. [Getting started with C/C++](#getting-started)
3. [PHP API & Examples](#php-api)
4. [Python API & Examples](#python-api)
5. [Technical](#tech)
6. [Limitations](#limitations)

Saxon/C 1.2.1 is the latest release of Saxon-HE/PE/EE on the C/C++, PHP and Python programming platforms. The APIs support the specifications XSLT 3.0, XQuery 3.1, Schema Validation 1.0/1.1 and XPath 3.1.

Saxon/C is built from the Saxon 9.9.1.5 Java product using Excelsior JET Enterprise 15.3 edition (MP1).

Platforms supported: Linux 64-bit, Mac OS and Windows 64-bit. 

Saxon/C is released in three separate editions, as on the Java platform: Enterprise Edition (Saxon-EE/C), Professional Edition (Saxon-PE/C), and Home Edition (Saxon-HE/C)

<div id='installation'/>
## Installation: ##

#### Linux: Saxon-HE/C, Saxon-PE/C and Saxon-EE/C: ####
To install any of the Saxon/C releases, unzip the file libsaxon-EDITION-setup-v#.#.#.zip and execute the command './libsaxon-EDITION-setup-v#.#.#'
First step is to select the destination of where the product files will be installed.
The product files are unpacked in the directory 'Saxon-EDITIONC'

Link the dynamic saxon library so it can be found. For example:

	ln -s /usr/lib/Saxonica/Saxon-EDITIONC#.#.#/libsaxonEDITION.so /usr/lib/libsaxonEDITION.so

You need to setup the environment for the jet jvm. The jvm is in the directory JET-home=Saxonica/Saxon-EDITION1.2.0/rt
The directory JET_home/lib/amd64 must be listed in the LD_LIBRARY_PATH environment variable. For instance, if you
are using bash or Bourne shell, use the following commands:

    export LD_LIBRARY_PATH=/usr/lib/rt/lib/amd64:$LD_LIBRARY_PATH

We assume that the 'rt' directory is in the location /usr/lib.

Link the jetvm library so it can be found. For example:

	ln -s /usr/lib/Saxonica/Saxon-EDITIONC#.#.#/rt /usr/lib/rt

The Saxon-EDITION API assumes the library is installed as follows: '/usr/lib/libsaxonhec.so', '/usr/lib/libsaxonpec.so' or '/usr/lib/libsaxoneec.so'


Example of running the C++ test files (i.e. testXPath.cpp, testXQuery.cpp, testXSLT.cpp, testXSLT30.cpp and testValidator.cpp):
 
    cd samples/cppTests/
 
    ./build64-linux.sh
 
    ./testXPath
    ./testXSLT
    ./testXSLT30
    ./testXQuery
    ./testValidator (Saxon-EE/C only)

 #### Mac OS: Saxon-HE/C, Saxon-PE/C and Saxon-EE/C: ####
To install any of the Saxon/C releases on the Mac OS system, unzip the self-contained file libsaxon-EDITION-mac-setup-v#.#.#.zip
 
The first step is to copy the library libsaxonEDITION.dylib and the rt directories to a your install location. 
The C/C++ interface by default assumes the library files and directories are installed in the directory '/usr/local/lib'. 
The location of the Saxon/C library can be set using the SAXONC_HOME environment variable. 
The privileges of the folders and files may need adjusting after copying everything if you encounter permission issues.

    cd libsaxon-HEC-mac-setup-v1.2.0/    
    sudo cp libsaxonhec.dylib /usr/local/lib/.    
    sudo cp -r rt /usr/local/lib/.
 
The DYLD_LIBRARY_PATH environment variable must be set as follows:

    export JET_HOME=/usr/local/lib/rt
    export DYLD_LIBRARY_PATH=$JET_HOME/lib/jetvm:$DYLD_LIBRARY_PATH
    
    
Example of running the C++ test file:
 
    cd samples/cppTests/
 
    ./build64-mac.sh
 
    ./testXPath

#### PHP extension: ####
 
A built php extension module is included in the Saxon/C distrubtion, see the directory 'php-library-module'.
 See the file saxon.so (Available for Linux and Mac OS). This was built using the php 7.2 version.
 For PHP5 please copy files in the PHP5-Build directory into the Saxon.C.API directory.
 
To build the php extension follow the steps below:

Run the commands (from the root directory of the Saxon/C installation):

    cd Saxon.C.API
    phpize
    ./configure --enable-saxon
    make
    sudo make install

Create a module conf file:

nano /etc/php7/mods-available/saxon.ini
and add contents:

	; configuration for php Saxon HE/PE/EE module
	    extension=saxon.so
	save the file.

Enable the module for PHP:

	php7enmod saxon
	
Similar for PHP5

Alternatively, you can update the php.ini file (if using ubuntu it is usually in the location '/etc/php7/apache2/') to contain the php extension: insert the following in the Dynamic Extensions section: extension=saxon.so

* sudo service apache2 restart

Check that the extension has installed properly:

* php -d"extension=saxon.so" -m
* Also Create a php page and call the function 'phpinfo()'. Look for the Saxon/C entry.

See example PHP scripts in the 'samples/php' directory. Specifically the files (xpathExamples.php, xqueryExamples.php, xsltExamples.php, xslt30Examples.php and validatorExamples.php). 


### Python ###
The Saxon/C Python extension API has been developed using [Cython](https://cython.org/) for Python3.
Cython is required to build the extension library.

To install python and cython on MacOS I recommend using brew or MacPorts. 

The Saxon/C Python extension is in the directory Saxon.C.API/python-saxon

The Python extension on the Linux and MacOS platforms can be built using the following command:

`python3 saxon-setup.py build_ext -if`

Please see the [Python API documentation](http://www.saxonica.com/????/saxonc.html)

<div id='getting-started'/>

## Getting started with C/C++: ##

To get started please browse the Saxon/C API starting with the class [SaxonProcessor](classSaxonProcessor.html) class which acts as a factory class for generating the processors.

## C/C++ ##



### c: ###

For c programming see the test harnesses for XSLT, XQuery, Schema Validation and XPath in C code along with the build and run script in the directory 'cTests'.

The following files are required to build Saxon/C on C++:  SaxonCGlue.c, SaxonXProcessor.c, SaxonCXPath.c

To compile the sample test code in C execute the 'build.sh' file the directory 'cTests'. This file builds executables for the test cases testing XSLT, XPath, XQuery and schema Validator. The command is similar to the following:

> gcc -m32 -I$jdkdir/include -I$jdkdir/include/linux -I /System/Library/Frameworks/JavaVM.framework/Headers ../SaxonCGlue.c ../SaxonCProcessor.c ../SaxonCXPath.c  testXSLT.c -o testXSLT -ldl -lc $1

Saxon/C can be run from the commandline in a similar way to its Java counterpart (same options are available). See the file Transform.c, Query.c and Validate.c (which is available in Saxon-EE/C) in the directory 'command'. The build.sh script can be executed to build the commandline programs.


### C++: ###
For C++ programming see sample code for XSLT, XQuery, Schema Validation and XPath in C++ code along with the build and run script in the directory 'cppTests'.

The following files are required to build Saxon/C on C++:  SaxonCGlue.c, SaxonCXPath.c, XdmValue.cpp, XdmItem.cpp, XdmNode.cpp, XdmAtomicValue.cpp, SaxonProcessor.cpp, XsltProcessor.cpp, Xslt30Processor.cpp and XQueryProcessor.cpp, XPathProcessor.cpp, SchemaValidator.cpp

To compile the sample test code in C++ execute the 'build.sh' file the directory 'cppTests'. This file builds executables for the test cases testing XSLT, XPath, XQuery and schema Validator. The command is similar to the following: 

> g++ -m32  ../bin/SaxonCGlue.o ../bin/SaxonCXPath.o ../bin/SaxonProcessor.o ../bin/XQueryProcessor.o ../bin/XsltProcessor.o, ../bin/Xslt30Processor.o ../bin/XPathProcessor.o ../bin/XdmValue.o ../bin/XdmItem.o ../bin/XdmNode.o ../bin/XdmAtomicValue.o ../bin/SchemaValidator.o testXSLT.cpp -o testXSLT -ldl -lc $1 $2




### Configuration of Processors - (setParameter & setProperty methods) ###

There are many parameters and options that can be set to control the way in which Saxon behaves. At a global level when the SaxonProcessor is created, the configuration features can be set with the method 'setConfigurationProperty(const char * name, const char * value)'. For a comprehensive guide on the configuration see the [Saxon documentation](http://saxonica.com/documentation/index.html#!configuration/config-features). There are some feature that don't work or are under tested. For eample, 'bytecode generation' we know does not work.

The example below shows how we can set the configuration features on the processor before we create any of the processors (.e.g. XsltProcessor, XQueryProcess, etc):

> processor->setConfigurationProperty("xsdversion", "1.1"); 
or
> processor->setConfigurationProperty("http://saxon.sf.net/feature/multipleSchemaImports", "on");

The processors for XSLT, XQuery, XPath and Schema Validator can be configured using the methods setParameter and setProperty. Depending on the specific processor the exact purpose of these methods may differs. In the following sections we will go through the options available.


We now give a quick guide for running Saxon/C in C++

### XSLT ###

#### setParameter(string $name, XdmValue $value) Method ####

| Name | Example | Comment |
| :---- | :---- | :---- |
| 'node'=xdmValue | setParameter("node",xdmNodeObj) | Sets the source document for transformation. We also accept the parameter names 'item'.|
| param=xdmValue | setParameter("numParam",value1) | set the value of a stylesheet parameter|

#### setProperty(string $name, string $propValue) Method ####

The properties are a subset to those specified for running XSLT from the [command line](http://www.saxonica.com/documentation/index.html#!using-xsl/commandline).

| Name | Example | Comment |
| :---- | :---- | :---- |
|![serialization name]=value  | setProperty("!INDENT","yes") | Influence the serialization of the XML by the parameters specified with a exclamation mark with a name and the value. See [Documentation](http://saxonica.com/documentation/index.html#!javadoc/net.sf.saxon.s9api/Serializer/Property) |
| 'o'=filename | setProperty("o", "output.xml") | Sets the destination for the result of the transformation to the specificed filename  |
| 'it'=name | setProperty("it", "name") | Set the initial named template for the transformation by name|
| 'dtd'=boolean | setProperty("dtd", "true") | Set whether DTD validation should be applied to documents loaded |
| 'im'=name | setProperty("im", "mode-name")  | Set the initial mode for the transformation |
| 's'=filename | setProperty("s", "filename") | Identifies the source file or directory. Mandatory unless the -it option is used. |
| 'resources'=directory | setProperty("resources", "dir") | Specifies the directory where the resources file are found|
| 'tunnel' | setProperty("tunnel", "true") | XSLT3.0 only. Accepts the values true, false, yes, no. True if the initial template parameter values are to be used for setting tunnel parameters; false if they are to be used for non-tunnel parameters |
| 'outvalue' | setProperty("outvalue", "true") | XSLT30 only. Accepts the values true, false, yes, no. Set if the return type of callTemplate, applyTemplate and transform methods is to return XdmValue, otherwise return XdmNode object with root Document node |
| 'extc'=dir/saxonc | setProperty("extc", "dir/saxonc") | Specifies the full path to the C/C++ Saxon/C API library which contains the extension function. See example in samples/cppTests|
| 'm' | setProperty("m", "") | The presence of this property creates a message listener which is available in the C/C++ API of Saxon/C|



Example 1:
 
<pre><code>
	SaxonProcessor *processor = new SaxonProcessor(true);
	XsltProcessor * xslt = processor->newXsltTransformer();
	cout<<"Hello World"<<endl;
	cout<<"Test output: "<<xslt->transformFileToString("cat.xml","test.xsl")<<endl;
</code></pre>

Example 2:

<pre><code>
	SaxonProcessor * processor = new SaxonProcessor(false);
	XsltProcessor * xslt = processor->newXsltTransformer();

        xslt->setSourceFile("xml/foo.xml");
	XdmAtomicValue * xdmvaluex =processor->makeStringValue("Hello to you");
	if(xdmvaluex !=NULL){
		cerr<< "xdmvaluex ok"<<endl; 			
	}
	xslt->setParameter("a-param", xdmvaluex);
        const char * result = test->transformFileToString(NULL, "xsl/foo.xsl");
	if(result != NULL) {
		cerr<<result<<endl;
	} else {
		cerr<<"Result is NULL"<<endl;
	}
	processor->clearParameters(true);
	processor->clearProperties();
</code></pre>

Example 3:

<pre><code>
	SaxonProcessor * processor = new SaxonProcessor(false);
	Xslt30Processor * xslt = processor->newXslt30Transformer();

    xslt->setInitialMatchSelectionAsFile("cat.xml");
    const char * output = xslt->applyTemplatesReturningString("test.xsl");
	if(output !=NULL){
		cerr<< output<<endl; 			
	}
	XdmValue * values = new XdmValue(processor);
    values->addXdmItem((XdmItem*)processor->makeIntegerValue(10));
    values->addXdmItem((XdmItem*)processor->makeIntegerValue(5));
    values->addXdmItem((XdmItem*)processor->makeIntegerValue(6));
    values->addXdmItem((XdmItem*)processor->makeIntegerValue(7));
       
    xslt->setParameter("values",(XdmValue *)values);
        
    xslt->setInitialMatchSelection((XdmValue*)input);
	xslt->compileFromFile("test2.xsl");
    
    const char * rootValue = trans->callTemplateReturningString(NULL, "main");

	
	if(rootValue != NULL) {
		cerr<<rootValue<<endl;
	} else {
		cerr<<"Result is NULL"<<endl;
	}
	xslt->clearParameters(true);
	xslt->clearProperties();
</code></pre>

### XQuery ###

#### setParameter(string $name, XdmValue $value) Method ####

| Name | Example | Comment |
| :---- | :---- | :---- |
| 'node'=xdmValue | setParameter("node",xdmNodeObj) | Sets the source document for query. We also accept the parameter names 'item'.|
| param=xdmValue | setParameter("numParam",value1) | Set the value of external variable defined in the query |

#### setProperty(string $name, string $propValue) Method ####

The properties are a subset to those specified for running XQuery from the [command line](http://www.saxonica.com/documentation/index.html#!using-xquery/commandline).
| Name | Example | Comment |
| :---- | :---- | :---- |
| 'base'=base-URI | setProperty("base", "/home/username/example") | |
| 'q'=query-fileName | setProperty("q", "filename") | Identifies the file containing the query. |
|'qs'=query-string  | setProperty("qs", "saxon:line-number((//person)[1])") | Allows the query to be specified inline. |
|![serialization name]=value  | setProperty("!INDENT","yes") | Influence the serialization of the XML by the parameters specified with a exclamation mark with a name and the value. See [Documentation](http://saxonica.com/documentation/index.html#!javadoc/net.sf.saxon.s9api/Serializer/Property) |
| 'o'=filename | setProperty("o", "output.xml") | Sets the destination for the result of the XQuery to the specificed filename  |
| 'dtd'=boolean | setProperty("dtd", "true") | Set whether DTD validation should be applied to documents loaded |
| 's'=filename | setProperty("s", "filename") | Identifies the source file or directory. Mandatory unless the -it option is used. |
| 'resources'=directory | setProperty("resources", "dir") | Specifies the directory where the resources file are found|
| 'sa'=boolean | setProperty("sa", "true") | Invoke a schema-aware query. Requires Saxon-EE to be installed. |
| 'extc'=dir/saxonc | setProperty("extc", "dir/saxonc") | Specifies the full path to the C/C++ Saxon/C API library which contains the extension function. See example in samples/cppTests|

Example:

<pre><code>
	SaxonProcessor *processor = new SaxonProcessor(true);
	XsltProcessor * xslt = processor->newXQueryProcessor();
	 queryProc->setProperty("s", "cat.xml");

        queryProc->setProperty("q", "family.xq");
        queryProc->runQueryToString();
</code></pre>

### XPath ###

#### setParameter(string $name, XdmValue $value) Method ####

| Name | Example | Comment |
| :---- | :---- | :---- |
| 'node'=xdmValue | setParameter("node",xdmNodeObj) | Sets the source document for query. We also accept the parameter names 'item'.|
| param=xdmValue | setParameter("numParam",value1) | Set the value of external variable defined in the query |

#### setProperty(string $name, string $propValue) Method ####

| Name | Example | Comment |
| :---- | :---- | :---- |
|![serialization name]=value  | setProperty("!INDENT","yes") | Influence the serialization of the XML by the parameters specified with a exclamation mark with a name and the value. See [Documentation](http://saxonica.com/documentation/index.html#!javadoc/net.sf.saxon.s9api/Serializer/Property) |
| 'o'=filename | setProperty("o", "output.xml") | Sets the destination for the result of the XQuery to the specificed filename  |
| 'dtd'=boolean | setProperty("dtd", "true") | Set whether DTD validation should be applied to documents loaded |
| 's'=filename | setProperty("s", "filename") | Identifies the source file or directory. Mandatory unless the -it option is used. |
| 'resources'=directory | setProperty("resources", "dir") | Specifies the directory where the resources file are found|
| 'extc'=dir/saxonc | setProperty("extc", "dir/saxonc") | Specifies the full path to the C/C++ Saxon/C API library which contains the extension function. See example in samples/cppTests|

Example:

<pre><code>
	SaxonProcessor *processor = new SaxonProcessor();
	XPathProcessor * xpath = processor->newXPathProcessor();
 
	xpath->setContextFile("cat.xml");

	XdmValue * resultValues = xpath->evaluate("//person");
	
	if(resultValues == NULL) {
		 printf("result is null \n");
	} else {
		cout<<"Number of items="<<resultValues->size();
		for(int i =0; i< resultValues->size();i++){
			XdmItem * itemi = resultValues->itemAt(i);
			if(itemi == NULL) {
				cout<<"Item at position "<<i<<" should not be null";
				break;
			}
			cout<<"Item at "<<i<<" ="<<itemi->getStringValue(processor);		
		}
	}
	xpath->clearParameters(true);
  	xpath->clearProperties();
</code></pre>

### XML Schema Validation ###

| Name | Example | Comment |
| :---- | :---- | :---- |
| 'node'=xdmValue | setParameter("node",xdmNodeObj) | Sets the source document for the validation. We also accept the parameter names 'item'.|
| param=xdmValue | setParameter("numParam",value1) | Set the value of external variable defined in the query |

#### setProperty(string $name, string $propValue) Method ####

The properties are a subset to those specified for running the Schema Validator from the [command line](http://www.saxonica.com/documentation/index.html#!schema-processing/commandline).
| Name | Example | Comment |
| :---- | :---- | :---- |
|![serialization name]=value  | setProperty("!INDENT","yes") | Influence the serialization of the XML by the parameters specified with a exclamation mark with a name and the value. See [Documentation](http://saxonica.com/documentation/index.html#!javadoc/net.sf.saxon.s9api/Serializer/Property) |
| 'o'=filename | setProperty("o", "output.xml") | Sets the destination for the result of the XQuery to the specificed filename  |
| 'string'=xml-string | setProperty("string",xml-string) | Sets the source document aas a string for validation. Parsing will happen when the validate method has been called.|
| 'dtd'=boolean | setProperty("dtd", "true") | Set whether DTD validation should be applied to documents loaded |
| 's'=filename | setProperty("s", "filename") | Identifies the source file or directory. Mandatory unless the -it option is used. |
| 'resources'=directory | setProperty("resources", "dir") | Specifies the directory where the resources file are found|
| 'report-node'=boolean | setProperty("report-node", "true") | Flag for validation reporting feature. Error validation failures are represented in an XML document |
| 'report-file'=filename | setProperty("report-file", "filename") | Switches on the validation reporting feature. Validation failures collected and saved in an XML format in a file.|
| 'verbose'=boolean | setProperty("verbose", "true") | Set verbose mode to output to the terminal validation exceptions. The default is on providing the reporting feature has not been enabled.|
| 'element-type'=string | setProperty("element-type", "{uri}local") | Set the name of the required type of the top-level element of the document to be validated. The string should be in the Clark notation: {uri}local|
| 'element-name'=string | setProperty("element-name", "{uri}local") | Set the name of the required top-level element of the document to be validated (that is, the name of the outermost element of the document). The string should be in the Clark notation: {uri}local|
| 'lax'=boolean | setProperty("lax", "true") | The validation mode may be either strict or lax. Default is strict. This property indicates that lax validation is required.|

Example:

<pre><code>
	SaxonProcessor * processor = new SaxonProcessor(true);
	processor->setConfigurationProperty("xsdversion", "1.1");
	processor->setConfigurationProperty("http://saxon.sf.net/feature/multipleSchemaImports", "on");
	SchemaValidator * val = processor->newSchemaValidator();
	val->registerSchemaFromFile("family-ext.xsd");
      
	val->registerSchemaFromFile("family.xsd");
	val->setProperty("report-node", "true");	
	val->setProperty("verbose", "true");
	val->validate("family.xml");
	XdmNode * node = val->getValidationReport(); 
	if(node != NULL) {
		cout<<"Validation Report"<<node->getStringValue();
	} else {
		cout<<"Error: Validation Report is NULL";
	}
</code></pre>



<div id='php-api'/>
## PHP ##

#### PHP API ####
The PHP API is split up in the following class (links are to the C++ classes): SaxonProcessor, XsltProcessor, Xslt30Processor, XPathProcessor, XQueryProcessor  and SchemaValidator. We also have class for a sub-set of the  XDM data model: XdmValue, XdmNode, XdmItem and XdmAtomicValue.

The methods on these class are given below. For a more comprehensive description of the methods and their argument please see its counterpart in the C++ API.

#### Saxon\\SaxonProcessor class ####
<sup>PHP API</sup>


|  |  |
| ----: | :---- |
|     | *SaxonProcessor()* <br> *Default Constructor. Create an unlicensed Saxon Processor*   |
|   | SaxonProcessor(boolean $license)<br> *Constructor. Indicates whether the Processor requires features of Saxon that need a license file. If false, the method will creates a Configuration appropriate for Saxon HE (Home edition). If true, the method will create a Configuration appropriate to the version of the software that is running  Saxon-PE or Saxon-EE*  |
|  |SaxonProcessor(boolean $license, string $cwd) <br> *Constructor. Indicates whether the Processor requires features of Saxon that need a license file. The cwd arugment is used to manually set the current working directory used for executions of source files*  |
| XdmValue | createAtomicValue($primitive_type val)<br> *Create an Xdm Atomic value from any of the main primitive types (i.e. bool, int, float, double, string)* |
| Saxon\\XdmNode | parseXmlFromString(string $value) <br> *Create an XdmNode object. The $value is a lexical representation of the XML document* |
| Saxon\\XdmNode | parseXmlFromFile(string $fileName) <br> *Create an XdmNode object. Value is a string type and the file name to the XML document. File name can be relative or absolute. IF relative the cwd is used to resolve the file.* |
| void | setcwd(string $cwd) <br> *Set the current working directory used to resolve against files* |
| Saxon\\XdmNode | parseXmlFromFile(string $fileName) <br> *Create an XdmNode object. Value is a string type and the file name to the XML document. File name can be relative or absolute. IF relative the cwd is used to resolve the file.* |
| void | setResourceDirectory(string $dir) <br> *Set the resources directory of where Saxon can locate data folder* |
| void | setConfigurationProperty(string $name, string $value) <br> *Set a configuration property specific to the processor in use. Properties specified here are common across all the processors. See [Configuration Features](http://www.saxonica.com/documentation/index.html#!configuration/config-features)* |
| Saxon\\XsltProcessor | newXsltProcessor() <br> *Create an XsltProcessor in the PHP environment. An XsltProcessor is used to compile and execute XSLT sytlesheets* |
| Saxon\\Xslt30Processor | newXslt30Processor() <br> *Create an Xslt30Processor in the PHP environment specifically designed for XSLT 3.0 processing. An Xslt30Processor is used to compile and execute XSLT 3.0 sytlesheets. Use this class object (Xslt30Processor) instead of the XsltProcessor for XSLT 3.0 processing.* |
| Saxon\\XQueryProcessor | newXQueryProcessor() <br> *Create an XQueryProcessor in the PHP environment. An XQueryProcessor is used to compile and execute XQuery queries* |
| Saxon\\XPathProcesssor | newXPathProcessor() <br> *Create an XPathProcessor in the PHP environment. An XPathProcessor is used to compile and execute XPath expressions* |
| Saxon\\SchemaValidator | newSchemaValidator() <br> *Create a SchemaValidator in the PHP environment. A SchemaValidator provides capabilities to load and cache XML schema definitions. You can also valdiate source documents with egistered XML schema definitions* |
| string | version() <br> *Report the Java Saxon version* |
| void | registerPHPFunctions(string $library) <br> *Enables the ability to use PHP functions as XSLT functions. Accepts as parameter the full path of the Saxon/C PHP Extension library. This is needed to do the callbacks* |


#### Saxon\\XsltProcessor class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| void | transformFileToFile(string $sourceFileName, string $stylesheetFileName, string outputfileName) <br> *Perform a one shot transformation. The result is stored in the supplied outputfile name.*  |
| string | transformFileToString(string $sourceFileName, string $stylesheetFileName) <br> *Perform a one shot transformation. The result is returned as a string. If there are failures then a null is returned* |
| XdmValue | transformFileToValue(string $fileName) <br> *Perform a one shot transformation. The result is returned as an XdmValue* |
| void | transformToFile() <br> *Perform the transformation based upon cached stylesheet and source document.* |
| string | transformToString() |
| XdmValue | transformToValue() <br> *Perform the transformation based upon cached stylesheet and any source document. Result returned as an XdmValue object. If there are failures then a null is returned* |
| void | compileFromFile(string $fileName) <br> *Compile a stylesheet suplied as by file name* |
| void | compileFromString(string $str) <br> *Compile a stylesheet received as a string.*  |
| void | compileFromValue(XdmNode $node)<br> *Compile a stylesheet received as an XdmNode.* |
| void | setOutputFile(string $fileName) <br> *Set the output file name of where the transformation result is sent* |
| void | setSourceFromXdmValue(XdmValue $value) <br> *The source used for a query or stylesheet. Requires an XdmValue object* |
| void | setSourceFromFile(string $filename) <br> *The source used for query or stylesheet. Requires a file name as string* |
| void | setParameter(string $name, XdmValue $value) <br> *Set the parameters required for XSLT stylesheet* |
| void | setProperty(string $name, string $value) <br> *Set properties for the stylesheet.* |
| void | clearParameters() <br> *Clear parameter values set* |
| void | clearProperties() <br> *Clear property values set* |
| void | exceptionClear() <br> *Clear any exception thrown* |
| string | getErrorCode(int $i)  <br> *Get the ith error code if there are any errors* |
| string | getErrorMessage(int $i) <br> *Get the ith error message if there are any error* |
| int | getExceptionCount() <br> *Get number of error during execution or evaluate of stylesheet* |


#### Saxon\\Xslt30Processor class ####
<sup>PHP API</sup>


|  |  |
| ----: | :---- |
| void | addPackages(array packageFileNames) <br> *File names to XsltPackages stored on filestore are added to a set of packages, which will imported later for use when compiling.*  |
| void | applyTemplatesReturningFile(string $stylesheetFileName) <br> *Invoke the stylesheet by applying templates to a supplied input sequence, Saving the results to file. The stylesheet file name argument can be supplied here. If null then the most recently compiled stylsheet is used.*  |
| string | applyTemplatesReturningString(string $stylesheetFileName) <br> *Invoke the stylesheet by applying templates to a supplied input sequence. The result is returned as a serialized string. The stylesheet file name argument can be supplied here. If null then the most recently compiled stylsheet is used.* |
| PyXdmValue | applyTemplatesReturningValue(string $stylesheetFileName) <br> *Invoke the stylesheet by applying templates to a supplied input sequence. the result is returned as an XdmValue object. The stylesheet file name argument can be supplied here. If null then the most recently compiled stylsheet is used.* |
| void | compileFromAssociatedFile(string xmlFileName)<br> *Get the stylesheet associated via the xml-stylesheet processing instruction (see http://www.w3.org/TR/xml-stylesheet/) with the document document specified in the source parameter, and that match the given criteria.  If there are several suitable xml-stylesheet processing instructions, then the returned Source will identify a synthesized stylesheet module that imports all the referenced stylesheet module.* |
| void | compileFromFile(string $fileName) <br> *Compile a stylesheet suplied as by file name* |
| void | compileFromString(string $str) <br> *Compile a stylesheet received as a string.*  |
| void | compileFromValue(XdmNode $node)<br> *Compile a stylesheet received as an XdmNode.* |
| void | compileFromFileAndSave(string $fileName, string outputFileName) <br> *Compile a stylesheet suplied as by file name and save as an exported file (SEF)* |
| void | compileFromStringAndSave(string $str, string outputFileName) <br> *Compile a stylesheet received as a string and save as an exported file (SEF).*  |
| void | compileFromValueAndSave(XdmNode $node, string outputFileName)<br> *Compile a stylesheet received as an XdmNode and save as an exported file (SEF).* |
| void | callFunctionReturningFile(string $FunctionName, array arguments, string outputfileName) <br> *Call a public user-defined function in the stylesheet. Here we wrap the result in an XML document, and sending this document to a specified file. Arguments: function name and array of XdmValue objects - he values of the arguments to be supplied to the function. These will be converted if necessary to the type as defined in the function signature, using the function conversion rules. *  |
| string | callFunctionReturningString(string $FunctionName, array arguments) <br> *Call a public user-defined function in the stylesheet. Here we wrap the result in an XML document, and serialized this document to string value. Arguments: function name and array of XdmValue objects - he values of the arguments to be supplied to the function. These will be converted if necessary to the type as defined in the function signature, using the function conversion rules.* |
| PyXdmValue | callFunctionReturningValue(string $FunctionName, array arguments) <br> *Call a public user-defined function in the stylesheet. Here we wrap the result in an XML document, and return the document as an XdmVale. Arguments: function name and array of XdmValue objects - he values of the arguments to be supplied to the function. These will be converted if necessary to the type as defined in the function signature, using the function conversion rules.* |
| void | callTemplateReturningFile(string $stylesheetFileName, string $templateName, string outputfileName) <br> *Invoke a transformation by calling a named template. The result is stored in the supplied outputfile name. If the templateName argument is null then the xsl:iitial-template is used. Parameters supplied using setInitialTemplateParameters are made available to the called template.*  |
| string | callTemplateReturningString(string $stylesheetFileName, string $templateName) <br> *Invoke a transformation by calling a named template and return result as a string. If the templateName argument is null then the xsl:iitial-template is used. Parameters supplied using setInitialTemplateParameters are made available to the called template.* |
| PyXdmValue | callTemplateReturningValue(string $stylesheetFileName, string $templateName) <br> *Invoke a transformation by calling a named template and return result as an XdmValue. If the templateName argument is null then the xsl:iitial-template is used. Parameters supplied using setInitialTemplateParameters are made available to the called template.* |
| void | transformFileToFile(string $sourceFileName, string $stylesheetFileName, string outputfileName) <br> *Perform a one shot transformation. The result is stored in the supplied outputfile name.*  |
| XdmValue | transformFileToValue(string $fileName) <br> *Perform a one shot transformation. The result is returned as an XdmValue* |
| XdmValue | transformFileToString(string $fileName) <br> *Perform a one shot transformation. The result is returned as a stringe* |
| void | transformToFile() <br> *Perform the transformation based upon cached stylesheet and source document. Result is saved to the supplied file name* |
| string | transformToString() <br> *Perform the transformation based upon cached stylesheet and source document. Result is returned as a serialized string* |
| PyXdmValue | transformToValue() <br> *Perform the transformation based upon cached stylesheet and any source document. Result returned as an XdmValue object. If there are failures then a null is returned* |
| void | setInitialTemplateParameters(array parameters, bool tunnel) <br> *Set parameters to be passed to the initial template. These are used whether the transformation is invoked by applying templates to an initial source item, or by invoking a named template. The parameters in question are the xsl:param elements appearing as children of the xsl:template element. The tunnel argument if set to true these values are to be used for setting tunnel parameters.* |
| void | setInitialMatchSelection() <br> *The initial value to which templates are to be applied (equivalent to the 'select' attribute of xsl:apply-templates)*|
| void | setInitialMatchSelectionAsFile <br> *The initial filename to which templates are to be applied (equivalent to the 'select' attribute of xsl:apply-templates) * |
| void | setGlobalContextItem <br> *Set the source document from an XdmNode for the transformation.*|
| void | setGlobalContextFromFile <br> *Set the source from file for the transformation.* |
| void | setOutputFile(string $fileName) <br> *Set the output file name of where the transformation result is sent* |
| void | setParameter(string $name, XdmValue $value) <br> *Set the parameters required for XSLT stylesheet* |
| void | setProperty(string $name, string $value) <br> *Set properties for the stylesheet.* |
| void | setJustInTimeCompilation(bool $value) <br> *ay whether just-in-time compilation of template rules should be used.* |
| void | setResultAsRawValue(bool $value) <br> *Set true if the return type of callTemplate, applyTemplates and transform methods is to return XdmValue, otherwise return XdmNode object with root Document node.* |
| void | clearParameters() <br> *Clear parameter values set* |
| void | clearProperties() <br> *Clear property values set* |
| void | exceptionClear() <br> *Clear any exception thrown* |
| string | getErrorCode(int $i)  <br> *Get the ith error code if there are any errors* |
| string | getErrorMessage(int $i) <br> *Get the ith error message if there are any error* |
| int | getExceptionCount() <br> *Get number of error during execution or evaluate of stylesheet* |



#### Saxon\\XQueryProcessor class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| XdmValue | runQueryToValue() <br> *compile and evaluate the query. Result returned as an XdmValue object. If there are failures then a null is returned* |
| string | runQueryToString() <br> *compile and evaluate the query. Result returned as string. If there are failures then a null is returned* |
| void | runQueryToFile(string $outfilename) <br> *compile and evaluate the query. Save the result to file* |
| void | setQueryContent(string $str) <br> *query supplied as a string* |
| void | setQueryItem(XdmItem $item) <br> ** |
| void | setQueryFile($string $filename) <br> *query supplied as a file* |
| void | setContextItemFromFile(string $fileName) <br> *Set the initial context item for the query. Supplied as filename* |
| void | setContextItem(Xdm $obj) <br> *Set the initial context item for the query. Any one of the objects are accepted: XdmValue, XdmItem, XdmNode and XdmAtomicValue.* |
| void | setQueryBaseURI(string $uri) <br> *Set the static base URI for a query expressions compiled using this XQuery Processor. The base URI is part of the static context, and is used to resolve any relative URIS appearing within a query* |
| void | declareNamespace(string $prefix, string $namespace) <br> *Declare a namespace binding as part of the static context for XPath expressions compiled using this XQuery processor* |
| void | setParameter(string $name, XdmValue $value) <br> *Set the parameters required for XQuery Processor* |
| void | setProperty(string $name, string $value) <br> *Set properties for Query.* |
| void | clearParameters() <br> *Clear parameter values set* |
| void | clearProperties() <br> *Clear property values set* |
| void | exceptionClear() <br> *Clear any exception thrown* |
| string | getErrorCode(int $i) <br> *Get the ith error code if there are any errors* |
| string | getErrorMessage(int $i) <br> *Get the ith error message if there are any error* |
| int | getExceptionCount() <br> *Get number of error during execution or evaluate of query* |

#### Saxon\\XPathProcessor class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| void | setContextItem(string $fileName) <br> *Set the context item from a XdmItem* |
| void | setContextFile(string $fileName) <br> *Set the context item from  file* |
| boolean | effectiveBooleanValue(string $xpathStr) <br> *Evaluate the XPath expression, returning the effective boolean value of the result.* |
| XdmValue | evaluate(string $xpathStr) <br> *Compile and evaluate an XPath expression, supplied as a character string. Result is an XdmValue* |
| XdmItem | evaluateSingle(string $xpathStr) <br> *Compile and evaluate an XPath expression whose result is expected to be a single item, with a given context item. The expression is supplied as a character string.* |
| void | declareNamespace(string $prefix, string $namespace) <br> *Declare a namespace binding as part of the static context for XPath expressions compiled using this XPathProcessor* |
| void | setBaseURI(string $uri) <br> *Set the static base URI for XPath expressions compiled using this XQuery Processor. The base URI is part of the static context, and is used to resolve any relative URIS appearing within a query* |
| void | setParameter(string $name, XdmValue $value) <br> *Set the parameters required for XQuery Processor* |
| void | setProperty(string $name, string $value) <br> *Set properties for Query.* |
| void | clearParameters() <br> *Clear parameter values set* |
| void | clearProperties() <br> *Clear property values set* |
| void | exceptionClear() <br> *Clear any exception thrown* 
| string | getErrorCode(int $i) <br> *Get the ith error code if there are any errors*  |
| string | getErrorMessage(int $i) <br> *Get the ith error message if there are any error* |
| int | getExceptionCount() <br> *Get number of error during execution or evaluate of stylesheet and query, respectively* | 

#### Saxon\\SchemaValidator class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| void | setSourceNode(XdmNode $node) <br> *The instance document to be validated. Supplied as an Xdm Node* |
| void | setOutputFile(string $fileName) <br> *The instance document to be validated. Supplied file name is resolved and accessed* |
| void | registerSchemaFromFile(string $fileName) <br> *Register the Schema which is given as file name.* |
| void | registerSchemaFromString(string $schemaStr) <br> *Register the Schema which is given as a string representation.* |
| void | validate() <br> *Validate an instance document supplied as a Source object. Assume source document has already been supplied through accessor methods* | 
| void | validate(string $fileName) <br> *Validate an instance document supplied as a Source object. $filename - The name of the file to be validated. $filename can be null* |
| XdmNode | validateToNode() <br> *Validate an instance document supplied as a Source object with the validated document returned to the calling program. Assume source document has already been supplied through accessor methods* |
| XdmNode | validateToNode(string $fileName) <br> *Validate an instance document supplied as a Source object with the validated document returned to the calling program. $filename - The name of the file to be validated. $filename can be null* |
| XdmNode | getValidationReport <br> *Get the valdiation report produced after valdiating the soucre document. The reporting feature is switched on via setting the property on the SchemaValidator: validator.setProperty('report', 'true'). Return XdmNode* |
| void | setParameter(string $name, XdmValue $value) <br> *Set the parameters required for XQuery Processor* |
| void | setProperty(string $name, string $value) <br> *Set properties for Schema Validator.* |
| void | clearParameters() <br> *Clear parameter values set* |
| void | clearProperties() <br> *Clear property values set* |
| void | exceptionClear() <br> *Clear any exception thrown* 
| string | getErrorCode(int $i) <br> *Get the ith error code if there are any errors*  |
| string | getErrorMessage(int $i) <br> *Get the ith error message if there are any error* |
| int | getExceptionCount() <br> *Get number of error during execution of the validator* |
#### Saxon\\XdmValue class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| XdmItem | getHead() <br> *Get the first item in the sequence* |
| XdmItem | itemAt(int $index) <br> *Get the n'th item in the value, counting from zero* |
| int |  size() <br> *Get the number of items in the sequence* |
|  | addXdmItem(XdmItem $item) <br> *Add item to the sequence at the end.* |


#### Saxon\\XdmItem class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| string | getStringValue() <br> *Get the string value of the item. For a node, this gets the string value of the node. For an atomic value, it has the same effect as casting the value to a string. In all cases the result is the same as applying the XPath string() function.* |
| boolean |  isNode() <br> *Determine whether the item is a node value or not.* |
| boolean |  isAtomic() <br> *Determine whether the item is an atomic value or not.* |
|  XdmAtomicValue| getAtomicValue() <br> *Provided the item is an atomic value we return the XdmAtomicValue otherwise return null* |
| XdmNode |  getNodeValue() <br> *Provided the item is a node value we return the XdmNode otherwise return null* |

#### Saxon\\XdmNode class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| string | getStringValue() <br> *Get the string value of the item. For a node, this gets the string value of the node.* |
| int | getNodeKind() <br> *Get the kind of node* |
| string | getNodeName <br> *et the name of the node, as a EQName* |
| boolean | isAtomic() <br> *Determine whether the item is an atomic value or a node. This method will return FALSE as the item is not atomic* |
| int | getChildCount() <br> *Get the count of child node at this current node* |
| int | getAttributeCount() <br> *Get the count of  attribute nodes at this node* |
| XdmNode | getChildNode(int index) <br> *Get the n'th child node at this node. If the child node selected does not exist then return null* |
| XdmNode | getParent() <br> *Get the parent of this node. If parent node does not exist then return null* |
| XdmNode | getAttributeNode(int $index) <br> *Get the n'th attribute node at this node. If the attribute node selected does not exist then return null* |
| string | getAttributeValue(int $index) <br> *Get the n'th attribute node value at this node. If the attribute node selected does not exist then return null* |

#### Saxon\\XdmAtomicValue class ####
<sup>PHP API</sup>

|  |  |
| ----: | :---- |
| string | getStringValue <br> *Get the string value of the item. For an atomic value, it has the same effect as casting the value to a string. In all cases the result is the same as applying the XPath string() function.* |
| boolean | getBooleanValue <br> *Get the value converted to a boolean using the XPath casting rules* |
| double | getDoubleValue <br> *Get the value converted to a double using the XPath casting rules. If the value is a string, the XSD 1.1 rules are used, which means that the string "+INF" is recognised* |
| long | getLongValue <Br> *Get the value converted to an integer using the XPath casting rules* |
| boolean | isAtomic <br> *Determine whether the item is an atomic value or a node. Return TRUE if the item is an atomic value* |





#### PHP unit tests ####

In the Saxon/C download please see the PHP unit tests (i.e. xslt30_PHPUnit.php i nthe samples/php directory) for XSLT. There are also same files for XSLT, XQuery, XPath and Schema Validator. The PHP test files are contained in the 'samples/php' folder along with associated files. Namely: xsltExamples.php, xslt30Examples.php, xqueryExamples.php, xpathExamples.php, validatorExamples.php. These files contain many useful examples which will get you started.

The unit tests run under [PHPUnit](https://phpunit.de/) for PHP 7.2 which can be downloaded and installed seperately in the same directory of the unit tests.

Example command:
    
    cd samples/php
    ./phpunit xslt30_PHPUnit.php

To run a single test:

    ./phpunit --filter testPipeline xslt30_PHPUnit.php


Example code in the new XSLT3.0 API:

<pre><code>
    <?php
        $saxonproc = new Saxon\\SaxonProcessor();
        $transformer = $saxonProc->newXslt30Processor();
        $transformer->compileFromString("<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>" .
                  "<xsl:template name='go'><a/></xsl:template>" .
                  "</xsl:stylesheet>");
      
        $root = $transformer->callTemplateReturningValue("go");
        
        $node = $root->getHead()->getNodeValue();
    
    
    
    ?>


</code>
</pre>

Example of the old styled PHP API designed for older XSLT API:
<pre><code>
	<?php 
	    $xmlfile = "xml/foo.xml";
	    $xslFile = "xsl/foo.xsl";
		$proc = new Saxon\\SaxonProcessor();
        $version = $proc->version();
        echo 'Saxon Processor version: '.$version;
		$xsltProc = $saxonProc->newXsltProcessor();
        $xsltProc->setSourceFromFile($xmlfile);
        $xsltProc->compileFromFile($xslFile);      
        $result = $xsltProc->transformToString();               
		if($result != null) {               
		  echo '<b>exampleSimple1:</b><br/>';
		  echo 'Output:'.$result;
		} else {
			echo "Result is null";
		}
		$xsltProc->clearParameters();
		$xsltProc->clearProperties(); 
	?>
</code></pre>


In the example below we show how to debug if something unexpected is happening. It is also very useful to examine the apache error.log file:

<pre><code>
	<?php 
	        $xmlfile = "xml/foo.xml";
	        $xslFile = "xsl/foo.xsl";
		    $proc = new Saxon\\SaxonProcessor();
		    $xsltProc = $saxonProc->newXsltProcessor();
            $xsltProc->setSourceFromFile($xmlFile);
            $xsltProc->compileFromFile($xslFile);
                
            $result = $xsltProc->transformToString();
                
            if($result == NULL) {
                    $errCount = $xsltProc->getExceptionCount();
				    if($errCount > 0 ){ 
				        for($i = 0; $i < $errCount; $i++) {
					       $errCode = $xsltProc->getErrorCode(intval($i));
					       $errMessage = $xsltProc->getErrorMessage(intval($i));
					       echo 'Expected error: Code='.$errCode.' Message='.$errMessage;
					   }
						$xsltProc->exceptionClear();	
					}
                
                
                }                
            echo $result;
            $xsltProc->clearParameters();
		    $xsltProc->clearProperties();
	?>
</code></pre>


<div id='python-api'/>
## Python ##
The Saxon/C Python extension API has been developed using [Cython](https://cython.org/).
Saxon/C only supports Python3. Cython is required to build the extension library.

### Python API ###

The Python API is split up in the following class (links are to the equivalent [C++ classes](https://www.saxonica.com/saxon-c/doc/html/annotated.html)): [PySaxonProcessor](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PySaxonProcessor), 
[PyXsltProcessor](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXsltProcessor), [PyXPathProcessor](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXPathProcessor), [PyXQueryProcessor](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXQueryProcessor) and 
[PySchemaValidator](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PySchemaValidator). 
We also have class for a sub-set of the XDM data model: [PyXdmValue](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXdmValue), [PyXdmNode](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXdmNode), [PyXdmItem](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXdmItem) and [PyXdmAtomicValue](https://www.saxonica.com/saxon-c/doc/html/saxonc.html#PyXdmAtomicValue).

The methods on these class are given below. For a more comprehensive description of the methods and their argument please see its counterpart in the C++ API.

Please see the [Python API documentation](http://www.saxonica.com/saxon-c/doc/html/saxonc.html)


#### Python unit tests ####

There are a collection of Python unit test cases to be run with the [pytest](https://docs.pytest.org) framework. Test unit files: test_saxonc.py and test_saxon_Schema.py. 
See also some python example scripts saxon_example.py, saxon_example2.py and saxon_example3.py to get started with Saxon/C and Python

The pyunit tests can be run with the following command:

    cd Saxon.C.API/python-saxon
    pytest test_saxonc.py


Example Python script with Saxon/C API:

<pre>
     <code>
     with saxonc.PySaxonProcessor(license=False) as proc:        
        print(proc.version)
        #print(dir(proc))
        xdmAtomicval = proc.make_boolean_value(False)
     
        xsltproc = proc.new_xslt_processor()
        document = proc.parse_xml(xml_text="<out><person>text1</person><person>text2</person><person>text3</person></out>")
        xsltproc.set_source(xdm_node=document)
        xsltproc.compile_stylesheet(stylesheet_file="test2.xsl")
        xsltproc.set_just_in_time_compilation(True)
     
        output2 = xsltproc.transform_to_string()
        print(output2)
        print('test 0 \n')
        xml = """\
         <out>
             <person>text1</person>
             <person>text2</person>
             <person>text3</person>
         </out>"""
        xp = proc.new_xpath_processor()
         
        node = proc.parse_xml(xml_text=xml)
        print('test 1\n node='+node.string_value)
        xp.set_context(xdm_item=node)
        item = xp.evaluate_single('//person[1]')
        if isinstance(item,saxonc.PyXdmNode):
            print(item.string_value)

     </code>

</pre  

<div id='tech'/>
## Technical Information: ##

Saxon/C is built by cross compiling the Java code of Saxon 9.9.1.5 using the Excelsior Jet Enterprise edition (MP1).
This generates platform specific machine code, which we interface with C/C++ using the Java Native Interace (JNI).

The PHP interface is in the form of a C/C++ PHP extension to Saxon/C created using the Zend module API.

The Python interface is in the form of a Cython module interfaced with the C/C++ Saxon/C API.

The XML parser used is the one supplied by the Excelsior JET runtime. There are currently no links to libxml.

<div id='limitations'/>
## Limitations: ##

The following limitations apply to the 1.2.0 release:

* No support for the XdmFunction type in the Xdm data model


### Feedback/Comments: ###

Please use the help forums and bug trackers at [saxonica.plan.io](https://saxonica.plan.io/projects/saxon-c) if you need help or advice.


