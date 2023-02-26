package org.matihost.learning.java.utils;

import org.w3c.dom.Document;

import javax.xml.xpath.XPathExpressionException;
import java.math.BigDecimal;
import java.util.Currency;

import static org.matihost.learning.java.utils.Utils.httpGet;
import static org.matihost.learning.java.utils.XmlUtils.parseXml;

public class NBPExchangeRate {
  private static final String EXCHANGE_RATE_FOR_CURRENCY_XPATH = "/tabela_kursow/pozycja[kod_waluty=$currencyCode]/kurs_sredni";
  private static final String NBP_TABLE_A_URL = "https://static.nbp.pl/dane/kursy/xml/LastA.xml";

  private Document currentExchangeRatesToPLN;

  public NBPExchangeRate(){
    var currRates = httpGet(NBP_TABLE_A_URL);
    this.currentExchangeRatesToPLN = parseXml(currRates);
  }

  public BigDecimal getExchangeRateToPLN(Currency currency) {
    try {
      var rate = XPathProcessor.fromExpression(EXCHANGE_RATE_FOR_CURRENCY_XPATH)
        .withVariable("currencyCode", currency.getCurrencyCode())
        .evaluate(this.currentExchangeRatesToPLN);
      return new BigDecimal(rate.replace(',', '.'));
    } catch (XPathExpressionException e) {
      throw new RuntimeException("Unable to convert exchange rate to number", e);
    }
  }
}
