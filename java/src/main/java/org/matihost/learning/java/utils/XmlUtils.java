package org.matihost.learning.java.utils;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.*;
import java.io.StringReader;
import java.util.Map;


public class XmlUtils {
  private static final XPathFactory xpathFactory = XPathFactory.newInstance();
  private static final DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();


  public static String xpath(Document xml, String xPathExpression) throws XPathExpressionException {
    return xpath(xml, xPathExpression, null);
  }

  public static String xpath(Document xml, String xPathExpression, Map<String, Object> variables) throws XPathExpressionException {
    XPath xPath = xpathFactory.newXPath();
    if (variables != null) {
      xPath.setXPathVariableResolver(new MapVariableResolver(variables));
    }
    return (String) xPath.compile(xPathExpression).evaluate(xml, XPathConstants.STRING);
  }


  public static Document parseXml(String content) {
    try {
      DocumentBuilder builder = domFactory.newDocumentBuilder();
      return builder.parse(new InputSource(new StringReader(content)));
    } catch (Exception e) {
      throw new IllegalStateException("Unable to parse XML", e);
    }
  }

  private static class MapVariableResolver implements XPathVariableResolver {
    private Map<String, Object> variableMappings;

    MapVariableResolver(Map<String, Object> variableMappings) {
      this.variableMappings = variableMappings;
    }


    @Override
    public Object resolveVariable(QName varName) {
      String key = varName.getLocalPart();
      return variableMappings.get(key);
    }
  }
}
