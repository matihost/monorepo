package org.matihost.learning.java.handlers;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.matihost.junit5.extensions.OutputCaptureExtension;
import org.matihost.learning.java.utils.NBPExchangeRate;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.ApplicationArguments;

import java.math.BigDecimal;
import java.util.Currency;
import java.util.List;

import static java.lang.String.format;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith({MockitoExtension.class, OutputCaptureExtension.class})
class ExchangeRateTest {

  @Mock
  private NBPExchangeRate nbpExchangeRate;

  @InjectMocks
  private ExchangeRate exchangeRate;


  @Test
  void shouldReturnExchangeRateForDollar() {
    // given
    String targetCurrency = "USD";
    BigDecimal exchangeRate = BigDecimal.TEN;
    ApplicationArguments args = mock(ApplicationArguments.class);

    when(nbpExchangeRate.getExchangeRateToPLN(eq(Currency.getInstance(targetCurrency)))).thenReturn(exchangeRate);
    when(args.getOptionValues("currency")).thenReturn(List.of(targetCurrency));

    // when
    this.exchangeRate.accept(args);

    //then
    assertThat(OutputCaptureExtension.getCapturedOutput()).contains(format("Exchange rate:  1 %s =  %.4f PLN", targetCurrency, exchangeRate));
  }
}