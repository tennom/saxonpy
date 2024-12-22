# Why NO new release!

Thanks for checking out this repo. Let me explain why I haven’t released new Python packages for SaxonC (HE, the open source version). Saxonica, the official people behind SaxonC, has adopted a new method, native executables, to support C/C++ since SaxonC 12. It made things simpler to make Python packages and in fact Saxonica started offering their official Python packages, so no need for me to make packages for SaxonC. As soon as they offer a usable and reasonable open source SaxonC, we may not need to fork the SaxonC.

# Welcome to Saxonpy!

This's a python wheel package for [Saxon](https://www.saxonica.com/saxon-c/documentation/index.html), an XML processor from the Saxonica company. Saxon includes a range of tools for XML transformations, XML queries, and schema validations. For this release, we only include the support for the home edition or the open-source version. 

## When to choose Saxonpy

If you need to use **XSLT versions greater than 1.0** like 2.0 and 3.0, then you may use Saxonpy.

- As of 2021, there are two great python packages already available: ***[xml](https://docs.python.org/3/library/xml.etree.elementtree.html)*** and ***[lxml](https://lxml.de/index.html)*** . The Python **xml** seems to be great if you just need to parse the xml documents while **lxml** seems to offer more options for processing xml files. Because **lxml** uses libxslt, a C library for transforming xmls, it supports xslt version 1.0 only.

## Installation

```bash
pip install saxonpy
```

## Usage

I will make references to the Saxonica official documentation a lot from here because they list all the Python APIs with examples for some.  
 Import all the modules
```python 
from saxonpy import *
```

Import specific modules
```python 
from saxonpy import PySaxonProcessor
```

Now, let's check what 6 other processors are available from Saxon by visiting the [Saxonica's site](https://www.saxonica.com/saxon-c/documentation/index.html#!api/saxon_c_python_api). In the API section, you will find more info about what each processor does.

Next, we will use `PySaxonProcessor` to check the Saxon version.
```python
from saxonpy import PySaxonProcessor

with PySaxonProcessor(license=False) as proc:
	print(proc.version)
```
It will print the version like below if your installation is successful.

```bash
Saxon/C 1.2.1 running with Saxon-HE 9.9.1.5C from Saxonica
```
Please **note** that `license=False` indicates the open-source version of Saxon.

### Example #1
Let's parse a toy XML that was available from Saxonica source code.
```python
from  saxonpy  import PySaxonProcessor

with PySaxonProcessor(license=False) as  proc:
	xml = """\
		<out>
			<person att1='value1' att2='value2'>text1</person>
			<person>text2</person>
			<person>text3</person>
		</out>
		"""
	node = proc.parse_xml(xml_text=xml)
	print("node.node_kind="+ node.node_kind_str)
	print("node.size="+ str(node.size))
	outNode = node.children
	print("len of children="+str(len(node.children)))
	print('element name='+outNode[0].name)
	children = outNode[0].children
	print(*children, sep= ', ')
	attrs = children[1].attributes
	if  len(attrs) == 2:
		print(attrs[1].string_value)
```
In the output, we will get this.
```bash
node.node_kind=document
node.size=1
len of children=1
element name=out
        , <person att1="value1" att2="value2">text1</person>, 
        , <person>text2</person>, 
        , <person>text3</person>, 
value2
```
As we can see, we can explore the XML node structure, attributes, and many other things if you check more on the [APIs](https://www.saxonica.com/saxon-c/documentation/index.html#!api/saxon_c_python_api).

### Example #2
Let's use the XML path processor from Saxonica. 
```python
from  saxonpy  import PySaxonProcessor

with PySaxonProcessor(license=False) as  proc:
	xml = """\
		<out>
			<person>text1</person>
			<person>text2</person>
			<person>text3</person>
		</out>"""

	xp = proc.new_xpath_processor()
	node = proc.parse_xml(xml_text=xml)
	xp.set_context(xdm_item=node)
	
	item = xp.evaluate_single('//person[1]')
	if  isinstance(item,PyXdmNode):
		print(item.string_value)
	# pay attention, Saxon's xdm data type
	value = proc.make_double_value(3.5)
	print(value.primitive_type_name)
```
The output shows here.
```bash
text1
Q{http://www.w3.org/2001/XMLSchema}double
```
Saxon shows the result given the path. 

### Example #3
The XSLT processor, #1
```python
from  saxonpy  import PySaxonProcessor

with PySaxonProcessor(license=False) as  proc:
	xsltproc = proc.new_xslt_processor()
	
	document = proc.parse_xml(xml_text="<out><person>text1</person><person>text2</person><person>text3</person></out>")

	xsltproc.set_source(xdm_node=document)
	xsltproc.compile_stylesheet(stylesheet_text="<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'> <xsl:param name='values' select='(2,3,4)' /><xsl:output method='xml' indent='yes' /><xsl:template match='*'><output><xsl:value-of select='//person[1]'/><xsl:for-each select='$values' ><out><xsl:value-of select='. * 3'/></out></xsl:for-each></output></xsl:template></xsl:stylesheet>")

	output2 = xsltproc.transform_to_string()
	print(output2)
```
Here is the output that shows the result of trasformation.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<output>text1<out>6</out>
   <out>9</out>
   <out>12</out>
</output>
```
### Example #4
Watch out for the not-pythonic way!
```python
from  saxonpy  import PySaxonProcessor

with PySaxonProcessor(license=False) as  proc:
	xsltproc = proc.new_xslt_processor()

	xml = '<a><b>Text</b></a>'
	xslt = '''\
		<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		<xsl:param name="a" />
		<xsl:output method='xml' indent='yes' />
		<xsl:template match="/">
		<foo><xsl:value-of select="$a" /></foo>
		</xsl:template>
		</xsl:stylesheet>'''

	document = proc.parse_xml(xml_text=xml)

	#please note the not Python way in the next two lines.
	xdm_a = proc.make_string_value('a was given in the parameter')
	xsltproc.set_parameter('a', xdm_a)

	xsltproc.set_source(xdm_node=document)
	xsltproc.compile_stylesheet(stylesheet_text=xslt)
	output2 = xsltproc.transform_to_string()
	print(output2)
```
Here we use an XSLT/stylesheet parameter. I just want to highlight that Python String (object) is not the same string that Saxon uses, and the same goes for other types. We need to convert to it by `make_string_value`. This may be a little exotic and not so pythonic because Saxon is written in Java and cross-compiled for C and then Python. Just be aware of it but you don't need to know anything more about Java or C to use Saxonpy.
Please check out the [Saxonica's documentation](https://www.saxonica.com/saxon-c/documentation/index.html) for `xquery`, schema validation, and others.

## Why the `with` keyword
`with` is good to clear out the underlying processes when the program exits.

## Source code & Development
- We downloaded the Saxonc HE from the [Saxonica's site](https://www.saxonica.com/download/c.xml) 
- We have the source code on a [github repo](https://github.com/tennom/saxonpy) to make the wheel packages for Linux and macOS. We have [a separate repo](https://github.com/tennom/saxonpy-win) for Windows. 
- We use Github actions runners for CI and releases.

## Our use cases
Here at the projects of the University of Virginia, we use Saxon for Tibetan cataloging and SolrDb indexing.
