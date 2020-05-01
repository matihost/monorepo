#!/usr/bin/env python3
"""
Shows Foreign Currency/PLN pair based on Polish Central Bank (NBP) fixing exchange rate.
"""
import argparse
from exchange_rate.helpers.version import package_version
from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN

_DESCRIPTION = "Ensure SAMBA/CIFS is mounted as autofs"


def _parse_program_argv():
    parser = argparse.ArgumentParser(description=_DESCRIPTION)
    parser.add_argument('mount_root', metavar='domain', nargs='1', type=str,
                        help='mount root name, usually the server name')
    parser.add_argument('resource', metavar='resource', nargs='1', type=str,
                        help='the directory to mount from server name')
    parser.add_argument('path', metavar='paht', nargs='1', type=str,
                        help='the url to mount')


    parser.add_argument('-v', '--version', action='version',
                        version=package_version('setup_autofs'))
    args = parser.parse_args()
    return args.currency


def main():
    """
    Main program method
    """
    currency = _parse_program_argv()
    rate_to_pln = ExchangeRateToPLN().get_exchange_rate_to_pln(currency)
    print('1 {0} = {1} PLN'.format(currency, rate_to_pln))


if __name__ == "__main__":
    main()
