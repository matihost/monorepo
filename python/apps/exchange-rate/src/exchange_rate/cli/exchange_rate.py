#!/usr/bin/env python3
"""
Shows USD/PLN pair based on Polish Central Bank (NBP) fixing exchange rate.
"""
import sys
import xml.etree.ElementTree as ET
import requests

RATE_TO_PLN_XPATH = './pozycja[kod_waluty="{0}"]/kurs_sredni'
NPB_FIXING_URL = 'http://www.nbp.pl/kursy/xml/LastA.xml'


def get_exchange_rate_to_pln(currency):
    """
    Get convertion rate for currency
    """
    response = requests.get(NPB_FIXING_URL).text
    xml = ET.fromstring(response)
    rate = xml.find(RATE_TO_PLN_XPATH.format(currency))
    return None if rate is None else rate.text


def main():
    """
    Main program method
    """
    currency = 'USD' if len(sys.argv) == 1 else sys.argv[1]
    print('1 {0} = {1} PLN'.format(
        currency, get_exchange_rate_to_pln(currency)))


if __name__ == "__main__":
    main()
