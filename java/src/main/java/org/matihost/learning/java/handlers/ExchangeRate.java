package org.matihost.learning.java.handlers;

import org.matihost.learning.java.utils.NBPExchangeRate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.stereotype.Component;

import java.util.Currency;
import java.util.function.Consumer;

import static java.lang.String.format;
import static org.matihost.learning.java.utils.Utils.getArg;

/**
 * ExchangeRate
 */
@Component
public class ExchangeRate implements Consumer<ApplicationArguments> {
  private static Logger logger = LoggerFactory.getLogger(ExchangeRate.class);

  @Override
  public void accept(ApplicationArguments appArgs) {
    Currency targetCurrency = Currency.getInstance(getArg(appArgs, "currency", "USD"));

    var plnExchangeRate = NBPExchangeRate.getExchangeRateInPLN(targetCurrency);

    logger.info(format("Exchange rate:  1 %s =  %.4f PLN", targetCurrency.getCurrencyCode(), plnExchangeRate));
  }
}
