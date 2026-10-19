"""Currencies utility functions."""

import re

from babel import numbers

_CURRENCY_CODE = re.compile(r"[A-Z]{3}")


def validate_currency_code(currency: str):
    """Validate whether provider currency code represent valid currency."""
    if isinstance(currency, str) and _CURRENCY_CODE.fullmatch(currency) and numbers.is_currency(currency):
        return currency
    raise TypeError(f"'{currency}' is not valid currency code")
