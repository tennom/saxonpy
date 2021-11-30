from saxonpy import (PySaxonProcessor, PyXPathProcessor, PyXsltProcessor, PyXslt30Processor)


def test_create_bool():
    """Create SaxonProcessor object with a boolean argument"""
    sp1 = PySaxonProcessor(True)
    sp2 = PySaxonProcessor(False)
    assert isinstance(sp1, PySaxonProcessor)
    assert isinstance(sp2, PySaxonProcessor)

def test_create_procs():
    """Create XPathProcessor, XsltProcessor from SaxonProcessor object"""
    sp = PySaxonProcessor()
    xp = sp.new_xpath_processor()
    xsl = sp.new_xslt_processor()
    xsl30 = sp.new_xslt30_processor()
    assert isinstance(xp, PyXPathProcessor)
    assert isinstance(xsl, PyXsltProcessor)
    assert isinstance(xsl30, PyXslt30Processor)


def test_version():
    """SaxonProcessor version string content"""
    sp = PySaxonProcessor()
    ver = sp.version
    
    assert ver.startswith('Saxon/C ')
    assert ver.endswith('from Saxonica')