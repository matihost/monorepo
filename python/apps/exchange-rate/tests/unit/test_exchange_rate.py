"""Test for ExchangeRateToPLN."""
from datetime import date
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
def test_exchange_rate_for_last_fixing(currency, range):
    """Test exchange rate."""
    # when
    rate = exchange_rates.get_exchange_rate_to_pln(currency)
    # then
    assert range[0] <= float(rate.replace(',', '.')) <= range[1]


@pytest.mark.parametrize(
    ('currency', 'expected_convert_rate', 'convert_date'),
    [
        ("USD", "3.9688", "2021-10-05"),
        ("CHF", "4.2836", "2021-10-05"),
    ],
)
def test_exchange_rate(currency, expected_convert_rate, convert_date):
    """Test exchange rate."""
    # when
    rate = exchange_rates.get_exchange_rate_to_pln(currency, date.fromisoformat(convert_date))
    # then
    assert expected_convert_rate == rate
