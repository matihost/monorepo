package org.matihost.learning.groovy

import spock.lang.Specification

class NBPExchangeRateTest extends Specification {
  def "exchange rate Test"() {
    def exchangeRates = new NBPExchangeRates()

    expect:
    exchangeRates.getExchangeRateToPLN(currency) < exchangeRate

    //https://github.com/spockframework/spock/issues/911 spock 2.5.3 doesn't like long nor bigdecimal constants
    where:
    currency | exchangeRate
    "USD"    | 3.99d
    "EUR"    | 4.99d
  }

}
