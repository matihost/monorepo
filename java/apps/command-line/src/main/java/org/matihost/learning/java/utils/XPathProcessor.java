package org.matihost.learning.java.utils;

import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.xml.namespace.QName;
import javax.xml.xpath.*;
import java.util.HashMap;
import java.util.Map;

/**
 * XPath expression handler.
 * <p>
 * XPathUtils from
 * <dependency>
 * <groupId>org.springframework.integration</groupId>
 * <artifactId>spring-integration-xml</artifactId>
 * </dependency>
 * does not support complex XPath containing variables (aka XPathVariableResolver).
 *
 * XPathProcessor is not thread safe, however can be reused after reset() method call.
 */
public class XPathProcessor {
  private static final XPathFactory xpathFactory = XPathFactory.newInstance();

  private final XPathExpression xPathExpression;
  private final Map<String, Object> xPathVariables = new HashMap<>();


  public static XPathProcessor fromExpression(String xPathExpression) {
    return new XPathProcessor(xPathExpression);
  }

  public XPathProcessor withVariable(String key, Object value) {
    this.xPathVariables.put(key, value);
    return this;
  }

  public XPathProcessor reset() {
    this.xPathVariables.clear();
    return this;
  }

  public String evaluate(Node xml) throws XPathExpressionException {
    return xPathExpression.evaluate(xml);
  }

  @SuppressWarnings("unchecked")
  public <T> T evaluate(Node xml, Class<T> type) throws XPathExpressionException {
    QName resultType = getXPathResultFrom(type);
    return (T) xPathExpression.evaluate(xml, resultType);
  }

  private XPathProcessor(String expression) {
    XPath xPath = xpathFactory.newXPath();
    xPath.setXPathVariableResolver(new MapVariableResolver());
    try {
      this.xPathExpression = xPath.compile(expression);
    } catch (Exception e) {
      throw new RuntimeException(String.format("Unable to create XPath expression from '%s'", expression), e);
    }
  }

  private QName getXPathResultFrom(Class<?> type) throws XPathExpressionException {
    QName resultType;
    if (String.class.equals(type)) {
      resultType = XPathConstants.STRING;
    } else if (Boolean.class.equals(type)) {
      resultType = XPathConstants.BOOLEAN;
    } else if (Double.class.equals(type)) {
      resultType = XPathConstants.NUMBER;
    } else if (Node.class.isAssignableFrom(type)) {
      resultType = XPathConstants.NODE;
    } else if (NodeList.class.isAssignableFrom(type)) {
      resultType = XPathConstants.NODESET;
    } else {
      throw new XPathExpressionException("Incompatible xPath result type: " + type);
    }
    return resultType;
  }

  private class MapVariableResolver implements XPathVariableResolver {
    @Override
    public Object resolveVariable(QName variableName) {
      String key = variableName.getLocalPart();
      return xPathVariables.get(key);
    }
  }
}
