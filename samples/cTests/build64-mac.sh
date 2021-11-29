#!/bin/sh

jdkdir=/Library/Java/JavaVirtualMachines/jdk1.8.0_77.jdk/Contents/Home

# $jdkdir/bin/javac MyClassInDll.java

#jc =p MyDll.prj
#rm -rf MyDll_jetpdb

gcc -m64 -fPIC -I$jdkdir/include  -I$jdkdir/include/darwin ../../Saxon.C.API/SaxonCGlue.c ../../Saxon.C.API/SaxonCProcessor.c ../../Saxon.C.API/SaxonCXPath.c  testXSLT.c -o testXSLT -ldl -L.  $1

gcc -m64 -fPIC -I$jdkdir/include  -I$jdkdir/include/darwin ../../Saxon.C.API/SaxonCGlue.c ../../Saxon.C.API/SaxonCProcessor.c  testXQuery.c -o testXQuery -ldl -L. $1
	
gcc -m64 -fPIC -I$jdkdir/include -I$jdkdir/include/darwin ../../Saxon.C.API/SaxonCGlue.c ../../Saxon.C.API/SaxonCProcessor.c ../../Saxon.C.API/SaxonCXPath.c testXPath.c -o testXPath -ldl -L. $1

