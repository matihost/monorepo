from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN


def test_exchange_rate():
  # given
  currency = 'USD'
  # when
  rate = ExchangeRateToPLN().get_exchange_rate_to_pln(currency)
  # then
  assert 3 <= float(rate.replace(',','.')) <= 5
