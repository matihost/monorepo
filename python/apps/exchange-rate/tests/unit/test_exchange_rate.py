"""Test for ExchangeRateToPLN."""

from datetime import date

import pytest

from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN

exchange_rates = ExchangeRateToPLN()


@pytest.mark.parametrize(
    ("currency", "range"),
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
    assert range[0] <= float(rate.replace(",", ".")) <= range[1]


@pytest.mark.parametrize(
    ("currency", "expected_convert_rate", "convert_date"),
    [
        ("USD", "3.9025", "2024-09-12"),
        ("CHF", "4.5674", "2024-09-12"),
    ],
)
def test_exchange_rate(currency, expected_convert_rate, convert_date):
    """Test exchange rate."""
    # when
    rate = exchange_rates.get_exchange_rate_to_pln(currency, date.fromisoformat(convert_date))
    # then
    assert expected_convert_rate == rate
