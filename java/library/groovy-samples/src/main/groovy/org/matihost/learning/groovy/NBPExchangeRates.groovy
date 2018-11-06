package org.matihost.learning.groovy

class NBPExchangeRates {
  private static final String NBP_TABLE_A_URL = "http://www.nbp.pl/kursy/xml/LastA.xml";

  def exchangeRates = new XmlSlurper().parse(NBP_TABLE_A_URL)

  def getExchangeRateToPLN(currency){
    String exchangeRate = exchangeRates.pozycja.find { it.kod_waluty.text() == currency }.kurs_sredni.text()
    return new BigDecimal(exchangeRate.replace(',','.'))
  }
}
