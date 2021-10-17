#!/usr/bin/env python3
"""
Show Foreign Currency/PLN pair.

It is based on Polish Central Bank (NBP) fixing exchange rate.
"""
from datetime import date

import argparse
from exchange_rate.helpers.version import package_version
from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN

_DESCRIPTION = "Shows Foreign Currency/PLN pair based on Polish \
Central Bank (NBP) fixing exchange rate."

_DATE_HELP = """
currency exchange date in iso format, yyyy-MM-dd, default - last working day
"""


def _parse_program_argv():
    parser = argparse.ArgumentParser(description=_DESCRIPTION)
    parser.add_argument('currency', metavar='currency', nargs='?', type=str, default='USD',
                        help='currency code to compare with PLN')
    parser.add_argument('convert_date', metavar='date', nargs='?', type=date.fromisoformat,
                        default=None, help=_DATE_HELP)
    parser.add_argument('-v', '--version', action='version',
                        version=package_version('exchange-rate'))
    args = parser.parse_args()
    return args.currency, args.convert_date


def main():
    """Enter the program."""
    currency, convert_date = _parse_program_argv()
    rate_to_pln = ExchangeRateToPLN().get_exchange_rate_to_pln(currency, convert_date)
    print(f'1 {currency} = {rate_to_pln} PLN')


if __name__ == "__main__":
    main()
