PHP_ARG_ENABLE(saxon,
    [Whether to enable the "saxon" extension],
    [  --enable-saxon      Enable "saxon" extension support])

if test $PHP_SAXON != "no"; then
    PHP_REQUIRE_CXX()
    PHP_ADD_INCLUDE(jni)
    PHP_SUBST(SAXON_SHARED_LIBADD)
    PHP_ADD_LIBRARY(stdc++, 1, SAXON_SHARED_LIBADD)
    PHP_ADD_LIBRARY(dl, 1, SAXON_SHARED_LIBADD)
    PHP_NEW_EXTENSION(saxon, php7_saxon.cpp SaxonProcessor.cpp XQueryProcessor.cpp XsltProcessor.cpp Xslt30Processor.cpp XPathProcessor.cpp SchemaValidator.cpp XdmValue.cpp XdmItem.cpp XdmNode.cpp XdmAtomicValue.cpp SaxonCGlue.c SaxonCProcessor.c  SaxonCXPath.c, $ext_shared)
fi

