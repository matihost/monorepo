package org.matihost.learning.java.utils;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.xpath.XPathExpressionException;
import java.util.stream.Stream;

class XPathProcessorTest {
  private static Document xmlDoc = XmlUtils.parseXml("<ala><ma ile='5'>kota</ma><niema>psa</niema></ala>");

  @Test
  void evaluateToString() throws XPathExpressionException {
    // given
    XPathProcessor xPath = XPathProcessor.fromExpression("/ala/ma/text()[.=$value]")
        .withVariable("value", "kota");

    // when
    String result = xPath.evaluate(xmlDoc);

    //then
    Assertions.assertEquals("kota", result);
  }

  @ParameterizedTest
  @MethodSource("evaluateToOther")
  <T> void evaluateToOther(String xpathExrp, Class<T> expectedType, T object) throws XPathExpressionException {

    // given
    XPathProcessor xPath = XPathProcessor.fromExpression(xpathExrp);

    // when
    T result = xPath.evaluate(xmlDoc, expectedType);

    //then
    Assertions.assertEquals(object, result);
  }

  private static Stream<Arguments> evaluateToOther() {
    return Stream.of(
        Arguments.of("/ala/ma/@ile", Double.class, 5D),
        Arguments.of("/ala/ma/text()='kota'", Boolean.class, true),
        Arguments.of("/ala/niema", Element.class, xmlDoc.getDocumentElement().getFirstChild().getNextSibling())
    );
  }

  @ParameterizedTest
  @ValueSource(strings = {"", "\\/", "/ala[@jakiego=$param"})
  void evaluateToException(String invalidXPath) {
    // when
    RuntimeException ex = Assertions.assertThrows(RuntimeException.class, () -> XPathProcessor.fromExpression(invalidXPath));

    // then
    org.assertj.core.api.Assertions.assertThat(ex).hasMessage("Unable to create XPath expression from '%s'", invalidXPath);
  }
}