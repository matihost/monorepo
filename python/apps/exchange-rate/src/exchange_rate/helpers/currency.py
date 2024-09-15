"""Currencies utility functions."""

from babel import numbers


def validate_currency_code(currency: str):
    """Validate whether provider currency code represent valid currency."""
    if numbers.is_currency(currency):
        return currency
    raise TypeError(f"'{currency}' is not valid currency code")
