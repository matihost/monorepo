#!/usr/bin/env python3
"""
Show Foreign Currency/PLN pair.

It is based on Polish Central Bank (NBP) fixing exchange rate.
"""
import argparse
from exchange_rate.helpers.version import package_version
from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN

_DESCRIPTION = "Shows Foreign Currency/PLN pair based on Polish \
Central Bank (NBP) fixing exchange rate."


def _parse_program_argv():
    parser = argparse.ArgumentParser(description=_DESCRIPTION)
    parser.add_argument('currency', metavar='currency', nargs='?', type=str, default='USD',
                        help='currency code to compare with PLN')
    parser.add_argument('-v', '--version', action='version',
                        version=package_version('exchange-rate'))
    args = parser.parse_args()
    return args.currency


def main():
    """Enter the program."""
    currency = _parse_program_argv()
    rate_to_pln = ExchangeRateToPLN().get_exchange_rate_to_pln(currency)
    print('1 {0} = {1} PLN'.format(currency, rate_to_pln))


if __name__ == "__main__":
    main()
