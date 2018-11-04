package org.matihost.learning.java.utils;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPathExpressionException;
import java.io.StringReader;


public class XmlUtils {

  private static final DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();


  public static String xpath(Document xml, String xPathExpression) throws XPathExpressionException {
    return XPathProcessor.fromExpression(xPathExpression).evaluate(xml);
  }

  public static Document parseXml(String content) {
    try {
      DocumentBuilder builder = domFactory.newDocumentBuilder();
      return builder.parse(new InputSource(new StringReader(content)));
    } catch (Exception e) {
      throw new IllegalStateException("Unable to parse XML", e);
    }
  }


}
