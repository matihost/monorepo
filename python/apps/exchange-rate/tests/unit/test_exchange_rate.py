"""Test for ExchangeRateToPLN."""
from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN
import pytest


exchange_rates = ExchangeRateToPLN()


@pytest.mark.parametrize(
    ('currency', 'range'),
    [
        ("USD", (2, 6)),
        ("EUR", (2, 7)),
        ("CHF", (2, 7)),
    ],
)
def test_exchange_rate(currency, range):
    """Test exchange rate."""
    # when
    rate = exchange_rates.get_exchange_rate_to_pln(currency)
    # then
    assert range[0] <= float(rate.replace(',', '.')) <= range[1]
