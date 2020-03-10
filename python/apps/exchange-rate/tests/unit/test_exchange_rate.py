import exchange_rate.cli.exchange_rate as ex
def test_exchange_rate():
  # given
  currency = 'USD'
  # when
  rate = ex.get_exchange_rate_to_pln(currency)
  # then
  assert 3 <= float(rate.replace(',','.')) <= 5
