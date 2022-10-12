package org.matihost.learning.groovy

import spock.lang.Specification

class NBPExchangeRateTest extends Specification {
  def "exchange rate Test"() {
    def exchangeRates = new NBPExchangeRates()

    expect:
    exchangeRates.getExchangeRateToPLN(currency) < exchangeRate

    where:
    currency | exchangeRate
    "USD"    | 5.99
    "EUR"    | 5.99
  }

}
