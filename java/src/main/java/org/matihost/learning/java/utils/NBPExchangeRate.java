package org.matihost.learning.java.utils;

import javax.xml.xpath.XPathExpressionException;
import java.math.BigDecimal;
import java.util.Currency;

import static org.matihost.learning.java.utils.Utils.httpGet;
import static org.matihost.learning.java.utils.XmlUtils.parseXml;

public class NBPExchangeRate {
  private static final String EXCHANGE_RATE_FOR_CURRENCY_XPATH = "/tabela_kursow/pozycja[kod_waluty=$currencyCode]/kurs_sredni";
  private static final String NBP_TABLE_A_URL = "http://www.nbp.pl/kursy/xml/LastA.xml";

  public static BigDecimal getExchangeRateInPLN(Currency currency) {
    var currRates = httpGet(NBP_TABLE_A_URL);
    var currRatesDoc = parseXml(currRates);
    try {
      var rate = XPathProcessor.fromExpression(EXCHANGE_RATE_FOR_CURRENCY_XPATH)
        .withVariable("currencyCode", currency.getCurrencyCode())
        .evaluate(currRatesDoc);
      return new BigDecimal(rate.replace(',', '.'));
    } catch (XPathExpressionException e) {
      throw new RuntimeException("Unable to convert exchange rate to number", e);
    }
  }
}
