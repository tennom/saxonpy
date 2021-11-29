from setuptools import setup, find_packages, Extension
# from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize

from pathlib import Path
this_directory = Path(__file__).parent
long_description = (this_directory / "README.md").read_text()

ext_modules = [Extension(
                        "saxonc", 
                        sources=[
                            "python_saxon/saxonc.pyx", 
                            "Saxon.C.API/SaxonProcessor.cpp", 
                            "Saxon.C.API/SaxonCGlue.c", 
                            "Saxon.C.API/SaxonCXPath.c", 
                            "Saxon.C.API/XdmValue.cpp", 
                            "Saxon.C.API/XdmItem.cpp",
                            "Saxon.C.API/XdmNode.cpp", 
                            "Saxon.C.API/XdmAtomicValue.cpp", 
                            "Saxon.C.API/XsltProcessor.cpp",
                            "Saxon.C.API/Xslt30Processor.cpp", 
                            "Saxon.C.API/XQueryProcessor.cpp",
                            "Saxon.C.API/XPathProcessor.cpp",
                            "Saxon.C.API/SchemaValidator.cpp"], 
                        language="c++",
                        include_dirs = ['Saxon.C.API/jni', "Saxon.C.API/jni/unix",],
                        ),
                    "python_saxon/nodekind.py",
                ]
setup(
    name='saxonpy',
    version='0.0.2',
    description='A python package for the Saxon/C 1.2.1, an XML processor by Saxonica.',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Tennom',
    author_email='tennom@outlook.com',
    include_package_data=True,
    # packages=find_packages(),
    package_dir={'saxonpy':'src'},
    packages=['saxonpy'],
    python_requires='>=3.6',                # Minimum version requirement of the package
    ext_modules=cythonize(ext_modules,
                          compiler_directives={'language_level': 3},
                          ),

    cmdclass = {'build_ext': build_ext},

)